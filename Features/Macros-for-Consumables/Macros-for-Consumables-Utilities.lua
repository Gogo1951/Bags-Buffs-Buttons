local _, ns = ...

--[[
    The consumable macros' own helpers, used by several of their files: game
    names their strings mention, and the small game-state predicates the macros
    test.
]]

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

-- The client's names for game records our strings mention, read by ID (Style Guide → GAME NAMES).

function ns.GetWellFedName()
	return C_Spell.GetSpellName(ns.WELL_FED_SPELL_ID) or ""
end

-- The First Aid skill line's name, as the skill list shows it.
function ns.GetFirstAidName()
	return C_TradeSkillUI.GetTradeSkillDisplayName(ns.FIRST_AID_SKILL_LINE_ID) or ""
end

--------------------------------------------------------------------------------
-- Game-State Predicates
--------------------------------------------------------------------------------

--[[
    The level cap on this client, which the Leveling and Max Level modes
    compare against: the smaller of the expansion's cap and the player's own,
    the rule Blizzard's GameRulesUtil.GetEffectiveMaxLevelForPlayer applies on
    all three clients, which ship both readers. Show Connoisseur Context prints
    what each answers.
]]
function ns.GetMaxPlayerLevel()
	return math.min(GetMaxLevelForPlayerExpansion(), GetMaxPlayerLevel())
end

--[[
    The group-mode settings' shared test, behind every when-to-use dropdown
    (Buff Food, Scroll Buffs, Pet Food Buffs, and Use Conjured Food & Water
    First), which all offer the same six modes. Every group read here must
    stay inside the group signature (ns.GroupSignatureChanged), or a join or
    leave never rescans. The level modes need no signature: PLAYER_LEVEL_UP
    already refreshes ns.cachedPlayerLevel and rebuilds every macro, and
    leveling means below the client's own max level (ns.GetMaxPlayerLevel),
    never a hard-coded one. An unknown mode counts as active.
]]
function ns.IsModeActive(mode)
	if mode == "always" then
		return true
	end
	if mode == "party" then
		return IsInGroup()
	end
	if mode == "raid" then
		return IsInRaid()
	end
	if mode == "solo" then
		return not IsInGroup()
	end
	if mode == "leveling" or mode == "maxlevel" then
		local atMaxLevel = (ns.cachedPlayerLevel or UnitLevel("player")) >= ns.GetMaxPlayerLevel()
		if mode == "maxlevel" then
			return atMaxLevel
		end
		return not atMaxLevel
	end
	return true
end

function ns.KnowsAny(spellList)
	if not spellList then
		return false
	end
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return true
		end
	end
	return false
end
