local _, ns = ...

--[[
    How short the bags are of the Restock List, with no merchant involved: the
    grocery list the reminders, the mini-map tooltip and the window's footer
    read, and the one-row test behind the Keep box's mark. The merchant restock
    itself is Restocker-Merchant.lua.
]]

--------------------------------------------------------------------------------
-- Grocery List
--------------------------------------------------------------------------------

--[[
    What the current list is short of right now: the same shortfall
    BuildPurchaseOrder computes, minus the vendor. Used by the mini-map tooltip,
    the entering-town reminder and the reminders after a merchant or bank window
    closes, none of which reads a vendor's stock.

    Two differences from a real purchase order, both because there is no vendor:
    the required-reputation gate is skipped (it depends on which vendor you walk
    up to), and crafting reagents are left out (ns.BuildCraftingPurchaseOrder
    resolves those against the merchant's stock). So this answers "what am I low on", which is
    what a shopping list is, rather than "what will this vendor sell me".

    Counts are bags only -- C_Item.GetItemCount(id, false, false) -- matching what the
    merchant restock compares against, so the list agrees with what would
    actually be bought.
]]
function ns.BuildGroceryList()
	local settings = ns.restockSettings
	local restockList = settings and settings.lists and settings.lists[settings.currentList]
	local list = {}
	if not restockList then
		return list
	end

	for _, record in pairs(restockList) do
		local wanted = record.amount or 0
		local key = record.itemID or record.itemName
		-- nil buyFromMerchant defaults to true, the same rule ns.RestockFromMerchant uses
		if key and wanted > 0 and (record.buyFromMerchant == nil or record.buyFromMerchant) then
			local have = C_Item.GetItemCount(key, false, false) or 0
			local short = wanted - have
			if short > 0 then
				--[[
				    have/wanted ride along for the verbose town reminder, which reports
				    the ratio rather than the shortfall.
				]]
				list[#list + 1] = {
					itemID = record.itemID,
					itemName = record.itemName,
					have = have,
					wanted = wanted,
					needed = short,
				}
			end
		end
	end

	table.sort(list, function(a, b)
		return (a.itemName or "") < (b.itemName or "")
	end)
	return list
end

--[[
    Do the bags hold fewer of this row's item than its Keep amount? The grocery
    list's own shortfall, asked of one row and without its Buy gate: the Restock
    window marks every short row, not only the ones a merchant would be asked
    for, so a row the bank is meant to fill is marked too.

    Bags only and counted by the same key, so a row this calls short with Buy on
    is always an order on the list above. A Keep of 0 asks for nothing and is
    never short; with Store on it sends the whole stock to the bank.
]]
function ns.IsRestockItemShort(record)
	local wanted = record.amount or 0
	local key = record.itemID or record.itemName
	return key ~= nil and wanted > 0 and (C_Item.GetItemCount(key, false, false) or 0) < wanted
end
