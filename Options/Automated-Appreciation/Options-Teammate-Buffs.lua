local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    "Teammate Buffs" panel -- party/raid buffs & cooldowns cast on you. Two
    sections, as on Stranger Buffs: Praise (what the teammate sees) and
    Notifications (the chat line and sound only you get). The tracked abilities
    live in their own sub-panel (Options-Teammate-Buffs-Tracked.lua). The
    controls come from the shared factories in Options-Automated-Appreciation-Utilities.lua (ns.Define*).

    No cooldown dropdowns here, unlike Strangers: a teammate's cooldown is worth
    acknowledging every single time it lands, so only the outgoing whisper is
    rate-limited, and that happens in the engine rather than as a setting.
]]

function ns.BuildTeammatesOptions()
	local function settings()
		return ns.db.global.teammates
	end

	local options = {
		name = L["TAB_TEAMMATES"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["TEAMMATES_DESCRIPTION"], 1),
			space0 = ns.OptionsSpacer(2),

			--[[
			    Master switch: everything below it hides when off, and the feature
			    itself stops -- see the `enabled` gate in Praise. Its twin sits on
			    Thanks for the Buff's heading page. Fractional orders keep it above
			    the first header without renumbering the panel.
			]]
			enable = ns.OptionsFeatureToggle(ns.GetFeatureSwitch("teammates"), 2.5),
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
			whisperExample = ns.DefineWhisperExample(settings, 9.6, ns.GAME_IDS.SAMPLE_BUFF_SPELL_ID),
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
				local link = ns.GetSpellLink(ns.GAME_IDS.SAMPLE_BUFF_SPELL_ID) or ""
				return ns:BuildTrackedMessage({ type = Data.BUFF.SOLO, detect = Data.DETECT.AURA }, class, name, link)
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
