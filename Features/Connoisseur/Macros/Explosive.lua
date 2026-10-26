local _, ns = ...

--------------------------------------------------------------------------------
-- Explosive Macro
--------------------------------------------------------------------------------

--[[
    The Explosive macro fires in one of two click layouts (the
    explosivesClickMode setting): one button self-targets via [@player],
    setting the charge off at the player's feet with no targeting reticle
    (the melee case), and the other performs the standard toss with the
    normal reticle. Keybind presses register as left-click, so "atplayer"
    also makes keybinds drop at the player's feet.
]]
local function GetExplosiveClickMode()
	local settings = ns.db and ns.db.profile
	if settings and settings.explosivesClickMode == "toss" then
		return "toss"
	end
	return "atplayer"
end

local function BuildExplosiveUseLine(itemID)
	if GetExplosiveClickMode() == "toss" then
		return "/use [btn:2,@player] item:" .. itemID .. "; item:" .. itemID
	end
	return "/use [btn:2] item:" .. itemID .. "; [@player] item:" .. itemID
end

ns.RegisterMacroType({
	typeName = "Explosive",

	-- Selection: ranked by minimum damage; ties fall to the standard ladder.
	itemTypes = { explosive = true },
	score = function(data)
		return data.damageValue
	end,

	buildUseLine = BuildExplosiveUseLine,

	--[[
	    The click layout shapes the body, so it must live in the state key:
	    flipping the dropdown rewrites the macro.
	]]
	stateExtras = function(parts, itemID)
		if itemID then
			parts[#parts + 1] = "EX:" .. GetExplosiveClickMode()
		end
	end,
})
