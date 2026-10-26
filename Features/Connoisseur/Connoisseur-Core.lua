local _, ns = ...

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame")

--[[
    Two-flag throttle. isUpdatePending means "a rescan/rebuild is wanted but
    hasn't been applied yet"; isTickScheduled means "the OnUpdate throttle is
    currently armed." Keeping them separate is what makes the throttle
    self-healing: RequestUpdate re-arms whenever the tick is disarmed, so a
    pending update can never get stranded with no OnUpdate attached — even if a
    combat-exit (PLAYER_REGEN_ENABLED) clear is ever missed, the next
    out-of-combat request re-arms the tick instead of being swallowed.
]]
local isUpdatePending = false
local isTickScheduled = false
local updateTimer = 0
local UPDATE_THROTTLE = 0.5

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local sessionConstantsInitialized = false

--[[
    Login-time setup, once Features/Core.lua has opened the database. Session
    constants and the mini-map button are set up once; the item cache is
    checked against its stamps every time it runs.
]]
local function InitializeConnoisseur()
	ns.EnsureItemCache()
	if not sessionConstantsInitialized then
		sessionConstantsInitialized = true
		ns.InitializeCharacterConstants()
		ns.RegisterMinimapIcon()
	end
end

--[[
    Switching, copying, or resetting a profile swaps the settings themselves
    as well as the character's Ignore List and the Restock List in use, so the
    macro bodies and aura tracking must rebuild. Which macros exist does NOT
    change -- enabledMacros is account-wide, like the macros themselves. The
    account-wide keys survive untouched, but the two applied imperatively
    (mini-map visibility, macro-name text) have to be pushed again from global
    because nothing else re-reads them. Features/Core.lua calls this and then
    redraws every open panel.
]]
function ns.ApplyConnoisseurProfile()
	ns.EnsureItemCache()
	ns.ApplyProfileRestockList()
	ns.ResetMacroState()
	ns.UpdateAuraTracking()
	ns.ApplyMacroNameVisibility()
	if ns.db.global.minimap then
		ns.ToggleMinimapButton(not ns.db.global.minimap.hide)
	end
	ns.RequestUpdate()
end

--[[
    Per-arrival state: refreshed at login AND on every later loading screen,
    because the cached level and zone move as the player levels and travels.

    Kept apart from InitializeConnoisseur, which runs at PLAYER_LOGIN only.
    Nothing here touches the database.

    Order matters on the login path: this runs AFTER InitializeConnoisseur, because
    ns.InitializeCharacterConstants is what resolves ns.isHunter for the registration
    below.
]]
local function RefreshArrivalState()
	ns.cachedPlayerLevel = UnitLevel("player") or 1
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	--[[
	    QUEST_LOG_UPDATE fires very frequently, and the only consumer of quest
	    data is Hunter pet-food quest-objective skipping (ScanPetFood via
	    BuildActiveQuestSet). Register it only for hunters so everyone else
	    doesn't pay for a full bag rescan + macro rebuild on every quest-log
	    churn. Idempotent, so registration follows ns.isHunter on every arrival.
	]]
	ns.SetEventRegistered("QUEST_LOG_UPDATE", ns.isHunter)
end

--------------------------------------------------------------------------------
-- Update Throttling
--------------------------------------------------------------------------------

local function OnUpdateHandler(_, elapsed)
	if InCombatLockdown() then
		--[[
		    Macros can't be written in combat. Disarm the tick but leave the
		    work pending (isUpdatePending stays true); PLAYER_REGEN_ENABLED, or
		    any later out-of-combat request, re-arms it.
		]]
		frame:SetScript("OnUpdate", nil)
		isTickScheduled = false
		return
	end

	updateTimer = updateTimer + elapsed
	if updateTimer > UPDATE_THROTTLE then
		frame:SetScript("OnUpdate", nil)
		isTickScheduled = false
		isUpdatePending = false
		ns.UpdateMacros()
	end
end

function ns.RequestUpdate()
	isUpdatePending = true

	--[[
	    In combat, leave the work pending without arming the tick — macro
	    writes are blocked until combat drops, and PLAYER_REGEN_ENABLED
	    re-requests then.
	]]
	if InCombatLockdown() then
		return
	end

	--[[
	    Out of combat, ensure the throttled tick is armed. Gating on
	    isTickScheduled (not isUpdatePending) means a request always re-arms a
	    disarmed tick, so a stranded isUpdatePending can never swallow updates
	    until a /reload. updateTimer is reset only when arming a fresh tick, so
	    the throttle still fires ~UPDATE_THROTTLE after the first request in a
	    burst rather than debouncing to the last.
	]]
	if not isTickScheduled then
		isTickScheduled = true
		updateTimer = 0
		frame:SetScript("OnUpdate", OnUpdateHandler)
	end
end

-- Leaves the work pending without arming the tick, for a deferral something else is sure to replay.
function ns.MarkUpdatePending()
	isUpdatePending = true
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

--[[
    Connoisseur & Restocker's dispatcher. Features/Core.lua hands it every event
    it subscribed to below, after Core's own handling: by PLAYER_LOGIN the
    database exists.
]]
local function OnEvent(event, ...)
	--[[
	    Handled ahead of the lockdown guard below, and nothing here touches a
	    protected function, so the feature starts even when the player enters
	    the world already in combat (e.g. zoning into an in-progress
	    battleground) -- a case the guard would otherwise swallow, leaving it
	    uninitialized until combat dropped.
	]]
	if event == "PLAYER_LOGIN" then
		InitializeConnoisseur()
		--[[
		    Restocker starts here rather than on its own frame, so it is
		    guaranteed ns.db already exists. Everything it does at this point is
		    saved-variable and frame setup, none of it protected.
		]]
		ns.InitializeRestocker()
		--[[
		    After the Restocker, whose settings the report reads for a list
		    item's Keep amount. Only binds this character's saved entry and hooks
		    the tooltips, so it is as safe here as the Restocker is.

		    Tested for, here and in the dispatcher below: the client reads a
		    TOC's file list only at startup, so a player who updates with the
		    game running and reloads gets this file without Inventory-Report.lua
		    until the next restart. The report just stays off until then.
		]]
		if ns.InitializeInventoryReport then
			ns.InitializeInventoryReport()
		end
		RefreshArrivalState()
		return
	end

	--[[
	    Restocker's handlers, ahead of the lockdown guard below. None of them
	    touches a protected function: a merchant or bank window cannot open in
	    combat, and a logout mid-combat must still pack the Restock List for the
	    saved-variables file. Routing them here rather than through a private
	    frame is also what puts them in the Diagnostics event log.
	]]
	local restockerHandler = ns.restockerEventHandlers[event]
	if restockerHandler then
		restockerHandler(...)
	end

	--[[
	    The Inventory Report's recorders, ahead of the guard for the same
	    reasons: they only read containers and write saved variables, and a
	    logout mid-combat must still save this character's bags. BAG_UPDATE_DELAYED
	    continues past here to the macro rebuild below.
	]]
	local inventoryHandler = ns.inventoryEventHandlers and ns.inventoryEventHandlers[event]
	if inventoryHandler then
		inventoryHandler(...)
	end

	--[[
	    Options item lists waiting on this answer repaint now: after the
	    Restocker handler above, which forgets the item's remembered miss before
	    anything asks about it again.
	]]
	if event == "GET_ITEM_INFO_RECEIVED" then
		ns.OnOptionsItemInfoReceived(...)
		--[[
		    Only a consumable's answer can change a macro: ns.CacheItemData, which
		    covers the consumable tables alone, is the one macro input that reads
		    item info. Any other answer rebuilds nothing.
		]]
		local itemID = ...
		if not ns.HasRawData(itemID) then
			return
		end
	end

	--[[
	    UI_ERROR_MESSAGE is also handled ahead of the lockdown guard: both
	    of its consumers must work mid-combat and neither touches protected
	    functions. The wrong-zone report mostly fires when a zone-locked
	    potion is pressed mid-fight — exactly when the guard below would
	    swallow it — and the dead-pet branch only flips a flag plus
	    RequestUpdate, whose OnUpdate handler already defers macro writes
	    until combat drops.
	]]
	if event == "UI_ERROR_MESSAGE" then
		local _, message = ...

		ns.OnHunterUiErrorMessage(message)

		ns.OnMacroUiErrorMessage(message)
		return
	end

	--[[
	    UNIT_PET is handled ahead of the guard as well: a pet revived or called
	    mid-fight must clear the dead-pet flag then, not when combat ends, and the
	    handler only flips that flag and calls RequestUpdate, which defers the
	    rebuild itself.
	]]
	if event == "UNIT_PET" then
		ns.OnUnitPet(...)
		return
	end

	--[[
	    Leveling changes which items, scrolls, and spells qualify, so a
	    level-up forces a full rebuild of every macro. Refresh the cached level
	    and hunter spell names here, above the combat lockdown guard, because a
	    ding from a killing blow fires PLAYER_LEVEL_UP in combat, and the
	    event's own level / C_Spell.GetSpellName are safe combat reads. Wiping the
	    macro state forces every macro to rewrite; the write itself still
	    defers to the post-combat tick via the throttled update.

	    The level comes off the event rather than from UnitLevel("player"),
	    which still reads the OLD level while this event is being handled --
	    caching that would rebuild every macro one level behind and leave it
	    there until some later event happened to rebuild them again.
	]]
	if event == "PLAYER_LEVEL_UP" then
		local newLevel = ...
		ns.cachedPlayerLevel = newLevel or UnitLevel("player") or ns.cachedPlayerLevel or 1
		if ns.isHunter then
			ns.ResolveHunterSpells()
		end
		ns.ResetMacroState()
		ns.RequestUpdate()
		return
	end

	--[[
	    PLAYER_LOGOUT runs ahead of the lockdown guard too: a /reload issued
	    mid-combat still fires it, and the guard below would swallow the prune
	    and leave stale entries on the Ignore List. Pruning only reads and
	    rewrites SavedVariables, so it touches nothing protected.
	]]
	if event == "PLAYER_LOGOUT" then
		ns.OnIgnoreListPlayerLogout()
		return
	end

	--[[
	    READY_CHECK is handled ahead of the lockdown guard for the same reason
	    as the events above: a ready check routinely fires with the raid
	    already pulling, and the report only reads auras and the last scan's
	    results before printing, so it touches nothing protected. Where the
	    client restricts aura data mid-fight (Forever), ns.OnReadyCheck
	    stays silent rather than read a secret value.
	]]
	if event == "READY_CHECK" then
		ns.OnReadyCheck()
		return
	end

	--[[
	    Target and group changes are recorded ahead of the lockdown guard too.
	    Behind it, a change made mid-fight would leave the remembered signature at
	    its pre-fight reading, so changing back after combat would read as no
	    change and leave the macros built for the fight. Both only read unit
	    state, the target comparison only while C_Secrets allows it (Forever
	    can restrict it mid-fight), and ns.RequestUpdate leaves the rebuild
	    pending until combat drops.
	    Request only on a real change; see Target and Group Tracking in
	    Features/Macros/Signatures.lua.
	]]
	if event == "PLAYER_TARGET_CHANGED" then
		if ns.TargetSignatureChanged() then
			ns.RequestUpdate()
		end
		return
	end

	if event == "GROUP_ROSTER_UPDATE" then
		if ns.GroupSignatureChanged() then
			ns.RequestUpdate()
		end
		return
	end

	--[[
	    A cast is sorted ahead of the lockdown guard as well, which would
	    otherwise take every cast in a fight as a reason to rebuild. Only the
	    casts ns.SpellCastChangesMacros names change what the macros hold, and
	    ns.RequestUpdate leaves that rebuild pending until combat drops.
	]]
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...
		-- A secret spellID (Forever, while casts are restricted) errors as a table key.
		if ns.IsSecretValue(spellID) then
			return
		end
		if ns.SpellCastChangesMacros(spellID) then
			ns.RequestUpdate()
		end
		return
	end

	--[[
	    Skill ranks are read ahead of the guard: a bandage in a fight raises First
	    Aid there, and nothing re-reads the skills when combat ends. The reads
	    touch nothing protected, and ns.RequestUpdate defers the rebuild.
	]]
	if event == "SKILL_LINES_CHANGED" then
		ns.UpdateFirstAidSkill()
		ns.UpdateAlchemySkill()
		ns.UpdateEngineeringSkill()
		ns.RequestUpdate()
		return
	end

	-- Hiding macro names only sets font-string alpha, which combat allows, so a mid-fight login still applies it.
	if event == "PLAYER_ENTERING_WORLD" then
		ns.ApplyMacroNameVisibility()
	end

	if InCombatLockdown() then
		isUpdatePending = true
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		if isUpdatePending then
			ns.RequestUpdate()
		end
		return
	end

	if event == "QUEST_LOG_UPDATE" then
		if ns.PetFoodQuestsChanged() then
			ns.RequestUpdate()
		end
		return
	end

	if
		event == "BAG_UPDATE_DELAYED"
		or event == "ITEM_PUSH"
		or event == "GET_ITEM_INFO_RECEIVED"
		or event == "PLAYER_ALIVE"
		or event == "PLAYER_UNGHOST"
	then
		ns.RequestUpdate()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		ns.cachedMapID = C_Map.GetBestMapForUnit("player")
		ns.RequestUpdate()
	elseif event == "SPELLS_CHANGED" then
		--[[
		    Hunter spell-name cache refreshes here so a level-up training
		    visit (e.g. Mend Pet at 12) starts participating in the macro
		    immediately. Mages/warlocks don't have a name cache, but their
		    macro bodies still depend on KnowsAny / GetSmartSpell results,
		    so we trigger a generic rebuild for everyone.
		]]
		if ns.isHunter then
			ns.ResolveHunterSpells()
		end
		ns.RequestUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		RefreshArrivalState()
		ns.UpdateAuraTracking()
		ns.RequestUpdate()
		C_Timer.After(3, function()
			ns.RequestUpdate()
		end)
	elseif event == "UNIT_AURA" then
		ns.OnUnitAura(...)
	end
end

local MODULE = "Connoisseur"
ns.RegisterEventModule(MODULE, OnEvent)

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
    Every event Connoisseur & Restocker handles. The plain ones subscribe at
    load; UNIT_PET and UNIT_SPELLCAST_SUCCEEDED for the player alone; the
    on-demand ones only while needed (UNIT_AURA via ns.UpdateAuraTracking,
    QUEST_LOG_UPDATE for hunters in RefreshArrivalState, GET_ITEM_INFO_RECEIVED
    via ns.RequestItemInfoEvents), each through ns.SetEventRegistered.
]]
local EVENTS = {
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"BANKFRAME_OPENED",
	"ITEM_PUSH",
	"MERCHANT_CLOSED",
	"MERCHANT_SHOW",
	"PLAYER_ALIVE",
	"PLAYER_CONTROL_GAINED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_LOGOUT",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_UNGHOST",
	"PLAYER_UPDATE_RESTING",
	"READY_CHECK",
	"UI_ERROR_MESSAGE",
	"ZONE_CHANGED_NEW_AREA",
	"SKILL_LINES_CHANGED",
	"SPELLS_CHANGED",
	"GROUP_ROSTER_UPDATE",
	"UNIT_PET",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_AURA",
	"QUEST_LOG_UPDATE",
	"GET_ITEM_INFO_RECEIVED",
}

local DEFERRED_EVENTS = {
	UNIT_PET = true,
	UNIT_SPELLCAST_SUCCEEDED = true,
	UNIT_AURA = true,
	QUEST_LOG_UPDATE = true,
	GET_ITEM_INFO_RECEIVED = true,
}

--[[
    How a feature file subscribes to or releases one of its on-demand events,
    through Core's dispatcher. Unit arguments after `enabled` make the
    subscription unit-filtered.
]]
function ns.SetEventRegistered(event, enabled, ...)
	ns.SetModuleEvent(MODULE, event, enabled, ...)
end

for _, event in ipairs(EVENTS) do
	if not DEFERRED_EVENTS[event] then
		ns.SetEventRegistered(event, true)
	end
end

ns.SetEventRegistered("UNIT_PET", true, "player")
ns.SetEventRegistered("UNIT_SPELLCAST_SUCCEEDED", true, "player")
