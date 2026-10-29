local _, ns = ...
local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

local REGISTRY = ns.OPTIONS_REGISTRY

--[[
    Registration is deferred to ns.RegisterOptionsPanels, called once from
    Features/Core.lua after AceDB creates ns.db: the Profiles panel's tree label
    is read from the stock AceDBOptions-3.0 table, which needs the database.

    The tree is split by the add-on each part came from, each under a heading
    page of its own that holds its features' master switches:

      Bags Buffs & Buttons    (General: welcome, mini-map, /commands)
        Connoisseur           Macros (Class & Race, Ignore List), Readiness Report
        Restocker
        Thanks for the Buff   Stranger Buffs, Teammate Buffs, Send Good News,
                              Service Alerts, Buff Duty, Thank You Button
        Spellbook
        Profiles, Feedback & Support, Diagnostic Tools

    Child-panel order is the order of the AddToBlizOptions calls. The third
    argument is the parent: the root's display name by default, or a child's
    category ID to nest a panel a level deeper. AceConfigDialog maps only root
    names to IDs, so a nested panel passes the ID its parent's registration
    returned; the Settings panel finds a category at any depth by ID and
    indents each level.

    Every category ID is kept by registry key, so ns:OpenOptionsPanel can open
    any panel directly; a title lookup fails wherever the ID is a number.
]]
local function RegisterChild(registryKey, builder, displayName, parentID)
	AceConfig:RegisterOptionsTable(REGISTRY[registryKey], builder)
	local _, categoryID =
		AceConfigDialog:AddToBlizOptions(REGISTRY[registryKey], displayName, parentID or L["ADDON_TITLE"])
	ns.optionsFrames.categories[registryKey] = categoryID
	return categoryID
end

local function RegisterConnoisseurPanels()
	local connoisseurID = RegisterChild("Connoisseur", ns.BuildConnoisseurOptions, L["TAB_CONNOISSEUR"])

	--[[
	    Macros panel -- every macro setting, led by the Macros master switch,
	    with Class & Race and the Ignore List nested under it: the list only
	    says what the macros may offer. The Ignore List registers its builder
	    function, not a built table, so it never renders a stale list.
	]]
	local macrosID = RegisterChild("Macros", ns.BuildMacrosOptions, L["TAB_MACROS"], connoisseurID)
	RegisterChild("ClassRace", ns.BuildClassRaceOptions, L["TAB_CLASS_RACE"], macrosID)
	RegisterChild("IgnoreList", ns.BuildIgnoreListOptions, L["TAB_IGNORE_LIST"], macrosID)

	--[[
	    Seed the Ignore List tree's width (ns.OPTIONS_TREE_WIDTH). AceGUI's
	    SetStatusTable fills treewidth in only when the key is absent -- so
	    seeding it here wins, while a player dragging the splitter still
	    overwrites it from then on.
	]]
	local ignoreStatus = AceConfigDialog:GetStatusTable(REGISTRY.IgnoreList)
	ignoreStatus.groups = ignoreStatus.groups or {}
	ignoreStatus.groups.treewidth = ns.OPTIONS_TREE_WIDTH

	RegisterChild("ReadinessReport", ns.BuildReadinessReportOptions, L["TAB_READINESS_REPORT"], connoisseurID)
end

local function RegisterRestockerPanels()
	RegisterChild("Restocker", ns.BuildRestockerOptions, L["TAB_RESTOCKER"])
end

local function RegisterThanksForTheBuffPanels()
	local tftbID = RegisterChild("ThanksForTheBuff", ns.BuildThanksForTheBuffOptions, L["TAB_THANKS_FOR_THE_BUFF"])

	RegisterChild("StrangerBuffs", ns.BuildStrangersOptions(), L["TAB_STRANGERS"], tftbID)

	--[[
	    Each panel with a tracked list gets it as a "Tracked Abilities" sub-panel.
	    The sub-panels register as functions (not prebuilt tables) so the list is
	    rebuilt and re-sorted on open, once lazily-loaded item names are cached.
	]]
	local teammatesID = RegisterChild("TeammateBuffs", ns.BuildTeammatesOptions, L["TAB_TEAMMATES"], tftbID)
	RegisterChild("TeammateBuffsTracked", ns.BuildTeammatesTrackedOptions, L["TRACKED_HEADER"], teammatesID)

	local goodNewsID = RegisterChild("SendGoodNews", ns.BuildGoodNewsOptions, L["TAB_GOOD_NEWS"], tftbID)
	RegisterChild("SendGoodNewsTracked", ns.BuildGoodNewsTrackedOptions, L["TRACKED_HEADER"], goodNewsID)

	local servicesID = RegisterChild("ServiceAlerts", ns.BuildServicesOptions, L["TAB_SERVICES"], tftbID)
	RegisterChild("ServiceAlertsTracked", ns.BuildServicesTrackedOptions, L["TRACKED_HEADER"], servicesID)

	-- Builders: the class lists exist only after login.
	local buffWindowID = RegisterChild("BuffWindow", ns.BuildBuffWindowOptions, L["TAB_BUFF_WINDOW"], tftbID)
	RegisterChild("BuffWindowBuffs", ns.BuildBuffWindowBuffsOptions, L["TRACKED_HEADER"], buffWindowID)
	RegisterChild("BuffWindowSelfBuffs", ns.BuildBuffWindowSelfBuffsOptions, L["BUFF_WINDOW_SELF_HEADER"], buffWindowID)
	RegisterChild(
		"BuffWindowWeaponBuffs",
		ns.BuildBuffWindowWeaponBuffsOptions,
		L["BUFF_WINDOW_WEAPON_PANEL_HEADER"],
		buffWindowID
	)

	RegisterChild("ThankYouButton", ns.BuildThankYouButtonOptions(), L["TAB_THANK_YOU_BUTTON"], tftbID)
end

-- A builder, not a built table: the Key Bindings row reads the bound key each time the panel draws.
local function RegisterSpellbookPanels()
	RegisterChild("Spellbook", ns.BuildSpellbookOptions, L["TAB_SPELLBOOK"])
end

function ns.RegisterOptionsPanels()
	AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions)
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(REGISTRY.General, L["ADDON_TITLE"])
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID, categories = {} }

	RegisterConnoisseurPanels()
	RegisterRestockerPanels()
	RegisterThanksForTheBuffPanels()
	RegisterSpellbookPanels()

	--[[
	    Profiles panel: the stock AceDBOptions-3.0 table, unmodified. Its display
	    name comes already-localized from AceDBOptions, read off the built table
	    so we neither hardcode it nor add a locale key for a stock widget.
	]]
	local profilesOptions = ns.BuildProfilesOptions()
	RegisterChild("Profiles", profilesOptions, profilesOptions.name)

	RegisterChild("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	--[[
	    Diagnostic Tools last so it sits at the bottom of the tree. Registered as
	    the builder, so the tabs come and go with the enable toggle; its display
	    name is a plain English string, never a locale key.
	]]
	RegisterChild("Diagnostics", ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

--[[
    Opens the root panel, or the panel named by an ns.OPTIONS_REGISTRY key.
    Combat first: Blizzard's Settings panel is protected in combat, so every
    route below is blocked and the player would get an ADDON_ACTION_BLOCKED
    error naming the add-on instead of an answer. The gate sits at this single
    entry point, so the slash command and the mini-map button's Shift +
    Middle-Click answer identically. It returns -- never queues the open for
    when combat ends.
]]
function ns:OpenOptionsPanel(panel)
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end
	if not ns.optionsFrames then
		return
	end
	local categoryID = ns.optionsFrames.categories[panel] or ns.optionsFrames.categoryID
	if Settings and Settings.OpenToCategory and categoryID then
		Settings.OpenToCategory(categoryID)
		return
	end
	AceConfigDialog:Open(REGISTRY[panel] or REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_BAGSBUFFSBUTTONS1 = "/bbb"
SlashCmdList["BAGSBUFFSBUTTONS"] = function()
	ns:OpenOptionsPanel()
end

--[[
    The Restock List's own command, registered here with the options command
    rather than inside the feature: slash registration is this file's job, and
    the handler stays with the feature that answers it.
]]
SLASH_BAGSBUFFSBUTTONSRESTOCK1 = "/restock"
SlashCmdList["BAGSBUFFSBUTTONSRESTOCK"] = function(message)
	ns.HandleRestockerCommand(message)
end

--[[
    One command per Thank You button, generated from the same list the macros
    and the options sections come from. The command TEXT is what users and their
    existing macros type; only the internal SlashCmdList key is namespaced.
]]
for index, button in ipairs(ns.Data.THANK_YOU_BUTTONS) do
	local key = "BAGSBUFFSBUTTONS_THANKYOU" .. index
	_G["SLASH_" .. key .. "1"] = button.command
	SlashCmdList[key] = function()
		if ns.RunThankYou then
			ns.RunThankYou(button)
		end
	end
end
