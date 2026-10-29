local _, ns = ...

--------------------------------------------------------------------------------
-- Bandage Macro
--------------------------------------------------------------------------------

-- Standard single-item macro; the engine's default body needs no hooks.
ns.RegisterMacroType({
	typeName = "Bandage",

	--[[
	    Selection: best bandage by raw heal; the BG-only bandages win ties
	    through the ladder's hasZones step.
	]]
	itemTypes = { bandage = true },
	score = function(data)
		return data.healthValue
	end,
})
