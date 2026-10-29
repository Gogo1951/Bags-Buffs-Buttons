local _, ns = ...

--------------------------------------------------------------------------------
-- Profile Changes
--------------------------------------------------------------------------------

--[[
    Thanks for the Buff's settings are account-wide, so a profile switch, copy
    or reset leaves them as they were; this re-seeds the watched-buff lists and
    brings the Buff Window and the Thank You macros in line anyway, so a Reset
    never leaves them reading a stale table.
    Features/Core.lua calls this and then redraws every open panel.
]]
function ns.ApplyThanksForTheBuffProfile()
	ns.UpdateThanksForTheBuffEvents()
	if ns.PopulateWatchedBuffs then
		ns.PopulateWatchedBuffs()
	end
	if ns.PopulateBuffWindowAudience then
		ns.PopulateBuffWindowAudience()
		ns.RefreshBuffWindow()
	end
	if ns.ReconcileMacros then
		ns.ReconcileMacros()
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
    Every feature's on/off switch, placed twice by the options panels: at the top
    of the feature's own panel and on Thanks for the Buff's heading page. Both
    copies bind the same setting and carry the same caption and tooltip, and
    flipping either repaints every panel so the other copy and the settings it
    hides follow at once.
]]
ns.FEATURE_SWITCHES = {
	--[[
	    key: the profile subtable, setting: its on/off field, name/desc: locale keys,
	    onChange: present only for a feature that must react the moment either copy flips.
	]]
	{ key = "strangers", setting = "enabled", name = "STRANGERS_ENABLE", desc = "STRANGERS_ENABLE_DESCRIPTION" },
	{ key = "teammates", setting = "enabled", name = "TEAMMATES_ENABLE", desc = "TEAMMATES_ENABLE_DESCRIPTION" },
	{ key = "goodNews", setting = "whisperEnabled", name = "GOOD_NEWS_ENABLE", desc = "GOOD_NEWS_ENABLE_DESCRIPTION" },
	{ key = "services", setting = "enabled", name = "SERVICES_ENABLE", desc = "SERVICES_ENABLE_DESCRIPTION" },
	{
		key = "buffWindow",
		setting = "enabled",
		name = "BUFF_WINDOW_ENABLE",
		desc = "BUFF_WINDOW_ENABLE_DESCRIPTION",
		onChange = function()
			ns.RefreshBuffWindow()
		end,
	},
}

local function NotifyAllPanels()
	local registry = LibStub("AceConfigRegistry-3.0")
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		registry:NotifyChange(name)
	end
end

function ns.GetFeatureSwitch(key)
	for _, feature in ipairs(ns.FEATURE_SWITCHES) do
		if feature.key == key then
			return feature
		end
	end
	return nil
end

function ns.IsFeatureOn(key)
	local feature = ns.GetFeatureSwitch(key)
	return ns.db.global[key][feature.setting] and true or false
end

--[[
    Flips a feature from anywhere -- either copy of its toggle, the mini-map
    button, the Buff Duty window's close button -- so each one reacts and every
    open panel repaints the same way.
]]
function ns.SetFeatureSwitch(key, value)
	local feature = ns.GetFeatureSwitch(key)
	ns.db.global[key][feature.setting] = value
	ns.UpdateThanksForTheBuffEvents()
	if feature.onChange then
		feature.onChange()
	end
	NotifyAllPanels()
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

--[[
    Every event Thanks for the Buff handles. Each feature file attaches its
    handler with ns.SetEventHandler; attaching the same event twice replaces
    the earlier handler -- one owner per event.
]]
local EVENTS = {
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"UNIT_SPELLCAST_SENT",
	"UNIT_SPELLCAST_SUCCEEDED",
	"LOADING_SCREEN_DISABLED",
	"UNIT_AURA",
	"GROUP_ROSTER_UPDATE",
	"SPELLS_CHANGED",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED",
	"UNIT_PET",
	"SPELL_UPDATE_COOLDOWN",
	"GET_ITEM_INFO_RECEIVED",
	"UNIT_INVENTORY_CHANGED",
	"BAG_UPDATE_DELAYED",
	"REPLACE_ENCHANT",
	"UI_ERROR_MESSAGE",
}

-- Forever has no combat log, and registering COMBAT_LOG_EVENT_UNFILTERED there errors.
if ns.FLAVOR ~= "Camelot" then
	table.insert(EVENTS, "COMBAT_LOG_EVENT_UNFILTERED")
end

--[[
    Unit events Thanks for the Buff only ever needs for these units. Every
    other event subscribes unfiltered -- UNIT_AURA included, since the Buff
    Window reads every group member.
]]
local EVENT_UNITS = {
	UNIT_SPELLCAST_SENT = { "player", "pet" },
	UNIT_INVENTORY_CHANGED = { "player" },
}

local MODULE = "ThanksForTheBuff"
local eventHandlers = {}

function ns.SetEventHandler(event, handler)
	eventHandlers[event] = handler
end

ns.RegisterEventModule(MODULE, function(event, ...)
	local handler = eventHandlers[event]
	if handler then
		handler(...)
	end
end)

--[[
    The firehoses, each subscribed only while a feature that reads it is on:

      COMBAT_LOG_EVENT_UNFILTERED  Stranger and Teammate praise, Good News's
                                   resurrects, and Buff Duty's resurrects and
                                   Return the Favor. Never on Forever.
      UNIT_SPELLCAST_SENT          Good News, naming who a cast of yours is for.
      UNIT_SPELLCAST_SUCCEEDED     Good News, Service Alerts, and Buff Duty's
                                   Buff Key and resurrects.
      UNIT_AURA                    Buff Duty's group reads, every unit, while
                                   it is on for your class; otherwise, on
                                   Forever, your own auras for Stranger and
                                   Teammate praise.
]]
local FEATURE_EVENTS = {
	COMBAT_LOG_EVENT_UNFILTERED = true,
	UNIT_SPELLCAST_SENT = true,
	UNIT_SPELLCAST_SUCCEEDED = true,
	UNIT_AURA = true,
}

for _, event in ipairs(EVENTS) do
	if not FEATURE_EVENTS[event] then
		ns.SetModuleEvent(MODULE, event, true, unpack(EVENT_UNITS[event] or {}))
	end
end

function ns.UpdateThanksForTheBuffEvents()
	if not (ns.db and ns.db.global) then
		return
	end
	local IsOn = ns.IsFeatureOn
	local praise = IsOn("strangers") or IsOn("teammates")
	local goodNews, services = IsOn("goodNews"), IsOn("services")
	local buffDuty = ns.IsBuffDutyOnForClass and ns.IsBuffDutyOnForClass() or false
	local wanted = {
		COMBAT_LOG_EVENT_UNFILTERED = praise or goodNews or buffDuty,
		UNIT_SPELLCAST_SENT = goodNews,
		UNIT_SPELLCAST_SUCCEEDED = goodNews or services or buffDuty,
	}
	-- EVENTS, not wanted: on Forever the combat log is never in the list.
	for _, event in ipairs(EVENTS) do
		if FEATURE_EVENTS[event] and event ~= "UNIT_AURA" then
			ns.SetModuleEvent(MODULE, event, wanted[event], unpack(EVENT_UNITS[event] or {}))
		end
	end
	if buffDuty then
		ns.SetModuleEvent(MODULE, "UNIT_AURA", true)
	elseif praise and ns.FLAVOR == "Camelot" then
		ns.SetModuleEvent(MODULE, "UNIT_AURA", true, "player")
	else
		ns.SetModuleEvent(MODULE, "UNIT_AURA", false)
	end
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

--[[
    Login-time setup, once Features/Core.lua has opened the database and
    registered the panels, which draw the display groups on open and so need
    nothing from here. Core only calls each feature's setup hook, in order.
]]
ns.SetEventHandler("PLAYER_LOGIN", function()
	ns.UpdateThanksForTheBuffEvents()
	if ns.SetupBuffTracking then
		ns.SetupBuffTracking()
	end
	if ns.SetupBuffWindow then
		ns.SetupBuffWindow()
	end
	if ns.CreateAutoMacro then
		ns:CreateAutoMacro()
	end
end)

-- Buff Duty's In Instance: every way into or out of one is a loading screen.
ns.SetEventHandler("PLAYER_ENTERING_WORLD", function()
	if ns.db and ns.RequestBuffWindowRefresh then
		ns.RequestBuffWindowRefresh()
	end
end)
