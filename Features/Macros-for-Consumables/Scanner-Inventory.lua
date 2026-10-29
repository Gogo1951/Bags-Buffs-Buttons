local _, ns = ...

--[[
    Scanner-Inventory -- scans the player's bags and selects the best item per
    macro category, applying scoring, ranking, and usability gates. WHAT each
    category consumes and HOW it scores is declared by the macro definitions
    themselves (itemTypes / accepts / score / ranked / ... — see the
    definition protocol in Features/Macros-for-Consumables/Macros/Engine.lua); this file owns the
    usability gates and the scan loop that dispatches each bag item to every
    matching definition. How two items compare (the RANKING_PRIORITY tiebreak
    ladder) is Features/Macros-for-Consumables/Scanner-Ranking.lua's.
]]

local Ranking = ns.ScanRanking
local best, rankedCandidates = Ranking.best, Ranking.rankedCandidates
local diagnosticCandidates, candidateRecord = Ranking.diagnosticCandidates, Ranking.candidateRecord
local ResetBest, BuildSelectionTables = Ranking.ResetBest, Ranking.BuildSelectionTables
local FillRecord, IsBetter, RetainCandidate = Ranking.FillRecord, Ranking.IsBetter, Ranking.RetainCandidate
local AddRankedCandidate, RankCandidates = Ranking.AddRankedCandidate, Ranking.RankCandidates
local CaptureDiagnosticCandidates = Ranking.CaptureDiagnosticCandidates

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.bestFoodID = nil
ns.bestFoodLink = nil

--------------------------------------------------------------------------------
-- Bag Scanning
--------------------------------------------------------------------------------

local itemCounts = {}
local slotItems = {}
local ignoredTypes = {}

--[[
    The bag walk, published so a second consumer does not have to repeat it.
    itemCounts is stack totals by itemID across bags 0..NUM_BAG_SLOTS; slotItems
    is one hyperlink per itemID, from the first slot holding it; ignoredTypes
    names every category a usable item on either Ignore List would have
    competed in, so the Readiness Report can count it as carried.

    Assigned once here, and wiped-and-refilled in place by every scan, so the
    reference stays valid while the contents do not: these are the LAST scan's
    snapshot and are only current inside the update pass that produced them.
    Read them, never retain them, and never write to them from outside ScanBags.
]]
ns.scannedItemCounts = itemCounts
ns.scannedItemLinks = slotItems
ns.scannedIgnoredTypes = ignoredTypes

function ns.ScanBags()
	--[[
	    Refresh the zone at scan time. A zone change during combat is gated out
	    by the lockdown guard in Core's dispatcher, so ZONE_CHANGED_NEW_AREA
	    never updates the cache mid-fight; reading it here keeps zone-restricted
	    item filtering from running against a stale map after combat drops.
	]]
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	--[[
	    Party/raid-restricted Buff Food, Scrolls, and Pet Food go stale when
	    group composition or the mode dropdown changes — those flip whether a
	    feature is active but have no dedicated UpdateAuraTracking call, so
	    ns.wellFedState and UNIT_AURA registration would otherwise drift.
	    ScanBags is the single point every rescan passes through, so reconcile
	    aura tracking here, before allowBuffFood reads ns.wellFedState below.
	    The snapshot it takes is handed on to ns.FindScrollOverrides, so a scan
	    walks the player's auras once. Nothing between here and that call may
	    take another snapshot: the buffer is shared (see ns.GetPlayerBuffSnapshot).
	]]
	local buffSnapshot = ns.UpdateAuraTracking()

	local playerLevel = ns.cachedPlayerLevel
	local currentMap = ns.cachedMapID
	--[[
	    Arena-only consumables (e.g. Star's Tears) are gated on the live
	    instance type instead of a zone-ID list, so every arena is covered with
	    no map IDs to maintain. IsInInstance is safe on Era (returns "none").
	    ScanBags re-runs on PLAYER_ENTERING_WORLD and ZONE_CHANGED_NEW_AREA, so
	    this refreshes on every arena entry and exit.
	]]
	local inArena = select(2, IsInInstance()) == "arena"
	local firstAidSkill = ns.currentFirstAidSkill or 0
	local alchemySkill = ns.currentAlchemySkill or 0
	local engineeringSkill = ns.currentEngineeringSkill or 0
	local settings = (ns.db and ns.db.profile) or {}
	local itemCache = (ns.db and ns.db.profile.itemCache) or {}

	--[[
	    Testing aid: targeting yourself forces the Food macro into plain-food
	    mode — no scrolls, no buff food, just the best non-buff food. Useful
	    for verifying what the macro picks without re-toggling settings.
	    Scrolls are already suppressed on any friendly-player target (including
	    self) in UpdateMacros, so we only need to disable buff-food here. On
	    Forever the comparison can come back secret, so C_Secrets is asked first
	    and a restricted read counts as not targeting yourself.
	]]
	local targetingSelf = C_Secrets.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")

	--[[
	    Arena rule: scrolls, pet buff food, and buff food cannot be consumed in
	    a PvP Arena, so the Food macro must stay in plain (non-buff) food mode
	    there. Buff-food preference is gated here; the scroll and pet-buff
	    override resolvers are gated below.
	]]
	ns.allowBuffFood = settings.useBuffFood
		and ns.IsModeActive(settings.buffFoodMode)
		and not ns.wellFedState
		and not targetingSelf
		and not inArena

	--[[
	    Use Conjured Food & Water First: the setting and its mode, from the
	    list Buff Food's shares (the default "leveling" means below max level).
	    Group reads join the group signature and a level-up rebuilds every
	    macro, so a mode flipping always rescans. It needs no arena or self-target exception: an arena already
	    leaves only conjured food and water and the arena drinks, and
	    targeting yourself is the buff-food testing aid.
	]]
	ns.allowConjuredFirst = settings.useConjuredFirst and ns.IsModeActive(settings.conjuredFirstMode)

	--[[
	    Use Restock List Food & Water Last: no mode, on whenever ticked. The
	    current list is captured here for FillRecord; every list edit redraws
	    through ns.UpdateRestockList, which requests a rescan while it is on
	    and the list's items have changed.
	]]
	ns.allowRestockLast = settings.useRestockLast
	local restockSettings = ns.restockSettings
	Ranking.SetScanRestockList(
		restockSettings and restockSettings.lists and restockSettings.lists[restockSettings.currentList] or {}
	)

	BuildSelectionTables()

	for _, entry in pairs(best) do
		ResetBest(entry)
	end

	for _, list in pairs(rankedCandidates) do
		wipe(list)
	end

	--[[
	    Wiped unconditionally, not just while diagnostics are enabled, so
	    turning the panel off leaves no stale candidate list behind for the
	    next report to present as current.
	]]
	for _, list in pairs(diagnosticCandidates) do
		wipe(list)
	end

	local dataRetry = false
	wipe(itemCounts)
	wipe(slotItems)
	wipe(ignoredTypes)

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID then
				local id = info.itemID
				itemCounts[id] = (itemCounts[id] or 0) + info.stackCount
				if not slotItems[id] then
					slotItems[id] = info.hyperlink
				end
			end
		end
	end

	--[[
	    Overrides check happens before standard consumable scan. Skipped
	    entirely in a PvP Arena (see the arena rule above): scroll mode and pet
	    buff food can't be used there, so both stay nil and the Food macro keeps
	    its plain food/conjure form.
	]]
	if inArena then
		ns.scrollOverrideIDs = nil
		ns.petBuffOverrideID = nil
	else
		ns.scrollOverrideIDs = ns.FindScrollOverrides(itemCounts, buffSnapshot)
		ns.petBuffOverrideID = ns.FindPetBuffOverride(itemCounts)
	end

	--[[
	    Both halves of the Ignore List hide an item from every macro's selection.
	    An ignored item is still resolved like any other, but where it would
	    compete it only marks its categories in ignoredTypes.
	]]
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	for id, hyperlink in pairs(slotItems) do
		local ignored = characterIgnoreList[id] or globalIgnoreList[id]
		--[[
		    Scroll items skip normal consumable processing; the scroll
		    override system handles them.
		]]
		if not (ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[id]) then
			local data = itemCache[id]
			--[[
			    The cache holds consumables only, so a stored "IGNORE" is
			    stale: clear it and let ns.CacheItemData answer from the
			    consumable tables. Version-stamp invalidation only wipes the
			    cache on a release bump, never on a dev copy, whose version
			    is always "Dev".
			]]
			if data == "IGNORE" then
				data = nil
				itemCache[id] = nil
			end
			--[[
			    Drop cache entries from an older schema so CacheItemData
			    re-derives them below. Test the NEWEST cached field, not an
			    old one: version-stamp invalidation only fires on a release
			    bump, so a same-version update (dev edit) that adds a field
			    would otherwise keep stale entries missing it. The newest
			    field is itemID (CacheItemData always writes it, so == nil
			    only ever means "older schema"); the older fields are kept
			    in the test to also catch pre-maxStack/-arenaUsable/
			    -isConjured/-damageValue/-isSoulbound entries.
			]]
			if
				data
				and (
					data.maxStack == nil
					or data.arenaUsable == nil
					or data.isConjured == nil
					or data.damageValue == nil
					or data.isSoulbound == nil
					or data.itemID == nil
				)
			then
				data = nil
				itemCache[id] = nil
			end
			if not data then
				data = ns.CacheItemData(id)
			end

			if not data then
				dataRetry = true
			elseif data ~= "IGNORE" then
				local usable = true

				if data.requiredLevel > playerLevel then
					usable = false
				end

				if usable and data.requiredFirstAid > 0 and data.requiredFirstAid > firstAidSkill then
					usable = false
				end

				if usable and (data.requiredAlchemy or 0) > 0 and (data.requiredAlchemy or 0) > alchemySkill then
					usable = false
				end

				if
					usable
					and (data.requiredEngineering or 0) > 0
					and (data.requiredEngineering or 0) > engineeringSkill
				then
					usable = false
				end

				--[[
				    Engineering specialization gate (Global Thermal Sapper
				    Charge requires Goblin Engineer). Checked live rather
				    than cached at login because the specialization can be
				    learned mid-session; SPELLS_CHANGED triggers the rescan.
				    Same ns.IsSpellKnown + ns.IsPlayerSpell pair as
				    GetSmartSpell — profession passives can live on either
				    surface depending on client.
				]]
				if usable and data.requiredSpellID then
					local spellID = data.requiredSpellID
					if not (ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)) then
						usable = false
					end
				end

				if usable and data.zones then
					usable = (currentMap ~= nil) and (data.zones[currentMap] == true)
				end

				if usable and data.arenaOnly and not inArena then
					usable = false
				end

				--[[
				    A PvP Arena blocks potions and regular food and drink: of
				    the food and drink, only conjured food/water and the
				    arena-only drinks (Star's Tears/Lament) can be consumed.
				    Healthstones, Mana Gems, bandages and explosives still work.
				    Gate the blocked ones out so the macro never selects an item
				    that fails on press in the arena. Ranking within what
				    survives is unchanged (RANKING_PRIORITY).
				]]
				if usable and inArena then
					local itemType = data.itemType
					local isFoodOrWater = (itemType == "food" or itemType == "water" or itemType == "foodwater")
					if itemType == "potion" or (isFoodOrWater and not data.arenaUsable) then
						usable = false
					end
				end

				if usable then
					local totalCount = itemCounts[id]

					--[[
					    Dispatch the item to every registered definition
					    whose itemTypes set claims its cached itemType.
					    Deliberately not first-match-wins: more than one
					    category may consume the same item — a potion
					    with both health and mana values feeds Health
					    Potion and Mana Potion, and a foodwater hybrid
					    feeds Food and Water.
					]]
					for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
						if
							definition.itemTypes
							and definition.itemTypes[data.itemType]
							and (not definition.accepts or definition.accepts(data))
						then
							local score = definition.score(data)
							if ignored then
								ignoredTypes[definition.typeName] = true
							elseif definition.ranked then
								AddRankedCandidate(definition.typeName, data, score, totalCount)
							else
								local entry = best[definition.typeName]
								--[[
								    allowBuffFood, allowConjuredFirst and
								    allowRestockLast defs track the live
								    scan preferences;
								    everyone else compares with those
								    steps gated off.
								]]
								local allowBuffFood = definition.allowBuffFood and ns.allowBuffFood
								local allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
								local allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
								if
									IsBetter(
										data,
										totalCount,
										data.price,
										entry,
										score,
										allowBuffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								then
									FillRecord(entry, data, totalCount, data.price, score)
									if definition.winnerExtras then
										definition.winnerExtras(entry, data, hyperlink)
									end
								end

								if ns.diagnostics.enabled then
									RetainCandidate(
										definition.typeName,
										FillRecord(candidateRecord, data, totalCount, data.price, score),
										allowBuffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								end
							end
						end
					end
				end
			end
		end
	end

	RankCandidates()
	CaptureDiagnosticCandidates()

	ns.bestFoodID = best["Food"].id
	ns.bestFoodLink = best["Food"].link

	return best, dataRetry
end
