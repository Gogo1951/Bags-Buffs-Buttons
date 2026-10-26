local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    "Service Alerts" panel -- raid-wide help with no aura on you (feasts, soulwells,
    portals, repair bots). The controls come from Options-Utilities.lua
    (ns.Define*); the tracked list lives in its own sub-panel
    (Options-Service-Alerts-Tracked.lua).

    Same shape as Teammate Buffs -- the Praise / Notifications split, the
    same headers, the same controls -- minus the cooldown dropdowns, which only
    Strangers carries.
]]

function ns.BuildServicesOptions()
	local function settings()
		return ns.db.global.services
	end

	local options = {
		name = L["TAB_SERVICES"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["SERVICES_DESCRIPTION"], 1),
			space0 = ns.OptionsSpacer(2),

			--[[
			    Master switch: everything below it hides when off, and the feature
			    itself stops -- see the `enabled` gate in Praise. Its twin sits on
			    Thanks for the Buff's heading page. Fractional orders keep it above
			    the first header without renumbering the panel.
			]]
			enable = ns.OptionsFeatureToggle(ns.GetFeatureSwitch("services"), 2.5),
			enableSpacer = ns.OptionsSpacer(2.6),

			headerPraise = ns.OptionsHeader(L["PRAISE_HEADER"], 3),
			space1 = ns.OptionsSpacer(4),
			descPraise = ns.OptionsDesc(L["PRAISE_DESCRIPTION"], 4.3),
			spacePraise = ns.OptionsSpacer(4.6),
			emotes = ns.DefineEmotesToggle(settings, 5),
			emoteSpacer = ns.OptionsSpacer(6, ns.EmotesHidden(settings)),
			emoteGroup = ns.DefineEmoteGroup(settings, 7),
			space2 = ns.OptionsSpacer(8),
			whisper = ns.DefineWhisperToggle(settings, 9),
			whisperExampleSpacer = ns.DefineExampleSpacer(settings, "whisperEnabled", 9.3),
			whisperExample = ns.DefineWhisperExample(settings, 9.6, ns.GAME_IDS.SAMPLE_SERVICE_SPELL_ID),
			space3 = ns.OptionsSpacer(10),
			praiseDelay = ns.DefinePraiseDelayToggle(settings, 11),
			praiseDelayLength = ns.DefinePraiseDelaySelect(settings, 12),
			space4 = ns.OptionsSpacer(13),

			headerNotifications = ns.OptionsHeader(L["NOTIFICATIONS_HEADER"], 14),
			space5 = ns.OptionsSpacer(15),
			descNotifications = ns.OptionsDesc(L["NOTIFICATIONS_DESCRIPTION"], 15.3),
			spaceNotifications = ns.OptionsSpacer(15.6),
			printOut = ns.DefinePrintToggle(settings, 16),
			printExampleSpacer = ns.DefineExampleSpacer(settings, "printEnabled", 16.3),
			printExample = ns.DefinePrintExample(settings, 16.6, function(class, name)
				local link = ns.GetSpellLink(ns.GAME_IDS.SAMPLE_SERVICE_SPELL_ID) or ""
				return ns:BuildTrackedMessage({ type = Data.BUFF.SERVICE, opened = true }, class, name, link)
			end),
			space6 = ns.OptionsSpacer(17),
			sound = ns.DefineSoundToggle(settings, 18),
			soundPreview = ns.DefineSoundPreview(ns.PlayBuffSound, 19),
		},
	}

	-- Intro text and the switch itself stay; everything else follows the switch.
	ns.HideAllExcept(options.args, function()
		return not settings().enabled
	end, { descIntro = true, space0 = true, enable = true })

	return options
end
