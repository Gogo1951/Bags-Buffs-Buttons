local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The Buff Window -- who in your group is missing a buff YOU can give.

    Reads this client's ns.BUFF_WINDOW_SPELLS, keeps the rows for your class
    whose spells you know, and on every roster or aura change works out, per
    party, which members lack each buff. What it finds goes to
    Features/Buff-Window-Frame.lua as plain section tables to draw; no Buff
    Window logic file owns a frame. A member only appears while they are
    missing something, and a party only while one of its members is, so a fully
    buffed raid shows no window at all.

    The work is split six ways, sharing state through ns.BuffWindow:
    Buff-Window-Castable.lua (what you can cast), Buff-Window-Units.lua
    (reading one unit and building its icons), Buff-Window-Self.lua (your own
    buffs, weapons and Soulstone, pinned on top), Buff-Window-Outsiders.lua
    (your target, and strangers who just buffed you, listed above the parties),
    this file (your group's sections, the refresh, events and setup), and
    Buff-Window-Keys.lua (the key binding that casts from the same list).

    Nothing is read in combat: the window's buttons are secure and can't be
    redrawn there anyway (see the frame file), so a change mid-fight waits for
    PLAYER_REGEN_ENABLED.
]]

local BuffWindow = ns.BuffWindow
local buffs = BuffWindow.buffs
local HasAnythingToOffer = BuffWindow.HasAnythingToOffer
local GroupMembers = BuffWindow.GroupMembers
local CanBuff = BuffWindow.CanBuff
local ReadAuras = BuffWindow.ReadAuras
local RoleOf = BuffWindow.RoleOf
local Wants = BuffWindow.Wants
local Has = BuffWindow.Has
local SingleIcon = BuffWindow.SingleIcon
local ResurrectionIcon = BuffWindow.ResurrectionIcon
local PlayerLabel = BuffWindow.PlayerLabel
local PetRow = BuffWindow.PetRow
local PetUnitOf = BuffWindow.PetUnitOf
local MarkAurasDirty = BuffWindow.MarkAurasDirty
local MarkAllAurasDirty = BuffWindow.MarkAllAurasDirty

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local inCombat = false
local settingsPending = false
local refreshQueued = false

-- Long enough to fold a raid-wide buff landing on 40 people into one redraw.
local REFRESH_DELAY = 0.3

--[[
    A redraw on a timer, for the changes no event reaches the window with: a
    buff running down under Refresh Under, and a member dying, reviving or
    dropping offline. Neither needs a full re-read: Has compares cached
    expirations with the clock, and ReadAuras re-reads a record whose unit has
    died, revived or changed connection since it was read.
]]
local BACKSTOP_INTERVAL = 3

--------------------------------------------------------------------------------
-- Group Sections
--------------------------------------------------------------------------------

--[[
    A group buff lands on its target's party, so any member who needs it will
    do; one in range is the one worth clicking.
]]
local function PickGroupTarget(units, spellName)
	for _, unit in ipairs(units) do
		if ns.IsBuffInRange(unit, spellName) then
			return unit
		end
	end
	return units[1]
end

--[[
    One section per party with something missing: the party's group-buff icons
    on its header, then a row per member with their single-target icons. Every
    party gets its own group icon once any of its members is missing the buff
    -- a raid buffs party by party, so a party of one in a raid still needs its
    own. Only solo, outside any group, is there none: the single version does
    the same for no reagent.

    A member's pet sits on its own row under them, and keeps the member listed
    -- with no icons of their own, if they need nothing -- until the pet is
    buffed too. Pets don't count toward a group icon: the group versions are
    cast to be sure of the players.

    A dead member you can resurrect gets a row with that one icon, in its own
    column on the left, and drops off once they're back up (or a resurrection
    is waiting on them to accept).
]]
local function AddGroupSections(sections)
	local grouped = IsInGroup()
	local raid = IsInRaid()
	local parties = {}

	for _, member in ipairs(GroupMembers()) do
		local party = parties[member.subgroup]
		if not party then
			party = { missing = {}, low = {}, rows = {} }
			parties[member.subgroup] = party
		end

		local unit = member.unit
		local _, class = UnitClass(unit)
		local name = GetUnitName(unit, false) or ""
		local row
		if CanBuff(unit) then
			ReadAuras(unit)
			local role = RoleOf(unit, class)
			for _, buff in ipairs(buffs) do
				local has, expires, duration = true, nil, nil
				if Wants(buff, class, role) then
					has, expires, duration = Has(buff, unit)
				end
				if not has then
					local missing = party.missing[buff] or {}
					party.missing[buff] = missing
					missing[#missing + 1] = unit
					--[[
					    The group icon shows time left only while every member it
					    is for has some: the soonest of theirs. One with none
					    makes it whole.
					]]
					local low = party.low[buff] or { count = 0 }
					party.low[buff] = low
					if expires then
						low.count = low.count + 1
						if not low.expires or expires < low.expires then
							low.expires, low.duration = expires, duration
						end
					end
					local icon = buff.singleName and SingleIcon(buff, unit, unit, name)
					if icon then
						row = row or { label = PlayerLabel(name, class, unit), icons = {} }
						row.icons[#row.icons + 1] = BuffWindow.WithTimeLeft(icon, expires, duration)
					end
				end
			end
		else
			local icon = ResurrectionIcon(unit, unit, name)
			if icon then
				row = { label = PlayerLabel(name, class, unit), icons = { icon } }
			end
		end

		local petRow = PetRow(PetUnitOf(unit), PetUnitOf(unit), class)
		if petRow then
			row = row or { label = PlayerLabel(name, class, unit), icons = {} }
		end
		if row then
			party.rows[#party.rows + 1] = row
		end
		if petRow then
			party.rows[#party.rows + 1] = petRow
		end
	end

	for subgroup = 1, 8 do
		local party = parties[subgroup]
		if party then
			local icons = {}
			for _, buff in ipairs(buffs) do
				local missing = party.missing[buff]
				if buff.groupName and missing and grouped then
					local target = PickGroupTarget(missing, buff.groupName)
					local low = party.low[buff]
					local partial = low.count == #missing
					icons[#icons + 1] = BuffWindow.WithTimeLeft({
						spellId = buff.groupId,
						castIds = buff.groupIds,
						column = buff.column,
						spellName = buff.groupName,
						castSpell = buff.groupCastText,
						unit = target,
						targetName = GetUnitName(target, false) or "",
						isGroup = true,
						buffKey = buff.key,
						--[[
						    For the Buff Key, which weighs this against the
						    members' single casts (GroupChoices).
						]]
						subgroup = subgroup,
						members = missing,
					}, partial and low.expires, partial and low.duration)
				end
			end
			if #icons > 0 or #party.rows > 0 then
				sections[#sections + 1] = {
					kind = "party",
					subgroup = subgroup,
					label = raid and GROUP_NUMBER:format(subgroup) or GROUP,
					icons = icons,
					rows = party.rows,
					-- The frame lays parties out two to a row.
					party = true,
				}
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Refresh
--------------------------------------------------------------------------------

--[[
    Every section the window would show, in display order: your own buffs,
    then the players outside your group (Target, Return the Favor), then the
    parties, which the frame lays out two to a row in a raid. The Buff
    Key reads the same list, so it casts only what the window offers.
]]
function BuffWindow.BuildSections()
	BuffWindow.refreshSeconds = (ns.db.global.buffWindow.refreshMinutes or 0) * 60
	local sections = {}
	BuffWindow.AddSelfSection(sections)
	BuffWindow.AddOutsiderSections(sections)
	AddGroupSections(sections)
	return sections
end

--[[
    When to Show: your class ticked, then Solo or In Group, whichever you are
    now, switched on, and In Instance kept to dungeons, raids, battlegrounds
    and arenas. The Buff Key asks the same, so it casts nothing the window
    hides.
]]
function BuffWindow.ShowsHere()
	local db = ns.db.global.buffWindow
	local _, class = UnitClass("player")
	if db.showClasses[class] == false then
		return false
	end
	local show, where
	if IsInGroup() then
		show, where = db.showGroup, db.showGroupWhere
	else
		show, where = db.showSolo, db.showSoloWhere
	end
	if not show then
		return false
	end
	return where ~= Data.BUFF_WINDOW_WHERE.INSTANCE or (IsInInstance())
end

local function Refresh()
	if not BuffWindow.isSetUp or not ns.db then
		return
	end
	-- Combat: the buttons can't be redrawn, and REGEN_ENABLED re-runs this.
	if inCombat or InCombatLockdown() then
		return
	end

	local db = ns.db.global.buffWindow
	if not db.enabled or not HasAnythingToOffer() or ns.AreAurasSecret() or not BuffWindow.ShowsHere() then
		ns.HideBuffWindow()
		return
	end

	local sections = BuffWindow.BuildSections()
	if #sections == 0 then
		ns.HideBuffWindow()
	else
		ns.RenderBuffWindow(sections)
	end
end

-- Every trigger funnels through here, so a burst of them costs one Refresh.
function ns.RequestBuffWindowRefresh()
	if refreshQueued then
		return
	end
	refreshQueued = true
	C_Timer.After(REFRESH_DELAY, function()
		refreshQueued = false
		Refresh()
	end)
end

local function ApplySettings()
	settingsPending = not ns.ApplyBuffWindowSettings()
end

-- Re-applies the window's settings, its position included, once combat ends.
function ns.QueueBuffWindowSettings()
	settingsPending = true
end

-- The options panel's entry point after any Buff Window setting changes.
function ns.RefreshBuffWindow()
	if not BuffWindow.isSetUp then
		return
	end
	BuffWindow.BuildBuffs()
	ApplySettings()
	MarkAllAurasDirty()
	ns.RequestBuffWindowRefresh()
end

--[[
    Buff Duty on the class you're playing: the feature switch on and your
    class ticked under Classes. The close button and the mini-map button work
    per class through these, so closing the window on a rogue leaves it up on
    a druid. Turning it on ticks your class and flips the switch on with it.
]]
function ns.IsBuffDutyOnForClass()
	local _, class = UnitClass("player")
	return ns.IsFeatureOn("buffWindow") and ns.db.global.buffWindow.showClasses[class] ~= false
end

function ns.SetBuffDutyForClass(on)
	local _, class = UnitClass("player")
	ns.db.global.buffWindow.showClasses[class] = on
	-- Through the feature switch, which redraws the window and repaints the panels.
	ns.SetFeatureSwitch("buffWindow", on or ns.IsFeatureOn("buffWindow"))
end

--[[
    The window's close button. Turns Buff Duty off for your class and says
    how to turn it back on. In combat the window stays up until combat ends,
    like any other change to it.
]]
function ns.CloseBuffWindow()
	ns.SetBuffDutyForClass(false)
	local _, class = UnitClass("player")
	ns:PrintMessage(
		L["BUFF_WINDOW_CLOSED"]:format(ns.OptionsClassName(class), ns.GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r")
	)
end

--------------------------------------------------------------------------------
-- More Powerful Spell
--------------------------------------------------------------------------------

--[[
    How long after a click or Buff Key press a "more powerful spell" refusal
    still belongs to that cast; the error comes back from the server.
]]
local BOUNCE_WINDOW = 2
local lastAttempt -- { guid, unit, key, at }: the last buff cast the window or key made
-- The error type this client gives the refusal, learned from its text, for Diagnostics.
local bounceErrorType

--[[
    Forever has no combat log, so its SPELL_RESURRECT never arrives to keep a
    resurrected player's icon away while they decide to accept
    (BuffWindow.NoteResurrect). There, a resurrection the window or key cast is
    noted from the player's own cast going off instead.
]]
local RESURRECT_CAST_SECONDS = 15 -- a resurrection's cast time, with room for lag
local lastResurrect -- { guid, ids, expires }: the last resurrection the window or key cast, on Forever

function ns.OnResurrectCastSucceeded(unit, spellID)
	if not lastResurrect or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	if GetTime() > lastResurrect.expires then
		lastResurrect = nil
	elseif lastResurrect.ids[spellID] then
		BuffWindow.NoteResurrect(lastResurrect.guid)
		lastResurrect = nil
	end
end

-- Called from a window icon's PreClick and the Buff Key's, for every cast they make.
function ns.NoteBuffCastAttempt(spec)
	lastAttempt = nil
	if ns.FLAVOR == "Camelot" and spec and spec.isResurrection and spec.unit then
		local guid = UnitGUID(spec.unit)
		if guid and ns.IsPlain(guid) then
			local ids = {}
			for _, id in ipairs(spec.castIds or { spec.spellId }) do
				ids[id] = true
			end
			lastResurrect = { guid = guid, ids = ids, expires = GetTime() + RESURRECT_CAST_SECONDS }
		end
	end
	if not spec or not spec.buffKey then
		return
	end
	local guid = spec.favorGUID or (spec.unit and UnitGUID(spec.unit))
	if guid and ns.IsPlain(guid) then
		lastAttempt = { guid = guid, unit = spec.unit, key = spec.buffKey, at = GetTime() }
	end
end

-- Diagnostics' event-log filter asks whether an error type is the one this file acts on.
function ns.IsBuffBounceError(errorType)
	return bounceErrorType ~= nil and errorType == bounceErrorType
end

--[[
    The refusal names no target, so it is pinned on the cast the window or
    the Buff Key just made. A favor's macro leaves them targeted, so a unit
    is found for them by GUID. The text is the client's own
    SPELL_FAILED_AURA_BOUNCED, so it matches in every locale.
]]
local function OnUIErrorMessage(errorType, message)
	if not lastAttempt or not ns.IsPlain(message) or message ~= SPELL_FAILED_AURA_BOUNCED then
		return
	end
	if ns.IsPlain(errorType) and errorType ~= bounceErrorType then
		-- The event log counted this firing before the type was known; log it in full.
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEventNow("UI_ERROR_MESSAGE", errorType, message)
		end
		bounceErrorType = errorType
	end
	local attempt = lastAttempt
	lastAttempt = nil
	if GetTime() - attempt.at > BOUNCE_WINDOW then
		return
	end
	local unit = attempt.unit
	if not unit or UnitGUID(unit) ~= attempt.guid then
		unit = ns.GetUnitByGUID(attempt.guid)
	end
	if unit then
		BuffWindow.NoteBounce(unit, attempt.key)
		ns.RequestBuffWindowRefresh()
	end
end

-- A change that can move who a unit token names, or what the window offers.
local function RequestFullRefresh()
	MarkAllAurasDirty()
	ns.RequestBuffWindowRefresh()
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--[[
    Called from Buff-Tracking's UNIT_AURA handler, which owns the event. Core
    registers it unfiltered, so nameplates arrive here too; only the units the
    window reads are worth a refresh. Nothing is queued while the window is off
    or in combat: turning it on and PLAYER_REGEN_ENABLED each request a fresh
    read.
]]
function ns.OnBuffWindowAura(unit)
	if not BuffWindow.isSetUp or inCombat or not ns.db.global.buffWindow.enabled then
		return
	end
	if not HasAnythingToOffer() or not ns.IsPlain(unit) or not unit then
		return
	end
	if
		unit == "player"
		or unit == "target"
		or unit == "targetpet"
		or unit == "pet"
		or unit:find("^party%d")
		or unit:find("^raid%d")
		or unit:find("^partypet%d")
		or unit:find("^raidpet%d")
	then
		MarkAurasDirty(unit)
		ns.RequestBuffWindowRefresh()
	end
end

--[[
    The aura cache is keyed by GUID, so a roster change or a new target needs no
    re-read of anyone already read: a token that now names someone else finds
    that player's own record. Only the units that changed are marked, and a
    player the window hasn't read yet is read fresh anyway.
]]
local function OnGroupRosterUpdate()
	BuffWindow.PruneAuraCache()
	ns.RequestBuffWindowRefresh()
end

local function OnUnitPet(unit)
	local pet = ns.IsPlain(unit) and unit and PetUnitOf(unit)
	if pet and UnitExists(pet) then
		MarkAurasDirty(pet)
	end
	ns.RequestBuffWindowRefresh()
end

local function OnPlayerTargetChanged()
	for _, unit in ipairs({ "target", "targetpet" }) do
		if UnitExists(unit) then
			MarkAurasDirty(unit)
		end
	end
	ns.RequestBuffWindowRefresh()
end

local function OnSpellsChanged()
	if BuffWindow.isSetUp then
		BuffWindow.ForgetMyStrengths()
		BuffWindow.BuildBuffs()
		RequestFullRefresh()
	end
end

--[[
    A poison, imbue or oil going on or wearing off, a weapon swapped, and an
    item used up or bought: the Self Buffs icons read your weapons and bags,
    which no aura event reaches.
]]
local function RefreshForInventory()
	if BuffWindow.isSetUp and not inCombat then
		ns.RequestBuffWindowRefresh()
	end
end

local function OnUnitInventoryChanged()
	RefreshForInventory()
end

local function OnBagUpdateDelayed()
	RefreshForInventory()
end

local function OnPlayerRegenDisabled()
	inCombat = true
end

local function OnPlayerRegenEnabled()
	inCombat = false
	if not BuffWindow.isSetUp then
		return
	end
	if settingsPending then
		ApplySettings()
	end
	RequestFullRefresh()
end

-- The backstop's tick, which skips the redraw while the window is off or in combat.
local function OnBackstopTick()
	if inCombat or not ns.db.global.buffWindow.enabled then
		return
	end
	BuffWindow.PruneAuraCache()
	ns.RequestBuffWindowRefresh()
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

-- Run once from Core's login sequence, after the saved variables are live.
function ns.SetupBuffWindow()
	inCombat = InCombatLockdown() and true or false
	BuffWindow.BuildLookup()
	ns.BuffWindowCategories = BuffWindow.BuildCategories(BuffWindow.entries)
	-- The Self-Buffs panel lists the Soulstone with the warlock's self buffs.
	local selfListed = { unpack(BuffWindow.selfEntries) }
	selfListed[#selfListed + 1] = BuffWindow.soulstoneEntry
	ns.BuffWindowSelfCategories = BuffWindow.BuildCategories(selfListed)
	ns.PopulateBuffWindowAudience()
	BuffWindow.BuildBuffs()
	ns.CreateBuffWindowFrame()
	ApplySettings()
	-- MIGRATION (remove after 2026-11-21): the old Group Buff key's binding moves to the Buff Key.
	ns.MigrateBuffKeys()
	BuffWindow.isSetUp = true
	ns.RequestBuffWindowRefresh()
	C_Timer.NewTicker(BACKSTOP_INTERVAL, OnBackstopTick)
end

ns.SetEventHandler("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
ns.SetEventHandler("UNIT_PET", OnUnitPet)
ns.SetEventHandler("PLAYER_TARGET_CHANGED", OnPlayerTargetChanged)
ns.SetEventHandler("SPELLS_CHANGED", OnSpellsChanged)
ns.SetEventHandler("UNIT_INVENTORY_CHANGED", OnUnitInventoryChanged)
ns.SetEventHandler("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
ns.SetEventHandler("PLAYER_REGEN_DISABLED", OnPlayerRegenDisabled)
ns.SetEventHandler("PLAYER_REGEN_ENABLED", OnPlayerRegenEnabled)
ns.SetEventHandler("UI_ERROR_MESSAGE", OnUIErrorMessage)
