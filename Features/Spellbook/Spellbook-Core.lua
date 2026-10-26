local _, ns = ...

--------------------------------------------------------------------------------
-- Profile Changes
--------------------------------------------------------------------------------

-- A profile switch, reset or copy changes every macro option, so the page and the macros it made follow it.
function ns.ApplySpellbookProfile()
	if ns.IsSpellbookEnabled() then
		ns:RefreshMacros()
	end
end

--------------------------------------------------------------------------------
-- Master Switch
--------------------------------------------------------------------------------

function ns.IsSpellbookEnabled()
	return ns.db ~= nil and ns.db.global.spellbookEnabled
end

--[[
	Off closes the window and hides its tab in the game's spellbook, and the events below stop reaching the
	page, so nothing rewrites its macros: they stay as they last were. On brings the macros up to date at once,
	as the events missed while off would have.
]]
function ns.SetSpellbookEnabled(value)
	ns.db.global.spellbookEnabled = value
	if value then
		ns:RefreshMacros()
	else
		ns.HideSpellbookWindow()
	end
	if ns.SyncSpellbookHost then
		ns.SyncSpellbookHost()
	end
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
	The Spellbook's events. Each event's handler is ns:On<Event>, resolved by name when the event fires, so
	feature files loaded after this one supply their own. The trainer events belong to Trainer-Recording.lua,
	which some TOCs leave out, so they subscribe only once login shows it loaded.
]]
local EVENT_HANDLERS = {
	SPELLS_CHANGED = "OnSpellsChanged",
	PLAYER_EQUIPMENT_CHANGED = "OnPlayerEquipmentChanged",
	SPELL_DATA_LOAD_RESULT = "OnSpellDataLoadResult",
	ACTIONBAR_SLOT_CHANGED = "OnActionbarSlotChanged",
	UPDATE_MACROS = "OnUpdateMacros",
	PLAYER_TARGET_CHANGED = "OnPlayerTargetChanged",
	UPDATE_MOUSEOVER_UNIT = "OnUpdateMouseoverUnit",
	PLAYER_REGEN_ENABLED = "OnPlayerRegenEnabled",
	PLAYER_REGEN_DISABLED = "OnPlayerRegenDisabled",
	UPDATE_BINDINGS = "OnUpdateBindings",
	TRAINER_SHOW = "OnTrainerShow",
	TRAINER_UPDATE = "OnTrainerUpdate",
}

local LOGIN_REGISTERED_EVENTS = { TRAINER_SHOW = true, TRAINER_UPDATE = true }

-- Heard with the Spellbook off: the Key Bindings row on its options page shows the key whatever the switch says.
local WHILE_OFF_EVENTS = { UPDATE_BINDINGS = true }

local MODULE = "Spellbook"

local function OnPlayerLogin()
	-- MIGRATION (remove after 2026-11-26): the retired Custom Macros feature's lists, in every profile.
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		profile.customMacros, profile.customMacrosSeeded = nil, nil
	end
	-- MIGRATION (remove after 2026-11-26): the retired Profession Tooltips feature's saved skill levels.
	ns.db.global.professionSkills = nil
	for event in pairs(LOGIN_REGISTERED_EVENTS) do
		if ns[EVENT_HANDLERS[event]] then
			ns.SetModuleEvent(MODULE, event, true)
		end
	end
end

ns.RegisterEventModule(MODULE, function(event, ...)
	if event == "PLAYER_LOGIN" then
		OnPlayerLogin()
		return
	end
	if not ns.IsSpellbookEnabled() and not WHILE_OFF_EVENTS[event] then
		return
	end
	local handlerName = EVENT_HANDLERS[event]
	local handler = handlerName and ns[handlerName]
	if handler then
		handler(ns, ...)
	end
end)

ns.SetModuleEvent(MODULE, "PLAYER_LOGIN", true)
for event in pairs(EVENT_HANDLERS) do
	if not LOGIN_REGISTERED_EVENTS[event] then
		ns.SetModuleEvent(MODULE, event, true)
	end
end
