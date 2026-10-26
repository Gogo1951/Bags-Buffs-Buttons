local _, ns = ...

--[[
    Connoisseur & Restocker's own helpers, used by several of its files: game
    names its strings mention, the quest, skill, pet and merchant shims, and
    the small game-state predicates its macros test.
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

--[[
    A required-reputation standing's label, by its reaction code. No requirement
    is our own word; a standing is the client's, in the player's gender, picked
    the way the reputation pane picks it.
]]
function ns.GetStandingLabel(reaction)
	if not reaction or reaction == 0 then
		return ns.L["RESTOCKER_REPUTATION_ANY"]
	end
	return GetText("FACTION_STANDING_LABEL" .. reaction, UnitSex("player"))
end

--------------------------------------------------------------------------------
-- Quest, Skill, Pet & Merchant API Shims
--------------------------------------------------------------------------------

--[[
    Forever runs on the Retail client, which has dropped these legacy readers
    for namespaced ones that return a table; Era and TBC have only the legacy
    globals. Each shim gives its call sites one shape on all three clients: the
    legacy return order, except the quest reader (a quest ID, nil for a header
    line) and the pet diet reader (a list). The merchant reader's goes as far as
    the eighth value, whether the slot costs something besides gold.

    Spell names need no shim: every call site reads C_Spell.GetSpellName, which
    all three clients ship, and Forever has no GetSpellInfo.
]]
if C_QuestLog and C_QuestLog.GetInfo then
	ns.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local info = C_QuestLog.GetInfo(questIndex)
		if info and not info.isHeader then
			return info.questID
		end
	end
else
	ns.GetNumQuestLogEntries = GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questIndex)
		if not isHeader then
			return questID
		end
	end
end

if C_SkillInfo and C_SkillInfo.GetSkillLineInfo then
	ns.GetNumSkillLines = C_SkillInfo.GetNumSkillLines

	function ns.GetSkillLineInfo(skillIndex)
		local info = C_SkillInfo.GetSkillLineInfo(skillIndex)
		if info then
			return info.name, info.isHeader, not info.isCollapsed, info.rank
		end
	end
else
	ns.GetNumSkillLines = GetNumSkillLines
	ns.GetSkillLineInfo = GetSkillLineInfo
end

if C_PetInfo and C_PetInfo.GetPetFoodTypes then
	ns.GetPetFoodTypes = C_PetInfo.GetPetFoodTypes
else
	function ns.GetPetFoodTypes()
		return { GetPetFoodTypes() }
	end
end

if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
	function ns.GetMerchantItemInfo(index)
		local info = C_MerchantFrame.GetItemInfo(index)
		if info then
			return info.name,
				info.texture,
				info.price,
				info.stackCount,
				info.numAvailable,
				info.isPurchasable,
				info.isUsable,
				info.hasExtendedCost
		end
	end
else
	ns.GetMerchantItemInfo = GetMerchantItemInfo
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
