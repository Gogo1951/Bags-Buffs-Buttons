local _, ns = ...
local GetSetting = ns.GetMacroSetting
local StoreSetting = ns.StoreMacroSetting
local NO_SLOTS = ns.NO_SLOTS

--[[
	A macro's target priority, one of its options. The rest of them, and the per-spell settings this reads and
	writes, are Features/Spellbook/Macro-Options.lua, which loads first.
]]

--------------------------------------------------------------------------------
-- Target Priority
--------------------------------------------------------------------------------

--[[
	Who a macro casts on, in turn: a list of up to TARGET_PRIORITY_SLOTS units ("targetPriority"), each tried
	only when it can take the spell, then a plain cast. Each unit is { unit, menu label key }, in the order the
	Target submenu lists them. A macro follows its kind's list (kindDefaults[kind].targetPriority) until it is
	given its own. A list nobody set is the target alone.
]]
ns.TARGET_UNITS = {
	{ "target", "MENU_UNIT_TARGET" },
	{ "player", "MENU_UNIT_SELF" },
	{ "pet", "MENU_UNIT_PET" },
	{ "focus", "MENU_UNIT_FOCUS" },
	{ "targettarget", "MENU_UNIT_TARGETS_TARGET" },
	{ "mouseover", "MENU_UNIT_MOUSEOVER" },
}
ns.TARGET_PRIORITY_SLOTS = 3

local DEFAULT_PRIORITY = { "target" }
--[[
	The units a kind can't pick: an enemy spell can't go on the player or the pet, nor a resurrection, which
	can't raise the player casting it or a pet, nor reach the target's target of a dead target
]]
local LEFT_OUT_UNITS = {
	enemy = { player = true, pet = true },
	resurrect = { player = true, pet = true, targettarget = true },
}

--[[
	Whether a kind's macros cast on someone, so take a target priority: a spell cast on an enemy, a friend,
	a dead friend or either. Ground spells, forms and the rest have no one to pick.
]]
local PRIORITY_KINDS = { enemy = true, friendly = true, buff = true, resurrect = true, anyone = true }

function ns.KindOffersTargetPriority(kind)
	return PRIORITY_KINDS[kind] == true
end

-- Whether a unit can be picked for a kind (see LEFT_OUT_UNITS), and never the focus without one.
function ns.KindOffersUnit(kind, unit)
	if unit == "focus" and ns.FLAVOR == "Vanilla" then
		return false
	end
	return not (LEFT_OUT_UNITS[kind] and LEFT_OUT_UNITS[kind][unit])
end

-- A macro's own list, a focus copy keeping its own focus-then-target cast.
function ns.OffersTargetPriority(macro)
	return not macro.focus and ns.KindOffersTargetPriority(macro.kind)
end

-- A list with the units a kind can't pick, and any unit a second time, left out; the target alone when that leaves none.
local function Usable(list, kind)
	local usable, seen = {}, {}
	for _, unit in ipairs(list) do
		if not seen[unit] and ns.KindOffersUnit(kind, unit) then
			seen[unit] = true
			usable[#usable + 1] = unit
		end
	end
	return #usable > 0 and usable or DEFAULT_PRIORITY
end

-- A kind's list: the one set as its default from a macro's menu, or the target alone.
function ns.KindTargetPriority(kind)
	local list = ns.db.profile.kindDefaults[kind].targetPriority
	if type(list) ~= "table" then
		return DEFAULT_PRIORITY
	end
	return Usable(list, kind)
end

function ns.SetKindTargetPriority(kind, list)
	ns.db.profile.kindDefaults[kind].targetPriority = list
end

-- The macro's list, in order. Don't modify it.
function ns.TargetPriority(macro)
	if not ns.OffersTargetPriority(macro) then
		return NO_SLOTS
	end
	local own = GetSetting(macro, "targetPriority")
	if type(own) == "table" then
		return Usable(own, macro.kind)
	end
	return ns.KindTargetPriority(macro.kind)
end

-- Whether the macro tries a unit, such as the mouseover, which rewrites its Dynamic Rank as that unit changes.
function ns.TriesUnit(macro, unit)
	for _, tried in ipairs(ns.TargetPriority(macro)) do
		if tried == unit then
			return true
		end
	end
	return false
end

-- Whether the macro's list is anything but the target alone, which is just the plain cast.
function ns.HasTargetPriority(macro)
	local list = ns.TargetPriority(macro)
	return #list > 1 or (list[1] ~= nil and list[1] ~= "target")
end

-- Whether two lists hold the same units in the same order.
local function SameList(a, b)
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

--[[
	A list with unit picked at a place in it, from 1: a unit taken lower down moves up to this place, the one
	it replaces and those after it move down a place (the last drops off past three), and nil (None, never
	for the first) ends the list here.
]]
local function PlaceUnit(current, place, unit)
	local list = {}
	for i, tried in ipairs(current) do
		if i < place and tried ~= unit then
			list[#list + 1] = tried
		end
	end
	if unit then
		list[#list + 1] = unit
		for i, tried in ipairs(current) do
			if i >= place and tried ~= unit and #list < ns.TARGET_PRIORITY_SLOTS then
				list[#list + 1] = tried
			end
		end
	end
	return list
end

--[[
	Picks the unit at a place in the macro's list (see PlaceUnit). Stored only where it differs from the kind's
	list.
]]
function ns.SetTargetPriorityUnit(macro, place, unit)
	local list = PlaceUnit(ns.TargetPriority(macro), place, unit)
	StoreSetting(macro, "targetPriority", not SameList(list, ns.KindTargetPriority(macro.kind)) and list or nil)
end

-- Makes the macro's list its kind's, and has the macro follow it.
function ns.MakeTargetPriorityDefault(macro)
	local list = {}
	for i, unit in ipairs(ns.TargetPriority(macro)) do
		list[i] = unit
	end
	ns.SetKindTargetPriority(macro.kind, list)
	StoreSetting(macro, "targetPriority", nil)
end
