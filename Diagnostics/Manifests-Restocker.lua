local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

local function ItemText(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	return string.format("%d (%s)", itemID, name or "name not loaded")
end

--------------------------------------------------------------------------------
-- Restocker Context
--------------------------------------------------------------------------------

--[[
    The probe for "the Restocker did nothing" and "the tooltip shows no counts"
    reports: the switches, the list this character shops from, the gold and
    bag space a purchase needs, the windows open now, the open vendor's
    standing, the reagents the list's crafts need, the staples offer's gates,
    what a merchant would buy now, the reminders and their gates, and the
    Inventory Report's hook and records. Read-only.
]]
local function MoneyText(copper)
	copper = copper or 0
	return string.format("%dg %ds %dc", math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end

-- Free slots in the carried bags that take any item (bag family 0).
local function FreeBagSlots()
	local free = 0
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, family = C_Container.GetContainerNumFreeSlots(bag)
		if family == 0 then
			free = free + (slots or 0)
		end
	end
	return free
end

function ns:BuildRestockerContextReport()
	local lines = { GetClientHeader(), "" }
	local global = ns.db and ns.db.global
	if not global then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end
	local settings = global.restocker or {}
	local lists = settings.lists or {}
	local list = settings.currentList and lists[settings.currentList]
	local characterKey = ns.GetCharacterKey()

	lines[#lines + 1] = "-- Restocker --"
	lines[#lines + 1] = string.format(
		"Restocker switch: %s (off stops the window, /restock, the reminders and every purchase) // started: %s",
		OnOff(global.restockerEnabled),
		YesNo(ns.restockerLoaded)
	)
	lines[#lines + 1] = string.format(
		"List in use: %s // this profile picks: %s // exists: %s // rows: %d // lists saved: %d",
		tostring(settings.currentList),
		tostring(ns.db.profile.restockList),
		YesNo(list),
		CountKeys(list),
		CountKeys(lists)
	)
	lines[#lines + 1] = string.format(
		"Gold Reserve: %s, %s gold // money now: %s",
		OnOff(settings.goldReserve),
		tostring(settings.goldReserveAmount),
		MoneyText(GetMoney())
	)
	lines[#lines + 1] = string.format("Free bag slots: %d", FreeBagSlots())
	lines[#lines + 1] = string.format(
		"Merchant open: %s // buying skipped: %s // Bank open: %s",
		YesNo(ns.merchantIsOpen),
		YesNo(ns.merchantBuyingSkipped),
		YesNo(ns.bankIsOpen)
	)

	--[[
	    What the vendor itself decides (Restocker-Merchant.lua): a row needing a
	    better standing than this vendor's is skipped in silence, and a vendor
	    missing any reagent a craft needs sells none of them.
	]]
	if ns.merchantIsOpen then
		local reaction = UnitReaction("npc", "player") or UnitReaction("target", "player") or 0
		lines[#lines + 1] = string.format(
			"Vendor standing: %d (%s) // items it lists: %d",
			reaction,
			tostring(ns.GetStandingLabel(reaction)),
			GetMerchantNumItems() or 0
		)
	end
	local reagents = {}
	if ns.restockerLoaded and list then
		for reagentID, count in pairs(ns.BuildCraftingPurchaseOrder()) do
			if count > 0 then
				reagents[#reagents + 1] = string.format("%s x%d", ItemText(reagentID), count)
			end
		end
		table.sort(reagents)
	end
	lines[#lines + 1] = string.format(
		"Reagents the list's crafts need now: %s",
		#reagents > 0 and table.concat(reagents, ", ") or "(none)"
	)

	lines[#lines + 1] = string.format(
		"Town reminder: chat %s, sound %s, %s // resting: %s, on a flight: %s",
		OnOff(settings.restockReminderChat),
		OnOff(settings.restockReminderSound),
		tostring(settings.restockReminderMode),
		YesNo(IsResting()),
		YesNo(UnitOnTaxi("player"))
	)
	lines[#lines + 1] = string.format(
		"Merchant reminder: %s, %s // auto-open at merchant: %s",
		OnOff(settings.merchantReminder),
		tostring(settings.merchantReminderMode),
		OnOff(settings.autoOpenAtMerchant)
	)
	lines[#lines + 1] = string.format(
		"Bank reminder: %s, %s // auto-open at bank: %s",
		OnOff(settings.bankReminder),
		tostring(settings.bankReminderMode),
		OnOff(settings.autoOpenAtBank)
	)
	lines[#lines + 1] = string.format(
		"Window open: %s // level: %d",
		YesNo(ns.restockWindow and ns.restockWindow:IsShown()),
		UnitLevel("player") or 0
	)

	-- What a merchant visit would buy now (the rows short of their Keep amount with Buy on), with what the bags hold.
	local short = {}
	for _, entry in ipairs(ns.BuildGroceryList()) do
		short[#short + 1] =
			string.format("%s %d/%d", tostring(entry.itemName or entry.itemID), entry.have, entry.wanted)
	end
	lines[#lines + 1] =
		string.format("Short now (a merchant would buy): %s", #short > 0 and table.concat(short, ", ") or "(nothing)")

	--[[
	    The Inventory Report's file is new in a TOC, so a client updated while
	    running reads it only after a restart: until then the feature is absent.
	]]
	local inventory = global.inventory or {}
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Inventory Report --"
	lines[#lines + 1] = string.format(
		"Inventory Report switch: %s // feature loaded: %s",
		OnOff(global.inventoryReport),
		YesNo(ns.InitializeInventoryReport)
	)
	lines[#lines + 1] = string.format(
		"Tooltip hook: %s",
		(TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall) and "TooltipDataProcessor post-call"
			or "OnTooltipSetItem"
	)
	--[[
	    Only characters on this realm are listed, and a bank never opened yet
	    counts as 0 (Inventory-Report.lua).
	]]
	local realm = GetRealmName()
	local onRealm = 0
	for _, entry in pairs(inventory) do
		if entry.realm == realm and entry.name then
			onRealm = onRealm + 1
		end
	end
	local own = inventory[characterKey]
	lines[#lines + 1] = string.format(
		"This character recorded: %s (%s) // bank saved by an earlier session: %s",
		YesNo(own),
		characterKey,
		YesNo(own and own.bank)
	)
	lines[#lines + 1] = string.format("Characters recorded: %d // on this realm: %d", CountKeys(inventory), onRealm)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Account --"
	lines[#lines + 1] = string.format(
		"Welcome message: %s // Macro names on buttons: %s // Readiness Report: %s",
		OnOff(global.showWelcome),
		OnOff(global.showMacroNames),
		OnOff(global.readinessReportEnabled)
	)
	return (table.concat(lines, "\n"):gsub("|", "||"))
end
