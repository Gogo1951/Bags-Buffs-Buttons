local _, ns = ...
local L = ns.L

-- Keeps the WoW macros the page creates in step with it, and reads the action bars for the page's glows.

--[[
	The macro slot limits. The Retail engine has them in Constants.MacroConsts; the Classic engine's
	UIParent sets the MAX_ACCOUNT_MACROS and MAX_CHARACTER_MACROS globals. Every flavor is 120 general
	and 30 character today, the fallback if neither is there.
]]
local MACRO_CONSTS = Constants and Constants.MacroConsts or {}

local function MaxCharacterMacros()
	return MACRO_CONSTS.MAX_CHARACTER_MACROS or MAX_CHARACTER_MACROS or 30
end

local function MaxAccountMacros()
	return MACRO_CONSTS.MAX_ACCOUNT_MACROS or MAX_ACCOUNT_MACROS or 120
end

-- The macros in use and the slots there are: general used, general max, character used, character max.
function ns.MacroCounts()
	local numAccount, numCharacter = GetNumMacros()
	return numAccount, MaxAccountMacros(), numCharacter, MaxCharacterMacros()
end

--[[
	The WoW macros the add-on writes carry a tag line (ns.MacroTag), which is how the page finds them. Macros
	from before the tags are found by name instead, and only those the add-on created, by name: character
	ones listed in ns.db.char (as true), general ones in ns.db.global as the key of the character that created
	it, the only character that rewrites it. The next sync tags each one it finds, so a player's own macro that
	happens to share a spell's name is never touched. Macro indexes run general first, then character, so the
	index says which list a macro belongs to. New macros are still recorded, so one whose tag line the player
	deletes is found by name again. The records are kept by WoW macro name, prefix and all.
]]

--[[
	The name the WoW macro for a page macro takes: the page macro's own behind ns.MACRO_NAME_PREFIX
	("-Divine Spirit"), so the add-on's macros sort together in /macro. A consumable's is Connoisseur's own
	(Features/Spellbook/Consumable-Macros.lua).
]]
function ns.WowMacroName(macro)
	return macro.wowName or ns.MACRO_NAME_PREFIX .. macro.macroName
end

--[[
	MIGRATION (remove after 2026-11-23): the name the add-on gave a WoW macro before the prefix, when names ran
	to the full 16 bytes: a spell macro's name cut to 16, a focus copy's or a Duplicate's cut to fit
	its suffix in 16.
]]
local LEGACY_NAME_MAX_LENGTH = 16

--[[
	MIGRATION (remove after 2026-11-26): the prefix the Spellbook's macros had before Bags Buffs & Buttons gave
	every one of its macros a leading "-". A macro still under it is renamed on its next sync.
]]
local OLD_PREFIX = "~"

local function OldPrefixName(macro)
	return OLD_PREFIX .. macro.macroName
end

local function LegacyMacroName(macro)
	if macro.copy then
		local suffix = " " .. macro.copy
		return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH - #suffix) .. suffix
	elseif macro.focus then
		return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH - #ns.FOCUS_SUFFIX) .. ns.FOCUS_SUFFIX
	end
	return ns.TrimMacroName(macro.name, LEGACY_NAME_MAX_LENGTH)
end

local function IsGeneral(index)
	return index <= MaxAccountMacros()
end

local function OwnedList(index)
	return IsGeneral(index) and ns.db.global.ownedMacros or ns.db.char.ownedMacros
end

-- The record a macro the add-on creates at index takes in its OwnedList.
local function OwnerRecord(index)
	if IsGeneral(index) then
		return ns.db.keys.char
	end
	return true
end

--[[
	How a page macro stands to the untagged WoW macro of its name at index: "owned" (recorded as the add-on's,
	for this character), "claim" (MIGRATION, remove after 2026-11-23: a general macro recorded true before
	owners were, which the first character to find it claims), "adopt" (MIGRATION, remove after 2026-11-23:
	unrecorded, from before ownership tracking, but its text is the page's own), or nil (the player's own, or
	another character's). Reads only; ns.SyncMacro records a claim or adoption.
]]
function ns.LegacyOwnership(macro, index)
	local name, _, body = GetMacroInfo(index)
	local record = OwnedList(index)[name]
	if record == true and IsGeneral(index) then
		return "claim"
	end
	if record ~= nil then
		return record == OwnerRecord(index) and "owned" or nil
	end
	if body and (ns.TaggedBody(macro, body) == macro.body or body == ns.BareBody(macro.name)) then
		return "adopt"
	end
	return nil
end

local NO_INDEXES = {}

--[[
	Where the WoW macros are, read in one pass over them: tags maps each tag to the first macro carrying it,
	and names each name to the untagged macros of that name, character ones first, as the page's lookups by
	name have always preferred them.
]]
local function ReadMacroIndexes()
	local indexes = { tags = {}, names = {} }
	local numAccount, numCharacter = GetNumMacros()
	local function read(index)
		local name, _, body = GetMacroInfo(index)
		local tag = ns.BodyTag(body)
		if tag then
			indexes.tags[tag] = indexes.tags[tag] or index
		elseif name then
			indexes.names[name] = indexes.names[name] or {}
			table.insert(indexes.names[name], index)
		end
	end
	local first = MaxAccountMacros()
	for index = first + 1, first + numCharacter do
		read(index)
	end
	for index = 1, numAccount do
		read(index)
	end
	return indexes
end

ns.ReadMacroIndexes = ReadMacroIndexes

-- The first untagged WoW macro called name that ns.LegacyOwnership says is the page macro's, and how.
local function FindByName(macro, indexes, name)
	for _, named in ipairs(name and indexes.names[name] or NO_INDEXES) do
		local ownership = ns.LegacyOwnership(macro, named)
		if ownership then
			return named, ownership
		end
	end
	return nil
end

--[[
	The WoW macro that is a page macro's: the one carrying its tag, else an untagged one of its name the
	add-on created (see ns.LegacyOwnership), under its name or, from before the prefix, its old one. Returns
	the index, 0 for none, and how it was found: "tag", or the ownership answer. Reads only. indexes is a
	ReadMacroIndexes result, read here when nil.
]]
function ns.FindMacroIndex(macro, indexes)
	indexes = indexes or ReadMacroIndexes()
	local index = indexes.tags[ns.MacroTag(macro)]
	if index then
		return index, "tag"
	end
	local ownership
	index, ownership = FindByName(macro, indexes, ns.WowMacroName(macro))
	if not index then
		-- MIGRATION (remove after 2026-11-26)
		index, ownership = FindByName(macro, indexes, OldPrefixName(macro))
	end
	if not index then
		-- MIGRATION (remove after 2026-11-23)
		index, ownership = FindByName(macro, indexes, LegacyMacroName(macro))
	end
	return index or 0, ownership
end

--[[
	Whether the macro's body fits the game's limit, measured in bytes, which a translated name reaches sooner.
	A longer body would be cut off, so it is never written, and the player is told once.
]]
local function Fits(macro)
	if #macro.body <= ns.MACRO_BODY_MAX_LENGTH then
		return true
	end
	ns.WarnOnce(L["CHAT_MACRO_TOO_LONG"]:format(macro.label or macro.name, #macro.body, ns.MACRO_BODY_MAX_LENGTH))
	return false
end

--[[
	Why the page can't place a macro, or nil when it can: "long", with the body's length in bytes, when the
	body is over what a macro holds. ns.PickupMacro asks the same, so the page's warnings and a click never
	disagree. A macro of the same name never blocks one: the page's macros are told apart by their tags.
]]
function ns.MacroBlockReason(macro)
	if #macro.body > ns.MACRO_BODY_MAX_LENGTH then
		return "long", #macro.body
	end
	return nil
end

--[[
	Whether name is one the add-on gave the WoW macro of a spell this macro replaced in its group, which it
	took over (see ns.HandOverMacro in Features/Macro-Builder.lua).
]]
local function IsReplacedSpellsName(macro, name)
	if macro.focus or macro.copy then
		return false
	end
	for _, replaced in ipairs(macro.replaces or NO_INDEXES) do
		local trimmed = ns.TrimMacroName(replaced)
		-- MIGRATION (remove after 2026-11-26): OLD_PREFIX
		if name == ns.MACRO_NAME_PREFIX .. trimmed or name == OLD_PREFIX .. trimmed then
			return true
		end
	end
	return false
end

--[[
	Rewrites the WoW macro at index if its body differs from the page's and fits. One still under its name
	from before the prefix (MIGRATION, remove after 2026-11-23), under the old "~" prefix (MIGRATION, remove
	after 2026-11-26), or under the name of a replaced spell whose macro it took over ("-Bear Form", now Dire
	Bear Form's), is renamed, its ownership record moving with
	it; a name the player gave it is kept. A new name sorts the macro elsewhere in its list, so this returns
	the index it ends up at.
]]
local function SyncAt(macro, index)
	if index == 0 then
		return 0
	end
	local name, _, body = GetMacroInfo(index)
	local newBody = body ~= macro.body and Fits(macro) and macro.body or nil
	if name ~= LegacyMacroName(macro) and name ~= OldPrefixName(macro) and not IsReplacedSpellsName(macro, name) then
		if newBody then
			EditMacro(index, nil, nil, newBody)
		end
		return index
	end
	local wowName = ns.WowMacroName(macro)
	local owned = OwnedList(index)
	owned[name] = nil
	owned[wowName] = OwnerRecord(index)
	return EditMacro(index, wowName, nil, newBody) or index
end

--[[
	Rewrites this character's WoW macro for a page macro if its body has changed, and returns its index. One
	found by name gets its tag line here, and is recorded as the add-on's; indexes, when given, then lists it
	under its tag, so a second page macro of the same name in the same pass doesn't take it too. A rename
	moves macros about, so indexes is then read again.
]]
function ns.SyncMacro(macro, indexes)
	local index, found = ns.FindMacroIndex(macro, indexes)
	if index ~= 0 and found ~= "tag" then
		local name = GetMacroInfo(index)
		OwnedList(index)[name] = OwnerRecord(index)
		ns.AssignMacroTag(macro)
		if indexes then
			indexes.tags[ns.MacroTag(macro)] = index
			local named = indexes.names[name]
			for i = #named, 1, -1 do
				if named[i] == index then
					table.remove(named, i)
				end
			end
		end
	end
	local moved = SyncAt(macro, index)
	if moved ~= index and indexes then
		local fresh = ReadMacroIndexes()
		indexes.tags, indexes.names = fresh.tags, fresh.names
	end
	return moved
end

--[[
	Creates the macro on first use (character specific, or general once those slots are full), then puts
	it on the cursor so it can be dropped on an action bar. A macro of the same name the add-on didn't make is
	left alone, and the new one sits beside it under the same name.
]]
function ns.PickupMacro(macro)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
		return
	end
	-- a consumable's macro is Connoisseur's to write, so the page only picks it up
	if macro.consumable then
		local index = GetMacroIndexByName(macro.wowName)
		if index > 0 then
			PickupMacro(index)
		end
		return
	end
	if ns.MacroBlockReason(macro) then
		Fits(macro) -- tells the player, once
		return
	end
	local index = ns.FindMacroIndex(macro)
	if index == 0 then
		local numAccount, numCharacter = GetNumMacros()
		local perCharacter = numCharacter < MaxCharacterMacros()
		if not perCharacter and numAccount >= MaxAccountMacros() then
			UIErrorsFrame:AddMessage(L["ADDON_SHORT_NAME"] .. " // " .. L["ERROR_MACRO_SLOTS_FULL"], 1, 0.1, 0.1)
			return
		end
		ns.AssignMacroTag(macro)
		-- a tag that grows to three characters adds a byte, so the tagged body is measured again
		if not Fits(macro) then
			return
		end
		index = CreateMacro(ns.WowMacroName(macro), macro.macroIcon, macro.body, perCharacter)
		if not index or index == 0 then
			return
		end
		OwnedList(index)[ns.WowMacroName(macro)] = OwnerRecord(index)
		ns.ForgetPlacedRankMacros()
	else
		index = ns.SyncMacro(macro)
	end
	PickupMacro(index)
end

-- Macros can't be edited in combat, so a rewrite asked for then waits for combat to end.
local syncPending = false

function ns.QueueMacroSync()
	syncPending = true
end

function ns:OnPlayerRegenEnabled()
	if syncPending then
		syncPending = false
		ns:RefreshMacros()
	end
end

-- Rewrites the existing WoW macros whose body no longer matches the page (a setting or config changed).
function ns.SyncAllMacros()
	if InCombatLockdown() then
		ns.QueueMacroSync()
		return
	end
	local indexes = ReadMacroIndexes()
	for _, macro in ipairs(ns.macros) do
		ns.SyncMacro(macro, indexes)
	end
end

--[[
	The index range of one macro list and its ownership records: the General one (general true), which every
	character on the account shares, or this character's. Another character's own list can't be read from here.
]]
local function MacroList(general)
	local numAccount, numCharacter = GetNumMacros()
	if general then
		return 1, numAccount, ns.db.global.ownedMacros
	end
	local first = MaxAccountMacros() + 1
	return first, first + numCharacter - 1, ns.db.char.ownedMacros
end

--[[
	The add-on's WoW macros in one list, highest index first: those carrying a tag the register handed out,
	under a name the add-on recorded creating. Both are asked, so a player's own macro whose last line happens
	to read like a tag ("#end") is never taken for one.
]]
local function AddonMacroIndexes(general)
	local first, last, owned = MacroList(general)
	local handedOut = {}
	for _, tag in pairs(ns.db.global.macroTags) do
		handedOut[tag] = true
	end
	local found = {}
	for index = last, first, -1 do
		local name, _, body = GetMacroInfo(index)
		local tag = ns.BodyTag(body)
		if tag and handedOut[tag] and owned[name] ~= nil then
			found[#found + 1] = index
		end
	end
	return found, owned
end

-- How many of the add-on's WoW macros one list holds.
function ns.CountAddonMacros(general)
	return #AddonMacroIndexes(general)
end

--[[
	Deletes the add-on's WoW macros from one list, which takes them off the action bars too; a player's own
	macro is never touched. A sync first tags the page's macros from before the tags, so they go as well.
	Indexes shift down as macros go, so they are deleted highest first. The deleted names' ownership records
	go too, so a player's own macro later given one of those names is never taken for the add-on's. The page
	macros keep their tags, so one placed again gets its old tag back. Macros can't be deleted in combat.
]]
function ns.DeleteAddonMacros(general)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
		return
	end
	ns:RefreshMacros()
	local indexes, owned = AddonMacroIndexes(general)
	for _, index in ipairs(indexes) do
		owned[GetMacroInfo(index)] = nil
		DeleteMacro(index)
	end
	ns:PrintMessage(L["CHAT_MACROS_DELETED"]:format(#indexes))
	ns:RefreshOpenPages()
end

local MAX_ACTION_SLOTS = 180 -- Classic has 120; empty or missing slots return nil

--[[
	What is on the action bars: {macros = {[macro name] = true}, spells = {[spell name] = true}}. For a
	macro that shows a spell, GetActionInfo gives the spell's id (subtype "spell") rather than the macro's
	index, so macros are matched by the name GetActionText gives.
]]
function ns.ScanActionBars()
	local bars = { macros = {}, spells = {} }
	for slot = 1, MAX_ACTION_SLOTS do
		local actionType, id, subType = GetActionInfo(slot)
		if actionType == "macro" then
			local name = GetActionText(slot) or (subType ~= "spell" and GetMacroInfo(id))
			if name then
				bars.macros[name] = true
			end
		elseif actionType == "spell" and id then
			-- by name, not ID: the bar can hold any rank of a spell, and every rank has its own ID
			local name = C_Spell.GetSpellName(id)
			if name then
				bars.spells[name] = true
			end
		end
	end
	return bars
end

--[[
	How many action slots hold the WoW macro at index: matched by the name GetActionText gives, as
	ns.ScanActionBars matches, or by the index where the slot gives one rather than the spell's.
]]
function ns.MacroBarCount(index)
	local name, count = GetMacroInfo(index), 0
	for slot = 1, MAX_ACTION_SLOTS do
		local actionType, id, subType = GetActionInfo(slot)
		if actionType == "macro" and (GetActionText(slot) == name or (subType ~= "spell" and id == index)) then
			count = count + 1
		end
	end
	return count
end

--[[
	The menu's Delete: deletes the page macro's WoW macro, which takes it off the action bars, with its
	ownership record, and puts the macro back as it started: a spell's or slot's options all reset, its focus
	copy's WoW macro deleted too, and a Duplicate copy taken off the page. A spell's macro keeps its tag, so one
	placed again gets it back. Macros can't be deleted in combat.
]]
function ns.DeletePageMacro(macro)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
		return
	end
	local function delete(page)
		local index = ns.FindMacroIndex(page)
		if index ~= 0 then
			OwnedList(index)[GetMacroInfo(index)] = nil
			DeleteMacro(index)
		end
	end
	delete(macro)
	-- the focus copy goes with the options, so its WoW macro does too
	for _, other in ipairs(ns.macros) do
		if other.focus and other.name == macro.name and not macro.copy then
			delete(other)
		end
	end
	if macro.copy then
		ns.RemoveMacroCopy(macro)
	else
		ns.ResetMacroOptions(macro)
	end
end

StaticPopupDialogs.BAGSBUFFSBUTTONS_DELETE_MACRO = {
	text = L["MENU_DELETE_CONFIRM"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(_, data)
		data()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Asks before deleting a macro that is on the bars, by name; delete runs on Yes.
function ns.ConfirmDelete(name, delete)
	StaticPopup_Show("BAGSBUFFSBUTTONS_DELETE_MACRO", name, nil, delete)
end

--[[
	Whether a page macro is on the action bars, scanned by ns.ScanActionBars. A spell macro with no
	options on also counts when its plain spell is on a bar, and with ns.CountsSpellsOnBars() any spell
	macro does. The Shoot macro's plain spell is any of the ranged attacks it stands for.
]]
function ns.IsOnActionBars(macro, bars)
	if bars.macros[ns.WowMacroName(macro)] then
		return true
	end
	-- a consumable is placed only as its macro: Feed Pet the spell on a bar is not the Feed Pet macro
	if macro.consumable then
		return false
	end
	local spell = bars.spells[macro.name] and macro.name
	for name in pairs(macro.rangedAttacks or NO_INDEXES) do
		spell = spell or bars.spells[name] and name
	end
	if macro.focus or macro.copy or not spell then
		return false
	end
	return ns.CountsSpellsOnBars() or macro.body == ns.TaggedBody(macro, ns.BareBody(spell))
end
