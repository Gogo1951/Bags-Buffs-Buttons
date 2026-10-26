local _, ns = ...
local L = ns.L

local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Thanks for the Buff Panel
--------------------------------------------------------------------------------

--[[
    Thanks for the Buff's heading page in the settings tree: what it does, then
    every one of its features' master switches (ns.FEATURE_SWITCHES), two to a
    line. Each feature's panel sits under it and draws its own switch again on
    top; flipping either copy repaints both.
]]
function ns.BuildThanksForTheBuffOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_TFTB_DESCRIPTION"], 1),
		spaceFeatures = Spacer(2),
	}
	local toggles = {}
	for _, feature in ipairs(ns.FEATURE_SWITCHES) do
		toggles[#toggles + 1] = ns.OptionsFeatureToggle(feature)
	end
	ns.OptionsTogglePairs(args, "rowFeatures", 2, toggles)
	return {
		type = "group",
		name = L["TAB_THANKS_FOR_THE_BUFF"],
		args = args,
	}
end
