local _, ns = ...
local L = ns.L

--[[
    "Stranger Buffs" panel -- a helpful buff on you from a player outside
    your group. Two sections: Praise (what the buffer sees you send back, and the
    limits on it) and Notifications (the chat line and sound only you get). The
    controls themselves come from the shared factories in Options-Automated-Appreciation-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------

function ns.BuildStrangersOptions()
	local function settings()
		return ns.db.global.strangers
	end

	local options = {
		name = L["TAB_STRANGERS"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["STRANGERS_DESCRIPTION"], 1),
			space0 = ns.OptionsSpacer(2),

			--[[
			    Master switch: everything below it hides when off, and the feature
			    itself stops -- see the `enabled` gate in Praise. Its twin sits on
			    Thanks for the Buff's heading page. Fractional orders keep it above
			    the first header without renumbering the panel.
			]]
			enable = ns.OptionsFeatureToggle(ns.GetFeatureSwitch("strangers"), 2.5),
			enableSpacer = ns.OptionsSpacer(2.6),

			headerPraise = ns.OptionsHeader(L["PRAISE_HEADER"], 3),
			space1 = ns.OptionsSpacer(4),
			descPraise = ns.OptionsDesc(L["PRAISE_DESCRIPTION"], 4.3),
			spacePraise = ns.OptionsSpacer(4.6),
			emotesStrangers = ns.DefineEmotesToggle(settings, 5),
			emoteSpacer = ns.OptionsSpacer(6, ns.EmotesHidden(settings)),
			strangersEmoteGroup = ns.DefineEmoteGroup(settings, 7),
			space2 = ns.OptionsSpacer(8),
			whisperStrangers = ns.DefineWhisperToggle(settings, 9),
			whisperExampleSpacer = ns.DefineExampleSpacer(settings, "whisperEnabled", 9.3),
			whisperExample = ns.DefineWhisperExample(settings, 9.6, ns.GAME_IDS.SAMPLE_BUFF_SPELL_ID),
			space3 = ns.OptionsSpacer(10),
			-- Dropdowns over Data.SECONDS_CHOICES, the scale that explains its own steps.
			praiseCooldownStrangersLabel = ns.OptionsRowLabel(L["STRANGERS_OVERALL_COOLDOWN"], 11),
			praiseCooldownStrangers = ns.DefineSecondsSelect(
				settings,
				"praiseCooldown",
				11.1,
				L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"]
			),
			space4 = ns.OptionsSpacer(12),
			cooldownStrangersLabel = ns.OptionsRowLabel(L["STRANGERS_SOURCE_COOLDOWN"], 13),
			cooldownStrangers = ns.DefineSecondsSelect(
				settings,
				"cooldown",
				13.1,
				L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"]
			),
			space5 = ns.OptionsSpacer(14),
			minDurationStrangersLabel = ns.OptionsRowLabel(L["STRANGERS_MIN_DURATION"], 15),
			minDurationStrangers = ns.DefineSecondsSelect(
				settings,
				"minBuffDuration",
				15.1,
				L["STRANGERS_MIN_DURATION_DESCRIPTION"]
			),
			space6 = ns.OptionsSpacer(16),
			--[[
			    Praise Delay closes the section, matching Teammate Buffs and
			    Service Alerts, where it is already the last praise control.
			]]
			praiseDelayStrangers = ns.DefinePraiseDelayToggle(settings, 17),
			praiseDelayLengthStrangers = ns.DefinePraiseDelaySelect(settings, 18),
			space7 = ns.OptionsSpacer(19),

			headerNotifications = ns.OptionsHeader(L["NOTIFICATIONS_HEADER"], 20),
			space8 = ns.OptionsSpacer(21),
			descNotifications = ns.OptionsDesc(L["NOTIFICATIONS_DESCRIPTION"], 21.3),
			spaceNotifications = ns.OptionsSpacer(21.6),
			printStrangers = ns.DefinePrintToggle(settings, 22),
			printExampleSpacer = ns.DefineExampleSpacer(settings, "printEnabled", 22.3),
			printExample = ns.DefinePrintExample(settings, 22.6, function(class, name)
				return ns:BuildStrangerMessage(class, name, ns.GetSpellLink(ns.GAME_IDS.SAMPLE_BUFF_SPELL_ID) or "")
			end),
			space9 = ns.OptionsSpacer(23),
			soundStrangers = ns.DefineSoundToggle(settings, 24),
			soundPreviewStrangers = ns.DefineSoundPreview(ns.PlayBuffSound, 25),
		},
	}

	-- Intro text and the switch itself stay; everything else follows the switch.
	ns.HideAllExcept(options.args, function()
		return not settings().enabled
	end, { descIntro = true, space0 = true, enable = true })

	return options
end
