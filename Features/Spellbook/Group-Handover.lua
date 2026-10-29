local _, ns = ...

--[[
	A SPELL_GROUPS spell learned in place of another (Dire Bear Form for Bear Form) taking over the macro the
	other spell had, and noticing a group spell learned or lost with no page open.
]]

local SpellName = ns.SpellName
local NO_IDS = {}

--[[
	The spells a learned spell replaced in its SPELL_GROUPS group: those just before it no longer in the
	spellbook, nearest first, up to the first that still is. Bear Form goes from the book once Dire Bear
	Form is learned, so its WoW macro, wherever the player placed it, would never be rewritten again; the
	new spell takes it over instead (see ns.HandOverMacro). members is the group as { name, learned }.
]]
local function ReplacedSpells(name, members)
	local replaced, at = {}, nil
	for i, member in ipairs(members) do
		if member.name == name then
			at = i
		end
	end
	for i = (at or 1) - 1, 1, -1 do
		if members[i].learned then
			break
		end
		replaced[#replaced + 1] = members[i].name
	end
	return replaced
end

--[[
	Gives a learned spell the WoW macro of the nearest spell it replaced that has one, settings, focus copy and
	Duplicates included, when it has no macro of its own yet. The sync then finds each of those macros by its
	tag, rewrites it to cast the new spell and renames it (see SyncAt in Features/Spellbook/Macro-Sync.lua,
	which reads macro.replaces).
]]
function ns.HandOverMacro(name, replaced)
	for _, from in ipairs(replaced) do
		if ns.HandOverMacroTag(from, name, ns.MacroCopies(from)) then
			ns.MoveSpellSettings(from, name)
			return
		end
	end
end

--[[
	Whether a spell learned since the last build has a replaced spell's macro to take over, read from the
	spell IDs alone, so a spell learned with no page open still rewrites that macro (see RefreshForSpells in
	Features/Spellbook/Spellbook-Events.lua).
]]
function ns.HandOverDue()
	local class = select(2, UnitClass("player"))
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for i = #ids, 2, -1 do
			local to = ns.IsPlayerSpell(ids[i]) and SpellName(ids[i])
			if to and not ns.HasSpellMacroTag(to) then
				for j = i - 1, 1, -1 do
					if ns.IsPlayerSpell(ids[j]) then
						break
					end
					local from = SpellName(ids[j])
					if from and ns.HasSpellMacroTag(from) then
						return true
					end
				end
			end
		end
	end
	return false
end

-- Which of the class's SPELL_GROUPS spells the player knows, as one string of 1s and 0s.
local function GroupSpellsKnown()
	local class = select(2, UnitClass("player"))
	local known = {}
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for _, id in ipairs(ids) do
			known[#known + 1] = ns.IsPlayerSpell(id) and "1" or "0"
		end
	end
	return table.concat(known)
end

local groupSpellsKnown -- as the last call to ns.GroupSpellLearned found them

--[[
	Whether a SPELL_GROUPS spell was learned or lost since the last call, which can move a grouped macro to
	another spell (ns.CastSpellName), so a spell learned with no page open still rewrites it (see
	RefreshForSpells in Features/Spellbook/Spellbook-Events.lua). The first call only takes note.
]]
function ns.GroupSpellLearned()
	local known = GroupSpellsKnown()
	local changed = groupSpellsKnown ~= nil and known ~= groupSpellsKnown
	groupSpellsKnown = known
	return changed
end

ns.ReplacedSpells = ReplacedSpells
