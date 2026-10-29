local _, ns = ...

--[[
    Item-Cache -- derives and caches per-item consumable data in
    ns.db.profile.itemCache (the stateful item-metadata layer), and retries a
    scan that met a cold item. The session's item info and its
    GET_ITEM_INFO_RECEIVED waiters are shared, in Features/Item-Info.lua.
]]

--------------------------------------------------------------------------------
-- Item Cache
--------------------------------------------------------------------------------

--[[
    The derived item cache lives on the profile and is never declared in
    defaults, so a reset or a brand-new profile arrives without one. Core calls
    this at login and after every profile change. It invalidates on a version
    change, and on a change of data folder: Classic Era and Season of Discovery
    characters share one saved file, so an Era and a Season of Discovery character can take turns on one profile, while their realms
    build different folders' tables, so a record one of them derived can be
    wrong for the other. The scanner's stale-schema nil-test catches
    same-version (dev) field additions.
]]
function ns.EnsureItemCache()
	local profile = ns.db.profile
	if
		type(profile.itemCache) ~= "table"
		or profile.itemCacheVersion ~= ns.Version
		or profile.itemCacheFolder ~= ns.DATA_FOLDER
	then
		profile.itemCache = {}
		profile.itemCacheVersion = ns.Version
		profile.itemCacheFolder = ns.DATA_FOLDER
	end
end

-- Whether any consumable table carries the item: the test that decides what ns.CacheItemData caches.
function ns.HasRawData(itemID)
	return ns.FOOD_AND_WATER[itemID] ~= nil
		or ns.POTIONS[itemID] ~= nil
		or ns.HEALTHSTONES[itemID] ~= nil
		or ns.SOULSTONES[itemID] ~= nil
		or ns.BANDAGES[itemID] ~= nil
		or ns.MANA_GEMS[itemID] ~= nil
		or ns.MANA_RUNES[itemID] ~= nil
		or ns.EXPLOSIVES[itemID] ~= nil
end

--------------------------------------------------------------------------------
-- Cold Item Retry
--------------------------------------------------------------------------------

-- Budget for the cold-item retry below, sized to cover a slow login.
local DATA_RETRY_MAX_ATTEMPTS = 10
local dataRetryAttempts = 0

--[[
    An id the server never answers for would spin the rescan forever: every
    scan that ends with an unresolved bag item calls this, and the timer walks
    straight back into another scan, so the pair is self-sustaining with no
    outside signal to stop it. The timer therefore gets a budget of
    DATA_RETRY_MAX_ATTEMPTS and then stops arming.

    GET_ITEM_INFO_RECEIVED stays registered past the budget: the event is the
    real signal, it costs nothing while idle, and an answer arriving late still
    rebuilds. UnregisterDataRetry refunds the budget, so the next cold item
    starts from a full one rather than inheriting an exhausted one.
]]
function ns.RegisterDataRetry()
	ns.RequestItemInfoEvents("scan")

	if dataRetryAttempts >= DATA_RETRY_MAX_ATTEMPTS then
		return
	end
	dataRetryAttempts = dataRetryAttempts + 1

	C_Timer.After(2, function()
		ns.RequestUpdate()
	end)
end

function ns.UnregisterDataRetry()
	dataRetryAttempts = 0
	ns.ReleaseItemInfoEvents("scan")
end

--------------------------------------------------------------------------------
-- Zone Helpers
--------------------------------------------------------------------------------

local function BuildZoneSet(rawZoneArray)
	if not rawZoneArray then
		return nil
	end
	local set = {}
	for _, mapID in ipairs(rawZoneArray) do
		set[mapID] = true
	end
	return set
end

--------------------------------------------------------------------------------
-- Item Data Caching
--------------------------------------------------------------------------------

--[[
    Looks up an item in the consumable tables, derives a canonical shape
    (type, health/mana values, requirements, zones), and caches it under
    ns.db.profile.itemCache. An item no consumable table carries returns "IGNORE"
    without calling C_Item.GetItemInfo or writing to the cache, so the cache holds
    consumables only and a cold non-consumable never arms a rescan.
]]
function ns.CacheItemData(itemID)
	local itemCache = ns.db and ns.db.profile.itemCache
	if not itemCache then
		return nil
	end

	if not ns.HasRawData(itemID) then
		return "IGNORE"
	end

	local name, _, _, _, minLevel, _, _, maxStack, _, _, vendorPrice, _, _, bindType = C_Item.GetItemInfo(itemID)
	if not name then
		return nil
	end

	local rawFoodAndWater = ns.FOOD_AND_WATER[itemID]
	local rawPotion = ns.POTIONS[itemID]
	local rawHealthstone = ns.HEALTHSTONES[itemID]
	local rawSoulstone = ns.SOULSTONES[itemID]
	local rawBandage = ns.BANDAGES[itemID]
	local rawManaGem = ns.MANA_GEMS[itemID]
	local rawManaRune = ns.MANA_RUNES[itemID]
	local rawExplosive = ns.EXPLOSIVES[itemID]

	local data = {
		itemID = itemID,
		itemType = "",
		healthValue = 0,
		manaValue = 0,
		damageValue = 0,
		requiredLevel = minLevel or 0,
		requiredFirstAid = 0,
		requiredAlchemy = 0,
		requiredEngineering = 0,
		requiredSpellID = nil,
		price = vendorPrice or 0,
		maxStack = maxStack or 1,
		--[[
		    bindType 1 is Enum.ItemBind.OnAcquire. For a consumable that is
		    the exact test for "the stack in the bag is soulbound": you can
		    only be holding one by having acquired it, so the item's binding
		    rule and the state of this copy always agree, and no per-slot
		    lookup is needed. Bind-on-use (3) is deliberately NOT soulbound
		    -- it stays tradeable right up until it is consumed.
		]]
		isSoulbound = (bindType == 1),
		isBuffFood = false,
		isPercent = false,
		zones = nil,
		arenaOnly = false,
		arenaUsable = false,
		isConjured = false,
	}

	if rawFoodAndWater then
		local isBuffFoodType = (rawFoodAndWater[1] == 1)
		data.isBuffFood = isBuffFoodType
		data.zones = BuildZoneSet(rawFoodAndWater[6])

		--[[
		    Arena usability (column 7), a static per-item property so it caches
		    like the other fields. 1 = usable ONLY inside a PvP Arena (Star's
		    Tears/Lament); 2 = conjured, so ALSO usable inside an arena. The
		    scanner gates on the live instance type (IsInInstance) rather than a
		    zone-ID list, so every arena is covered with no map IDs to maintain.
		]]
		local arenaFlag = rawFoodAndWater[7]
		data.arenaOnly = (arenaFlag == 1)
		data.arenaUsable = (arenaFlag ~= nil)
		--[[
		    Conjured (flag 2) is a distinct selection axis from arena usability:
		    arenaUsable is true for BOTH the arena-only drinks (flag 1) and
		    conjured items (flag 2), so it can't tell them apart. isConjured
		    records the conjured status on its own so the scanner can prefer a
		    free, infinite conjured ration over an equal-value purchased,
		    quested, or arena-only item (see IsBetter in Scanner-Ranking).
		    Only flag 2 marks an item conjured: one that merely sells for
		    nothing, or whose tooltip says Conjured Item without an arena value
		    (Harvest Bread, Winter Veil Loaf), is ordinary food to Use Conjured
		    Food & Water First.
		]]
		data.isConjured = (arenaFlag == 2)

		local hasFood = false
		local hasWater = false

		if rawFoodAndWater[2] > 0 then
			hasFood = true
			data.healthValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[3] > 0 then
			hasFood = true
			data.healthValue = rawFoodAndWater[3]
		end

		if rawFoodAndWater[4] > 0 then
			hasWater = true
			data.manaValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[5] > 0 then
			hasWater = true
			data.manaValue = rawFoodAndWater[5]
		end

		if isBuffFoodType and not hasFood and not hasWater then
			hasFood = true
		end

		if hasFood and hasWater then
			data.itemType = "foodwater"
		elseif hasFood then
			data.itemType = "food"
		else
			data.itemType = "water"
		end
	elseif rawPotion then
		data.itemType = "potion"
		data.healthValue = rawPotion[1]
		data.manaValue = rawPotion[2]
		data.zones = BuildZoneSet(rawPotion[3])
		data.requiredAlchemy = rawPotion[4] or 0
	elseif rawHealthstone then
		data.itemType = "healthstone"
		data.healthValue = rawHealthstone[1]
		--[[
		    Required level for the bag-scan usable gate comes from the curated
		    ns.HEALTHSTONES column (static over API), falling back to
		    C_Item.GetItemInfo's minLevel. (Conjure downranking uses a separate table.)
		]]
		data.requiredLevel = rawHealthstone[2] or data.requiredLevel
	elseif rawSoulstone then
		data.itemType = "soulstone"
		data.healthValue = rawSoulstone[1]
	elseif rawBandage then
		-- Bandage row shape: {healAmount, requiredSkill, sellPrice, {zones}}
		data.itemType = "bandage"
		data.healthValue = rawBandage[1]
		data.requiredFirstAid = rawBandage[2] or 0
		data.zones = BuildZoneSet(rawBandage[4])
	elseif rawManaGem then
		data.itemType = "managem"
		data.manaValue = rawManaGem[1]
	elseif rawManaRune then
		data.itemType = "manarune"
		data.manaValue = rawManaRune[1]
	elseif rawExplosive then
		-- Explosive row shape: {minDamage, maxDamage, requiredSkill, requiredSpellID}
		data.itemType = "explosive"
		data.damageValue = rawExplosive[1]
		data.requiredEngineering = rawExplosive[3] or 0
		--[[
		    Engineering specialization gate (e.g. 20222 = Goblin Engineer for
		    the Global Thermal Sapper Charge). The scanner treats the item as
		    unusable until the player knows this spell.
		]]
		data.requiredSpellID = rawExplosive[4]
	end

	itemCache[itemID] = data
	return data
end
