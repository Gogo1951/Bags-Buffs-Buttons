local _, ns = ...

local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey

local NO_COPIES = {}

--[[
	Duplicate lists a spell macro again as "Drain Soul 2", "Drain Soul 3" and so on: a copy casting the same
	spell, with options of its own and a WoW macro of its own. ns.db.profile.macroCopies holds each spell's
	copy numbers, by spell name, in the order made; a number removed is never reused while a later one stands,
	so a copy keeps its name. A copy offers every option its spell does except a focus copy of its own.
]]
local COPIED_SETTINGS = { "pet", "stance", "fixedRank", "useItems", "groupedSpells", "targetPriority" }
for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
	COPIED_SETTINGS[#COPIED_SETTINGS + 1] = key
end

-- The copy numbers made of a spell's macro, lowest first. Don't modify it.
function ns.MacroCopies(name)
	return ns.db.profile.macroCopies[name] or NO_COPIES
end

-- Whether a macro can be duplicated: a learned spell's own macro or one of its copies, not a rank's.
function ns.OffersDuplicate(macro)
	return not macro.focus and not macro.unlearned and not macro.rank
end

-- Adds the next copy of the macro's spell, starting with the settings the macro has now.
function ns.DuplicateMacro(macro)
	local copies = ns.db.profile.macroCopies
	local list = copies[macro.name] or {}
	local number = (list[#list] or 1) + 1
	list[#list + 1] = number
	copies[macro.name] = list
	local from, to = SettingsKey(macro), macro.name .. " #" .. number
	for _, key in ipairs(COPIED_SETTINGS) do
		local value = SpellSettings(key)[from]
		if type(value) == "table" then
			local slots = {}
			for i, slot in ipairs(value) do
				slots[i] = slot
			end
			value = slots
		end
		SpellSettings(key)[to] = value
	end
end

--[[
	Drops every setting of the macro's own, so it follows its kind's defaults again, as the menu's Delete
	does: a spell's under its settings key, the focus copy among them.
]]
function ns.ResetMacroOptions(macro)
	local key = SettingsKey(macro)
	for _, setting in ipairs(COPIED_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
	SpellSettings("focus")[key] = nil
end

--[[
	Drops the options the macro set for itself, so it follows its kind's defaults again: the middle-click reset
	on a tile or a category's gear. Unlike ns.ResetMacroOptions it keeps the focus copy, which is a macro of its
	own on the page rather than an option, so no WoW macro is left behind un-kept.
]]
function ns.ResetMacroSettings(macro)
	local key = SettingsKey(macro)
	for _, setting in ipairs(COPIED_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
end

--[[
	Hands a spell's settings to the spell that replaced it in its group (see ns.HandOverMacro), setting by
	setting where the new spell has none of its own, and drops the old spell's.
]]
function ns.MoveSpellSettings(from, to)
	for _, key in ipairs(COPIED_SETTINGS) do
		local settings = SpellSettings(key)
		if settings[to] == nil then
			settings[to] = settings[from]
		end
		settings[from] = nil
	end
end

--[[
	Takes a copy off the page and drops its settings. Its WoW macro is left as it is, wherever it sits on the
	bars, so nothing the player placed stops working; the add-on just stops rewriting it.
]]
function ns.RemoveMacroCopy(macro)
	local copies = ns.db.profile.macroCopies
	local list = copies[macro.name] or {}
	for i = #list, 1, -1 do
		if list[i] == macro.copy then
			table.remove(list, i)
		end
	end
	copies[macro.name] = #list > 0 and list or nil
	local key = SettingsKey(macro)
	for _, setting in ipairs(COPIED_SETTINGS) do
		SpellSettings(setting)[key] = nil
	end
end
