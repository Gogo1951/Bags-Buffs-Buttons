local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- General Panel
--------------------------------------------------------------------------------

--[[
    The root page holds add-on-level behavior only. In order: intro, Welcome
    Message, Mini-map Button and /Commands. Every toggle on this page is
    account-wide (ns.db.global). The features' master switches are on each
    add-on's own heading page under it.

    Order values are grouped in spaced blocks so sections can be reordered or
    extended without renumbering their neighbors.
]]
function ns.BuildGeneralOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),

		-- Welcome Message
		spaceWelcome0 = Spacer(10),
		toggleWelcomeMessage = {
			type = "toggle",
			name = L["OPTIONS_WELCOME_MESSAGE"],
			desc = L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"],
			order = 11,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showWelcome
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.showWelcome = value
				end
			end,
		},

		-- Mini-map Button
		toggleMinimapButton = {
			type = "toggle",
			name = L["OPTIONS_MINIMAP_BUTTON"],
			desc = L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"],
			order = 13,
			width = "full",
			get = function()
				return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
			end,
			set = function(_, value)
				ns.ToggleMinimapButton(value)
			end,
		},

		-- /Commands
		spaceCommands0 = Spacer(90),
		headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 91),
		spaceCommands1 = Spacer(92),
		descCommands = Desc(
			GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
			93
		),
		spaceCommands2 = Spacer(94),
		descCommandsRestocker = Desc(
			GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. "  " .. L["RESTOCKER_COMMAND_DESCRIPTION"],
			95
		),
	}

	return {
		type = "group",
		name = L["ADDON_TITLE"],
		args = args,
	}
end
