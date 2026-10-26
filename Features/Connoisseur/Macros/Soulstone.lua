local _, ns = ...

--------------------------------------------------------------------------------
-- Soulstone Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Soulstone",

	-- Selection: single winner by the stone's heal-value column.
	itemTypes = { soulstone = true },
	score = function(data)
		return data.healthValue
	end,

	--[[
	    Warlock conjure resolution (right-click only, no checkUnique because
	    soulstones share a 30-minute cooldown) lives in Tools-Warlocks.lua;
	    called at update time.
	]]
	conjure = function()
		return ns.ResolveWarlockSoulstoneConjure()
	end,
})
