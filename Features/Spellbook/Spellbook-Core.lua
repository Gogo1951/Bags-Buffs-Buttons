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
		-- the gear worn may have changed while PLAYER_EQUIPMENT_CHANGED went unheard
		ns:InvalidateUsableSlots()
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
	so they subscribe only once login shows it loaded; ADDON_LOADED belongs to Spellbook-Tabs.lua, which loads
	only where the Retail-engine spellbook does and subscribes it itself.
]]
local EVENT_HANDLERS = {
	ADDON_LOADED = "OnAddonLoaded",
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
local OWNER_REGISTERED_EVENTS = { ADDON_LOADED = true }

--[[
	Heard with the Spellbook off: the Key Bindings row on its options page shows the key whatever the switch
	says, and the spellbook tab attaches whenever the game's book loads, so switching on later finds it there.
]]
local WHILE_OFF_EVENTS = { UPDATE_BINDINGS = true, ADDON_LOADED = true }

local MODULE = "Spellbook"

local function OnPlayerLogin()
	-- MIGRATION (remove after 2026-11-26): the retired Custom Macros feature's lists, in every profile.
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		profile.customMacros, profile.customMacrosSeeded = nil, nil
	end
	-- MIGRATION (remove after 2026-11-26): the retired Profession Tooltips feature's saved skill levels.
	ns.db.global.professionSkills = nil
	--[[
		MIGRATION (remove after 2026-11-26): each profile's recorded trainer spells, from before they were kept by
		class, move under the class of the character the profile is named for. Where that class isn't known
		they are dropped; the next trainer visit records them again.
	]]
	local classes = ns.GetClassesByProfileName()
	classes[ns.db:GetCurrentProfile()] = select(2, UnitClass("player"))
	for profileName, profile in pairs(ns.db.sv.profiles or {}) do
		local trainerSpells, flat = profile.trainerSpells, {}
		for id, level in pairs(type(trainerSpells) == "table" and trainerSpells or {}) do
			if type(id) == "number" then
				flat[id] = level
			end
		end
		local class = classes[profileName]
		for id, level in pairs(flat) do
			trainerSpells[id] = nil
			if class then
				trainerSpells[class] = trainerSpells[class] or {}
				trainerSpells[class][id] = trainerSpells[class][id] or level
			end
		end
	end
	--[[
		MIGRATION (remove after 2026-11-26): this character's macro records, from when they were kept under
		ns.db.keys.char, move to ns.MacroOwnerKey where the two differ. Records under a placeholder name can't
		be told apart by character, so they stay where they are.
	]]
	local oldKey, newKey = ns.db.keys.char, ns.MacroOwnerKey()
	if oldKey ~= newKey and ns.SplitCharacterProfileName(oldKey) then
		local tags, prefix, oldIdentities = ns.db.global.macroTags, oldKey .. ":", {}
		for identity in pairs(tags) do
			if identity:sub(1, #prefix) == prefix then
				oldIdentities[#oldIdentities + 1] = identity
			end
		end
		for _, identity in ipairs(oldIdentities) do
			local moved = newKey .. ":" .. identity:sub(#prefix + 1)
			if tags[moved] == nil then
				tags[moved] = tags[identity]
			end
			tags[identity] = nil
		end
		for name, owner in pairs(ns.db.global.ownedMacros) do
			if owner == oldKey then
				ns.db.global.ownedMacros[name] = newKey
			end
		end
	end
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
	if not LOGIN_REGISTERED_EVENTS[event] and not OWNER_REGISTERED_EVENTS[event] then
		ns.SetModuleEvent(MODULE, event, true)
	end
end
