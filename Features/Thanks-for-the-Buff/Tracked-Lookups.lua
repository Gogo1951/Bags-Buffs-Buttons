local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    The tracked data built from ns.TRACKED_ABILITIES at login: the lookups the
    buff engine and Good News match against, the seeded watched lists, and the
    display groups the options panels and diagnostics render.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local auraLookup = {}
local castLookup = {}
local givenLookup = {} -- Good News: keyed by CAST id (see BuildLookups)

--------------------------------------------------------------------------------
-- Tracked Lookups
--------------------------------------------------------------------------------

--[[
    The id the combat log carries for a trigger: the aura it applies (AURA) or the
    cast id (CAST). An item trigger's `spell` already is that id; a spell trigger
    may name a separate `aura`.
]]
local function WatchedId(entry, trigger)
	if entry.detect == Data.DETECT.AURA then
		return trigger.aura or trigger.spell
	end
	return trigger.spell
end

--[[
    Two lookups keyed by the id the combat log carries: auras (SPELL_AURA_APPLIED)
    and casts (SPELL_CAST_SUCCESS). Each records its message type and detect mode,
    and -- for item reactions -- the source item so the message links the item.

    A third, givenLookup, backs Good News and is keyed by the CAST id instead,
    because that is what UNIT_SPELLCAST_SENT/SUCCEEDED carry -- which for an
    aura-detect entry whose aura id differs from its cast id (Misdirection) is
    NOT the id auraLookup uses. It carries `watchedId` (the id the panel toggles
    and the settings list are keyed by) and `auraId` (what to read the duration
    off the recipient with), so neither has to be re-derived at cast time.
    Services are excluded: they have no per-person recipient to tell. A row
    marked `receivable = false` gets only this third lookup: its landing on you
    is invisible on this client, but your own cast of it still is.
]]
local function BuildLookups()
	local DoesSpellExist = C_Spell.DoesSpellExist
	wipe(auraLookup)
	wipe(castLookup)
	wipe(givenLookup)

	for _, entry in ipairs(ns.TRACKED_ABILITIES) do
		local lookup = (entry.detect == Data.DETECT.AURA) and auraLookup or castLookup
		--[[
		    Seeds consumed by PopulateWatchedBuffs: 0 seeds a checkbox off,
		    anything else on; a missing value seeds on.
		]]
		local receivedDefault = entry.received ~= 0
		local givenDefault = entry.given ~= 0
		for _, trigger in ipairs(entry.triggers) do
			local watched = WatchedId(entry, trigger)
			-- Drop triggers absent on this client (mirrors BuildDisplayGroups).
			if DoesSpellExist(trigger.spell) or DoesSpellExist(watched) then
				if entry.receivable ~= false then
					lookup[watched] = {
						type = entry.type,
						detect = entry.detect,
						itemId = trigger.item,
						opened = entry.opened,
						receivedDefault = receivedDefault,
					}
				end
				if entry.type ~= Data.BUFF.SERVICE then
					givenLookup[trigger.spell] = {
						type = entry.type,
						detect = entry.detect,
						itemId = trigger.item,
						watchedId = watched,
						givenDefault = givenDefault,
						--[[
						    What to read the recipient's remaining duration with.
						    Deliberately absent for a cast that leaves no aura and
						    for a `noDuration` entry (Fear Ward, Misdirection):
						    nothing to read is what drops the duration clause from
						    their message. A duration that IS read still has to
						    clear the under-a-minute cap in BuildGoodNewsMessage.
						]]
						auraId = (entry.detect == Data.DETECT.AURA and not entry.noDuration) and watched or nil,
					}
				end
			end
		end
	end

	-- Surface the watched-id counts for the diagnostics context report.
	local auraCount, castCount = 0, 0
	for _ in pairs(auraLookup) do
		auraCount = auraCount + 1
	end
	for _ in pairs(castLookup) do
		castCount = castCount + 1
	end
	ns.DIAGNOSTIC_TRACKED.auraIds = auraCount
	ns.DIAGNOSTIC_TRACKED.castIds = castCount
end

--[[
    Watched state is keyed by the watched spell id; a key the saved list doesn't
    hold yet seeds from the entry's received/given defaults, carried on
    the lookup records by BuildLookups (0 seeds off), and a user's own choice is
    never overwritten. One shared list backs both the Teammates and Services
    panels; ids never overlap between them, so a single table is unambiguous. The
    Good News panel reuses the teammate ids with independent choices, so it
    seeds its own list here from givenLookup, which holds no service ids (a
    service has no per-person recipient to whisper). A key this client's data
    lacks is left alone: Classic Era and Season of Discovery share one profile.
]]
local function PopulateWatchedBuffs()
	local watched = ns.db.global.watchedBuffs
	local given = ns.db.global.goodNews.watched
	for id, info in pairs(auraLookup) do
		if watched[id] == nil then
			watched[id] = info.receivedDefault
		end
	end
	for id, info in pairs(castLookup) do
		if watched[id] == nil then
			watched[id] = info.receivedDefault
		end
	end
	for _, info in pairs(givenLookup) do
		if given[info.watchedId] == nil then
			given[info.watchedId] = info.givenDefault
		end
	end
end
ns.PopulateWatchedBuffs = PopulateWatchedBuffs

--------------------------------------------------------------------------------
-- Display Groups
--------------------------------------------------------------------------------

local trackedItemIds = {}

local function WarmItemCache()
	--[[
	    Touch every tracked item so its name/link is cached for the options panel
	    and the "used their X on you" message. Cold entries resolve asynchronously.
	]]
	wipe(trackedItemIds)
	for _, entry in ipairs(ns.TRACKED_ABILITIES) do
		for _, trigger in ipairs(entry.triggers) do
			if trigger.item then
				trackedItemIds[trigger.item] = true
				C_Item.GetItemInfo(trigger.item)
			end
		end
	end
end

--[[
    An item that loads while a panel is open repaints it, replacing its "Item #"
    placeholder. This file owns the event and hands every firing to the Buff
    Window first, whose Weapon Buffs panel names poisons, oils, stones and
    lures the same way.
]]
local function OnGetItemInfoReceived(itemId)
	if ns.OnBuffWindowItemInfo then
		ns.OnBuffWindowItemInfo(itemId)
	end
	if not trackedItemIds[itemId] then
		return
	end
	local registry = LibStub("AceConfigRegistry-3.0")
	registry:NotifyChange(ns.OPTIONS_REGISTRY.TeammateBuffsTracked)
	registry:NotifyChange(ns.OPTIONS_REGISTRY.SendGoodNewsTracked)
	registry:NotifyChange(ns.OPTIONS_REGISTRY.ServiceAlertsTracked)
end

ns.SetEventHandler("GET_ITEM_INFO_RECEIVED", OnGetItemInfoReceived)

local function AddToBuckets(buckets, class, toggle)
	local list
	if class then
		buckets.classes[class] = buckets.classes[class] or {}
		list = buckets.classes[class]
	else
		list = buckets.items
	end
	list[#list + 1] = toggle
end

-- Classes alphabetically, then the generic Items group.
local function BucketsToCategories(buckets)
	local categories = {}
	local classNames = {}
	for class in pairs(buckets.classes) do
		classNames[#classNames + 1] = class
	end
	table.sort(classNames)
	for _, class in ipairs(classNames) do
		local color = Data.CLASS_COLORS[class] or ns.PALETTE.TEXT
		local label = "|cff" .. color .. (LOCALIZED_CLASS_NAMES_MALE[class] or class) .. "|r"
		categories[#categories + 1] = { id = class, name = label, entries = buckets.classes[class] }
	end

	if #buckets.items > 0 then
		categories[#categories + 1] = {
			id = "ITEMS",
			name = GetColor("TITLE") .. L["TRACKED_GROUP_ITEMS"] .. "|r",
			entries = buckets.items,
		}
	end
	return categories
end

--[[
    Reshape ns.TRACKED_ABILITIES into the products the options panels and the diagnostics
    report consume. Built once at login, when the spell/item APIs are live:

    - ns.TeammateCategories : ordered categories for the Teammate Buffs
      panel -- one per class, then a generic Items group.
    - ns.GoodNewsCategories : the same shape for the Good News panel, which also
      lists the `receivable = false` rows the teammate panel leaves out.
    - ns.ServiceEntries     : a flat list for the Service Alerts panel.
    - ns.DIAGNOSTIC_SPELLS  : per-class { name, ids } (ability ids) for the
      IsPlayerSpell probe in the diagnostics report.
    - ns.DIAGNOSTIC_TRACKED : live/total entry and watched-id counts for the
      diagnostics report, so a Data/client spell-id mismatch is visible.

    One tracked entry becomes exactly one toggle; triggers absent from the
    running client are dropped, and an entry with none left is skipped.
]]
local function BuildDisplayGroups()
	local SERVICE = Data.BUFF.SERVICE
	local GetSpellName = C_Spell.GetSpellName
	local DoesSpellExist = C_Spell.DoesSpellExist

	local teammateBuckets = { classes = {}, items = {} } -- Teammate Buffs
	local goodNewsBuckets = { classes = {}, items = {} } -- Good News
	local serviceEntries = {} -- Service Alerts
	local diagnostic = {} -- class -> { {name, ids} }
	local entriesTotal, entriesLive = 0, 0 -- client coverage for diagnostics

	for _, entry in ipairs(ns.TRACKED_ABILITIES) do
		entriesTotal = entriesTotal + 1
		-- Drop triggers whose spell is absent on this client; skip a hollow entry.
		local ids, items, abilities, iconItem = {}, {}, {}, nil
		for _, trigger in ipairs(entry.triggers) do
			local watched = WatchedId(entry, trigger)
			if DoesSpellExist(trigger.spell) or DoesSpellExist(watched) then
				ids[#ids + 1] = watched
				abilities[#abilities + 1] = trigger.spell
				if trigger.item then
					items[#items + 1] = trigger.item
					iconItem = iconItem or trigger.item
				end
			end
		end

		if #ids > 0 then
			entriesLive = entriesLive + 1
			local name = entry.name or GetSpellName(abilities[1]) or L["TRACKED_SPELL_PENDING"]:format(abilities[1])

			-- One TRACKED entry == one toggle.
			local toggle = { ids = ids }
			if #items > 0 then
				toggle.itemId = iconItem
				toggle.itemIds = items -- tooltip lists them when more than one
				toggle.label = entry.name -- nil for a lone item -> uses its own name
				toggle.labelItem = entry.labelItem -- a group named after one of its items
			else
				toggle.spellName = name
				if entry.name then
					toggle.spellIds = abilities -- named group -> tooltip lists members
				end
			end

			-- Route to a panel: services first, then class, then generic items.
			if entry.type == SERVICE then
				serviceEntries[#serviceEntries + 1] = toggle
			else
				if entry.receivable ~= false then
					AddToBuckets(teammateBuckets, entry.class, toggle)
				end
				AddToBuckets(goodNewsBuckets, entry.class, toggle)
			end

			-- Diagnostics: every class-flavored *spell* (items aren't player spells).
			if entry.class and #items == 0 then
				diagnostic[entry.class] = diagnostic[entry.class] or {}
				local classSpells = diagnostic[entry.class]
				classSpells[#classSpells + 1] = { name = name, ids = abilities }
			end
		end
	end

	ns.DIAGNOSTIC_SPELLS = diagnostic
	ns.DIAGNOSTIC_TRACKED.entriesLive = entriesLive
	ns.DIAGNOSTIC_TRACKED.entriesTotal = entriesTotal

	ns.TeammateCategories = BucketsToCategories(teammateBuckets)
	ns.GoodNewsCategories = BucketsToCategories(goodNewsBuckets)
	ns.ServiceEntries = serviceEntries
end

--------------------------------------------------------------------------------
-- Accessors
--------------------------------------------------------------------------------

function ns.GetAuraEntry(spellID)
	return auraLookup[spellID]
end

function ns.GetCastEntry(spellID)
	return castLookup[spellID]
end

-- Good News reads this one: keyed by cast id.
function ns.GetGivenEntry(spellID)
	return givenLookup[spellID]
end

-- Run from ns.SetupBuffTracking at login, once the spell and item APIs return real data.
function ns.BuildTrackedData()
	BuildLookups()
	PopulateWatchedBuffs()
	WarmItemCache()
	BuildDisplayGroups()
end
