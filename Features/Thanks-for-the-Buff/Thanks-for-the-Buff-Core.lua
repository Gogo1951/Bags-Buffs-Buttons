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

for _, event in ipairs(EVENTS) do
	ns.SetModuleEvent(MODULE, event, true, unpack(EVENT_UNITS[event] or {}))
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
