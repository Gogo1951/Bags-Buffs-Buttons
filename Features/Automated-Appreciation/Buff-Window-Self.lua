local _, ns = ...
local L = ns.L

--[[
    The Buff Window's Self Buffs section: your self-only buffs and a Soulstone
    while nobody in your group carries one, as icons on the Self Buffs header
    in a grid of its own; then a row per hand for the poison, imbue, oil,
    stone or lure each weapon needs, each row in a grid of its own
    (Buff-Window-Weapons.lua). Shared with the other Buff Window files through
    ns.BuffWindow.
]]

local BuffWindow = ns.BuffWindow
local selfBuffs = BuffWindow.selfBuffs
local CanBuff = BuffWindow.CanBuff
local GroupMembers = BuffWindow.GroupMembers
local ReadAuras = BuffWindow.ReadAuras
local RoleOf = BuffWindow.RoleOf
local Has = BuffWindow.Has
local SingleIcon = BuffWindow.SingleIcon

local GetItemCount = C_Item.GetItemCount
local IsItemInRange = C_Item.IsItemInRange

--------------------------------------------------------------------------------
-- Self Buffs
--------------------------------------------------------------------------------

local function HasPet()
	return UnitExists("pet") and not UnitIsDeadOrGhost("pet")
end

--------------------------------------------------------------------------------
-- Soulstone
--------------------------------------------------------------------------------

-- The best stone in your bags; the list runs from the lowest rank up.
local function BestStone(items)
	for index = #items, 1, -1 do
		if GetItemCount(items[index]) > 0 then
			return items[index]
		end
	end
	return nil
end

-- A unit the client can't answer for counts as in range, as in IsBuffInRange.
local function StoneInRange(itemId, unit)
	local inRange = IsItemInRange(itemId, unit)
	return not ns.IsPlain(inRange) or inRange ~= false
end

--[[
    Nothing while anyone in your group carries a Soulstone, yours or another
    warlock's. Otherwise the stone in your bags goes on a healer, one in range
    if any is, or on you when the group has none (or you have no group). With
    no stone in your bags, the button makes one. A stone running low on
    someone shows its time left on the icon.
]]
local function SoulstoneIcon()
	local buff = BuffWindow.soulstoneBuff
	if not buff then
		return nil
	end
	local healers = {}
	local lowExpires, lowDuration
	for _, member in ipairs(GroupMembers()) do
		local unit = member.unit
		if CanBuff(unit) then
			ReadAuras(unit)
			local has, expires, duration = Has(buff, unit)
			if has then
				return nil
			end
			if expires and (not lowExpires or expires > lowExpires) then
				lowExpires, lowDuration = expires, duration
			end
			if RoleOf(unit) == "HEALER" then
				healers[#healers + 1] = unit
			end
		end
	end

	local itemId = BestStone(buff.items)
	if not itemId then
		return BuffWindow.WithTimeLeft({
			spellId = buff.create.id,
			column = buff.column,
			spellName = buff.create.name,
			castSpell = buff.create.name,
			unit = "player",
			targetName = GetUnitName("player", false) or "",
			hint = L["BUFF_WINDOW_TOOLTIP_CREATE"],
		}, lowExpires, lowDuration)
	end
	local target = "player"
	for _, unit in ipairs(healers) do
		if StoneInRange(itemId, unit) then
			target = unit
			break
		end
	end
	if target == "player" and healers[1] then
		target = healers[1]
	end
	local targetName = GetUnitName(target, false) or ""
	return BuffWindow.WithTimeLeft({
		itemId = itemId,
		item = "item:" .. itemId,
		-- Every stone shares a long cooldown, so the Buff Key leaves this one to its icon.
		hasCooldown = true,
		column = buff.column,
		unit = target,
		targetName = targetName,
		hint = L["BUFF_WINDOW_TOOLTIP_USE"]:format(targetName),
	}, lowExpires, lowDuration)
end

--------------------------------------------------------------------------------
-- Section
--------------------------------------------------------------------------------

--[[
    Each self buff casts your highest rank on yourself. A family you keep one
    of (an armor, an aura, an aspect, a shield) asks for nothing while any one
    of yours is up -- Has handles that, as it does for blessings. Soul Link
    waits for a demon to link to. The weapons have their own switch
    (weaponBuffs is empty while it's off) and show as rows under the same
    header, which stands even with no self buff of its own to offer.
]]
function BuffWindow.AddSelfSection(sections)
	if UnitIsDeadOrGhost("player") then
		return
	end
	local selfEnabled = ns.db.global.buffWindow.selfEnabled
	local icons, rows = {}, {}

	ReadAuras("player")
	local name = GetUnitName("player", false) or ""
	for _, buff in ipairs(selfEnabled and selfBuffs or {}) do
		if HasPet() or not buff.needsPet then
			local has, expires, duration = Has(buff, "player")
			if not has then
				icons[#icons + 1] =
					BuffWindow.WithTimeLeft(SingleIcon(buff, "player", "player", name), expires, duration)
			end
		end
	end

	BuffWindow.AddWeaponRows(rows)

	if selfEnabled then
		icons[#icons + 1] = SoulstoneIcon()
	end

	if #icons > 0 or #rows > 0 then
		sections[#sections + 1] =
			{ kind = "self", label = L["BUFF_WINDOW_SELF_HEADER"], icons = icons, rows = rows, grid = "self" }
	end
end
