local _, ns = ...

--------------------------------------------------------------------------------
-- Smart Spell Resolution
--------------------------------------------------------------------------------

--[[
    Best rank first, by requiredLevel: GetSmartSpell walks each list top-down
    and its fallback bottom-up, so the data's row order carries no meaning.
    Sorted once at load; the lists have no two rows at one level, and the
    spell ID settles any that ever do.
]]
local function ByRequiredLevelDescending(a, b)
	if a[2] ~= b[2] then
		return a[2] > b[2]
	end
	return a[1] > b[1]
end

for _, spellList in pairs(ns.CONJURE_SPELLS) do
	table.sort(spellList, ByRequiredLevelDescending)
end

--[[
    The name a /cast line needs. Only a row whose client casts the rank by
    number carries one (see the RECURRING BUG note on WarlockCreateHealthstone),
    and the rank text must be the client's own: word order and grammar differ
    by locale ("7 레벨", "7-й уровень"), so a translated rank word never matches.
]]
local function CastName(spellName, spellID, rankNumber)
	if rankNumber then
		local subtext = C_Spell.GetSpellSubtext(spellID)
		if subtext and subtext ~= "" then
			return spellName .. "(" .. subtext .. ")"
		end
	end
	return spellName
end

--[[
    Picks the highest-rank spell the player knows that the target (or player)
    can still receive. Targeting a friendly player of lower level drops the
    rank down so the conjured item matches their level cap.
]]
function ns.GetSmartSpell(spellList, ignoreTarget, checkUnique)
	if not spellList then
		return nil, 0
	end

	local levelCap = UnitLevel("player")

	if not ignoreTarget and ns.HasFriendlyPlayerTarget() then
		local targetLevel = UnitLevel("target")
		if targetLevel > 0 then
			levelCap = targetLevel
		end
	end

	for _, data in ipairs(spellList) do
		local spellID, requiredLevel, rankNumber = data[1], data[2], data[3]

		local known = ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)

		if known and requiredLevel <= levelCap then
			local shouldSkip = false

			local conjuredItems = checkUnique and ns.CONJURED_ITEM_IDS_BY_SPELL[spellID]
			if conjuredItems then
				for _, conjuredItemID in ipairs(conjuredItems) do
					if C_Item.GetItemCount(conjuredItemID) > 0 then
						shouldSkip = true
						break
					end
				end
			end

			if not shouldSkip then
				local spellName = C_Spell.GetSpellName(spellID)
				if spellName then
					return CastName(spellName, spellID, rankNumber), spellID
				end
			end
		end
	end

	--[[
	    Fallback when no rank matched the level cap (targeting a low-level
	    friend): walk the list bottom-up and use the lowest rank the player
	    actually KNOWS. Players can skip training low ranks, so the list's
	    last entry may be untrained — and /cast of an untrained spell is a
	    silent no-op that would make the conjure click look broken. Knows
	    nothing at all → nil, 0, same as an empty list.
	]]
	for i = #spellList, 1, -1 do
		local spellID, rankNumber = spellList[i][1], spellList[i][3]

		if ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID) then
			local fallbackName = C_Spell.GetSpellName(spellID)
			if fallbackName then
				return CastName(fallbackName, spellID, rankNumber), spellID
			end
		end
	end

	return nil, 0
end
