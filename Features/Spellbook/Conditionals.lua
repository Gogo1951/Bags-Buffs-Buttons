local _, ns = ...
local L = ns.L
local SpellSettings = ns.SpellSettings
local SettingsKey = ns.SettingsKey

--[[
	A page macro's Conditionals: rows checked top to bottom, each one or two conditions and the spell the macro
	casts in its place when they all match, ahead of everything the macro casts on its own. They are one of the
	per-spell settings (Features/Spellbook/Macro-Options.lua), "conditionals", so a Duplicate copy keeps its own
	and the menu's Delete and the middle-click reset drop them with the rest. Features/Spellbook/Macro-Body.lua
	writes them into the /cast line, and Features/Spellbook/Conditionals-Panel.lua is the panel docked beside the
	Spell Book that sets them.
]]

--------------------------------------------------------------------------------
-- Conditions
--------------------------------------------------------------------------------

--[[
	Every condition a row can check, in the order its dropdown lists them, as { key, the macro conditional it
	writes, its label key, its short label key for the menu's value, its explanation key }. combat marks the two
	a macro's own combat check makes pointless, spec the two only a character with dual spec is offered, and
	opposite the condition that can never match alongside it, which a row's second dropdown leaves out.
]]
ns.CONDITIONS = {
	{
		key = "shift",
		clause = "mod:shift",
		labelKey = "CONDITION_SHIFT",
		shortKey = "CONDITION_SHIFT_SHORT",
		descKey = "CONDITION_SHIFT_DESCRIPTION",
	},
	{
		key = "ctrl",
		clause = "mod:ctrl",
		labelKey = "CONDITION_CTRL",
		shortKey = "CONDITION_CTRL_SHORT",
		descKey = "CONDITION_CTRL_DESCRIPTION",
	},
	{
		key = "alt",
		clause = "mod:alt",
		labelKey = "CONDITION_ALT",
		shortKey = "CONDITION_ALT_SHORT",
		descKey = "CONDITION_ALT_DESCRIPTION",
	},
	{
		key = "rightClick",
		clause = "btn:2",
		labelKey = "CONDITION_RIGHT_CLICK",
		shortKey = "CONDITION_RIGHT_CLICK",
		descKey = "CONDITION_RIGHT_CLICK_DESCRIPTION",
	},
	{
		key = "combat",
		clause = "combat",
		labelKey = "CONDITION_IN_COMBAT",
		shortKey = "CONDITION_IN_COMBAT",
		descKey = "CONDITION_IN_COMBAT_DESCRIPTION",
		combat = true,
		opposite = "noCombat",
	},
	{
		key = "noCombat",
		clause = "nocombat",
		labelKey = "CONDITION_OUT_OF_COMBAT",
		shortKey = "CONDITION_OUT_OF_COMBAT",
		descKey = "CONDITION_OUT_OF_COMBAT_DESCRIPTION",
		combat = true,
		opposite = "combat",
	},
	{
		key = "spec1",
		clause = "spec:1",
		labelKey = "CONDITION_SPEC_1",
		shortKey = "CONDITION_SPEC_1",
		descKey = "CONDITION_SPEC_1_DESCRIPTION",
		spec = true,
		opposite = "spec2",
	},
	{
		key = "spec2",
		clause = "spec:2",
		labelKey = "CONDITION_SPEC_2",
		shortKey = "CONDITION_SPEC_2",
		descKey = "CONDITION_SPEC_2_DESCRIPTION",
		spec = true,
		opposite = "spec1",
	},
}

local BY_KEY = {}
for _, condition in ipairs(ns.CONDITIONS) do
	BY_KEY[condition.key] = condition
end

-- A condition's row in ns.CONDITIONS, by its key, or nil for a key no client knows.
function ns.ConditionRow(key)
	return BY_KEY[key]
end

--[[
	The most rows a macro takes, which is what the panel has room for, and the most conditions a row joins. Every
	row repeats its whole condition, so a full list runs into the macro's 255 bytes well before this.
]]
ns.CONDITIONALS_MAX_ROWS = 8
ns.CONDITIONALS_MAX_CONDITIONS = 2

--[[
	Whether the character has a second talent spec, which [spec:2] needs to ever match: dual spec is on the
	client and learned. A client without the API, or a character with one spec, is offered no Spec conditions.
]]
function ns.HasDualSpec()
	local count
	if C_SpecializationInfo and C_SpecializationInfo.GetNumSpecGroups then
		count = C_SpecializationInfo.GetNumSpecGroups()
	elseif GetNumTalentGroups then
		count = GetNumTalentGroups()
	end
	return (count or 1) >= 2
end

-- Whether a condition is listed in a row's dropdown: every one but the Spec conditions without dual spec.
function ns.OffersCondition(key)
	local condition = BY_KEY[key]
	return condition ~= nil and (not condition.spec or ns.HasDualSpec())
end

--[[
	Why a condition can't be used on a macro, as the line its tooltip explains it with, or nil when it can. The
	combat check in When writes a /stopmacro on the other side of combat, so In Combat would always match and
	Out Of Combat never, or the other way about. Grouped Spells' Right-Click For writes btn:2 clauses of its
	own, and the two never share the right-click: Right-Click For wins, since it is a kind default on buffs, so
	this condition waits until it is turned off (the menu, in turn, won't turn it on while a row uses
	Right-Click).
]]
function ns.ConditionBlockReason(macro, key)
	local condition = BY_KEY[key]
	if not condition then
		return nil
	end
	if condition.combat and ns.CombatCheck(macro) then
		return L["CONDITION_COMBAT_BLOCKED"]
	end
	if key == "rightClick" and ns.IsOptionOn(macro, "groupVersion") then
		return L["CONDITION_RIGHT_CLICK_BLOCKED"]:format(ns.RightClickSpell(macro))
	end
	return nil
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
	Every spell macro offers Conditionals but a focus copy, which shares its spell's settings key and casts only
	on the focus, and a consumable's, which is Connoisseur's.
]]
function ns.OffersConditionals(macro)
	return ns.HasOptions(macro) and not macro.focus
end

local NO_ROWS = {}

--[[
	The macro's rows, in order, each { when = { condition keys }, spell = name or nil, rank = rank text or nil }:
	a row with no spell yet is waiting for one, and writes nothing. Don't modify it; the setters below store a
	fresh list, so a Duplicate copy, which starts with a copy of the list itself, never shares a row with it.
]]
function ns.Conditionals(macro)
	if not ns.OffersConditionals(macro) then
		return NO_ROWS
	end
	local rows = SpellSettings("conditionals")[SettingsKey(macro)]
	return type(rows) == "table" and rows or NO_ROWS
end

-- A copy of the macro's rows, each row and its conditions copied too, for a setter to change and store.
local function CopyRows(macro)
	local rows = {}
	for i, row in ipairs(ns.Conditionals(macro)) do
		local when = {}
		for k, key in ipairs(row.when or NO_ROWS) do
			when[k] = key
		end
		rows[i] = { when = when, spell = row.spell, rank = row.rank }
	end
	return rows
end

local function StoreRows(macro, rows)
	SpellSettings("conditionals")[SettingsKey(macro)] = #rows > 0 and rows or nil
end

-- A row's conditions that this client knows, in order.
local function KnownConditions(row)
	local known = {}
	for _, key in ipairs(row.when or NO_ROWS) do
		if BY_KEY[key] then
			known[#known + 1] = key
		end
	end
	return known
end

-- Why a row writes nothing, as its first condition's ns.ConditionBlockReason, or nil when it can.
function ns.ConditionalRowBlockReason(macro, row)
	for _, key in ipairs(KnownConditions(row)) do
		local reason = ns.ConditionBlockReason(macro, key)
		if reason then
			return reason
		end
	end
	return nil
end

-- Whether a row of the macro checks Right-Click, which keeps Grouped Spells' Right-Click For off.
function ns.ConditionalsUseRightClick(macro)
	for _, row in ipairs(ns.Conditionals(macro)) do
		for _, key in ipairs(row.when or NO_ROWS) do
			if key == "rightClick" then
				return true
			end
		end
	end
	return false
end

-- How many rows have a spell, which the page's note counts ("2 Conditionals").
function ns.ConditionalCount(macro)
	local count = 0
	for _, row in ipairs(ns.Conditionals(macro)) do
		if row.spell then
			count = count + 1
		end
	end
	return count
end

-- What a row casts, as the macro text names it: "Frostbolt", or "Frostbolt(Rank 1)" for a rank's own macro picked.
function ns.ConditionalSpellText(row)
	return row.spell .. (row.rank and "(" .. row.rank .. ")" or "")
end

--[[
	Each row that has a spell, in short words, for the menu's value and the tile's tooltip: "Shift: Frost Nova",
	or "Spec 2 + Alt: Blizzard" for two conditions.
]]
function ns.ConditionalSummaries(macro)
	local summaries = {}
	for _, row in ipairs(ns.Conditionals(macro)) do
		if row.spell then
			local labels = {}
			for i, key in ipairs(KnownConditions(row)) do
				labels[i] = L[BY_KEY[key].shortKey]
			end
			local when = labels[1] or ""
			for i = 2, #labels do
				when = L["CONDITIONALS_JOIN"]:format(when, labels[i])
			end
			summaries[#summaries + 1] = L["CONDITIONALS_SUMMARY"]:format(when, ns.ConditionalSpellText(row))
		end
	end
	return summaries
end

--[[
	The rows as /cast clauses for the macro text, { condition, nil, spell }, in order: "spec:2,mod:alt" and the
	row's spell. Each casts on a plain target, never the macro's Target priority, since every clause would
	repeat the row's whole condition and fill the 255 bytes fast. A row with no spell, no condition this client
	knows, or a condition blocked on this macro (ns.ConditionBlockReason) is left out.
]]
function ns.ConditionalClauses(macro)
	local clauses = {}
	for _, row in ipairs(ns.Conditionals(macro)) do
		local known = KnownConditions(row)
		if row.spell and #known > 0 and not ns.ConditionalRowBlockReason(macro, row) then
			local parts = {}
			for i, key in ipairs(known) do
				parts[i] = BY_KEY[key].clause
			end
			clauses[#clauses + 1] = { table.concat(parts, ","), nil, ns.ConditionalSpellText(row) }
		end
	end
	return clauses
end

--[[
	The setters below only change the stored rows; the panel then rebuilds the page, which rewrites the macro
	(ns.RefreshSpellbookPage), as the menu does.
]]

-- Adds a row at the bottom, checking the first condition offered that the macro can use, with no spell yet.
function ns.AddConditional(macro)
	local rows = CopyRows(macro)
	if #rows >= ns.CONDITIONALS_MAX_ROWS then
		return
	end
	local first = "shift"
	for _, condition in ipairs(ns.CONDITIONS) do
		if ns.OffersCondition(condition.key) and not ns.ConditionBlockReason(macro, condition.key) then
			first = condition.key
			break
		end
	end
	rows[#rows + 1] = { when = { first } }
	StoreRows(macro, rows)
end

function ns.RemoveConditional(macro, index)
	local rows = CopyRows(macro)
	table.remove(rows, index)
	StoreRows(macro, rows)
end

-- Moves the row at from to the place to, the rows between shifting a place to make room.
function ns.MoveConditional(macro, from, to)
	local rows = CopyRows(macro)
	if from == to or not rows[from] or not rows[to] then
		return
	end
	local row = table.remove(rows, from)
	table.insert(rows, to, row)
	StoreRows(macro, rows)
end

--[[
	Sets the condition at a place in a row (1 or 2), or with nil drops the second, so the row checks one
	condition again.
]]
function ns.SetConditionalCondition(macro, index, place, key)
	local rows = CopyRows(macro)
	local row = rows[index]
	if not row then
		return
	end
	if key then
		row.when[math.min(place, #row.when + 1)] = key
	elseif place > 1 then
		row.when[place] = nil
	end
	StoreRows(macro, rows)
end

-- Sets the spell a row casts, by name, and the rank text when it was picked from a rank's own macro.
function ns.SetConditionalSpell(macro, index, name, rank)
	local rows = CopyRows(macro)
	local row = rows[index]
	if not row then
		return
	end
	row.spell, row.rank = name, rank
	StoreRows(macro, rows)
end

--[[
	The spell a page macro gives a row, its name and its rank text (a rank's own macro), or nil for one that can't
	be picked: a consumable's, which is an item, and a spell not learned yet. The Shoot macro gives the attack for
	the ranged weapon worn now.
]]
function ns.ConditionalSpellOf(macro)
	if macro.consumable or macro.unlearned then
		return nil
	end
	if macro.rangedAttacks then
		return ns.CastSpellName(macro), nil
	end
	return macro.name, macro.rank
end
