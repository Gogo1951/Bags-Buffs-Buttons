local _, ns = ...
local Data = ns.Data
local L = ns.L

-- Your weapons' row in the Buff Window's Self section: the poisons, imbues, oils and stones to put on each hand.

local BuffWindow = ns.BuffWindow
local weaponBuffs = BuffWindow.weaponBuffs

-- The client's own "Main Hand" and "Off Hand", for the tooltip and the options panel.
ns.WEAPON_HAND_LABELS = { MAIN = INVTYPE_WEAPONMAINHAND, OFF = INVTYPE_WEAPONOFFHAND }

local GetItemCount = C_Item.GetItemCount

--------------------------------------------------------------------------------
-- Weapons
--------------------------------------------------------------------------------

local WEAPON_CLASS = Enum.ItemClass and Enum.ItemClass.Weapon or 2
local FISHING_POLE = Enum.ItemWeaponSubclass and Enum.ItemWeaponSubclass.Fishingpole or 20

--[[
    The weapon subclass in a hand, or nil when it holds no weapon: an off hand
    holding a shield or a book, or nothing, has nothing to ask for.
]]
local function WeaponSubclass(slot)
	local itemID = GetInventoryItemID("player", slot)
	if not ns.IsPlain(itemID) or not itemID then
		return nil
	end
	local _, _, _, _, _, classID, subclassID = C_Item.GetItemInfoInstant(itemID)
	return classID == WEAPON_CLASS and subclassID or nil
end

local function HoldsWeapon(slot)
	local subclass = WeaponSubclass(slot)
	return subclass ~= nil and subclass ~= FISHING_POLE
end

--[[
    Whether a pick takes on a hand's weapon. A weapon item names the weapon
    types its spell takes (a subclass mask): a sharpening stone wants an edge,
    a weightstone a blunt weapon, a lure a fishing pole. A poison, an imbue,
    or an item naming none takes any weapon but a fishing pole.
]]
local function PickFits(pick, subclass)
	if not pick.types or pick.types == 0 then
		return subclass ~= FISHING_POLE
	end
	return bit.band(pick.types, bit.lshift(1, subclass)) ~= 0
end

--[[
    Each hand's temporary enchant, by slot: seconds left, and the enchant id
    that says which poison or imbue it is (nil for none). GetWeaponEnchantInfo
    has returned three values per hand on some clients and four (with the
    enchant id) on others, so the off hand is found by counting.
]]
local function ReadWeaponEnchants()
	local count = select("#", GetWeaponEnchantInfo())
	local stride = count >= 8 and 4 or 3
	local values = { GetWeaponEnchantInfo() }
	local left, enchants = {}, {}
	for index, slot in ipairs({ Data.WEAPON_HAND_SLOTS.MAIN, Data.WEAPON_HAND_SLOTS.OFF }) do
		local base = (index - 1) * stride
		local has, expiration = values[base + 1], values[base + 2]
		if ns.IsPlain(has) and has and ns.IsPlain(expiration) and expiration then
			left[slot] = expiration / 1000
			local enchant = stride == 4 and values[base + 4]
			enchants[slot] = ns.IsPlain(enchant) and enchant or nil
		end
	end
	return left, enchants
end

--[[
    Whether a pick on the weapon has time enough left by its own setting.
    One whose whole duration (the row's, from the data) is no longer than
    that time only needs offering once it's gone, as in Has, so a 5-minute
    Classic Era imbue under "Under 5 Minutes" isn't asked for the moment it
    lands.
]]
local function PickHolds(pick, seconds)
	local threshold = pick.refreshSeconds
	return (pick.durationSeconds and pick.durationSeconds <= threshold) or seconds >= threshold
end

--[[
    The picks a hand needs offered. None while the weapon carries one of them
    with time enough left; every pick otherwise (a bare weapon, one running
    low, or one carrying something not picked), so the player chooses -- a
    rogue topping up Instant Poison can switch to Deadly. A client that names
    no enchant lets any enchant count, held to the most lenient pick.
]]
local function PicksToOffer(hand, left, enchants)
	local seconds = left[hand.slot]
	if not seconds then
		return hand.picks
	end
	local enchant = enchants[hand.slot]
	for _, pick in ipairs(hand.picks) do
		if (not enchant or pick.enchants[enchant]) and PickHolds(pick, seconds) then
			return {}
		end
	end
	return hand.picks
end

--[[
    The hand a shaman's next imbue goes on. The spell picks for itself and
    can't be pointed at a weapon: the main hand, unless it already has an
    enchant and a bare off-hand weapon is waiting. So only that hand's imbue
    is offered, and an off hand running low waits until it's gone -- casting
    then would land on the main hand and replace what's there.
]]
local function ImbueLandsOn(left)
	local main, off = Data.WEAPON_HAND_SLOTS.MAIN, Data.WEAPON_HAND_SLOTS.OFF
	if left[main] and not left[off] and HoldsWeapon(off) then
		return off
	end
	return main
end

--[[
    Whether you're somewhere a weapon item works, for one that only works in
    certain places: an instance it names, by the map ID GetInstanceInfo
    reports, or an outdoor zone it names, by C_Map.GetBestMapForUnit's map.
    Asked at every refresh, so the backstop catches a zone change.
]]
local function InItemZones(zones)
	local instanceId = select(8, GetInstanceInfo())
	if ns.IsPlain(instanceId) and tContains(zones.instances or {}, instanceId) then
		return true
	end
	local uiMapId = C_Map.GetBestMapForUnit("player")
	return ns.IsPlain(uiMapId) and uiMapId ~= nil and tContains(zones.uiMaps or {}, uiMapId)
end

-- The best item of a pick in your bags that your level can use, { id, level, itemLevel? }, or nil.
local function BestItem(items)
	local level = UnitLevel("player")
	for _, item in ipairs(items) do
		if (not ns.IsPlain(level) or level >= item.level) and GetItemCount(item.id) > 0 then
			return item
		end
	end
	return nil
end

--[[
    An item's button (a poison, oil, stone or lure) names its hand by
    target-slot: using the item leaves the cursor waiting on a weapon, and the
    secure template picks that slot. An imbue never asks -- see ImbueLandsOn
    -- so its button just casts. Either way the game's "replace your
    enchant?" question is answered for you (confirmReplace): the click was
    the answer. The Buff Key passes every weapon icon by (weapon). `level`
    ranks what it uses, for SortWeaponIcons: an oil's, stone's or lure's item
    level, a poison's required level, or an imbue rank's learn level.
]]
local function WeaponIcon(hand, pick)
	if pick.zones and not InItemZones(pick.zones) then
		return nil
	end
	local handName = ns.WEAPON_HAND_LABELS[hand.hand]
	local spec = {
		targetName = handName,
		hint = L["BUFF_WINDOW_TOOLTIP_WEAPON"]:format(handName),
		confirmReplace = true,
		weapon = true,
		classPick = pick.classPick,
	}
	if pick.items then
		local item = BestItem(pick.items)
		if not item then
			return nil
		end
		spec.itemId = item.id
		spec.item = "item:" .. item.id
		spec.targetSlot = hand.slot
		spec.level = item.itemLevel or item.level
	else
		local rank = pick.ranks[1]
		spec.spellId = rank.id
		spec.spellName = rank.name
		spec.castSpell = rank.castText
		spec.unit = "player"
		spec.level = rank.level
	end
	return spec
end

--[[
    A hand's icons left to right: your class's poisons or imbues, then the
    oils, stones and lures, each by the level of what it uses, highest first
    -- Instant Poison IV (44) before Deadly Poison II (38), Solid Sharpening
    Stone before Rough. Each hand's row is
    its own grid, so the icons' order is their columns.
]]
local function SortWeaponIcons(specs)
	table.sort(specs, function(a, b)
		if (a.classPick or false) ~= (b.classPick or false) then
			return a.classPick == true
		end
		if a.level ~= b.level then
			return a.level > b.level
		end
		return (a.itemId or a.spellId) < (b.itemId or b.spellId)
	end)
	for index, spec in ipairs(specs) do
		spec.column = index
	end
end

--[[
    A hand's row label: the equipped weapon's icon, then the client's "Main
    Hand" or "Off Hand", so the row says which weapon its icons go on.
]]
local function WeaponRowLabel(hand)
	local name = ns.WEAPON_HAND_LABELS[hand.hand]
	local texture = GetInventoryItemTexture("player", hand.slot)
	if not ns.IsPlain(texture) or not texture then
		return name
	end
	return ("|T%s:%d:%d|t %s"):format(texture, Data.BUFF_WINDOW_ICON_SIZE, Data.BUFF_WINDOW_ICON_SIZE, name)
end

--[[
    Putting a poison or imbue over the one a weapon already has makes the game
    ask first (REPLACE_ENCHANT). A click on a weapon icon was the answer, so
    the question is accepted when it comes within a moment of one.
]]
local REPLACE_WINDOW = 2
local replaceClickedAt

-- Called by a weapon icon's PreClick.
function ns.ExpectReplaceEnchant()
	replaceClickedAt = GetTime()
end

--[[
    The game's own popup may open before or after this runs, so it is closed
    on the next frame too.
]]
local function OnReplaceEnchant()
	if not replaceClickedAt or GetTime() - replaceClickedAt > REPLACE_WINDOW then
		return
	end
	replaceClickedAt = nil
	C_Item.ReplaceEnchant()
	StaticPopup_Hide("REPLACE_ENCHANT")
	C_Timer.After(0, function()
		StaticPopup_Hide("REPLACE_ENCHANT")
	end)
end

ns.SetEventHandler("REPLACE_ENCHANT", OnReplaceEnchant)

--[[
    One row per hand holding a weapon, with the picks it can still take, for
    the Self section (BuffWindow.AddSelfSection). Nothing while the weapons'
    switch is off, which leaves weaponBuffs empty.
]]
function BuffWindow.AddWeaponRows(rows)
	if #weaponBuffs == 0 then
		return
	end
	local left, enchants = ReadWeaponEnchants()
	local imbueSlot = ImbueLandsOn(left)
	for _, hand in ipairs(weaponBuffs) do
		local subclass = WeaponSubclass(hand.slot)
		if subclass then
			local specs = {}
			for _, pick in ipairs(PicksToOffer(hand, left, enchants)) do
				if PickFits(pick, subclass) and (pick.items or hand.slot == imbueSlot) then
					specs[#specs + 1] = WeaponIcon(hand, pick)
				end
			end
			if specs[1] then
				SortWeaponIcons(specs)
				rows[#rows + 1] =
					{ label = WeaponRowLabel(hand), icons = specs, grid = "weapon" .. hand.hand, indent = 0 }
			end
		end
	end
end
