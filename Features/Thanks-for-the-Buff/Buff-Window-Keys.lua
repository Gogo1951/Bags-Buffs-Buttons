local _, ns = ...
local L = ns.L

--[[
    The Buff Key: a key binding that casts the next buff on Buff Duty's list,
    one press at a time, the way Pally Power's auto-buff keys do. A
    resurrection on your dead target, then on your group's dead (priests,
    paladins and shamans), then your self-buffs, then Return the Favor and
    your target, then your group -- your target's party first. For each
    buff a party is missing, the key casts the group version when it costs
    less mana than buffing everyone it would reach one at a time, and the
    single one otherwise (AddParty).

    The key is a hidden SecureActionButtonTemplate button bound by
    Bindings.xml ("CLICK <button>:LeftButton"), and a macro reaches the same
    button with "/click TFTBBuffIndividual" -- the way Pally Power's macros
    click its buttons. The name is the one it had as the first of two keys,
    so the bindings and macros made then still press it. A slash command of our own
    can't do it: the game only lets its own secure code cast, and an add-on's
    command never is. Casting from a key press is
    protected, so the pick happens in PreClick: it reads the group fresh,
    builds the same sections the window draws (ns.BuffWindow.BuildSections),
    writes the first castable icon's attributes onto the button, and the
    secure template casts it. PostClick clears them again. All of it needs
    combat to be over -- a secure button's attributes are locked in combat
    -- so a press mid-fight does nothing.
]]

local BuffWindow = ns.BuffWindow

-- The button's global name, which a macro's /click types.
local KEY_BUTTON = "TFTBBuffIndividual"

-- The binding command, as Bindings.xml names it; the options panel binds keys to it.
ns.BUFF_KEY_COMMAND = "CLICK " .. KEY_BUTTON .. ":LeftButton"

-- The macro line, shown under the binding on the options panel.
ns.BUFF_KEY_MACRO = "/click " .. KEY_BUTTON

--[[
    MIGRATION (remove after 2026-11-21): The Group Buff key's command, from before the one key picked group buffs
    on its own. Its button is gone; a key still bound to it moves over at
    login (ns.MigrateBuffKeys).
]]
local OLD_GROUP_COMMAND = "CLICK TFTBBuffGroup:LeftButton"

-- The names the game's Key Bindings list shows.
BINDING_HEADER_BAGSBUFFSBUTTONS = L["ADDON_TITLE"]
_G["BINDING_NAME_" .. ns.BUFF_KEY_COMMAND] = L["BUFF_KEY"]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

--[[
    How long a cast the key just made keeps it off that player and buff.
    A buff only needs to bridge the moment before its aura shows up; a
    resurrection waits out the minute its target has to accept it.
]]
local BUFF_SKIP_SECONDS = 3
local RESURRECTION_SKIP_SECONDS = 60
--[[
    A Return the Favor icon targets the stranger by name, and simply fails
    when they've moved off. The key moves past them for this long after a
    press, so one stranger out of reach doesn't stall the list; a cast that
    does go off is then held for BUFF_SKIP_SECONDS like any other
    (ns.OnBuffKeyCastSucceeded).
]]
local FAVOR_RETRY_SECONDS = 30
-- How long a press waits to hear its cast went off; a Resurrection takes 10 seconds.
local PENDING_SECONDS = 15
-- A spell whose base cooldown is this long or shorter has no cooldown of its own beyond the global one.
local GLOBAL_COOLDOWN = 1.5

local recent = {} -- "<GUID or party>:<spell name>" -> GetTime() it stops being skipped
local pending -- { key, ids, seconds, expires }: the last press, until its cast goes off

local GetItemCooldown = C_Container.GetItemCooldown
local IsSpellUsable = C_Spell.IsSpellUsable
local GetSpellPowerCost = C_Spell.GetSpellPowerCost or GetSpellPowerCost

--------------------------------------------------------------------------------
-- Readiness
--------------------------------------------------------------------------------

--[[
    What a press remembers a cast by: who it went on (a party, for a group
    buff) and the spell's name. Nil for an item (a Soulstone), whose result
    the window reads straight off your bags and the group's auras.
]]
local function SkipKey(spec)
	local name = spec.spellName
	if not name then
		return nil
	end
	if spec.subgroup then
		return "party" .. spec.subgroup .. ":" .. name
	end
	--[[
	    Its own key: the favor's macro targets the stranger, and if the cast
	    then fails (a press inside the global cooldown) the Target section's
	    icon for them shouldn't wait out the favor's retry.
	]]
	if spec.favorGUID then
		return "favor:" .. spec.favorGUID .. ":" .. name
	end
	local guid = spec.unit and UnitGUID(spec.unit)
	if guid and ns.IsPlain(guid) then
		return guid .. ":" .. name
	end
	return nil
end

-- Whether a press a moment ago already cast this, and the key waits on its aura.
local function Skipped(spec, now)
	local key = SkipKey(spec)
	return key and recent[key] and recent[key] > now
end

-- When the running global cooldown ends, or 0 when none is running or the client won't say.
local function GlobalCooldownEnd()
	local info = C_Spell.GetSpellCooldown(ns.GLOBAL_COOLDOWN_SPELL_ID)
	local start, duration = info and info.startTime, info and info.duration
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return 0
	end
	return start + duration
end

--[[
    A spell or item on the global cooldown reports it as a short cooldown of its
    own, so a real cooldown is one that runs past the global one's end. Haste
    shortens the global cooldown, so it is read, never assumed.
]]
local function OnCooldown(start, duration)
	if not (ns.IsPlain(start) and ns.IsPlain(duration) and start and duration and duration > 0) then
		return false
	end
	local ends = start + duration
	return ends > GetTime() and ends > GlobalCooldownEnd()
end

--[[
    "cooldown" for a spell or item that can't go off for a while yet (a used
    Soulstone, Fear Ward), "unusable" for one the client refuses for any
    reason but mana (no reagent, no Soul Shard), otherwise "ready". Short on
    mana still counts as ready: the cast's own error says so.
]]
local function Readiness(spec)
	if spec.itemId then
		if OnCooldown(GetItemCooldown(spec.itemId)) then
			return "cooldown"
		end
		return "ready"
	end
	local info = C_Spell.GetSpellCooldown(spec.spellId)
	if info and OnCooldown(info.startTime, info.duration) then
		return "cooldown"
	end
	local usable, noMana = IsSpellUsable(spec.spellId)
	if ns.IsPlain(usable) and ns.IsPlain(noMana) and not usable and not noMana then
		return "unusable"
	end
	return "ready"
end

--[[
    Whether a spell has a cooldown of its own beyond the global one (Fear
    Ward), ready or not, for Skip Buffs with Cooldowns. An item's (a
    Soulstone's) is the item's, not its spell's, and is never skipped.
]]
local function HasCooldown(spec)
	if spec.itemId or not spec.spellId then
		return false
	end
	local milliseconds = GetSpellBaseCooldown(spec.spellId)
	return ns.IsPlain(milliseconds) and milliseconds and milliseconds > GLOBAL_COOLDOWN * 1000 or false
end

-- The mana a spell costs, or nil when the client doesn't say.
local function ManaCost(spellId)
	local costs = spellId and GetSpellPowerCost and GetSpellPowerCost(spellId)
	if type(costs) ~= "table" then
		return nil
	end
	for _, cost in ipairs(costs) do
		if ns.IsPlain(cost.type) and cost.type == Enum.PowerType.Mana and ns.IsPlain(cost.cost) then
			return cost.cost
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Candidates
--------------------------------------------------------------------------------

--[[
    Your target, if they're a friendly dead player you can bring back -- in
    your group or not. BuffWindow.ResurrectionIcon says who can take one.
]]
local function ResurrectionSpec()
	if not UnitExists("target") or not UnitIsFriend("player", "target") then
		return nil
	end
	return BuffWindow.ResurrectionIcon("target", "target", GetUnitName("target", false) or "")
end

-- Your target's party, or nil when your target isn't in your group.
local function TargetSubgroup()
	if not UnitExists("target") then
		return nil
	end
	for _, member in ipairs(BuffWindow.GroupMembers()) do
		if UnitIsUnit(member.unit, "target") then
			return member.subgroup
		end
	end
	return nil
end

--[[
    The group buffs worth casting on a party, and the buff columns they
    cover. For each buff it is missing: the members who'd take it now, in
    range and not just given the single version. The group version goes out
    when it costs less mana than their single casts together, or when one of
    them is too low for any single rank you know; a client that names no
    costs counts the group version as cheaper once it reaches two. Otherwise,
    or with no reagent for it, the members keep their single icons. A group
    version with no single one to fall back on is always kept, so the key
    can say who it waits on. A group buff a press just cast covers its
    column until the aura shows, so its members aren't given singles over
    it. Pets take singles all the same: the group versions are cast to be
    sure of the players.
]]
local function GroupChoices(section, now)
	local chosen, covered = {}, {}
	for _, group in ipairs(section.icons) do
		local singles = {}
		for _, row in ipairs(section.rows) do
			if not row.pet then
				for _, spec in ipairs(row.icons) do
					if spec.column == group.column and spec.unit then
						singles[spec.unit] = spec
					end
				end
			end
		end
		if Skipped(group, now) then
			covered[group.column] = true
		else
			local reach, singleCost, groupOnly = 0, 0, false
			for _, unit in ipairs(group.members) do
				local single = singles[unit]
				if not (single and Skipped(single, now)) and ns.IsBuffInRange(unit, group.spellName) then
					reach = reach + 1
					if single then
						local cost = ManaCost(single.spellId)
						singleCost = singleCost and cost and singleCost + cost or nil
					else
						groupOnly = true
					end
				end
			end
			local groupCost = ManaCost(group.spellId)
			local cheaper
			if groupOnly then
				cheaper = true
			elseif singleCost and groupCost then
				cheaper = groupCost < singleCost
			else
				cheaper = reach >= 2
			end
			if not next(singles) or (reach > 0 and cheaper and Readiness(group) ~= "unusable") then
				chosen[#chosen + 1] = group
				covered[group.column] = true
			end
		end
	end
	return chosen, covered
end

--[[
    Every icon the key could cast, in the order it should: resurrections,
    self-buffs, Return the Favor, your target, then each party -- your
    target's first -- with its group buffs (GroupChoices) and then its
    members' single ones, less those a group buff covers.
]]
local function Candidates(sections, now)
	local list, added = {}, {}
	--[[
	    Weapon icons are never candidates: putting a poison or oil on, and
	    answering the game's "replace your enchant?" question, is a click on
	    the window, not a key run through a list.
	]]
	local function Add(spec)
		if spec and not spec.weapon and not added[spec] then
			added[spec] = true
			list[#list + 1] = spec
		end
	end
	local function AddRows(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				Add(spec)
			end
		end
	end
	local function Each(kind, handler)
		for _, section in ipairs(sections) do
			if section.kind == kind then
				handler(section)
			end
		end
	end

	-- Resurrections before anything else: your dead target, then your group's dead.
	Add(ResurrectionSpec())
	Each("party", function(section)
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if spec.isResurrection then
					Add(spec)
				end
			end
		end
	end)
	Each("self", function(section)
		for _, spec in ipairs(section.icons) do
			Add(spec)
		end
	end)

	Each("favor", AddRows)
	Each("target", AddRows)

	local function AddParty(section)
		local chosen, covered = GroupChoices(section, now)
		for _, spec in ipairs(chosen) do
			Add(spec)
		end
		for _, row in ipairs(section.rows) do
			for _, spec in ipairs(row.icons) do
				if row.pet or not covered[spec.column] then
					Add(spec)
				end
			end
		end
	end
	local targetSubgroup = TargetSubgroup()
	Each("party", function(section)
		if section.subgroup == targetSubgroup then
			AddParty(section)
		end
	end)
	Each("party", function(section)
		if section.subgroup ~= targetSubgroup then
			AddParty(section)
		end
	end)
	return list
end

--------------------------------------------------------------------------------
-- Picking
--------------------------------------------------------------------------------

--[[
    Whether the cast can reach anyone it's for, and if not, the name of
    someone it's waiting on. A group buff needs one member missing it in
    range: GroupChoices only keeps it when those in range make it worth it,
    and whoever it leaves out is offered again later.
]]
local function Reachable(spec)
	if spec.members then
		for _, unit in ipairs(spec.members) do
			if ns.IsBuffInRange(unit, spec.spellName) then
				return true
			end
		end
		return false, GetUnitName(spec.members[1], false)
	end
	if ns.IsBuffSpecInRange(spec) then
		return true
	end
	return false, spec.targetName
end

--[[
    The first candidate that is ready and in reach. With none, the first one
    the client refuses, so its own error ("Missing reagent") says why the key
    did nothing; failing that, nil and whoever the list is waiting on. With
    Skip Buffs with Cooldowns on, a spell with a cooldown of its own is never
    a candidate, ready or not.
]]
local function PickNext()
	local db = ns.db and ns.db.global.buffWindow
	if not BuffWindow.isSetUp or not db or not db.enabled or ns.AreAurasSecret() then
		return nil
	end
	if not BuffWindow.ShowsHere() then
		return nil
	end
	if UnitIsDeadOrGhost("player") then
		return nil
	end

	-- A cast a moment ago may not be in the cache yet; read everyone fresh.
	BuffWindow.MarkAllAurasDirty()
	local now = GetTime()
	local candidates = Candidates(BuffWindow.BuildSections(), now)
	local refused, waitingOn
	for _, spec in ipairs(candidates) do
		if not Skipped(spec, now) and not (db.keySkipCooldowns and HasCooldown(spec)) then
			local readiness = Readiness(spec)
			if readiness ~= "cooldown" then
				local inReach, waiting = Reachable(spec)
				if not inReach then
					waitingOn = waitingOn or waiting
				elseif readiness == "ready" then
					return spec
				else
					refused = refused or spec
				end
			end
		end
	end
	return refused, waitingOn
end

--------------------------------------------------------------------------------
-- Remembering Casts
--------------------------------------------------------------------------------

local function Remember(spec)
	local now = GetTime()
	for key, expires in pairs(recent) do
		if expires <= now then
			recent[key] = nil
		end
	end
	local key = SkipKey(spec)
	if not key then
		pending = nil
		return
	end
	if spec.favorGUID then
		recent[key] = now + FAVOR_RETRY_SECONDS
	end
	local ids = {}
	for _, id in ipairs(spec.castIds or { spec.spellId }) do
		ids[id] = true
	end
	pending = {
		key = key,
		ids = ids,
		seconds = spec.isResurrection and RESURRECTION_SKIP_SECONDS or BUFF_SKIP_SECONDS,
		expires = now + PENDING_SECONDS,
	}
end

--[[
    Called from Buff-Tracking's UNIT_SPELLCAST_SUCCEEDED handler, which owns
    the event. The cast is matched by spell ID against every rank the press
    could go off as, since a group buff or a resurrection is cast by its bare
    name and resolves to whichever rank you know.
]]
function ns.OnBuffKeyCastSucceeded(unit, spellID)
	if not pending or not ns.IsPlain(unit) or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	local now = GetTime()
	if now > pending.expires then
		pending = nil
		return
	end
	if pending.ids[spellID] then
		recent[pending.key] = now + pending.seconds
		pending = nil
	end
end

--------------------------------------------------------------------------------
-- Buttons
--------------------------------------------------------------------------------

--[[
    A key press reaches the button twice, down and up, while a macro's
    /click sends a single up. The button sets useOnKeyDown to false (below),
    so the secure template acts on the up half for both, whatever
    ActionButtonUseKeyDown says -- otherwise a key-down player's /click
    would cast nothing. Both halves write the attributes, so a client that
    acted on the other half would still cast; only the up half remembers
    the cast and shows a message.
]]
local function OnKeyPreClick(self, _, down)
	local acting = not down
	if InCombatLockdown() then
		if acting then
			UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
		end
		return
	end
	local spec, waitingOn = PickNext()
	ns.SetBuffButtonAttributes(self, spec)
	if not acting then
		return
	end
	if spec then
		Remember(spec)
		ns.NoteBuffCastAttempt(spec)
	elseif waitingOn then
		UIErrorsFrame:AddMessage(L["BUFF_KEY_WAITING"]:format(waitingOn), 1, 0.82, 0)
	else
		UIErrorsFrame:AddMessage(L["BUFF_KEY_DONE"], 1, 0.82, 0)
	end
end

local function OnKeyPostClick(self)
	if not InCombatLockdown() then
		ns.SetBuffButtonAttributes(self, nil)
	end
end

local keyButton = CreateFrame("Button", KEY_BUTTON, UIParent, "SecureActionButtonTemplate")
-- Both halves, as the window's own buttons do; see OnKeyPreClick.
keyButton:RegisterForClicks("AnyUp", "AnyDown")
keyButton:SetAttribute("useOnKeyDown", false)
keyButton:SetScript("PreClick", OnKeyPreClick)
keyButton:SetScript("PostClick", OnKeyPostClick)
keyButton:Hide()

--[[
    MIGRATION (remove after 2026-11-21): Run from the Buff Window's setup at login. A key still bound to the old
    Group Buff key now presses this one, which picks group buffs itself;
    once moved, nothing is left to move. Bindings are locked in combat, so a
    /reload mid-fight tries again next login.
]]
function ns.MigrateBuffKeys()
	if InCombatLockdown() then
		return
	end
	local keys = { GetBindingKey(OLD_GROUP_COMMAND) }
	if not keys[1] then
		return
	end
	for _, key in ipairs(keys) do
		SetBinding(key, ns.BUFF_KEY_COMMAND)
	end
	SaveBindings(GetCurrentBindingSet())
end
