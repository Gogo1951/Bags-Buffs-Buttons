local ADDON_NAME, ns = ...

--[[
	Adds the page's tab to the Retail-engine spellbook (Blizzard_PlayerSpells): a launcher that toggles the
	page's window (Features/Spellbook-Window.lua), lit while the window is open. Features/Spellbook-Tabs.lua
	owns the tab and its placement.
]]

local ICON_ADDON = ns.ICON_ADDON

local SpellbookTabs = ns.SpellbookTabs

SpellbookTabs:RegisterTab(ADDON_NAME, {
	name = ns.L["ADDON_TITLE"],
	description = ns.L["SPELLBOOK_TAB_DESCRIPTION"],
	hint = { ns.L["TOOLTIP_KEY_CLICK"], ns.L["TOOLTIP_ACTION_OPEN_PAGE"] },
	icon = ICON_ADDON,
	onClick = ns.ToggleSpellbookWindow,
	isSelected = ns.IsSpellbookWindowShown,
})

ns.OnSpellbookWindowToggled(function()
	SpellbookTabs:RequestSync()
end)

--[[
	Closes the game's book when the window opens (Features/Spellbook-Window.lua), the way the game closes one of
	its panels for another. Not in combat, where hiding the protected book is blocked.
]]
function ns.CloseGameSpellbook()
	if PlayerSpellsFrame and PlayerSpellsFrame:IsShown() and not InCombatLockdown() then
		HideUIPanel(PlayerSpellsFrame)
	end
end

-- The master switch shows or hides the tab at once.
function ns.SyncSpellbookHost()
	SpellbookTabs:RequestSync()
end
