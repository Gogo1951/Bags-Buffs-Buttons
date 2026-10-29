local _, ns = ...
local Data = ns.Data

--------------------------------------------------------------------------------
-- Good News
--------------------------------------------------------------------------------

--[[
    Good News whispers for tracked buffs YOU cast on another player.

    Driven by UNIT_SPELLCAST_SENT + UNIT_SPELLCAST_SUCCEEDED, NOT the combat log.
    Trap: the combat log is scoped to you, your group, and units in combat, so
    buffing a player outside your group produces no SPELL_AURA_APPLIED at all --
    the single most common case for this feature is exactly the one the combat
    log never reports. SENT is also the only event that names the recipient;
    SUCCEEDED then confirms the cast actually went off, so an interrupted cast
    stays silent.

    Deduped per recipient+spell so a quick recast doesn't whisper twice.
]]
local pendingGiven = {} -- castGUID -> recipient captured at UNIT_SPELLCAST_SENT

local GOODNEWS_DEDUP = 10
local PENDING_TTL = 15 -- a SENT whose SUCCEEDED never arrives (cast interrupted)
local AURA_SETTLE = 0.1 -- the aura lands a moment after the cast succeeds

--[[
    UNIT_SPELLCAST_SENT names the recipient but gives neither unit nor GUID. Map
    the name back to a unit we hold, which is what lets us confirm the recipient
    is a player (buffing a pet must stay silent -- it has nobody to read the
    whisper) and read the buff's duration off them afterwards. Ordered by how
    people actually cast: at your target, a mouseover/focus macro, then a group
    member by unit token.
]]
local CAST_AT_UNITS = { "target", "mouseover", "focus" }

local function ResolveUnitByName(name)
	if not name then
		return nil
	end
	local short = Ambiguate(name, "short")
	local function Matches(unit)
		if not UnitExists(unit) or ns.IsUnitIdentitySecret(unit) then
			return false
		end
		local unitName = GetUnitName(unit, true)
		return unitName ~= nil and (unitName == name or Ambiguate(unitName, "short") == short)
	end

	for _, unit in ipairs(CAST_AT_UNITS) do
		if Matches(unit) then
			return unit, UnitGUID(unit)
		end
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		local unit = prefix .. i
		if Matches(unit) then
			return unit, UnitGUID(unit)
		end
	end
	return nil
end

local function SweepPendingGiven()
	local cutoff = GetTime() - PENDING_TTL
	for castGUID, pending in pairs(pendingGiven) do
		if pending.at < cutoff then
			pendingGiven[castGUID] = nil
		end
	end
end

local function AnnounceGivenCast(pending)
	local dedupKey = "goodnews:" .. pending.guid .. ":" .. pending.spellID
	if ns.IsOnCooldown(dedupKey) then
		return
	end
	ns.SetCooldown(dedupKey, GOODNEWS_DEDUP)

	--[[
        The aura is applied a beat after the cast succeeds, so reading it now
        would report "no duration" for every buff. Wait a tick, then read it off
        the recipient -- re-checking the unit still holds their GUID, since they
        may have been untargeted in the meantime. A no-aura cast (Rebirth), an
        unreadable one, and one whose auras or identity are secret all fall
        through to the duration-less flavor.
    ]]
	C_Timer.After(AURA_SETTLE, function()
		local duration
		if
			pending.unit
			and pending.auraId
			and not ns.AreAurasSecret()
			and not ns.IsUnitIdentitySecret(pending.unit)
			and UnitGUID(pending.unit) == pending.guid
		then
			duration = ns.GetBuffDuration(pending.unit, pending.auraId)
		end
		ns:AnnounceGoodNews(pending.entry, pending.name, pending.spellID, duration)
	end)
end

--[[
    The other half of a resurrect-detect Good News whisper. UNIT_SPELLCAST_SUCCEEDED
    parks the record instead of announcing it, because a jumper-cable cast succeeds
    whether or not the target gets up; this is the combat-log event that only a
    working jolt produces, so it is what releases the whisper.

    Matched on recipient + spell rather than castGUID, which the combat log does
    not carry. Swept first so a failed jolt's stale record can never be claimed by
    a later revive of the same person with the same cables.
]]
function ns.ClaimPendingResurrect(destGUID, spellID)
	if not destGUID then
		return
	end
	SweepPendingGiven()
	for castGUID, pending in pairs(pendingGiven) do
		if pending.guid == destGUID and pending.spellID == spellID then
			pendingGiven[castGUID] = nil
			AnnounceGivenCast(pending)
			return
		end
	end
end

--[[
    Good News for a cast of yours. "Yours" includes your PET's: Roar of Sacrifice
    and Battle Squawk are cast by the pet, never by the player, so a bare
    unit == "player" test would leave every pet-cast entry silent.

    Nothing downstream needs to know which of the two it was. The whisper names
    the buff, not the caster, and the recipient's experience is identical either
    way; crediting the owner is the whole point of tracking a pet's cast at all.
    Core registers UNIT_SPELLCAST_SENT for "player" and "pet" only, and "pet"
    means yours, so no other caster reaches here.
]]
local function OnUnitSpellcastSent(_, target, castGUID, spellID)
	if not ns.IsBuffTrackingReady() or not ns.db then
		return
	end

	-- A recipient whose identity is secret arrives as a secret name that can't be compared or key a table.
	if not (ns.IsPlain(target) and ns.IsPlain(castGUID) and ns.IsPlain(spellID)) then
		return
	end

	local db = ns.db.global.goodNews
	if not db or not db.whisperEnabled then
		return
	end
	local entry = ns.GetGivenEntry(spellID)
	if not entry or not db.watched[entry.watchedId] then
		return
	end

	local recipientUnit, guid = ResolveUnitByName(target)
	--[[
	    Players only, never yourself. An unresolvable name is dropped rather than
	    guessed at: we can't confirm it isn't a pet, and a whisper to a pet bounces.
	]]
	if not ns.IsPlayerGUID(guid) or guid == ns.GetPlayerGUID() then
		return
	end
	local fullName = GetUnitName(recipientUnit, true)
	if not fullName or not ns.IsPlain(fullName) then
		fullName = target
	end

	--[[
	    Recipient scope: ALWAYS whispers anyone you buff; everything else means
	    group members only -- your party or raid, and a battleground IS a raid
	    group, so it needs no case of its own. Unrecognized values fail closed
	    into the group check: for an outgoing-whisper feature, the safe wrong
	    guess is fewer strangers whispered, not more.
	]]
	if db.scope ~= "ALWAYS" then
		if not (UnitInParty(recipientUnit) or UnitInRaid(recipientUnit)) then
			return
		end
	end

	SweepPendingGiven()
	pendingGiven[castGUID] = {
		name = fullName,
		guid = guid,
		unit = recipientUnit,
		entry = entry,
		spellID = spellID,
		auraId = entry.auraId,
		at = GetTime(),
	}
end

--[[
    The UNIT_SPELLCAST_SUCCEEDED half, called from Buff-Tracking's handler for
    every cast. A resurrect-detect cast is left parked instead of announced: the
    cables succeeding is not the target getting up, and whispering "I revived
    you" at someone still face-down is the bug. ns.ClaimPendingResurrect releases
    it when SPELL_RESURRECT confirms the revive, and SweepPendingGiven discards it
    when no such event ever arrives.
]]
function ns.ClaimPendingGiven(castGUID)
	local pending = pendingGiven[castGUID]
	if pending and pending.entry.detect ~= Data.DETECT.RESURRECT then
		pendingGiven[castGUID] = nil
		AnnounceGivenCast(pending)
	end
end

ns.SetEventHandler("UNIT_SPELLCAST_SENT", OnUnitSpellcastSent)
