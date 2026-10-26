local _, ns = ...
local L = ns.L

local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Connoisseur Panel
--------------------------------------------------------------------------------

--[[
    Connoisseur's heading page in the settings tree: what it does, then its
    features' master switches, two to a line. Macros and Readiness Report sit
    under it; each draws its own switch again atop its panel, and the two
    copies share one setter (ns.OptionsFeatureSwitch).
]]
function ns.BuildConnoisseurOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_CONNOISSEUR_DESCRIPTION"], 1),
		spaceFeatures = Spacer(2),
	}
	ns.OptionsTogglePairs(args, "rowFeatures", 2, {
		ns.OptionsFeatureSwitch("Macros"),
		ns.OptionsFeatureSwitch("ReadinessReport"),
	})
	return {
		type = "group",
		name = L["TAB_CONNOISSEUR"],
		args = args,
	}
end
