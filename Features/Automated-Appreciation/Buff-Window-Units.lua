local _, ns = ...
local Data = ns.Data

--[[
    The Buff Window's unit reads: whether a unit can take a buff, the role and
    class it is buffed as, how far away it is, its row label, and the icons
    that cast at it. What it has on is Buff-Window-Auras.lua's. Shared with the other Buff Window files
    through ns.BuffWindow.
]]

local BuffWindow = ns.BuffWindow
local buffs = BuffWindow.buffs
local RankFor = BuffWindow.RankFor
local Has = BuffWindow.Has

--------------------------------------------------------------------------------
-- Unit Reads
--------------------------------------------------------------------------------

function BuffWindow.CanBuff(unit)
	return UnitExists(unit) and UnitIsPlayer(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
end

-- Your group as { unit, subgroup }: the raid by roster order, or you and your party.
function BuffWindow.GroupMembers()
	local members = {}
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local _, _, subgroup = GetRaidRosterInfo(i)
			if subgroup then
				members[#members + 1] = { unit = "raid" .. i, subgroup = subgroup }
			end
		end
	else
		members[1] = { unit = "player", subgroup = 1 }
		for i = 1, 4 do
			if UnitExists("party" .. i) then
				members[#members + 1] = { unit = "party" .. i, subgroup = 1 }
			end
		end
	end
	return members
end

-- Whether a Count as Tanks entry (a class token, or Data.TANK_WHEN_PET) applies right now.
local function CountsAsTank(key)
	local when = key and ns.db.global.buffWindow.tankWhen[key]
	return when == Data.TANK_WHEN.ALWAYS or (when == Data.TANK_WHEN.SOLO and not IsInGroup())
end

--[[
    The role a player is buffed as, for a buff offered to Tanks or Healers: the
    raid's Main Tank mark, then the role assigned in the group finder (damage
    included, so an assigned role always beats a ticked box). For you alone,
    with no role assigned, the roles ticked in the group finder's own listing (Era's solo
    Tank / Healer / DPS boxes, which never assign a role), the first ticked of
    Tank, then Healer -- a tank's buffs matter most. Anyone with none of these -- a
    low-level player who can't pick a role yet, a group that never set one, or
    a stranger (`unit` nil when out of sight) -- counts as a tank when the
    player's Count as Tanks setting says their `class` does right now, and
    otherwise as damage. An actual role always wins over the class setting.
    In a raid only the Main Tank mark makes a tank: a Tank role or box there is
    one a player ticked for themselves in the group finder, not the raid's
    call. The mark is asked for exactly -- without that, GetPartyAssignment
    also says yes to anyone whose role is Tank. Every group call is asked for
    by name, so a client without one simply skips to the next answer.
]]
function BuffWindow.RoleOf(unit, class)
	if unit then
		if GetPartyAssignment and GetPartyAssignment("MAINTANK", unit, true) then
			return "TANK"
		end
		local inRaid = IsInRaid()
		if UnitGroupRolesAssigned then
			local role = UnitGroupRolesAssigned(unit)
			if ns.IsPlain(role) and ((role == "TANK" and not inRaid) or role == "HEALER" or role == "DAMAGER") then
				return role
			end
		end
		if GetLFGRoles and UnitIsUnit(unit, "player") then
			local _, tank, healer = GetLFGRoles()
			if tank and not inRaid then
				return "TANK"
			elseif healer then
				return "HEALER"
			end
		end
	end
	if CountsAsTank(class) then
		return "TANK"
	end
	return "DAMAGER"
end

-- Is this player someone the buff is offered to at all, whatever they have on?
function BuffWindow.Wants(buff, class, role)
	if buff.manaOnly and Data.NO_MANA_CLASSES[class] then
		return false
	end
	if buff.noCasters and Data.CASTER_CLASSES[class] then
		return false
	end
	if buff.audience == Data.BUFF_AUDIENCE.TANK then
		return role == "TANK"
	elseif buff.audience == Data.BUFF_AUDIENCE.HEALER then
		return role == "HEALER"
	end
	return true
end

--[[
    A pet in Phase Shift (a warlock's imp) can't be targeted, so no buff
    reaches it until it phases back in, however close it stands. Secret auras
    on WoW Forever read as not shifted. Each unit's answer is kept for the
    frame it was read in: the range ticker asks once per icon, and one pet can
    have several.
]]
local phaseShifted, phaseShiftedAt = {}, nil

local function IsPhaseShifted(unit)
	local spellId = ns.GAME_IDS.PHASE_SHIFT_SPELL_ID
	if not spellId or ns.AreAurasSecret() then
		return false
	end
	local isPlayer = UnitIsPlayer(unit)
	if not ns.IsPlain(isPlayer) or isPlayer then
		return false
	end
	local now = GetTime()
	if phaseShiftedAt ~= now then
		wipe(phaseShifted)
		phaseShiftedAt = now
	end
	if phaseShifted[unit] == nil then
		phaseShifted[unit] = ns.GetBuffDuration(unit, spellId) ~= nil
	end
	return phaseShifted[unit]
end

--[[
    Is `unit` close enough to take `spellName`? A phase-shifted pet never is.
    Otherwise the spell's own range check first; when it has no answer,
    UnitInRange's group-wide ~40 yards, which only knows about group members. A unit we can't ask about reads as in range, and so does any
    secret answer (WoW Forever's for a stranger): the fade is a hint, and a
    wrong "out of range" would hide a buff the player could have cast.
]]
function ns.IsBuffInRange(unit, spellName)
	if not unit then
		return true
	end
	local isPlayer = UnitIsUnit(unit, "player")
	if not ns.IsPlain(isPlayer) or isPlayer then
		return true
	end
	if IsPhaseShifted(unit) then
		return false
	end
	if spellName then
		local inRange = C_Spell.IsSpellInRange(spellName, unit)
		if ns.IsPlain(inRange) and inRange ~= nil then
			return inRange and true or false
		end
	end
	local visible = UnitIsVisible(unit)
	if not ns.IsPlain(visible) then
		return true
	end
	if not visible then
		return false
	end
	local inRange, checked = UnitInRange(unit)
	if ns.IsPlain(checked) and ns.IsPlain(inRange) and checked then
		return inRange and true or false
	end
	return true
end

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

-- A pet's inline icon in front of its name, sized to the small font.
local LABEL_ICON_SIZE = 14

--[[
    The group finder's round role icons, cut from its 64-pixel sheet (as pixels,
    the way the |T escape wants them): left, right, top, bottom.
]]
local ROLE_ICON_SHEET = "Interface/LFGFrame/UI-LFG-ICON-PORTRAITROLES"
local ROLE_ICON_COORDS = {
	TANK = "0:19:22:41",
	HEALER = "20:39:1:20",
	DAMAGER = "20:39:22:41",
}

local function RoleIcon(role)
	return ("|T%s:%d:%d:0:0:64:64:%s|t "):format(
		ROLE_ICON_SHEET,
		Data.BUFF_WINDOW_ICON_SIZE,
		Data.BUFF_WINDOW_ICON_SIZE,
		ROLE_ICON_COORDS[role]
	)
end

--[[
    A player's row label: role icon, then the name in its class color -- the
    color already says the class, so the icon says the role. `unit` is nil for
    a stranger out of sight, who is shown as damage.
]]
function BuffWindow.PlayerLabel(name, class, unit)
	return RoleIcon(BuffWindow.RoleOf(unit, class)) .. (ns.GetClassColor(class) or ns.GetColor("TEXT")) .. name .. "|r"
end

--[[
    A pet's row label: its summoning spell's icon, then the name in its owner's
    class color. A warlock's demon is told apart by the creature ID in its GUID
    ("Pet-0-server-instance-zone-npc-spawn"); every other pet wears Call Pet.
]]
local function PetNPCID(unit)
	local guid = UnitGUID(unit)
	return ns.IsPlain(guid) and guid and tonumber(guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")) or nil
end

--[[
    The class of a pet's owner, read off the pet: a known demon is a warlock's,
    and a pet that runs on Focus is a hunter's beast. The tooltip's "'s Pet" or
    "'s Minion" (`guessed`) is the last resort only -- on Classic Era it named
    the owner without matching the wording that gives the class away.
]]
function BuffWindow.PetOwnerClass(unit, guessed)
	local npcID = PetNPCID(unit)
	if npcID and ns.BUFF_WINDOW_PET_ICONS.demons[npcID] then
		return "WARLOCK"
	end
	local powerType = UnitPowerType(unit)
	if ns.IsPlain(powerType) and Enum.PowerType.Focus and powerType == Enum.PowerType.Focus then
		return "HUNTER"
	end
	return guessed
end

local function PetLabel(unit, name, ownerClass)
	local icons = ns.BUFF_WINDOW_PET_ICONS
	local npcID = PetNPCID(unit)
	local spell = (npcID and icons.demons[npcID]) or icons.beast
	local texture = spell and C_Spell.GetSpellTexture(spell)
	-- The same 5-pixel trim the window's buttons give every spell icon's border.
	local icon = texture
			and ("|T" .. texture .. ":" .. LABEL_ICON_SIZE .. ":" .. LABEL_ICON_SIZE .. ":0:0:64:64:5:59:5:59|t ")
		or ""
	return icon .. (ns.GetClassColor(ownerClass) or ns.GetColor("HELP")) .. name .. "|r"
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

--[[
    /targetexact finds a nearby player by name with no unit token, and a miss
    leaves the old target in place. Clearing first means a miss leaves nothing
    targeted, so [help] stops the cast instead of falling through to whoever
    you had targeted or to yourself. Leaving the found player targeted is
    deliberate: it is how the window sees the buff land and drops the icon.
]]
local function TargetMacro(name, castText)
	return "/cleartarget\n/targetexact " .. name .. "\n/cast [help] " .. castText
end

--[[
    One single-target icon, sized to the target: `unit` is who it is for (nil
    when out of sight), `castUnit` the token the button casts at. Without a
    castUnit the button targets `fullName` by macro instead. The button casts
    the chosen rank by its rank text, "Power Word: Fortitude(Rank 2)": a bare
    name casts your highest rank and fails on anyone too low for it, and a
    spell ID did nothing at all on Classic Era. Nil when the target is too low
    for any rank.
]]
local function SingleIcon(buff, unit, castUnit, targetName, fullName, favorGUID)
	local rank = RankFor(buff, unit and UnitLevel(unit))
	if not rank then
		return nil
	end
	return {
		spellId = rank.id,
		column = buff.column,
		spellName = rank.name,
		castSpell = rank.castText,
		unit = castUnit,
		targetName = targetName,
		macrotext = not castUnit and TargetMacro(fullName, rank.castText) or nil,
		favorGUID = favorGUID,
		buffKey = buff.key,
	}
end
BuffWindow.SingleIcon = SingleIcon

--[[
    Stamps an icon with the version running low that Has reported, so the
    window draws how much of it is left; an icon for a buff that is gone
    entirely carries none and draws whole. Returns the icon.
]]
function BuffWindow.WithTimeLeft(icon, expires, duration)
	if icon and expires and duration and duration > 0 then
		icon.buffExpires, icon.buffDuration = expires, duration
	end
	return icon
end

--------------------------------------------------------------------------------
-- Resurrections
--------------------------------------------------------------------------------

--[[
    A dead player's resurrection sits in a column of its own, ahead of every
    buff's (which count from 1), so it always lines up on the left.
]]
local RESURRECTION_COLUMN = 0

--[[
    How long a resurrection that went off -- yours or another healer's -- keeps
    its target's icon away: the minute the game gives them to accept it.
]]
local RESURRECT_PENDING_SECONDS = 60
local pendingResurrects = {} -- GUID -> GetTime() the offer runs out

--[[
    Called from Buff-Tracking's combat log handler on every SPELL_RESURRECT,
    which fires as the cast lands, before the dead player accepts, and on
    Forever, which has no combat log, from your own resurrection going off
    (ns.OnResurrectCastSucceeded). Without it
    the icon would stay up through that minute and invite a second healer to
    spend ten seconds on a resurrection already waiting.
]]
function BuffWindow.NoteResurrect(guid)
	if not ns.IsPlain(guid) or not guid then
		return
	end
	local now = GetTime()
	for key, expires in pairs(pendingResurrects) do
		if expires <= now then
			pendingResurrects[key] = nil
		end
	end
	pendingResurrects[guid] = now + RESURRECT_PENDING_SECONDS
	if ns.RequestBuffWindowRefresh then
		ns.RequestBuffWindowRefresh()
	end
end

--[[
    A dead player you can bring back: not you, still connected, and lying
    there -- a released ghost has no corpse here to cast on. One with a
    resurrection already being cast, or one waiting to accept, needs no second.
]]
local function CanResurrect(unit)
	if not UnitExists(unit) or not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
		return false
	end
	if not UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
		return false
	end
	if UnitHasIncomingResurrection then
		local incoming = UnitHasIncomingResurrection(unit)
		if ns.IsPlain(incoming) and incoming then
			return false
		end
	end
	local guid = UnitGUID(unit)
	local expires = ns.IsPlain(guid) and guid and pendingResurrects[guid]
	return not (expires and expires > GetTime())
end

--[[
    The icon that resurrects `unit`, cast at `castUnit`, or nil when you have
    no resurrection or they can't take one. Cast by its bare name, which
    resolves to the highest rank you know; castIds lets the Buff Key match
    the cast whichever rank that is.
]]
function BuffWindow.ResurrectionIcon(unit, castUnit, targetName)
	local resurrection = BuffWindow.resurrection
	if not resurrection or not CanResurrect(unit) then
		return nil
	end
	return {
		spellId = resurrection.id,
		column = RESURRECTION_COLUMN,
		spellName = resurrection.name,
		castSpell = resurrection.name,
		castIds = resurrection.ids,
		unit = castUnit,
		targetName = targetName,
		isResurrection = true,
	}
end

--------------------------------------------------------------------------------
-- Pets
--------------------------------------------------------------------------------

--[[
    A pet takes the buffs offered to Everyone, and those offered to Tanks while
    Count as Tanks says pets do (by default only while you're not grouped:
    solo, a pet is usually what holds aggro) -- never those for Healers. It has
    no role of its own, and its "class" is the creature's, not a player class.
    Whether it has mana is read off its power bar instead, so a warlock's demon
    gets Intellect and a hunter's beast doesn't.
]]
local function PetWants(buff, unit)
	if buff.audience == Data.BUFF_AUDIENCE.TANK then
		if not CountsAsTank(Data.TANK_WHEN_PET) then
			return false
		end
	elseif buff.audience ~= Data.BUFF_AUDIENCE.ALL then
		return false
	end
	if buff.manaOnly then
		local powerType = UnitPowerType(unit)
		return ns.IsPlain(powerType) and powerType == Enum.PowerType.Mana
	end
	return true
end

-- A phase-shifted imp drops off the list: nothing can reach it until it phases back in.
local function CanBuffPet(unit)
	return UnitExists(unit) and not UnitIsPlayer(unit) and not UnitIsDeadOrGhost(unit) and not IsPhaseShifted(unit)
end
BuffWindow.CanBuffPet = CanBuffPet

-- The pet token that goes with a group member's token.
function BuffWindow.PetUnitOf(unit)
	if unit == "player" then
		return "pet"
	end
	local prefix, index = unit:match("^(%a+)(%d+)$")
	return prefix and (prefix .. "pet" .. index) or nil
end

--[[
    A pet's row: its missing buffs, cast at `castUnit` (the pet's own token in
    the party list, "target" or "targetpet" in the Target list). Nil when it
    needs nothing. Under its owner it is indented and named alone; standing on
    its own (a targeted stranger's pet) it carries `ownerName` in brackets
    instead, "Valko (Kiib)", since the owner has no row of their own above it.
]]
function BuffWindow.PetRow(unit, castUnit, ownerClass, ownerName)
	if not unit or not CanBuffPet(unit) then
		return nil
	end
	BuffWindow.ReadAuras(unit)
	local name = GetUnitName(unit, false) or ""
	local icons = {}
	for _, buff in ipairs(buffs) do
		if buff.singleName and PetWants(buff, unit) then
			local has, expires, duration = Has(buff, unit)
			if not has then
				icons[#icons + 1] = BuffWindow.WithTimeLeft(SingleIcon(buff, unit, castUnit, name), expires, duration)
			end
		end
	end
	if #icons == 0 then
		return nil
	end
	if ownerName then
		return { label = PetLabel(unit, name .. " (" .. ownerName .. ")", ownerClass), icons = icons }
	end
	return { label = PetLabel(unit, name, ownerClass), icons = icons, pet = true }
end
