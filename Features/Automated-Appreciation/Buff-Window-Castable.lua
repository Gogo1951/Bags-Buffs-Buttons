local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The Buff Window's castable list: which of this client's ns.BUFF_WINDOW_SPELLS
    rows have live ids, who each is offered to (seeded into the profile), the
    options panels' class categories, and the buffs this character can cast
    right now, rank by rank. Creates ns.BuffWindow, the table the other Buff
    Window files share their state and helpers through.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local BuffWindow = {}
ns.BuffWindow = BuffWindow

--[[
    One per data row with live ids: { key, row, ids, ranks, rankLevels, groupIds,
    auraIds }. rankLevels maps each single-target rank's id to its learn level.
]]
local entries = {}
local lookup = {} -- setting key (a row's first live single-target id) -> its entry
--[[
    Exclusive family ("BLESSING") -> every aura id in it, so a buff can ask
    whether the target carries another of yours from the same family.
]]
local exclusiveIds = {}
local buffs = {} -- the entries this character can cast right now, built by BuildBuffs
--[[
    The same three for self buffs (ns.BUFF_WINDOW_SELF_SPELLS), whose setting is
    when each one shows rather than who it is for.
]]
local selfEntries, selfLookup, selfBuffs = {}, {}, {}
--[[
    The same three for weapon enchants (ns.BUFF_WINDOW_WEAPON_ENCHANTS), the
    poisons and imbues. Their setting is what goes on each hand, so the
    castable list holds one per hand rather than one per row.
]]
local weaponEntries, weaponLookup, weaponBuffs = {}, {}, {}
--[[
    One per ns.BUFF_WINDOW_WEAPON_ITEMS row, the oils, stones and lures any
    class can use, shaped like a poison's entry: { key, row, ids, items,
    enchants, types, kind, itemLevel }. Picked per hand, not per class.
]]
local weaponItemEntries = {}
--[[
    Enchant id (what GetWeaponEnchantInfo reports) -> an entry that puts it
    on, for Diagnostics. Two items can share one (a Season of Discovery copy
    of Blessed Wizard Oil), so the window asks each pick's own enchants set.
]]
local weaponByEnchant = {}
-- Every poison, weapon item and Soulstone item id this client's data names.
local itemIds = {}

BuffWindow.entries = entries
BuffWindow.exclusiveIds = exclusiveIds
BuffWindow.buffs = buffs
BuffWindow.selfEntries = selfEntries
BuffWindow.selfBuffs = selfBuffs
BuffWindow.weaponEntries = weaponEntries
BuffWindow.weaponLookup = weaponLookup
BuffWindow.weaponBuffs = weaponBuffs
BuffWindow.weaponItemEntries = weaponItemEntries
BuffWindow.weaponByEnchant = weaponByEnchant
--[[
    The Soulstone (ns.BUFF_WINDOW_SOULSTONE): its entry, and the buff the
    window offers when nobody in your group carries one. Both are replaced
    rather than refilled, so read them off BuffWindow at the time.
]]
BuffWindow.soulstoneEntry = nil
BuffWindow.soulstoneBuff = nil
-- The resurrection the Buff Key casts on a dead target, { id, name, ids }, or nil.
BuffWindow.resurrection = nil
--[[
    Seconds left under which a buff counts as missing; set from the profile at
    the start of each Refresh.
]]
BuffWindow.refreshSeconds = 0
BuffWindow.isSetUp = false

--------------------------------------------------------------------------------
-- Lookups & Audience Settings
--------------------------------------------------------------------------------

local function LiveIds(ids)
	local live = {}
	for _, id in ipairs(ids or {}) do
		if C_Spell.DoesSpellExist(id) then
			live[#live + 1] = id
		end
	end
	return live
end

function BuffWindow.BuildLookup()
	wipe(entries)
	wipe(lookup)
	wipe(exclusiveIds)
	for _, row in ipairs(ns.BUFF_WINDOW_SPELLS) do
		local ranks, ids, rankLevels = {}, {}, {}
		for _, rank in ipairs(row.single) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
				ids[#ids + 1] = rank[1]
				rankLevels[rank[1]] = rank[2]
			end
		end
		if ids[1] then
			local groupIds = LiveIds(row.group)
			--[[
			    Any version counts as buffed: each rank's aura carries its own id.
			    Has drops a single-target rank below the one you'd cast. A Greater
			    Blessing only ever counts, never casts.
			]]
			local auraIds = {}
			for _, list in ipairs({ ids, groupIds, LiveIds(row.greater) }) do
				for _, id in ipairs(list) do
					auraIds[id] = true
				end
			end
			if row.exclusive then
				exclusiveIds[row.exclusive] = exclusiveIds[row.exclusive] or {}
				for id in pairs(auraIds) do
					exclusiveIds[row.exclusive][id] = true
				end
			end
			local entry = {
				key = ids[1],
				row = row,
				ids = ids,
				ranks = ranks,
				rankLevels = rankLevels,
				groupIds = groupIds,
				auraIds = auraIds,
			}
			entries[#entries + 1] = entry
			lookup[entry.key] = entry
		end
	end

	wipe(selfEntries)
	wipe(selfLookup)
	for _, row in ipairs(ns.BUFF_WINDOW_SELF_SPELLS) do
		local ranks, ids, auraIds, rankLevels = {}, {}, {}, {}
		for _, rank in ipairs(row.ranks) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
				ids[#ids + 1] = rank[1]
				auraIds[rank[1]] = true
				rankLevels[rank[1]] = rank[2]
			end
		end
		if ids[1] then
			-- A buff whose aura isn't its cast (Demonic Sacrifice's four) names its auras.
			for _, id in ipairs(LiveIds(row.auras)) do
				auraIds[id] = true
			end
			if row.exclusive then
				exclusiveIds[row.exclusive] = exclusiveIds[row.exclusive] or {}
				for id in pairs(auraIds) do
					exclusiveIds[row.exclusive][id] = true
				end
			end
			local entry =
				{ key = ids[1], row = row, ids = ids, ranks = ranks, rankLevels = rankLevels, auraIds = auraIds }
			selfEntries[#selfEntries + 1] = entry
			selfLookup[entry.key] = entry
		end
	end

	--[[
	    A poison is an item, kept best first by the level it needs; an imbue is
	    a spell, kept like any self buff's ranks. Items aren't checked against
	    the client: a poison it doesn't know is one no bag ever holds. Every
	    rank's enchant id points back at its row (weaponByEnchant), which is how
	    the window tells which of the player's picks a weapon carries. A rank
	    may name several: TBC's Rockbiter lands a different enchant for each
	    weapon speed.
	]]
	local function AddEnchants(enchants, value)
		if type(value) == "table" then
			for _, enchant in ipairs(value) do
				enchants[enchant] = true
			end
		elseif value then
			enchants[value] = true
		end
	end
	wipe(weaponEntries)
	wipe(weaponLookup)
	wipe(weaponByEnchant)
	for _, row in ipairs(ns.BUFF_WINDOW_WEAPON_ENCHANTS) do
		local entry
		local enchants = {}
		if row.items then
			local items, ids = {}, {}
			for _, item in ipairs(row.items) do
				items[#items + 1] = { id = item[1], level = item[2] }
				ids[#ids + 1] = item[1]
				AddEnchants(enchants, item[3])
			end
			table.sort(items, function(a, b)
				return a.level > b.level
			end)
			entry = { key = ids[1], row = row, ids = ids, items = items, enchants = enchants }
		else
			local ranks, ids = {}, {}
			for _, rank in ipairs(row.ranks) do
				AddEnchants(enchants, rank[3])
				if C_Spell.DoesSpellExist(rank[1]) then
					ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
					ids[#ids + 1] = rank[1]
				end
			end
			if ids[1] then
				entry = { key = ids[1], row = row, ids = ids, ranks = ranks, enchants = enchants }
			end
		end
		if entry then
			weaponEntries[#weaponEntries + 1] = entry
			weaponLookup[entry.key] = entry
			for enchant in pairs(enchants) do
				weaponByEnchant[enchant] = entry
			end
		end
	end

	--[[
	    Every other weapon item, one entry each: its enchant, the weapon types
	    it takes (a subclass mask, 0 for any weapon), and the only places it
	    works, for an item that has them.
	]]
	wipe(weaponItemEntries)
	for _, row in ipairs(ns.BUFF_WINDOW_WEAPON_ITEMS or {}) do
		local itemId = row[1]
		local entry = {
			key = itemId,
			row = row,
			ids = { itemId },
			items = { { id = itemId, level = row[2], itemLevel = row[6] } },
			enchants = { [row[3]] = true },
			types = row[4],
			kind = row[5],
			itemLevel = row[6],
			zones = row[7],
		}
		weaponItemEntries[#weaponItemEntries + 1] = entry
		weaponByEnchant[row[3]] = weaponByEnchant[row[3]] or entry
	end

	--[[
	    Ask for every poison's, weapon item's and Soulstone's item data now, so
	    the Weapon Buffs panel names each one instead of its "Item #"
	    placeholder; ns.OnBuffWindowItemInfo repaints the panel as each one
	    arrives.
	]]
	wipe(itemIds)
	for _, list in ipairs({ weaponEntries, weaponItemEntries }) do
		for _, entry in ipairs(list) do
			for _, id in ipairs(entry.items and entry.ids or {}) do
				itemIds[id] = true
			end
		end
	end
	for _, id in ipairs(ns.BUFF_WINDOW_SOULSTONE and ns.BUFF_WINDOW_SOULSTONE.items or {}) do
		itemIds[id] = true
	end
	for id in pairs(itemIds) do
		C_Item.RequestLoadItemDataByID(id)
	end

	--[[
	    The Soulstone is offered by its Create Soulstone ranks, counted by its
	    Soulstone Resurrection auras, and named on the panel by the aura.
	]]
	BuffWindow.soulstoneEntry = nil
	local stone = ns.BUFF_WINDOW_SOULSTONE
	if stone then
		local ranks, auraIds = {}, {}
		for _, rank in ipairs(stone.create) do
			if C_Spell.DoesSpellExist(rank[1]) then
				ranks[#ranks + 1] = { id = rank[1], level = rank[2] }
			end
		end
		local auras = LiveIds(stone.auras)
		for _, id in ipairs(auras) do
			auraIds[id] = true
		end
		if ranks[1] and auras[1] then
			BuffWindow.soulstoneEntry = {
				key = ranks[1].id,
				row = stone,
				ids = auras,
				ranks = ranks,
				auraIds = auraIds,
				items = stone.items,
			}
		end
	end
end

--[[
    Seed what the player never set from the row's default, drop any value that isn't a choice the dropdown
    offers, and never touch a key this client lacks. Re-run on profile changes.
]]
local function PopulateBuffWindowAudience()
	local tankWhen = ns.db.global.buffWindow.tankWhen

	-- MIGRATION (remove after 2026-11-18): the 2026.10.19.A pets toggle and its "when" became tankWhen.PET.
	local legacy = ns.db.global.buffWindow
	if legacy.petsAsTanks ~= nil or legacy.petsAsTanksWhen ~= nil then
		if legacy.petsAsTanks == false then
			tankWhen[Data.TANK_WHEN_PET] = Data.TANK_WHEN.NEVER
		elseif legacy.petsAsTanksWhen == Data.TANK_WHEN.ALWAYS then
			tankWhen[Data.TANK_WHEN_PET] = Data.TANK_WHEN.ALWAYS
		end
		legacy.petsAsTanks = nil
		legacy.petsAsTanksWhen = nil
	end

	-- A value the Count as Tanks dropdowns don't offer reads as its default again.
	for key, value in pairs(tankWhen) do
		if not Data.TANK_WHEN[value] then
			tankWhen[key] = nil
		end
	end

	local audience = ns.db.global.buffWindow.audience
	for key, value in pairs(audience) do
		if not Data.BUFF_AUDIENCE[value] then
			audience[key] = nil
		end
	end
	for key, entry in pairs(lookup) do
		if audience[key] == nil then
			audience[key] = entry.row.default
		end
	end

	--[[
	    When each self buff shows, seeded from the row's default; a value the
	    dropdown doesn't offer is dropped and reseeded.
	]]
	local valid = {}
	for _, choice in ipairs(Data.SELF_REFRESH_CHOICES) do
		valid[choice] = true
	end
	local selfRefresh = ns.db.global.buffWindow.selfRefresh
	for key, value in pairs(selfRefresh) do
		if not valid[value] then
			selfRefresh[key] = nil
		end
	end
	for key, entry in pairs(selfLookup) do
		if selfRefresh[key] == nil then
			selfRefresh[key] = entry.row.default
		end
	end
	local stone = BuffWindow.soulstoneEntry
	if stone and selfRefresh[stone.key] == nil then
		selfRefresh[stone.key] = stone.row.default
	end

	--[[
	    MIGRATION (remove after 2026-11-21): self buffs whose default went from 5
	    minutes to 3 move a stored 5 to 3, and the Soulstone moves When Missing
	    to 3. Each key moves once, recorded in selfRefreshMigrated, so a player
	    who picks 5 again keeps it. A key this client lacks waits for the client
	    that has it: Classic Era and Season of Discovery share these settings.
	]]
	local migrated = ns.db.global.buffWindow.selfRefreshMigrated
	for key, entry in pairs(selfLookup) do
		if not migrated[key] then
			if entry.row.default == 3 and selfRefresh[key] == 5 then
				selfRefresh[key] = 3
			end
			migrated[key] = true
		end
	end
	if stone and not migrated[stone.key] then
		if selfRefresh[stone.key] == Data.SELF_REFRESH_MISSING then
			selfRefresh[stone.key] = 3
		end
		migrated[stone.key] = true
	end

	--[[
	    Weapon choices are ticked or not per hand (true or false; unset reads
	    as ticked, WeaponChoiceOn), so anything else stored is dropped. A
	    stored id this client has no row for is kept: Classic Era and Season
	    of Discovery share these settings, and an Occult Poison ticked on one is
	    the other's to keep. The one timing falls back to the default when it
	    isn't a choice the dropdown offers.
	]]
	local settings = ns.db.global.buffWindow
	for _, list in ipairs({ settings.weaponPicks, settings.weaponItems }) do
		for _, hand in pairs(list) do
			for key, value in pairs(hand) do
				if type(value) ~= "boolean" then
					hand[key] = nil
				end
			end
		end
	end
	if not tContains(Data.WEAPON_REFRESH_CHOICES, settings.weaponRefresh) then
		settings.weaponRefresh = Data.WEAPON_REFRESH_DEFAULT
	end
end
ns.PopulateBuffWindowAudience = PopulateBuffWindowAudience

--------------------------------------------------------------------------------
-- Display Categories
--------------------------------------------------------------------------------

--[[
    One class-colored category per class with live rows, each entry the
    { key, ids, spellName } the panel's audience dropdown needs. Every class is
    listed, not just yours, because these settings are account-wide.
    Only the single-target ids are carried: the dropdown should show and
    describe the buff, not its group version.
]]
function BuffWindow.BuildCategories(list)
	local buckets = {}
	for _, entry in ipairs(list) do
		local class = entry.row.class
		buckets[class] = buckets[class] or {}
		local bucket = buckets[class]
		bucket[#bucket + 1] = {
			key = entry.key,
			ids = entry.ids,
			spellName = C_Spell.GetSpellName(entry.ids[1]) or L["TRACKED_SPELL_PENDING"]:format(entry.ids[1]),
			exclusive = entry.row.exclusive,
		}
	end

	local classNames = {}
	for class in pairs(buckets) do
		classNames[#classNames + 1] = class
	end
	table.sort(classNames)

	local categories = {}
	for _, class in ipairs(classNames) do
		local label = ns.ClassName(class)
		categories[#categories + 1] = { id = class, name = label, entries = buckets[class] }
	end
	return categories
end

-- Called from Tracked-Lookups' GET_ITEM_INFO_RECEIVED handler, which owns the event.
function ns.OnBuffWindowItemInfo(itemId)
	if itemIds[itemId] then
		LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.BuffWindowWeaponBuffs)
	end
end

-- Diagnostics reads this to log a poison's, weapon item's or Soulstone's item load in full.
function ns.IsBuffWindowItem(itemId)
	return itemIds[itemId] == true
end

--[[
    The options panel reads this to say why the window never shows on a class
    with nothing to give on this client.
]]
function ns.BuffWindowHasClassRows()
	-- Any class can use an oil or a stone.
	if weaponItemEntries[1] then
		return true
	end
	local _, playerClass = UnitClass("player")
	for _, list in ipairs({ entries, selfEntries, weaponEntries, { BuffWindow.soulstoneEntry } }) do
		for _, entry in ipairs(list) do
			if entry.row.class == playerClass then
				return true
			end
		end
	end
	return false
end

--[[
    Whether a weapon choice is ticked for a hand. `list` is weaponPicks
    (keyed "ROGUE_MAIN" and so on) or weaponItems (keyed "MAIN" or "OFF");
    one never set reads as ticked, so a new row reaches every player on.
]]
function BuffWindow.WeaponChoiceOn(list, handKey, key)
	local hand = list[handKey]
	return not hand or hand[key] ~= false
end

-- Whether this character has anything at all the window could offer.
function BuffWindow.HasAnythingToOffer()
	return #buffs > 0
		or #selfBuffs > 0
		or #weaponBuffs > 0
		or BuffWindow.soulstoneBuff ~= nil
		or BuffWindow.resurrection ~= nil
end

--------------------------------------------------------------------------------
-- Castable Buffs
--------------------------------------------------------------------------------

--[[
    Any known rank of a resurrection will do: its key casts by name, which
    resolves to the highest rank you know.
]]
local function FirstKnown(ids)
	for _, id in ipairs(ids) do
		if ns.IsPlayerSpell(id) then
			return id
		end
	end
	return nil
end

--[[
    The highest group version you know. The data lists them lowest first, so
    the last known one; the tooltip shows it and the button casts it by rank.
]]
local function HighestKnown(ids)
	for index = #ids, 1, -1 do
		if ns.IsPlayerSpell(ids[index]) then
			return ids[index]
		end
	end
	return nil
end

-- The client's spell subtext ("Rank 3").
local GetSpellSubtext = C_Spell.GetSpellSubtext

--[[
    What a macro types to cast exactly this rank: "Prayer of Fortitude(Rank 2)",
    or the bare name for a spell with no rank text.
]]
local function CastText(id, name)
	local subtext = GetSpellSubtext(id)
	return (subtext and subtext ~= "") and (name .. "(" .. subtext .. ")") or name
end

--[[
    The single-target ranks you know, highest first, each with what a macro
    types to cast exactly that rank: "Power Word: Fortitude(Rank 3)", or the bare
    name for a spell with no rank text. Ranks with different names (the three
    Detect Invisibility spells) carry their own.
]]
local function KnownRanks(entry)
	local known = {}
	for _, rank in ipairs(entry.ranks) do
		if ns.IsPlayerSpell(rank.id) then
			local name = C_Spell.GetSpellName(rank.id)
			if name then
				known[#known + 1] =
					{ id = rank.id, level = rank.level, name = name, castText = CastText(rank.id, name) }
			end
		end
	end
	table.sort(known, function(a, b)
		return a.level > b.level
	end)
	return known
end

--[[
    Rebuilt at setup, on SPELLS_CHANGED (a new rank, or the group version at its
    level) and when a setting on the panel changes.
]]
function BuffWindow.BuildBuffs()
	wipe(buffs)
	local _, playerClass = UnitClass("player")
	local audience = ns.db.global.buffWindow.audience
	for _, entry in ipairs(entries) do
		local who = audience[entry.key]
		if entry.row.class == playerClass and who and who ~= Data.BUFF_AUDIENCE.OFF then
			local ranks, groupId = KnownRanks(entry), HighestKnown(entry.groupIds)
			local groupName = groupId and C_Spell.GetSpellName(groupId)
			if ranks[1] or groupId then
				buffs[#buffs + 1] = {
					--[[
					    The buff's column in the window, shared by its single and
					    group icons so a party's group buff sits over the single
					    one it replaces.
					]]
					column = #buffs + 1,
					key = entry.key,
					audience = who,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					manaOnly = entry.row.manaOnly,
					noCasters = entry.row.noCasters,
					exclusive = entry.row.exclusive,
					ranks = ranks,
					-- Set when you know any single-target rank at all.
					singleName = ranks[1] and ranks[1].name,
					groupId = groupId,
					groupIds = entry.groupIds,
					groupName = groupName,
					-- "Prayer of Fortitude(Rank 2)": the bare name can cast Rank 1.
					groupCastText = groupName and CastText(groupId, groupName),
				}
			end
		end
	end

	wipe(selfBuffs)
	local selfRefresh = ns.db.global.buffWindow.selfRefresh
	for _, entry in ipairs(selfEntries) do
		local when = selfRefresh[entry.key]
		if entry.row.class == playerClass and when and when ~= Data.SELF_REFRESH_OFF then
			local ranks = KnownRanks(entry)
			if ranks[1] then
				selfBuffs[#selfBuffs + 1] = {
					-- Self Buffs keeps its own grid, so its columns count from 1.
					column = #selfBuffs + 1,
					key = entry.key,
					auraIds = entry.auraIds,
					rankLevels = entry.rankLevels,
					exclusive = entry.row.exclusive,
					ranks = ranks,
					singleName = ranks[1].name,
					-- Its own "count as missing under", in seconds; 0 waits for it to drop.
					refreshSeconds = when * 60,
					-- Soul Link only means anything with a demon out.
					needsPet = entry.row.needsPet,
				}
			end
		end
	end

	--[[
	    One per hand with anything ticked, each its own row under Self Buffs:
	    the picks, all on the one Reapply timing -- your class's poisons or
	    imbues (classPick), and the oils, stones and lures any class can use.
	    The row orders its icons as it draws them, by the item or rank each
	    one uses (Buff-Window-Weapons.lua). An imbue needs a known rank; an item
	    is looked for in your bags at each refresh, since that changes without
	    SPELLS_CHANGED. Nothing while Weapon Buffs is off.
	]]
	wipe(weaponBuffs)
	local settings = ns.db.global.buffWindow
	local classHands = {}
	for _, hand in ipairs(ns.BUFF_WINDOW_WEAPON_HANDS[playerClass] or {}) do
		classHands[hand] = true
	end
	for _, hand in ipairs(settings.weaponEnabled and Data.WEAPON_HAND_ORDER or {}) do
		local chosen = {}
		local when = settings.weaponRefresh
		local function Choose(entry, ranks, classPick)
			chosen[#chosen + 1] = {
				key = entry.key,
				ranks = ranks,
				items = entry.items,
				enchants = entry.enchants,
				types = entry.types,
				zones = entry.zones,
				refreshSeconds = when * 60,
				durationSeconds = entry.row.duration and entry.row.duration * 60,
				classPick = classPick,
			}
		end
		for _, entry in ipairs(classHands[hand] and weaponEntries or {}) do
			local ranks = entry.ranks and KnownRanks(entry)
			if
				entry.row.class == playerClass
				and BuffWindow.WeaponChoiceOn(settings.weaponPicks, playerClass .. "_" .. hand, entry.key)
				and (entry.items or ranks[1])
			then
				Choose(entry, ranks, true)
			end
		end
		for _, entry in ipairs(weaponItemEntries) do
			local kindHands = Data.WEAPON_ITEM_KIND_HANDS[entry.kind]
			if
				(not kindHands or tContains(kindHands, hand))
				and BuffWindow.WeaponChoiceOn(settings.weaponItems, hand, entry.key)
			then
				Choose(entry)
			end
		end
		if chosen[1] then
			weaponBuffs[#weaponBuffs + 1] = {
				hand = hand,
				slot = Data.WEAPON_HAND_SLOTS[hand],
				picks = chosen,
			}
		end
	end

	--[[
	    Shaped like a self buff so Has can read it on anyone in the group: no
	    ranks of its own to weigh against theirs, only its auras. The button
	    makes a stone with the best Create Soulstone you know, cast by its bare
	    name -- Classic Era names each tier its own spell, and a "(Rank 1)"
	    added to one of those names a spell that doesn't exist.
	]]
	BuffWindow.soulstoneBuff = nil
	local stone = BuffWindow.soulstoneEntry
	local stoneWhen = stone and selfRefresh[stone.key]
	if stone and stone.row.class == playerClass and stoneWhen and stoneWhen ~= Data.SELF_REFRESH_OFF then
		local known = KnownRanks(stone)
		if known[1] then
			BuffWindow.soulstoneBuff = {
				column = #selfBuffs + 1,
				key = stone.key,
				auraIds = stone.auraIds,
				rankLevels = {},
				ranks = {},
				create = known[1],
				items = stone.items,
				refreshSeconds = stoneWhen * 60,
			}
		end
	end

	--[[
	    The Buff Key's resurrection (ns.BUFF_WINDOW_RESURRECTIONS): any rank
	    you know, cast by its bare name, which resolves to your highest.
	]]
	BuffWindow.resurrection = nil
	for _, row in ipairs(ns.BUFF_WINDOW_RESURRECTIONS or {}) do
		if row.class == playerClass then
			local id = FirstKnown(row.ranks)
			local name = id and C_Spell.GetSpellName(id)
			if name then
				BuffWindow.resurrection = { id = id, name = name, ids = row.ranks }
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Ranks
--------------------------------------------------------------------------------

--[[
    A rank can go on a player at most this many levels below the level it is
    learned at; lower than that, the cast fails with "Target is too low level".
]]
local RANK_LEVEL_GAP = 10

--[[
    The highest rank you know that a target of `level` can take, or nil when
    even your lowest is too high for them. An unknown level -- a stranger out of
    sight, or one too far above you to show (UnitLevel's -1) -- takes the top
    rank: there is nothing lower to fall back to.
]]
function BuffWindow.RankFor(buff, level)
	if not ns.IsPlain(level) or not level or level <= 0 then
		return buff.ranks[1]
	end
	for _, rank in ipairs(buff.ranks) do
		if level >= rank.level - RANK_LEVEL_GAP then
			return rank
		end
	end
	return nil
end
