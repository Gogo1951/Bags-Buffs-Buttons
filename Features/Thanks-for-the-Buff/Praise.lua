local _, ns = ...
local Data = ns.Data

--[[
    Reacting to a classified buff: the praise cooldowns, the emote target, and
    the print, sound, whisper and emote each buff panel offers. Buff-Tracking
    classifies the event and calls ns.HandleTracked or ns.HandleStrangersBuff.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local sessionCooldowns = {}

--------------------------------------------------------------------------------
-- Cooldowns
--------------------------------------------------------------------------------

local function IsOnCooldown(guid)
	local now = GetTime()
	local expiresAt = sessionCooldowns[guid]
	return expiresAt and expiresAt > now
end

local function SetCooldown(guid, duration)
	local now = GetTime()
	--[[
	    Opportunistic sweep: drop lapsed entries so the table can't grow unbounded
	    across a long session (one key per distinct source/recipient reacted to).
	    Clearing an existing field mid-pairs is defined behavior in Lua.
	]]
	for key, expiresAt in pairs(sessionCooldowns) do
		if expiresAt <= now then
			sessionCooldowns[key] = nil
		end
	end
	sessionCooldowns[guid] = now + (duration or 10)
end

--[[
    Per-recipient whisper throttle. Whispers go to OTHER players, so unlike the
    self-only prints (which fire on every buff) they must not repeat: a player who
    rebuffs you several times is thanked at most once per window, which also keeps
    us clear of Blizzard's whisper spam squelch. Keyed by GUID under a "whisper:"
    namespace so it never collides with the praise/service cooldowns on the same
    GUID, and it sits underneath the user-set praise cooldowns as a floor they
    cannot lower. Checks and stamps in one call, and only stamps when a whisper is
    actually cleared to send, so the window is measured from the last whisper we sent.
]]
local WHISPER_COOLDOWN = 45
local function TryWhisperCooldown(guid)
	if not guid then
		return true
	end
	local key = "whisper:" .. guid
	if IsOnCooldown(key) then
		return false
	end
	SetCooldown(key, WHISPER_COOLDOWN)
	return true
end

--[[
    The Strangers panel's overall praise limit: one key for the whole feature,
    since it asks "how recently did I praise ANYONE", not "how recently did I
    praise this player" (that is the per-source "praise:<guid>" key).
]]
local PRAISE_OVERALL_KEY = "praise:all"

-- Shared with Good News, which dedupes its whispers in the same table.
ns.IsOnCooldown = IsOnCooldown
ns.SetCooldown = SetCooldown

-- Diagnostics reads this: whether the overall, per-source and whisper throttles would hold praise back now. Never stamps.
function ns.GetPraiseCooldownState(guid)
	local overall = IsOnCooldown(PRAISE_OVERALL_KEY) and true or false
	local source = guid and IsOnCooldown("praise:" .. guid) and true or false
	local whisper = guid and IsOnCooldown("whisper:" .. guid) and true or false
	return overall, source, whisper
end

--------------------------------------------------------------------------------
-- Emote Target
--------------------------------------------------------------------------------

--[[
    Could this unit actually witness an emote? Holding a unit token proves the
    buffer exists, not that they are anywhere near you -- a party member who
    zoned into a dungeon, or ran two zones ahead, is still "party2".

    Two gates, both cheap. UnitIsVisible is the coarse one: it goes false the
    moment the client stops tracking the object, which is exactly the different
    zone / different instance / different continent case. UnitInRange is the
    tighter one at roughly spell range, but it answers only for group members --
    its second return says whether it checked at all, so a stranger falls
    through to the visibility verdict instead of to a bogus false.

    Deliberately looser than true emote range (emote text broadcasts at say
    range, far shorter than either check). Nothing in the API measures that, and
    erring loose costs an emote nobody sees, while erring tight silently drops
    thanks the buffer WAS standing there for -- the worse failure for an add-on
    whose whole job is thanking people.

    On WoW Forever UnitInRange answers a stranger with secret booleans even out
    of combat, and a boolean test on one errors. A secret verdict counts as
    "didn't check", the same as a stranger on the other flavors.
]]
local function CanWitnessEmote(unit)
	if not UnitExists(unit) or not UnitIsVisible(unit) then
		return false
	end
	local inRange, checkedRange = UnitInRange(unit)
	if ns.IsPlain(checkedRange) and ns.IsPlain(inRange) and checkedRange then
		return inRange
	end
	return true
end

--[[
    Best emote direction for a buffer: their unit token when we hold one, else
    their bare character name. The client resolves a name to any player it can
    currently see -- but only the bare form, never the combat log's cross-realm
    "Name-Realm", so the realm is stripped. Worst realistic miss is two visible
    same-named players from different realms, which just salutes the wrong twin.

    Returning nil means "do not emote", not "emote undirected" -- DoRandomEmote
    enforces that. A unit token we hold but that cannot witness the emote is
    dropped here rather than degraded, because degrading it produces "You thank
    everyone around you." aimed at nobody.

    Caveat on the name branch: no API pre-tests whether a name will resolve, and
    C_ChatInfo.PerformEmote does not report how it resolved one, so an absent
    stranger still reaches it as a name and still degrades to the undirected
    emote. That
    hole closes only by dropping the name fallback entirely, which would also
    drop the ordinary case of a stranger buffing you while standing right there
    untargeted -- the add-on's most common thank of all.
]]
local function ResolveEmoteTarget(guid, name)
	local unit = ns.GetUnitByGUID(guid)
	if unit then
		return CanWitnessEmote(unit) and unit or nil
	end
	if name then
		return Ambiguate(name, "short")
	end
	return nil
end

--------------------------------------------------------------------------------
-- Buff Handlers
--------------------------------------------------------------------------------

--[[
    Send the praise: the thank-you whisper, the emote, or both. Every gate -- the
    toggles, the cooldowns, the whisper throttle, the combat check -- is settled
    by the caller before the timer is armed, so the Praise Delay holds back
    delivery only; a burst of buffs can't slip past a cooldown by landing inside
    the delay window.

    Two things are deliberately decided late instead, when the emote actually
    fires. Combat, because the promise on that toggle is that an emote never
    plays while you are fighting. And the emote target: ResolveEmoteTarget hands
    back a live unit token, and "target", "focus", and "mouseover" all name
    whoever you are pointing at in that instant -- resolve it early and a delayed
    emote thanks whoever you moved on to. A buffer with no unit token degrades
    to their bare name, and nil means no emote at all; a bare name the client
    can't resolve still falls back to the undirected emote (see
    ResolveEmoteTarget).
]]
local function DeliverPraise(db, guid, name, link, whisperAllowed, emoteAllowed)
	local function Praise()
		if whisperAllowed then
			ns:WhisperThanks(name, link)
		end
		if emoteAllowed and not InCombatLockdown() then
			ns:DoRandomEmote(db.emotes, ResolveEmoteTarget(guid, name))
		end
	end

	local delay = db.praiseDelayEnabled and db.praiseDelay or 0
	if delay > 0 then
		C_Timer.After(delay, Praise)
	else
		Praise()
	end
end

--[[
    Group/raid PRINTS and emotes are intentionally NOT rate-limited: each cast is a
    distinct cooldown a teammate spent, so we acknowledge every one. The outgoing
    whisper is the exception -- it is throttled per-recipient (TryWhisperCooldown)
    so a teammate who repeatedly buffs you in a raid isn't whisper-spammed.
]]
local function HandleTracked(entry, spellID, creditGUID, creditName, destGUID)
	if entry.type == Data.BUFF.SERVICE then
		-- A service set out for the group: no per-you dest, just don't self-credit.
		if creditGUID == ns.GetPlayerGUID() then
			return
		end
	elseif destGUID ~= ns.GetPlayerGUID() then
		-- SOLO / GROUP buffs must actually land on you.
		return
	end

	if not ns.db.global.watchedBuffs[spellID] then
		return
	end

	--[[
	    No-aura raid help reacts with the Service Alerts settings; everything cast
	    on you (SOLO / GROUP) uses the Teammate Buffs settings.
	]]
	local db = (entry.type == Data.BUFF.SERVICE) and ns.db.global.services or ns.db.global.teammates
	--[[
	    Each panel's master switch, checked once here rather than at each of the
	    four outputs below.
	]]
	if not db.enabled then
		return
	end
	local link = ns.GetBuffLink(entry, spellID)

	if db.printEnabled then
		ns:AnnounceTracked(entry, creditGUID, creditName, link)
	end

	--[[
	    Like the print, the sound is self-only and fires on every acknowledged
	    cast, in or out of combat.
	]]
	if db.soundEnabled then
		ns.PlayBuffSound()
	end

	--[[
	    Emotes are visible and social, so a buff that lands while you are fighting
	    simply goes un-emoted: suppressed, never queued for after combat.
	]]
	local whisperAllowed = db.whisperEnabled and TryWhisperCooldown(creditGUID)
	local emoteAllowed = db.emotesEnabled and not InCombatLockdown()
	if whisperAllowed or emoteAllowed then
		DeliverPraise(db, creditGUID, creditName, link, whisperAllowed, emoteAllowed)
	end
end

local function HandleStrangersBuff(sourceGUID, sourceName, spellID)
	local db = ns.db.global.strangers
	if not db.enabled then
		return
	end

	-- nil means the buff isn't on you; a live buff may still report 0 (no timer).
	local duration = ns.GetBuffDuration("player", spellID)
	if not duration then
		return
	end

	-- Too short to be worth reacting to at all: no notification and no praise.
	if db.minBuffDuration and db.minBuffDuration > 0 and duration > 0 and duration < db.minBuffDuration then
		return
	end

	local link = ns.GetBuffLink(nil, spellID)

	--[[
	    Notifications are self-only and fire for every qualifying buff, in or out of
	    combat. Only the praise below answers to the cooldowns and the delay.
	]]
	if db.printEnabled then
		ns:AnnounceStranger(sourceGUID, sourceName, link)
	end

	if db.soundEnabled then
		ns.PlayBuffSound()
	end

	--[[
        Two praise cooldowns, both user settings: the overall one keeps a
        mass-buff moment from turning into a chain of thank-yous, the per-source
        one keeps a single player from being praised over and over. Neither is
        spent unless praise is cleared to go out, so a buff that arrives while you
        are in combat with emotes as your only enabled praise costs nothing. The
        per-recipient whisper throttle sits on top as a floor no setting can
        lower, so a short cooldown can't whisper someone into the server's chat
        squelch.
    ]]
	local sourceKey = "praise:" .. sourceGUID
	if IsOnCooldown(PRAISE_OVERALL_KEY) or IsOnCooldown(sourceKey) then
		return
	end

	local whisperAllowed = db.whisperEnabled and TryWhisperCooldown(sourceGUID)
	local emoteAllowed = db.emotesEnabled and not InCombatLockdown()
	if not whisperAllowed and not emoteAllowed then
		return
	end

	if db.praiseCooldown and db.praiseCooldown > 0 then
		SetCooldown(PRAISE_OVERALL_KEY, db.praiseCooldown)
	end
	SetCooldown(sourceKey, db.cooldown)

	DeliverPraise(db, sourceGUID, sourceName, link, whisperAllowed, emoteAllowed)
end

ns.HandleTracked = HandleTracked
ns.HandleStrangersBuff = HandleStrangersBuff
