local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The two lists above the parties are players outside your group: strangers
    who just buffed you (Return the Favor) and your target. Each player is
    listed once, and Target claims them first, so the list you asked for by
    targeting is never the one that loses them.

    An outsider has no lasting unit token. Target does -- "target" stays theirs
    for as long as they are targeted -- so its buttons cast at it. A favor is
    only reachable now and then (as your mouseover or focus), so its buttons
    find the player by name instead.

    There is no Players in Range list on purpose: the game reveals players
    around you to add-ons only through friendly nameplates, which are off for
    most players, so a list built on them would almost always be empty.
]]

local BuffWindow = ns.BuffWindow
local buffs = BuffWindow.buffs
local CanBuff = BuffWindow.CanBuff
local CanBuffPet = BuffWindow.CanBuffPet
local ReadAuras = BuffWindow.ReadAuras
local RoleOf = BuffWindow.RoleOf
local Wants = BuffWindow.Wants
local Has = BuffWindow.Has
local SingleIcon = BuffWindow.SingleIcon
local ResurrectionIcon = BuffWindow.ResurrectionIcon
local PlayerLabel = BuffWindow.PlayerLabel
local PetOwnerClass = BuffWindow.PetOwnerClass
local PetRow = BuffWindow.PetRow

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local favors = {} -- stranger GUID -> { name, short, class, at, given = { [buff key] = true } }

--------------------------------------------------------------------------------
-- Return the Favor
--------------------------------------------------------------------------------

--[[
    Called from Buff-Tracking's stranger path (combat log, or UNIT_AURA on
    Forever) for every helpful buff a player outside your group puts on you.
    Kept for the player's favorSeconds from their latest buff.
]]
function ns.NoteFavor(guid, name)
	if not BuffWindow.isSetUp or not ns.db or not ns.db.global.buffWindow.favorEnabled then
		return
	end
	if not (ns.IsPlain(guid) and ns.IsPlain(name)) or not ns.IsPlayerGUID(guid) or not name then
		return
	end

	local favor = favors[guid]
	if favor then
		favor.at = GetTime()
	else
		local _, class = GetPlayerInfoByGUID(guid)
		favors[guid] = {
			name = name,
			short = Ambiguate(name, "short"),
			class = ns.IsPlain(class) and class or nil,
			at = GetTime(),
			given = {},
		}
		-- Over the cap, the stranger who buffed you longest ago makes room.
		local count, oldestGUID, oldestAt = 0, nil, nil
		for key, entry in pairs(favors) do
			count = count + 1
			if not oldestAt or entry.at < oldestAt then
				oldestGUID, oldestAt = key, entry.at
			end
		end
		if count > Data.BUFF_WINDOW_FAVOR_MAX then
			favors[oldestGUID] = nil
		end
	end
	ns.RequestBuffWindowRefresh()
end

-- The favor icons' right-click.
function ns.DismissFavor(guid)
	favors[guid] = nil
	ns.RequestBuffWindowRefresh()
end

--------------------------------------------------------------------------------
-- Outsiders
--------------------------------------------------------------------------------

-- A player outside your group that you could buff right now.
local function IsOutsider(unit)
	return CanBuff(unit)
		and not UnitIsUnit(unit, "player")
		and not UnitInParty(unit)
		and not UnitInRaid(unit)
		and UnitCanAssist("player", unit)
end

--[[
    A friendly dead player outside your group. Whether they can take a
    resurrection right now (lying there, connected, none already waiting) is
    BuffWindow.ResurrectionIcon's call.
]]
local function IsDeadOutsider(unit)
	return UnitExists(unit)
		and UnitIsPlayer(unit)
		and UnitIsDeadOrGhost(unit)
		and not UnitIsUnit(unit, "player")
		and not UnitInParty(unit)
		and not UnitInRaid(unit)
		and UnitIsFriend("player", unit)
end

--[[
    The missing-buff icons for one outsider. `unit` reaches them right now, or
    is nil for a favor out of sight, whose auras can't be read -- then `given`
    alone says what they already have. `castUnit` is the token the buttons cast
    at; without one they target `fullName` by macro.
]]
local function OutsiderIcons(unit, class, short, fullName, castUnit, given, favorGUID)
	if unit then
		ReadAuras(unit)
	end
	local role = RoleOf(unit, class)
	local icons = {}
	for _, buff in ipairs(buffs) do
		local wanted = buff.singleName and Wants(buff, class, role)
		local expires, duration
		if wanted and unit then
			local has
			has, expires, duration = Has(buff, unit)
			if has then
				if given then
					given[buff.key] = true
				end
				wanted = false
			end
		end
		if wanted and not (given and given[buff.key]) then
			local icon = SingleIcon(buff, unit, castUnit, short, fullName, favorGUID)
			icons[#icons + 1] = BuffWindow.WithTimeLeft(icon, expires, duration)
		end
	end
	return icons
end

--[[
    A pet outside your group: targeting it lists it with its owner's name. Your own
    pet and your group's pets are already under their owners in the party list,
    so they never land here; your own counts even when you are solo. WoW
    Forever refused a buff on a stranger's pet ("Invalid target") in testing.
]]
local function IsOutsiderPet(unit)
	return CanBuffPet(unit)
		and UnitPlayerControlled(unit)
		and not UnitIsUnit(unit, "pet")
		and not UnitPlayerOrPetInParty(unit)
		and not UnitPlayerOrPetInRaid(unit)
		and UnitCanAssist("player", unit)
end

--[[
    The client's own wording for the line naming a pet's owner ("%s's Pet",
    "%s's Minion", ...), turned into patterns that capture the name. Built on
    first use from the client's globals, so it reads every locale's tooltips.
    A format the client lacks is skipped.

    Each with the owner's class the wording gives away, where it gives one: the
    client says "%s's Pet" of a hunter's beast and "%s's Minion" of a warlock's
    demon. Only a fallback for that class: PetOwnerClass reads the pet first.
]]
local OWNER_FORMATS = {
	{ "UNITNAME_TITLE_PET", "HUNTER" },
	{ "UNITNAME_TITLE_MINION", "WARLOCK" },
	{ "UNITNAME_TITLE_GUARDIAN" },
	{ "UNITNAME_TITLE_CREATION" },
	{ "UNITNAME_TITLE_CHARM" },
	{ "UNITNAME_TITLE_COMPANION" },
}
local ownerPatterns

local function OwnerPatterns()
	if not ownerPatterns then
		ownerPatterns = {}
		for _, ownerFormat in ipairs(OWNER_FORMATS) do
			local format = _G[ownerFormat[1]]
			if type(format) == "string" then
				--[[
				    Placeholder out first ("%s" or a positional "%1$s"), so escaping
				    the pattern characters can't mangle it.
				]]
				local text = format:gsub("%%%d?%$?s", "\001")
				text = text:gsub("[%%%(%)%.%+%-%*%?%[%]%^%$]", "%%%0")
				ownerPatterns[#ownerPatterns + 1] = { "^" .. text:gsub("\001", "(.+)") .. "$", ownerFormat[2] }
			end
		end
	end
	return ownerPatterns
end

--[[
    A unit's tooltip as plain left-hand lines, title first. Some facts about a
    unit reach add-ons only as tooltip text -- whose pet a pet is, above all --
    so the Buff Window reads them here. C_TooltipInfo hands the lines over as
    data where the client ships its GetUnit getter (WoW Forever); elsewhere they
    are read off a hidden tooltip that is never shown (Classic Era and TBC
    Anniversary), the same split Diagnostics makes for items and spells.
    Resolved once at load.
]]
local UNIT_SCAN_TOOLTIP_NAME = "BagsBuffsButtonsUnitScanTooltip"
local GetUnitTooltipData = C_TooltipInfo and C_TooltipInfo.GetUnit
local unitScanTooltip

local function GetUnitTooltipLines(unit)
	local lines = {}
	if GetUnitTooltipData then
		local data = GetUnitTooltipData(unit)
		for _, line in ipairs(data and data.lines or {}) do
			lines[#lines + 1] = line.leftText
		end
		return lines
	end

	if not unitScanTooltip then
		unitScanTooltip = CreateFrame("GameTooltip", UNIT_SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	unitScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	unitScanTooltip:SetUnit(unit)
	for i = 1, unitScanTooltip:NumLines() do
		local region = _G[UNIT_SCAN_TOOLTIP_NAME .. "TextLeft" .. i]
		lines[#lines + 1] = region and region:GetText()
	end
	unitScanTooltip:Hide()
	return lines
end

--[[
    The pet's owner as the tooltip names them, and the class that wording gives
    away (or nil); nil, nil when no line matches.
]]
local function PetOwnerName(unit)
	for _, line in ipairs(GetUnitTooltipLines(unit)) do
		if ns.IsPlain(line) and line then
			for _, pattern in ipairs(OwnerPatterns()) do
				local owner = line:match(pattern[1])
				if owner then
					return owner, pattern[2]
				end
			end
		end
	end
	return nil, nil
end

local function TargetSection(listed)
	if not ns.db.global.buffWindow.targetEnabled then
		return nil
	end

	--[[
	    A dead target is one row with the resurrection alone: no buff takes on
	    a corpse. Listed, so a dead favor isn't offered buffs below it.
	]]
	if IsDeadOutsider("target") then
		local guid = UnitGUID("target")
		local short = GetUnitName("target", false) or ""
		local icon = ResurrectionIcon("target", "target", short)
		if not icon or not guid or not ns.IsPlain(guid) then
			return nil
		end
		listed[guid] = true
		local _, class = UnitClass("target")
		local row = { label = PlayerLabel(short, class, "target"), icons = { icon } }
		return { kind = "target", label = L["BUFF_WINDOW_TARGET_HEADER"], icons = {}, rows = { row } }
	end

	local isPet = IsOutsiderPet("target")
	if not isPet and not IsOutsider("target") then
		return nil
	end
	local guid = UnitGUID("target")
	if not guid or not ns.IsPlain(guid) then
		return nil
	end
	listed[guid] = true

	--[[
        A targeted pet is one row, named for its owner -- "Valko (Kiib)" -- with
        the owner's class color and no buttons for the owner: offering to buff a
        player who isn't targeted, and may not be in sight, read as clutter. A
        targeted player has their pet ("targetpet") indented under them, the
        way the party list pairs them.
    ]]
	if isPet then
		local owner, guessed = PetOwnerName("target")
		local petRow = PetRow("target", "target", PetOwnerClass("target", guessed), owner and Ambiguate(owner, "short"))
		if not petRow then
			return nil
		end
		-- It stands on its own even when the tooltip named no owner.
		petRow.pet = nil
		return { kind = "target", label = L["BUFF_WINDOW_TARGET_HEADER"], icons = {}, rows = { petRow } }
	end

	local _, class = UnitClass("target")
	local short = GetUnitName("target", false) or ""
	-- A favor's record of what landed stays current while they're targeted.
	local favor = favors[guid]
	local icons = OutsiderIcons("target", class, short, nil, "target", favor and favor.given)
	local petRow = PetRow("targetpet", "targetpet", class)

	-- The player is listed while they or their pet need something.
	local rows = {}
	if #icons > 0 or petRow then
		rows[#rows + 1] = { label = PlayerLabel(short, class, "target"), icons = icons }
	end
	rows[#rows + 1] = petRow
	if #rows == 0 then
		return nil
	end
	return { kind = "target", label = L["BUFF_WINDOW_TARGET_HEADER"], icons = {}, rows = rows }
end

local function FavorSection(listed)
	if not ns.db.global.buffWindow.favorEnabled then
		return nil
	end

	local now = GetTime()
	local keep = ns.db.global.buffWindow.favorSeconds
	local rows = {}
	for guid, favor in pairs(favors) do
		local unit = ns.GetUnitByGUID(guid)
		if now - favor.at > keep then
			favors[guid] = nil
		elseif unit and (UnitInParty(unit) or UnitInRaid(unit)) then
			-- They joined your group, and their party lists them now.
			favors[guid] = nil
		elseif not listed[guid] then
			listed[guid] = true
			local readable = unit and CanBuff(unit) and unit or nil
			local icons = OutsiderIcons(readable, favor.class, favor.short, favor.name, nil, favor.given, guid)
			if #icons == 0 then
				-- Every buff you can give them, they have: the favor is returned.
				favors[guid] = nil
			else
				rows[#rows + 1] =
					{ at = favor.at, label = PlayerLabel(favor.short, favor.class, readable), icons = icons }
			end
		end
	end

	if #rows == 0 then
		return nil
	end
	-- Most recent first: the stranger who just buffed you is likely still in reach.
	table.sort(rows, function(a, b)
		return a.at > b.at
	end)
	return { kind = "favor", label = L["BUFF_WINDOW_FAVOR_HEADER"], icons = {}, rows = rows }
end

function BuffWindow.AddOutsiderSections(sections)
	local listed = {}
	-- Claimed in priority order, shown in reading order.
	local target = TargetSection(listed)
	local favor = FavorSection(listed)
	--[[
	    Not a loop over { target, favor }: ipairs stops at the first nil, so an
	    empty Target would drop Return the Favor after it.
	]]
	sections[#sections + 1] = target
	sections[#sections + 1] = favor
end
