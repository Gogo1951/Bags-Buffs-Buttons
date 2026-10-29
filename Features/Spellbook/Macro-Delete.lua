local _, ns = ...
local L = ns.L

--[[
	Deleting the add-on's WoW macros: a whole list from the options panel, or one page macro from its menu.
]]

local MaxAccountMacros = ns.MaxAccountMacros
local OwnedList = ns.OwnedMacroList

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
	-- the spell's focus copy goes with its options, so its WoW macro does too; a Duplicate's or a rank's has none
	for _, other in ipairs(ns.macros) do
		if other.focus and other.name == macro.name and not macro.copy and not macro.rank then
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
