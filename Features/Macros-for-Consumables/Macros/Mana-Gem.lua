local _, ns = ...

--------------------------------------------------------------------------------
-- Mana Gem Macro
--------------------------------------------------------------------------------

-- Multi-use ranked macro (ns.MULTI_USE_MACRO_TYPES).
ns.RegisterMacroType({
	typeName = "Mana Gem",

	--[[
	    Selection: every Mana Gem, plus Demonic and Dark Runes when the player
	    opts in, ranked by raw mana into topIDs for the stacked /use fallback
	    lines. Runes share the gems' cooldown, so they compete in the same
	    ranked list, and a press still uses exactly one item. Health Potion's
	    Healthstone stacking is the opposite case: there the two cooldowns are
	    separate.
	]]
	itemTypes = { managem = true, manarune = true },
	accepts = function(data)
		if data.itemType ~= "manarune" then
			return true
		end
		local settings = ns.db and ns.db.profile
		return settings and settings.includeManaRunes and true or false
	end,
	score = function(data)
		return data.manaValue
	end,
	ranked = true,

	--[[
	    Mage conjure resolution (single right-click slot, checkUnique
	    downranking) lives in Tools-Mages.lua; called at update time.
	]]
	conjure = function()
		return ns.ResolveMageManaGemConjure()
	end,
})
