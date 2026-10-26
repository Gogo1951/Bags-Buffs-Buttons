local _, ns = ...
local L = ns.L

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
	WoW's binding system reads only globals, so the binding costs two: Bindings.xml can only call a global
	function, and the Key Bindings list labels a binding with the BINDING_NAME_<name> global matching its
	name attribute. Bindings.xml itself is found at the add-on root by the client and is never listed in the
	TOC.

	The name attribute is also what the client saves a player's key against, so a shipped binding keeps its
	name for good: a renamed one comes back unbound for everyone who had set it.
]]

BINDING_NAME_MACROSPELLBOOK_TOGGLE = L["BINDING_TOGGLE_PAGE"]

-- Opens or closes the page through whichever host this client loaded.
function BagsBuffsButtons_ToggleSpellbook()
	if ns.ToggleSpellbookPage then
		ns.ToggleSpellbookPage()
	end
end

--------------------------------------------------------------------------------
-- Opening Key Bindings
--------------------------------------------------------------------------------

--[[
	The Spellbook panel's Set Key button. The clients disagree on how the game's Key Bindings list is reached,
	so the routes are tried in order, at click time rather than at load, since a Settings category can
	register after login:

	  1. Settings.KEYBINDINGS_CATEGORY_ID, where the client names it outright.
	  2. The Settings panel's own category list, searched for the category carrying the game's Key Bindings
	     title (KEY_BINDINGS, or SETTINGS_KEYBINDINGS_LABEL where that's the one in use).
	  3. The older standalone KeyBindingFrame, loaded on demand.

	When nothing works, a chat line says where to find the list by hand. The Diagnostic Tools API report has
	a row for each route, so a bug report says which one the client took.
]]
local function FindKeyBindingsCategoryID()
	if Settings and Settings.KEYBINDINGS_CATEGORY_ID then
		return Settings.KEYBINDINGS_CATEGORY_ID
	end

	if not (SettingsPanel and SettingsPanel.GetCategoryList) then
		return nil
	end

	local list = SettingsPanel:GetCategoryList()
	local categories = list and list.GetAllCategories and list:GetAllCategories()
	for _, category in ipairs(categories or {}) do
		local name = category.GetName and category:GetName()
		if name and (name == KEY_BINDINGS or name == SETTINGS_KEYBINDINGS_LABEL) and category.GetID then
			return category:GetID()
		end
	end
	return nil
end

--[[
	The fallback line names the menus by the client's own labels, so it matches what the player sees in every
	locale. All three clients label the list SETTINGS_KEYBINDINGS_LABEL; KEY_BINDINGS stands in where that is
	missing.
]]
local KEY_BINDINGS_LABEL = SETTINGS_KEYBINDINGS_LABEL ~= nil and SETTINGS_KEYBINDINGS_LABEL or KEY_BINDINGS

function ns:OpenKeyBindings()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_KEY_BINDINGS_IN_COMBAT"])
		return
	end

	local categoryId = FindKeyBindingsCategoryID()
	if categoryId and Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(categoryId)
		return
	end

	if not KeyBindingFrame and type(KeyBindingFrame_LoadUI) == "function" then
		KeyBindingFrame_LoadUI()
	end
	if type(KeyBindingFrame) == "table" and type(ShowUIPanel) == "function" then
		ShowUIPanel(KeyBindingFrame)
		return
	end

	ns:PrintMessage(L["KEY_BINDINGS_LOCATION"]:format(GAMEMENU_OPTIONS, KEY_BINDINGS_LABEL))
end

--[[
	UPDATE_BINDINGS. The Spellbook panel shows the binding's key or Not Bound, and the player changes it in the
	game's own Key Bindings list, so repaint the panel when they come back from it.
]]
function ns:OnUpdateBindings()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Spellbook)
end
