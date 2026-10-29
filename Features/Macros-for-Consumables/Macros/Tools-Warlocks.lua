local _, ns = ...

--------------------------------------------------------------------------------
-- Warlock Conjure Resolution
--------------------------------------------------------------------------------

--[[
    All warlock conjure resolution lives here (organizing rule and resolver
    contract: see Tools-Mages.lua and Engine.lua's definition protocol).

    Both stone families are represented differently per client flavor (Era:
    distinctly-named tiers cast bare; TBC: numeric ranks; WoW Forever: numeric
    ranks for Create Healthstone, a bare cast for Create Soulstone). That split is
    data, NOT code here: each flavor folder's ns.CONJURE_SPELLS rows carry a
    rank only where the client casts it by number, and ns.GetSmartSpell
    (Smart-Spell.lua) pins whatever a row carries. See the RECURRING BUG note on
    WarlockCreateHealthstone in Data/{Game}/Conjure-Spells-{Game}.lua before
    touching rank handling.
]]

--[[
    Right-click creates a healthstone; middle-click summons a Soulwell (TBC+
    ability). Healthstones are unique per tier, so GetSmartSpell runs with
    checkUnique=true: once a tier is in bags the next press conjures the rank
    below it instead of failing on a duplicate. Target downranking stays on
    (ignoreTarget=false) so a lower-level friendly target still gets a stone
    they can use. A warlock who hasn't learned Create Healthstone yet gets
    the missing-spell tip on click instead.
]]
function ns.ResolveWarlockHealthstoneConjure()
	if not ns.isWarlock then
		return nil
	end

	local info = {}

	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateHealthstone) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateHealthstone, false, true)
	else
		info.rightMiss = "noCreateHealthstone"
		info.noItemMiss = "noCreateHealthstone"
	end

	--[[
	    The Soulwell serves the whole raid, so ignoreTarget keeps a
	    low-level friendly target from downranking it; the unpinned
	    /cast always fires the highest rank known. A flavor whose folder has
	    no Ritual of Souls rows writes no middle-click at all.
	]]
	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulwell) then
		info.middleName, info.middleID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateSoulwell, true)
	elseif #ns.CONJURE_SPELLS.WarlockCreateSoulwell > 0 then
		info.middleMiss = "noRitualOfSouls"
	end

	return info
end

--[[
    Right-click only, always the best known conjure. No checkUnique downgrade
    here (unlike Healthstones): soulstones share a 30-minute use cooldown that
    matches the buff duration, so only one stone can ever be deployed at a
    time — conjuring a lower rank while holding the best one would just waste a
    soul shard. Right-clicking while holding the stone gets the game's own
    "You already have one of those" error; the add-on prints nothing. Target
    downranking stays off (ignoreTarget=true): the best known rank already
    satisfies the max-target-level caps (see WarlockCreateSoulstone in the
    flavor folder's Conjure-Spells-{Game}.lua). Lowest rank unlocks at level
    18, so a 1-17 warlock sees the missing-spell tip on both right-click (where
    they expected the conjure) and left-click (since they almost certainly
    don't have a Soulstone item to /use).
]]
function ns.ResolveWarlockSoulstoneConjure()
	if not ns.isWarlock then
		return nil
	end

	local info = {}

	if ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulstone) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.WarlockCreateSoulstone, true, false)
	else
		info.rightMiss = "noCreateSoulstone"
		info.noItemMiss = "noCreateSoulstone"
	end

	return info
end
