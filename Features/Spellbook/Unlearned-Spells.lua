local _, ns = ...

--[[
	The class spells the player hasn't learned yet, for the page's Show Unlearned Spells option. Classic Era,
	TBC and Forever only: their class trainers teach spell ranks the bundled data lists. MoP Classic and Retail
	leave this file out of their TOCs.
]]

-- The rank in a spell's subtext ("Rank 2"), or nil for a spell without ranks.
local function RankOf(id)
	local subtext = C_Spell.GetSpellSubtext(id)
	return subtext and tonumber(subtext:match("%d+"))
end

--[[
	Whether a spell isn't rank 1: its subtext says a higher rank, or it requires its own previous rank. Nil
	while a required spell's name isn't loaded.
]]
local function IsHigherRank(spell, name)
	if (RankOf(spell.id) or 1) > 1 then
		return true
	end
	for _, id in ipairs(spell.requires or {}) do
		local required = ns.SpellName(id)
		if not required then
			return nil
		end
		if required == name then
			return true
		end
	end
	return false
end

--[[
	Calls fn(name, icon, id, level, talent) for the rank 1 of every class trainer spell whose name isn't in
	learned: the bundled ones (Data/) by level, then the ones this character's trainers offered
	(Trainer-Recording.lua), then the class lists' extraSpells. level is the row's learn level, nil for an
	extraSpells entry; talent is true for a row Data/ marks as a talent. Data/ includes the rank 1 of each
	talent that has trainer ranks, so those talents show until learned; talents without trainer ranks need an
	extraSpells entry.
	Spells whose data isn't loaded yet are skipped: the page refreshes on SPELL_DATA_LOAD_RESULT.
]]
function ns.ForEachUnlearnedSpell(fn, learned)
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	local seen = {}
	local spells = {}
	local recorded = ns.RecordedTrainerSpells and ns.RecordedTrainerSpells() or {}
	for _, list in ipairs({ ns.TRAINER_SPELLS[select(2, UnitClass("player"))] or {}, recorded }) do
		for _, spell in ipairs(list) do
			spells[#spells + 1] = spell
		end
	end
	-- rows carry their level; the lowest level row of a spell is its rank 1
	table.sort(spells, function(a, b)
		return a.level < b.level
	end)
	for _, entry in ipairs(ns.ClassExtraSpells()) do
		spells[#spells + 1] = { id = type(entry) == "table" and entry[1] or entry }
	end
	for _, spell in ipairs(spells) do
		if (not spell.faction or spell.faction == faction) and (not spell.race or spell.race == race) then
			local name = ns.SpellName(spell.id)
			if name and not seen[name] then
				local higherRank = IsHigherRank(spell, name)
				if higherRank == false then
					seen[name] = true
					if not learned[name] and not C_Spell.IsSpellPassive(spell.id) then
						fn(name, C_Spell.GetSpellTexture(spell.id), spell.id, spell.level, spell.talent == true)
					end
				end
			end
		end
	end
end
