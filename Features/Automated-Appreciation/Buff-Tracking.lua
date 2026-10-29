local _, ns = ...
local Data = ns.Data

local GetAuraEntry = ns.GetAuraEntry
local GetCastEntry = ns.GetCastEntry
local HandleStrangersBuff = ns.HandleStrangersBuff
local HandleTracked = ns.HandleTracked
local IsOnCooldown = ns.IsOnCooldown
local SetCooldown = ns.SetCooldown

--[[
    The buff-reaction engine's event side. Watches the combat log (UNIT_AURA on
    Forever, read in Buff-Tracking-Forever.lua) and UNIT_SPELLCAST_SUCCEEDED, classifies the source against the
    lookups in Features/Automated-Appreciation/Tracked-Lookups.lua, and hands what qualifies to
    Features/Automated-Appreciation/Praise.lua. Owns the readiness timer Good News also reads; its event
    handlers attach through Core's dispatcher (ns.SetEventHandler), and the
    events themselves are declared in Core's ns.EVENT_NAMES.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local isReady = false
local playerGUID -- cached at login; a character's GUID never changes within a session

--------------------------------------------------------------------------------
-- Safety Timer
--------------------------------------------------------------------------------

--[[
    Suppresses buff reactions until the world settles after login or a loading screen.
    A token invalidates earlier timers: back-to-back loading screens each arm a new
    pause, and only the most recent callback may restore readiness, so a stale timer
    can't flip isReady back on mid-pause.
]]
local safetyToken = 0
local function StartSafetyTimer(duration)
	isReady = false
	safetyToken = safetyToken + 1
	local token = safetyToken
	C_Timer.After(duration or Data.SAFETY_PAUSE, function()
		if token == safetyToken then
			isReady = true
		end
	end)
end

--------------------------------------------------------------------------------
-- Source Resolution
--------------------------------------------------------------------------------

--[[
    A buff's combat-log source can be a pet or guardian (a hunter's Roar of
    Sacrifice, for example). Credit the owner so the message names the player,
    not the pet — owners are found by matching the pet's GUID to a group pet unit.
]]
local function GetPetOwnerUnit(petGUID)
	if UnitGUID("pet") == petGUID then
		return "player"
	end
	for i = 1, 4 do
		if UnitGUID("partypet" .. i) == petGUID then
			return "party" .. i
		end
	end
	for i = 1, 40 do
		if UnitGUID("raidpet" .. i) == petGUID then
			return "raid" .. i
		end
	end
	return nil
end

ns.GetPetOwnerUnit = GetPetOwnerUnit

--[[
    Credit for a buff goes to a player or to nobody. A pet/guardian source is
    traded for its owner; when that lookup fails -- group pet tokens are missing
    more often than you'd think (a raid pet out of range, a pet the client hasn't
    loaded) -- we return nil so the caller drops the event entirely. Trap: do NOT
    fall back to the pet itself. Its name is not a player's, so the thank-you
    whisper bounces ("No player named 'Woofbark' is currently playing") and the
    print credits an animal; and because a pet inherits its owner's PARTY/RAID
    affiliation, nothing downstream would catch it.
]]
local function ResolveSource(sourceGUID, sourceName)
	if ns.IsPlayerGUID(sourceGUID) then
		return sourceGUID, sourceName
	end
	local ownerUnit = GetPetOwnerUnit(sourceGUID)
	if ownerUnit then
		return UnitGUID(ownerUnit), GetUnitName(ownerUnit, true)
	end
	return nil
end

--[[
    Which tracked entry, if any, this combat-log event proves. The subevent has to
    match the entry's own detect mode, not merely find an id in a lookup: a
    resurrect-detect entry shares the cast lookup with ordinary casts (so the panel,
    the watched list and the seeds all keep working unchanged) but must ignore the
    SPELL_CAST_SUCCESS that an ordinary cast entry lives on, because a cast
    succeeding never proves the revive took. The reverse guard matters too: a
    CAST entry must not be triggered by a stray SPELL_RESURRECT.
]]
local function MatchTracked(spellID, isAura, isCast, isResurrect)
	if isAura then
		return GetAuraEntry(spellID)
	end
	local entry = GetCastEntry(spellID)
	if not entry then
		return nil
	end
	if entry.detect == Data.DETECT.RESURRECT then
		return isResurrect and entry or nil
	end
	return isCast and entry or nil
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

local function OnCombatLogEventUnfiltered()
	if not isReady or not ns.db then
		return
	end

	local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, _, _, _, spellID =
		CombatLogGetCurrentEventInfo()

	--[[
	    REFRESH counts as an aura landing: recasting a buff the target already has
	    emits SPELL_AURA_REFRESH, not APPLIED, and a rebuff earns the same thanks.
	]]
	local isAura = (subEvent == "SPELL_AURA_APPLIED") or (subEvent == "SPELL_AURA_REFRESH")
	local isCast = (subEvent == "SPELL_CAST_SUCCESS")
	--[[
	    The only event that proves a revive actually took: goblin jumper cables and
	    Defibrillate report a successful CAST on every attempt, including the ones
	    that leave the target dead.
	]]
	local isResurrect = (subEvent == "SPELL_RESURRECT")
	if not isAura and not isCast and not isResurrect then
		return
	end

	--[[
	    Diagnostics probe: log raw cast-success and resurrect events (portals,
	    summons, feasts, jumper cables), and every aura landing on you, before the
	    guards below drop anything, so even your own test casts and events that get
	    filtered out are still visible in the event log. Untracked casts are counted
	    by spell id in the log's summary rather than logged in full. Resurrects are
	    logged alongside casts specifically so a failed jolt and a working one can
	    be told apart by eye -- a cable that revives nobody logs CAST with no REZ
	    following it. See ns:LogCombatCast.
	]]
	local isAuraOnYou = isAura and destGUID == playerGUID
	if (isCast or isResurrect or isAuraOnYou) and ns.diagnostics and ns.diagnostics.logging then
		local tracked
		if isAura then
			tracked = GetAuraEntry(spellID) ~= nil
		else
			tracked = GetCastEntry(spellID) ~= nil
		end
		ns:LogCombatCast(
			spellID,
			sourceName,
			sourceFlags,
			tracked,
			ns.db.global.watchedBuffs and ns.db.global.watchedBuffs[spellID],
			(isResurrect and "REZ") or (isCast and "CAST") or "AURA"
		)
	end

	--[[
	    Good News for a resurrect-detect cast of YOURS. It has to be claimed above
	    the own-casts return below, which is otherwise the end of the line for
	    anything you did yourself.
	]]
	if isResurrect and sourceGUID == playerGUID then
		ns.ClaimPendingResurrect(destGUID, spellID)
	end

	-- Buff Duty hides a dead player's resurrect icon while anyone's offer waits on them.
	if isResurrect and ns.BuffWindow and ns.BuffWindow.NoteResurrect then
		ns.BuffWindow.NoteResurrect(destGUID)
	end

	--[[
	    Your own casts are Good News's business, and it runs off the cast events
	    instead (Features/Automated-Appreciation/Good-News.lua); everything below reacts to what OTHERS
	    do to you.
	]]
	if not sourceGUID or sourceGUID == playerGUID then
		return
	end

	local entry = MatchTracked(spellID, isAura, isCast, isResurrect)

	--[[
	    Service casts (portals, summons, feasts) are announced from
	    UNIT_SPELLCAST_SUCCEEDED instead -- they don't reliably reach the combat log
	    -- so drop any that surface here, both to avoid a double announce and because
	    the combat log can't be relied on to carry them at all.
	]]
	if entry and entry.type == Data.BUFF.SERVICE then
		entry = nil
	end

	--[[
        A stranger buff is a HELPFUL aura that lands on you from a friendly
        player outside your group. Combat doesn't suppress stranger messages
        (only the emote, which is dropped in combat -- see HandleStrangersBuff),
        but the source/group resolution below is still gated: react only to a
        tracked spell or to a stranger buff on you. Everything else -- including
        group members' untracked buffs in a raid -- bails here so combat log
        processing stays cheap, using the affiliation flag instead of a UnitIn*
        scan to recognize an outsider.

        Ordered cheapest first, so a cast event or an aura landing on anyone but
        you stops at a comparison before the GUID check allocates. Only that GUID
        check proves the source is a player (a pet's doesn't, whatever its flags
        claim); the flags then say whose side they're on and which group.
    ]]
	local maybeStranger = isAura
		and destGUID == playerGUID
		and ns.IsPlayerGUID(sourceGUID)
		and bit.band(sourceFlags or 0, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
		and bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0

	if not entry and not maybeStranger then
		return
	end

	local creditGUID, creditName = ResolveSource(sourceGUID, sourceName)
	if not creditName then
		return
	end

	--[[
        Trap: a name lookup misses cross-realm sources, whose combat-log name is
        "Name-Realm". Classify by affiliation flags instead. MINE/PARTY/RAID cover
        group members and their pets, which inherit the owner's affiliation. MINE
        also covers the player's own pet, so the creditGUID guard stops a self-cast
        (a hunter's Roar of Sacrifice on themselves) from crediting the player.
    ]]
	local sourceIsGroupMember = creditGUID ~= playerGUID
		and (
			bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
			or bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0
			or bit.band(sourceFlags or 0, COMBATLOG_OBJECT_AFFILIATION_RAID) > 0
		)

	if sourceIsGroupMember then
		if entry then
			HandleTracked(entry, spellID, creditGUID, creditName, destGUID)
		end
	elseif maybeStranger then
		HandleStrangersBuff(sourceGUID, sourceName, spellID)
		if ns.NoteFavor then
			ns.NoteFavor(sourceGUID, sourceName)
		end
	end
end

--[[
    Group services are announced from UNIT_SPELLCAST_SUCCEEDED, not the combat log:
    portals, summons, feasts and the like are utility casts that don't reliably
    produce a SPELL_CAST_SUCCESS in COMBAT_LOG_EVENT_UNFILTERED, but they DO fire
    this unit event for any unit the client tracks (party/raid, target, focus). A
    service has no per-you target, so crediting the casting unit is all we need --
    which is also why solo casts (Rebirth, Lay on Hands) stay on the combat log,
    where the destination tells us the buff actually landed on you.

    That same breadth is why the caster is filtered to your party or raid below:
    the event's reach is much wider than the feature's, and a service cast by
    someone you merely have targeted was never meant to announce.

    The per-source "service:" cooldown does double duty: it rate-limits a mage
    opening several portals in a row, and it dedupes the multiple tokens a single
    cast can fire (party1 and target for the same caster resolve to one GUID, so the
    second is already on cooldown).
]]
local function OnUnitSpellcastSucceeded(unitTarget, castGUID, spellID)
	-- The Buff Key hears its own casts go off, whether or not tracking is ready.
	if ns.OnBuffKeyCastSucceeded then
		ns.OnBuffKeyCastSucceeded(unitTarget, spellID)
	end
	if ns.OnResurrectCastSucceeded then
		ns.OnResurrectCastSucceeded(unitTarget, spellID)
	end

	if not isReady or not ns.db then
		return
	end

	-- Other players' casts on nameplates and the like arrive with secret ids that can't key a table.
	if not (ns.IsPlain(spellID) and ns.IsPlain(castGUID) and ns.IsPlain(unitTarget)) then
		return
	end

	--[[
	    Good News: a cast of yours that SENT already vetted and named the
	    recipient. Claimed before the service check below, which is about OTHER
	    people's casts.
	]]
	if castGUID then
		ns.ClaimPendingGiven(castGUID)
	end

	local entry = GetCastEntry(spellID)
	if not entry or entry.type ~= Data.BUFF.SERVICE then
		return
	end

	--[[
	    Group members only, never ourselves. The event fires for every unit the
	    client tracks, so without the group test a stranger opening a portal
	    across a capital city reads as a service to us -- and a group service is
	    the whole promise of the Service Alerts panel. Being in the group implies a friendly
	    player; UnitIsPlayer drops group pets, which the group calls don't
	    distinguish. A battleground IS a raid, so it needs no
	    case of its own. A caster whose identity is secret can't be credited.
	]]
	if ns.IsUnitIdentitySecret(unitTarget) then
		return
	end
	if not UnitIsPlayer(unitTarget) then
		return
	end
	if not (UnitInParty(unitTarget) or UnitInRaid(unitTarget)) then
		return
	end
	local creditGUID = UnitGUID(unitTarget)
	if not creditGUID or not ns.IsPlain(creditGUID) or creditGUID == playerGUID then
		return
	end
	local creditName = GetUnitName(unitTarget, true)
	if not creditName or not ns.IsPlain(creditName) then
		return
	end

	local cooldownKey = "service:" .. creditGUID
	if not IsOnCooldown(cooldownKey) then
		HandleTracked(entry, spellID, creditGUID, creditName, nil)
		SetCooldown(cooldownKey)
	end
end

--[[
    UNIT_AURA is subscribed for every unit while Buff Duty is on for your class,
    because it reads the whole group, and otherwise on Forever for you alone
    (ns.UpdateThanksForTheBuffEvents); this handler owns the event and hands it
    on to Buff Duty first. The rest is Forever's buff detection
    (ns.OnForeverPlayerAura), which only ever cares about auras on you.
]]
local function OnUnitAura(unit, updateInfo)
	if ns.OnBuffWindowAura then
		ns.OnBuffWindowAura(unit)
	end
	if ns.FLAVOR ~= "Camelot" or not ns.IsPlain(unit) or unit ~= "player" then
		return
	end
	ns.OnForeverPlayerAura(updateInfo)
end

local function OnLoadingScreenDisabled()
	StartSafetyTimer(Data.SAFETY_PAUSE)
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

-- Good News and Praise read these.
function ns.IsBuffTrackingReady()
	return isReady
end

function ns.GetPlayerGUID()
	return playerGUID
end

--[[
    Run once from Core's login sequence, after the saved variables are live and
    the spell/item APIs return real data. Builds the lookups and display groups,
    seeds the watched list, warms the item cache, and arms the safety timer.
]]
function ns.SetupBuffTracking()
	playerGUID = UnitGUID("player")
	ns.BuildTrackedData()
	StartSafetyTimer(Data.SAFETY_PAUSE)
end

ns.SetEventHandler("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered)
ns.SetEventHandler("UNIT_AURA", OnUnitAura)
ns.SetEventHandler("UNIT_SPELLCAST_SUCCEEDED", OnUnitSpellcastSucceeded)
ns.SetEventHandler("LOADING_SCREEN_DISABLED", OnLoadingScreenDisabled)
