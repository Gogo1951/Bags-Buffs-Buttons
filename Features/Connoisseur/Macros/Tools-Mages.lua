local _, ns = ...

--------------------------------------------------------------------------------
-- Mage Conjure Resolution
--------------------------------------------------------------------------------

--[[
    All mage conjure resolution lives here (the organizing rule: the definition
    files in Features/Macros/<Consumable>.lua own what the macro IS; the
    Tools-<Class> files own what the class KNOWS). Each resolver returns the
    conjure-info table documented in Engine.lua's definition protocol, or nil
    to mean "this macro has no conjure semantics for this character" — which is
    how non-mage classes fall through to a plain /use body. The matching
    definition files (Food.lua, Water.lua, Mana-Gem.lua) call these at update
    time — never at load time — so TOC order between this file and the
    definitions does not matter.
]]

--[[
    Water and Food share a middle-click slot (Refreshment Table), so their
    resolver branching is identical except for which "primary" conjure
    category drives the right-click slot — hence this one shared helper
    parameterized by the right-click list and its miss key.
]]
function ns.ResolveMageWaterOrFoodConjure(rightList, rightMissKey)
	if not ns.isMage then
		return nil
	end

	local info = {}

	if ns.KnowsAny(rightList) then
		info.rightName, info.rightID = ns.GetSmartSpell(rightList)
	else
		--[[
		    Mage who can theoretically learn this — print a tip on
		    right-click (and also on left-click when bags are empty).
		]]
		info.rightMiss = rightMissKey
		info.noItemMiss = rightMissKey
	end

	--[[
	    Middle-click: Ritual of Refreshment is a level-70 ability (Rank 2
	    at 80 in Wrath). The table serves the whole raid, so ignoreTarget
	    keeps a low-level friendly target from downranking it, and the
	    unpinned /cast always fires the highest rank known. A mage who
	    hasn't learned it yet gets the "you don't know Ritual of
	    Refreshment" tip on middle-click. A flavor whose folder has no
	    Ritual of Refreshment rows writes no middle-click at all, so there
	    middle-click does what left-click does.
	]]
	if ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateTable) then
		info.middleName, info.middleID = ns.GetSmartSpell(ns.CONJURE_SPELLS.MageCreateTable, true)
	elseif #ns.CONJURE_SPELLS.MageCreateTable > 0 then
		info.middleMiss = "noRitualOfRefreshment"
	end

	return info
end

--[[
    Mage conjure: single conjure slot on right-click. Unique-equipped
    items mean GetSmartSpell needs checkUnique=true so a second press
    conjures the next rank down rather than failing on a duplicate.
]]
function ns.ResolveMageManaGemConjure()
	if not ns.isMage then
		return nil
	end

	local info = {}
	if ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateManaGem) then
		info.rightName, info.rightID = ns.GetSmartSpell(ns.CONJURE_SPELLS.MageCreateManaGem, true, true)
	else
		info.rightMiss = "noConjureManaGem"
		--[[
		    Mana Gems are class-exclusive; a mage without the spell almost
		    certainly has no Mana Gem in bags either, so left-click should
		    explain that rather than the generic "no item found" message.
		]]
		info.noItemMiss = "noConjureManaGem"
	end
	return info
end
