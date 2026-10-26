local _, ns = ...

--------------------------------------------------------------------------------
-- Healthstone Macro
--------------------------------------------------------------------------------

-- Multi-use ranked macro (ns.MULTI_USE_MACRO_TYPES).
ns.RegisterMacroType({
	typeName = "Healthstone",

	--[[
	    Selection: ranked by raw heal into topIDs (also consumed by Health
	    Potion's healthstone-stacking hook).
	]]
	itemTypes = { healthstone = true },
	score = function(data)
		return data.healthValue
	end,
	ranked = true,

	--[[
	    Warlock conjure resolution (Create Healthstone right-click with
	    checkUnique tier-skip, Soulwell middle-click) lives in
	    Tools-Warlocks.lua; called at update time.
	]]
	conjure = function()
		return ns.ResolveWarlockHealthstoneConjure()
	end,
})
