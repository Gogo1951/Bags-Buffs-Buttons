local _, ns = ...

--[[
    The Buff Window's aura cache: what each player has on, read once per change
    and kept by GUID, the strength your own casts land with, and the buffs a
    stronger one refused. Shared with the other Buff Window files through
    ns.BuffWindow.
]]

local BuffWindow = ns.BuffWindow
local buffs = BuffWindow.buffs
local exclusiveIds = BuffWindow.exclusiveIds
local RankFor = BuffWindow.RankFor

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
    Each unit's buffs as last read, keyed by GUID so an aura change reported on
    any of a player's tokens marks the one record: spell id -> expiration time,
    -> duration, -> strength (see AuraStrength), and -> true for the auras you
    cast. A record is read again only
    once its GUID is marked dirty, a MarkAllAurasDirty has passed since its
    read, or its unit has died, revived or changed connection, so a raid's aura
    traffic re-reads only the members it touched.
]]
local auraCache = {}
local dirtyGUIDs = {}
local generation = 0

local function NewRecord()
	return { expires = {}, durations = {}, strengths = {}, mine = {} }
end

-- Read fresh every time: a unit whose GUID can't be read has no record to keep.
local uncachedRecord = NewRecord()

-- The record ReadAuras last selected, which Has reads.
local auraExpires, auraDurations, auraStrengths, auraMine =
	uncachedRecord.expires, uncachedRecord.durations, uncachedRecord.strengths, uncachedRecord.mine

--[[
    Spell id -> the strength your own cast of it landed with, learned from
    every aura of yours ReadAuras sees, on anyone. Talents raise it (Improved
    Mark of the Wild), so it is only known once you have cast that rank this
    session; until then Has falls back to comparing ranks.
]]
local myStrengths = {}

-- Talents and new ranks change what your casts land with, so it is learned again.
function BuffWindow.ForgetMyStrengths()
	wipe(myStrengths)
end

--[[
    GUID -> buff key -> { aura id -> expiration time }: the versions of a buff
    the game refused to cast over ("A more powerful spell is already active").
    Classic Era and TBC Anniversary give no strength for another caster's buff,
    so a stronger talented one only shows itself this way. Has counts the
    buff as had while that same version, by its expiration time, is still on
    them; a refresh or a new one is looked at afresh.
]]
local bounced = {}

-- The GUID whose record ReadAuras last selected, nil for an uncached one.
local auraGUID

--[[
    How strong an aura is: the sum of its effect values (`points`), the armor,
    stats or attack power it gives, talents included. Every version of a buff
    -- its ranks, its group and Greater versions -- shares one effect layout,
    so the sums compare across them. Nil when the client gives no values, or
    only zeros, or keeps them secret.
]]
local function AuraStrength(points)
	if not ns.IsPlain(points) or type(points) ~= "table" then
		return nil
	end
	local total = 0
	for _, value in ipairs(points) do
		if not ns.IsPlain(value) or type(value) ~= "number" then
			return nil
		end
		total = total + value
	end
	return total > 0 and total or nil
end

--[[
    Every record goes stale, and one not read since the last call is dropped, so
    the cache holds only players the window still looks at.
]]
function BuffWindow.MarkAllAurasDirty()
	for guid, record in pairs(auraCache) do
		if record.generation ~= generation then
			auraCache[guid] = nil
		end
	end
	for guid in pairs(bounced) do
		if not auraCache[guid] then
			bounced[guid] = nil
		end
	end
	wipe(dirtyGUIDs)
	generation = generation + 1
end

--[[
    Drops the records of players the window no longer looks at: anyone outside
    your group, your target, and their pets. One dropped by mistake is only read
    again, so this keeps the cache bounded without marking anyone stale.
]]
function BuffWindow.PruneAuraCache()
	local keep = {}
	local function Keep(unit)
		local guid = unit and UnitGUID(unit)
		if guid and ns.IsPlain(guid) then
			keep[guid] = true
		end
	end
	Keep("pet")
	Keep("target")
	Keep("targetpet")
	for _, member in ipairs(BuffWindow.GroupMembers()) do
		Keep(member.unit)
		Keep(BuffWindow.PetUnitOf(member.unit))
	end
	for guid in pairs(auraCache) do
		if not keep[guid] then
			auraCache[guid] = nil
			dirtyGUIDs[guid] = nil
		end
	end
	for guid in pairs(bounced) do
		if not keep[guid] then
			bounced[guid] = nil
		end
	end
end

function BuffWindow.MarkAurasDirty(unit)
	local guid = UnitGUID(unit)
	if guid and ns.IsPlain(guid) then
		dirtyGUIDs[guid] = true
	else
		BuffWindow.MarkAllAurasDirty()
	end
end

-- A death, revive or dropped connection may reach the window with no aura event, so each one re-reads.
function BuffWindow.ReadAuras(unit)
	local guid = UnitGUID(unit)
	local record = uncachedRecord
	auraGUID = nil
	if guid and ns.IsPlain(guid) then
		auraGUID = guid
		local dead = UnitIsDeadOrGhost(unit) and true or false
		local connected = UnitIsConnected(unit) and true or false
		record = auraCache[guid]
		if
			record
			and record.generation == generation
			and not dirtyGUIDs[guid]
			and record.dead == dead
			and record.connected == connected
		then
			auraExpires, auraDurations, auraStrengths, auraMine =
				record.expires, record.durations, record.strengths, record.mine
			return
		end
		record = record or NewRecord()
		record.generation = generation
		record.dead = dead
		record.connected = connected
		auraCache[guid] = record
		dirtyGUIDs[guid] = nil
	end

	auraExpires, auraDurations, auraStrengths, auraMine =
		record.expires, record.durations, record.strengths, record.mine
	wipe(auraExpires)
	wipe(auraDurations)
	wipe(auraStrengths)
	wipe(auraMine)
	for i = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
		if not data then
			return
		end
		if ns.IsPlain(data.spellId) and data.spellId then
			local expires, duration = data.expirationTime, data.duration
			auraExpires[data.spellId] = ns.IsPlain(expires) and expires or 0
			auraDurations[data.spellId] = ns.IsPlain(duration) and duration or 0
			local strength = AuraStrength(data.points)
			auraStrengths[data.spellId] = strength
			local source = data.sourceUnit
			if ns.IsPlain(source) and source == "player" then
				auraMine[data.spellId] = true
				myStrengths[data.spellId] = strength or myStrengths[data.spellId]
			end
		end
	end
end

--[[
    Asked after ReadAuras(unit) for the same unit. A buff about to run out --
    under the player's "Refresh Under" time -- counts as missing, so it
    can be topped up before it drops. A buff with no timer never runs out, and
    one whose whole duration is no longer than that time only counts once it is
    gone: otherwise a 10-minute Thorns under a 10-minute setting would read as
    missing the moment it landed, and never stop.

    Strength comes first, once both sides are known: the version on them
    against what your cast of the rank you'd use landed with (myStrengths). A
    stronger one -- another caster's talents, or a rank you don't have -- counts
    as had however little is left, since the game refuses to cast over it ("A
    more powerful spell is already active"). A weaker one counts as missing
    however much is left, so your talented version replaces it. An equal one
    goes by time, as above.

    With either side unknown, ranks decide instead. A single-target rank lower
    than the one you would cast on `unit` -- the highest you know that their
    level can take -- counts as missing, so a stranger's Rank 2 Arcane
    Intellect doesn't hide your Rank 5, and a higher one counts as had however
    little is left. Group and Greater versions go by time: they aren't ranked
    against the single ones.

    A version the game already refused to cast over (BuffWindow.NoteBounce)
    counts as had, by either rule, for as long as it stays on them.

    An exclusive buff (a blessing) also counts as had when the unit carries
    ANOTHER of yours from the same family, even one running low: you can only
    have one on them, so casting this one would replace yours rather than add
    to it. With none of yours on them, every one you turned on is offered.

    When it counts as missing because a version is running low, the second and
    third returns are that version's expiration time and full duration, which
    the window draws as the time left on the icon.
]]
local function Has(buff, unit)
	local now = GetTime()
	-- A self buff carries its own time; every other buff uses the window's.
	local threshold = buff.refreshSeconds or BuffWindow.refreshSeconds
	local best = RankFor(buff, unit and UnitLevel(unit))
	local mine = (best and myStrengths[best.id]) or (buff.groupId and myStrengths[buff.groupId])
	local bounce = auraGUID and bounced[auraGUID] and bounced[auraGUID][buff.key]
	local lowExpires, lowDuration
	for id in pairs(buff.auraIds) do
		local expires = auraExpires[id]
		if expires then
			if bounce and bounce[id] == expires then
				return true
			end
			local level = buff.rankLevels[id]
			local strength = auraStrengths[id]
			local counts
			if mine and strength then
				if strength > mine then
					return true
				end
				counts = strength == mine
			elseif best and level and level > best.level then
				return true
			else
				counts = not (best and level and level < best.level)
			end
			if counts then
				if expires == 0 or auraDurations[id] <= threshold or expires - now >= threshold then
					return true
				end
				if not lowExpires or expires > lowExpires then
					lowExpires, lowDuration = expires, auraDurations[id]
				end
			end
		end
	end
	if buff.exclusive then
		for id in pairs(exclusiveIds[buff.exclusive]) do
			if auraMine[id] and not buff.auraIds[id] then
				return true
			end
		end
	end
	return false, lowExpires, lowDuration
end
BuffWindow.Has = Has

--[[
    The game refused a cast of the buff with this key on `unit`: record every
    version of it they carry now, so Has leaves them alone until it changes.
    Read straight off the unit rather than the cache, which may be older.
]]
function BuffWindow.NoteBounce(unit, buffKey)
	if ns.AreAurasSecret() then
		return
	end
	local guid = UnitGUID(unit)
	if not guid or not ns.IsPlain(guid) then
		return
	end
	for _, buff in ipairs(buffs) do
		if buff.key == buffKey then
			local seen = {}
			for i = 1, 40 do
				local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
				if not data then
					break
				end
				local id, expires = data.spellId, data.expirationTime
				if ns.IsPlain(id) and ns.IsPlain(expires) and buff.auraIds[id] then
					seen[id] = expires
				end
			end
			if next(seen) then
				bounced[guid] = bounced[guid] or {}
				bounced[guid][buffKey] = seen
				dirtyGUIDs[guid] = true
			end
			return
		end
	end
end
