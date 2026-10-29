local _, ns = ...

-- The equipped items with a "Use:" effect, which a spell macro's Use Items options can use before its cast.

-- Each inventory slot's GlobalStrings constant, the name the menus show for it.
local SLOTS = {
	[1] = "HEADSLOT",
	[2] = "NECKSLOT",
	[3] = "SHOULDERSLOT",
	[4] = "SHIRTSLOT",
	[5] = "CHESTSLOT",
	[6] = "WAISTSLOT",
	[7] = "LEGSSLOT",
	[8] = "FEETSLOT",
	[9] = "WRISTSLOT",
	[10] = "HANDSSLOT",
	[11] = "FINGER0SLOT_UNIQUE",
	[12] = "FINGER1SLOT_UNIQUE",
	[13] = "TRINKET0SLOT_UNIQUE",
	[14] = "TRINKET1SLOT_UNIQUE",
	[15] = "BACKSLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
	[18] = "RANGEDSLOT",
	[19] = "TABARDSLOT",
}

-- The client's name for an inventory slot.
local function SlotName(slot)
	return _G[SLOTS[slot]]
end

ns.SlotName = SlotName

--[[
	Whether the item in an equipment slot has a "Use:" effect. The tooltip check catches effects added to the
	item, such as engineering tinkers, which GetItemSpell on the item itself may not see.
]]
local function HasUseEffect(slot, link)
	if C_Item.GetItemSpell(link) then
		return true
	end
	local prefix = ITEM_SPELL_TRIGGER_ONUSE
	for _, text in ipairs(ns.ReadTooltipLines("GetInventoryItem", "SetInventoryItem", "player", slot)) do
		if type(text) == "string" and text:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

--[[
	The equipped items with a "Use:" effect, in slot order, as {slot = 13, link = ...}. Cached until the gear
	worn changes (ns:InvalidateUsableSlots, on PLAYER_EQUIPMENT_CHANGED), and each item's answer is kept by its
	link, so the menus don't rescan nineteen tooltips on every redraw. Don't modify it.
]]
local usableSlots
local useEffectByLink = {}

function ns.UsableSlots()
	if usableSlots then
		return usableSlots
	end
	usableSlots = {}
	for slot = 1, #SLOTS do
		local link = GetInventoryItemLink("player", slot)
		if link then
			if useEffectByLink[link] == nil then
				useEffectByLink[link] = HasUseEffect(slot, link)
			end
			if useEffectByLink[link] then
				usableSlots[#usableSlots + 1] = { slot = slot, link = link }
			end
		end
	end
	return usableSlots
end

function ns:InvalidateUsableSlots()
	usableSlots = nil
end

-- The name a slot shows in menus and tooltips: "Use Trinket 1: Burst of Knowledge", or the slot alone when it's empty.
function ns.SlotLabel(slot)
	local link = GetInventoryItemLink("player", slot)
	local item = link and link:match("%[(.-)%]")
	return ns.L["MENU_USE_SLOT"]:format(SlotName(slot) .. (item and ": " .. item or ""))
end
