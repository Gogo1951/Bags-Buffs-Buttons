local _, ns = ...

-- A SPELL_GROUPS spell's macro casting the last spell learned of those ticked in its Grouped Spells menu.

local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey
local NO_SLOTS = ns.NO_SLOTS

--[[
	A spell in a SPELL_GROUPS group (Demon Skin, Demon Armor) offers the group's spells, a focus copy sharing its
	spell's. Ticked, a spell is one the macro may cast; the macro casts the last one learned of those ticked, so
	it moves up as the player trains. Every spell of the group is ticked to start with.
]]
function ns.OffersGroupedSpells(macro)
	return macro.groupMembers ~= nil
end

-- Every spell of the macro's group, in the group's order: the default ticks.
local function GroupNames(macro)
	local names = {}
	for i, member in ipairs(macro.groupMembers) do
		names[i] = member.name
	end
	return names
end

-- The names ticked in the macro's group, in the group's order. Don't modify it.
function ns.GroupedSpells(macro)
	if not ns.OffersGroupedSpells(macro) then
		return NO_SLOTS
	end
	return SpellSettings("groupedSpells")[SettingsKey(macro)] or GroupNames(macro)
end

function ns.IsGroupedSpellOn(macro, name)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked == name then
			return true
		end
	end
	return false
end

-- Whether the macro's group has any spell ticked but its own, which is when the group changes the macro.
function ns.IsGrouped(macro)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked ~= macro.name then
			return true
		end
	end
	return false
end

--[[
	Ticks or unticks a spell of the macro's group. Unticking the last one ticks the macro's own spell again,
	and the whole group ticked is stored as nil, the default.
]]
function ns.ToggleGroupedSpell(macro, name)
	local on = not ns.IsGroupedSpellOn(macro, name)
	local list = {}
	for _, member in ipairs(macro.groupMembers) do
		local ticked = on
		if member.name ~= name then
			ticked = ns.IsGroupedSpellOn(macro, member.name)
		end
		if ticked then
			list[#list + 1] = member.name
		end
	end
	if #list == 0 then
		list[1] = macro.name
	end
	SpellSettings("groupedSpells")[SettingsKey(macro)] = #list < #macro.groupMembers and list or nil
end

--[[
	The spell the macro casts: the Shoot macro's for the ranged weapon equipped (ns.EquippedRangedAttack, in
	Features/Spellbook/Ranged-Attacks.lua); else of its group's ticked
	spells, the last one learned, or its own spell when its group has none of them learned, or it has no group.
]]
function ns.CastSpellName(macro)
	if macro.rangedAttacks then
		return ns.EquippedRangedAttack(macro)
	end
	local cast
	for _, member in ipairs(ns.OffersGroupedSpells(macro) and macro.groupMembers or NO_SLOTS) do
		if member.learned and ns.IsGroupedSpellOn(macro, member.name) then
			cast = member.name
		end
	end
	return cast or macro.name
end
