local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
	A binding cannot be set from an AceConfig panel, so the row shows the key the player bound, or a muted Not
	Bound, and a Set Key button that opens the game's Key Bindings list through ns:OpenKeyBindings
	(Features/Spellbook/Key-Bindings.lua). The binding name comes from Bindings.xml's name attribute; the
	caption is the same BINDING_* string the Key Bindings list prints. ns:OnUpdateBindings repaints this panel
	when the player changes a key.
]]
local KEY_BINDINGS = {
	-- { bindingName, captionKey, descKey }
	{ "MACROSPELLBOOK_TOGGLE", "BINDING_TOGGLE_PAGE", "OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION" },
}

local KEY_LABEL_WIDTH = 1.9
local KEY_STATUS_WIDTH = 0.85
local KEY_BUTTON_WIDTH = 0.55

local function GetBindingStatus(bindingName)
	local key = GetBindingKey(bindingName)
	if not key then
		return GetColor("MUTED") .. NOT_BOUND .. "|r"
	end
	local text = (GetBindingText and GetBindingText(key)) or key
	return GetColor("TEXT") .. text .. "|r"
end

-- Each binding is its row (caption, key, Set Key), then its description under it.
local function AddKeyBindingRows(args, startOrder)
	local order = startOrder

	for index, entry in ipairs(KEY_BINDINGS) do
		local bindingName, captionKey, descKey = entry[1], entry[2], entry[3]

		if index > 1 then
			args["spacerKeyBinding" .. index] = Spacer(order)
			order = order + 1
		end

		args["rowKeyBinding" .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = {
				caption = ns.OptionsRowLabel(GetColor("INFO") .. L[captionKey] .. "|r", 1, KEY_LABEL_WIDTH),
				status = {
					type = "description",
					name = function()
						return GetBindingStatus(bindingName)
					end,
					fontSize = "medium",
					width = KEY_STATUS_WIDTH,
					order = 2,
				},
				setKey = {
					type = "execute",
					name = L["OPTIONS_KEY_SET"],
					desc = L["OPTIONS_KEY_SET_DESCRIPTION"],
					width = KEY_BUTTON_WIDTH,
					order = 3,
					func = function()
						ns:OpenKeyBindings()
					end,
				},
			},
		}
		order = order + 1

		args["descKeyBinding" .. index] = Desc(GetColor("HELP") .. L[descKey] .. "|r", order)
		order = order + 1
	end
end

--------------------------------------------------------------------------------
-- Delete Macros
--------------------------------------------------------------------------------

local DELETE_BUTTON_WIDTH = 1.5

--[[
	A button deleting the Spellbook's macros from one list (ns.DeleteAddonMacros), behind a confirm, and
	greyed out while the list holds none. The panel repaints after, so the button greys out at once.
]]
local function DeleteMacrosButton(general, nameKey, descKey, confirmKey, order)
	return {
		type = "execute",
		name = L[nameKey],
		desc = L[descKey],
		width = DELETE_BUTTON_WIDTH,
		order = order,
		confirm = true,
		confirmText = L[confirmKey],
		disabled = function()
			return ns.CountAddonMacros(general) == 0
		end,
		func = function()
			ns.DeleteAddonMacros(general)
			AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Spellbook)
		end,
	}
end

--------------------------------------------------------------------------------
-- Spellbook Panel
--------------------------------------------------------------------------------

--[[
	The Spellbook's page in the settings tree. Its settings live on the Spellbook itself, so this holds only
	what can't: the master switch, the key that opens it, and the buttons that delete the macros it made.
]]
function ns.BuildSpellbookOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_SPELLBOOK_DESCRIPTION"], 1),
		spaceEnable = Spacer(2),
		toggleSpellbookEnabled = {
			type = "toggle",
			name = L["SPELLBOOK_ENABLE"],
			desc = L["SPELLBOOK_ENABLE_DESCRIPTION"],
			order = 3,
			width = "full",
			get = function()
				return ns.IsSpellbookEnabled()
			end,
			set = function(_, value)
				ns.SetSpellbookEnabled(value)
			end,
		},

		-- Key Bindings: the rows fill 33 onward.
		spacerKeyBindings0 = Spacer(30),
		headerKeyBindings = Header(L["OPTIONS_KEY_BINDINGS_HEADER"], 31),
		spacerKeyBindings1 = Spacer(32),

		-- Delete Macros
		spacerDeleteMacros0 = Spacer(60),
		headerDeleteMacros = Header(L["OPTIONS_DELETE_MACROS_HEADER"], 61),
		spacerDeleteMacros1 = Spacer(62),
		descDeleteMacros = Desc(L["OPTIONS_DELETE_MACROS_DESCRIPTION"], 63),
		spacerDeleteMacros2 = Spacer(64),
		deleteCharacterMacros = DeleteMacrosButton(
			false,
			"OPTIONS_DELETE_CHARACTER_MACROS",
			"OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION",
			"OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM",
			65
		),
		deleteGeneralMacros = DeleteMacrosButton(
			true,
			"OPTIONS_DELETE_GENERAL_MACROS",
			"OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION",
			"OPTIONS_DELETE_GENERAL_MACROS_CONFIRM",
			66
		),
	}
	AddKeyBindingRows(args, 33)
	return {
		type = "group",
		name = L["TAB_SPELLBOOK"],
		args = args,
	}
end
