local _, ns = ...

--[[
    Inventory Report -- the block item tooltips gain under the game's own lines:
    the total across every character on the realm, this character on top, then
    one line per other character holding some, each with its bags and bank
    apart.

        BBB // Inventory Report                 Total 82
         Gogodruid                         Bag 7, Bank 18

         Coinpurse                                Bank 30
         Thornhoof                          Bag 7, Bank 20

    The shape is the house one for a branded block: the add-on's short name, the
    separator and a title in the chat prints' own colors (Announcements.lua),
    then double lines, each a space in from the header so the rows read as the
    block's own. The total rides on the header's right, so the block costs one
    line per character and one spacer, and every name wears its class color.

    Two halves. The recording half, this file, keeps a snapshot of every character's bags
    and bank on ns.db.global.inventory, so an alt's counts can show while it is
    logged out. Both are read while the character is playing -- the bags
    whenever they change, the bank whenever its window is open, which is the
    only time an add-on can read it -- and written down at logout. The
    reporting half adds the lines.

    Snapshots, then, for everything but the current character's bags, which are
    read live: an alt's counts are as of its last logout, and a bank's as of its
    last visit. A bank not seen yet, this character's or an alt's, counts as 0
    until it has been opened once.

    Only characters on the current realm are listed, and only those holding the
    item. Items cannot be mailed across realms, so a count there answers nothing
    the player can act on from here.

    Switched off from the Restocker panel (ns.db.global.inventoryReport):
    most auction add-ons put their own
    counts on the same tooltips, and two sets of numbers under one item is
    noise.
]]

-- Bank bag ids follow the player's own: 5..10 on Classic Era (six slots), 5..11 on TBC, as in Restocker-Bags.lua.
local BANK_BAG_COUNT = 7

-- The bank's contents can still be arriving when BANKFRAME_OPENED fires; one late look catches them.
local BANK_SETTLE_DELAY = 0.5

--------------------------------------------------------------------------------
-- Saved Format
--------------------------------------------------------------------------------

--[[
    One saved line per character per place: "itemID:count" pairs, space
    separated and in itemID order. WoW's serializer spreads a table over a line
    per key, and a character's bank can hold a few hundred different items, so
    this keeps the file to one short line each -- the same habit the Restock
    List keeps for its rows (Restocker-Saved-Format.lua).
]]
local function Pack(counts)
	local itemIDs = {}
	for itemID in pairs(counts) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)

	local parts = {}
	for index, itemID in ipairs(itemIDs) do
		parts[index] = itemID .. ":" .. counts[itemID]
	end
	return table.concat(parts, " ")
end

local function Unpack(text)
	local counts = {}
	for itemID, count in string.gmatch(text or "", "(%d+):(%d+)") do
		counts[tonumber(itemID)] = tonumber(count)
	end
	return counts
end

--------------------------------------------------------------------------------
-- Containers
--------------------------------------------------------------------------------

local function PlayerBagIDs()
	local bagIDs = {}
	for bagID = 0, NUM_BAG_SLOTS do
		bagIDs[#bagIDs + 1] = bagID
	end
	return bagIDs
end

--[[
    Forever's character bank is the tabs the player has bought (C_Bank); Era and
    TBC have BANK_CONTAINER and the bank bags. The seventh bank bag exists only
    on TBC, and asking Era about it just reads as empty.
]]
local function BankBagIDs()
	local tabIDs = ns.FetchPurchasedBankTabIDs()
	if tabIDs then
		return tabIDs
	end

	local bagIDs = { BANK_CONTAINER }
	for index = 1, BANK_BAG_COUNT do
		bagIDs[#bagIDs + 1] = NUM_BAG_SLOTS + index
	end
	return bagIDs
end

local function CountItems(bagIDs)
	local counts = {}
	for _, bagID in ipairs(bagIDs) do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
			local info = C_Container.GetContainerItemInfo(bagID, slot)
			if info and info.itemID then
				counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 1)
			end
		end
	end
	return counts
end

--------------------------------------------------------------------------------
-- Recording
--------------------------------------------------------------------------------

-- This character's saved entry, bound at login.
local record

--[[
    This character's bags as last read, which is what a logout saves. They are
    read while the character is playing -- on arriving in the world, and at
    every change after that -- and never at the logout itself: on Forever a
    read made at PLAYER_LOGOUT can find nothing, which would save every
    character's bags as empty. nil until a read has been made, so a session that never
    saw its bags leaves the file's last snapshot alone.
]]
local bagCounts

-- A bag change arrived mid-fight; the read it asked for is owed when the fight ends.
local bagsChangedInCombat = false

--[[
    This character's bank: the last visit's snapshot at login, then each scan
    while the window is open. nil until the bank has been seen at all: the
    report counts that as 0, and a logout writes no bank line over it.
]]
local bankCounts

local bankIsOpen = false

--[[
    The backpack has slots whenever the bags can be read at all, so a backpack
    with none is the client not answering, and the last read stands. Bags that
    are empty still have their slots, and are recorded as empty.
]]
local function ScanBags()
	if (C_Container.GetContainerNumSlots(BACKPACK_CONTAINER) or 0) > 0 then
		bagCounts = CountItems(PlayerBagIDs())
	end
end

local function ScanBank()
	bankCounts = CountItems(BankBagIDs())
end

--[[
    Called by the Restocker's PLAYER_LOGIN branch (Restocker-Events.lua), after
    ns.InitializeRestocker.
    Name, realm and class are refreshed every login. A renamed or transferred
    character gets a new key, so its old record, found by the GUID a rename
    keeps, is dropped here; a record saved before the GUID was stored goes only
    once its character logs in under the old key again. The name is the whole
    one, a Forever character's surname included (ns.GetPlayerFullName in
    Utilities).

    The class is read by the Restock List as well, which colors the characters
    on a list by it (Features/Inventory-Restocker/Restocker-Saved-Lists.lua).
]]
function ns.InitializeInventoryReport()
	local inventory = ns.db.global.inventory
	local key = ns.GetCharacterKey()
	record = inventory[key] or {}
	inventory[key] = record

	local _, classToken = UnitClass("player")
	record.name = ns.GetPlayerFullName()
	record.realm = GetRealmName()
	record.class = classToken

	local guid = UnitGUID("player")
	if guid and not ns.IsSecretValue(guid) then
		record.guid = guid
		for otherKey, entry in pairs(inventory) do
			if otherKey ~= key and entry.guid == guid then
				inventory[otherKey] = nil
			end
		end
	end

	bagCounts = nil
	bagsChangedInCombat = false
	bankCounts = record.bank and Unpack(record.bank) or nil

	ns.HookInventoryReportTooltipsLater()
end

--[[
    Handlers keyed by event name, read by the Restocker's dispatcher (Features/Inventory-Restocker/Restocker-Events.lua),
    which has no combat guard: every one only reads containers or writes saved
    variables, and a logout mid-combat must still save this character's bags.
]]
ns.inventoryEventHandlers = {
	-- Login and every loading screen after it: the first read, for a session in which the bags never change.
	PLAYER_ENTERING_WORLD = function()
		ScanBags()
	end,
	BANKFRAME_OPENED = function()
		bankIsOpen = true
		ScanBank()
		C_Timer.After(BANK_SETTLE_DELAY, function()
			if bankIsOpen then
				ScanBank()
			end
		end)
	end,
	--[[
	    The client also fires this on loading screens with no bank open, which
	    is harmless here: the last scan simply stands.
	]]
	BANKFRAME_CLOSED = function()
		bankIsOpen = false
	end,
	--[[
	    Every change to the bags is read as it lands, so the snapshot is current
	    whenever the session ends. Not mid-fight: a hunter's every shot changes
	    the bags, so a fight's changes are read once, when it is over. A logout
	    taken mid-fight saves the bags as they were when it began.

	    While the bank is open, every move in or out of it -- the Restocker's own
	    or the player's -- lands here too, so the bank's snapshot ends the visit
	    current.
	]]
	BAG_UPDATE_DELAYED = function()
		if InCombatLockdown() then
			bagsChangedInCombat = true
		else
			ScanBags()
		end
		if bankIsOpen then
			ScanBank()
		end
	end,
	PLAYER_REGEN_ENABLED = function()
		if bagsChangedInCombat then
			bagsChangedInCombat = false
			ScanBags()
		end
	end,
	-- Writes down what was last read: nothing is asked of the client here (see bagCounts).
	PLAYER_LOGOUT = function()
		if not record then
			return
		end
		if bagCounts then
			record.bags = Pack(bagCounts)
		end
		if bankCounts then
			record.bank = Pack(bankCounts)
		end
	end,
}

-- This character's saved entry, its bank as last read, and the saved counts' format, for the tooltip half.
function ns.GetInventoryRecord()
	return record
end

function ns.GetInventoryBankCounts()
	return bankCounts
end

ns.UnpackInventoryCounts = Unpack
