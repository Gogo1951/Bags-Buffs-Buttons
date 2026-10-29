local _, ns = ...

--------------------------------------------------------------------------------
-- Inventory Model
--------------------------------------------------------------------------------

-- Collection of items in the inventory or bank with their precise slot locations and counts, and summaries
local Inventory = {}
Inventory.__index = Inventory

function ns.NewRestockInventorySlot(bag, slot, itemCount)
	return {
		bag = bag,
		slot = slot,
		count = itemCount,
	}
end

local function NewSlotNumber(bag, slot)
	return {
		bag = bag,
		slot = slot,
	}
end

function ns.NewRestockInventory()
	return setmetatable({
		summary = {},
		slots = {},
	}, Inventory)
end

-- Sorts bag slots for each item, with smallest stacks first
function Inventory:SortSlots()
	for _, eachItemSlots in pairs(self.slots) do
		table.sort(eachItemSlots, ns.CompareByStackSizeAscending)
	end
end

function Inventory:FindBestFit(cachedItem, amount)
	local containingSlots = self.slots[cachedItem.itemID]
	if not containingSlots then
		ns.RestockerDebug("TRACE_BEST_FIT_NO_STACKS", cachedItem.itemName, amount)
		return nil
	end

	local mergeDestinations = {}

	for _, inventorySlot in ipairs(containingSlots) do
		local remainingAfterMerge = cachedItem.itemStackCount - (inventorySlot.count + amount)

		-- If can merge into this slot
		if remainingAfterMerge >= 0 then
			local candidate = ns.NewRestockInventorySlot(inventorySlot.bag, inventorySlot.slot, remainingAfterMerge)
			table.insert(mergeDestinations, candidate)
		end
	end

	if #mergeDestinations == 0 then
		ns.RestockerDebug("TRACE_BEST_FIT_NO_CANDIDATES", cachedItem.itemName, amount)
		return nil
	end

	-- Pick smallest remaining
	table.sort(mergeDestinations, ns.CompareByStackSizeAscending)

	-- First element should be lowest, i.e. closest to the perfection of a full stack
	local bestDestination = mergeDestinations[1]
	ns.RestockerDebug(
		"TRACE_BEST_FIT_CANDIDATE",
		cachedItem.itemName,
		amount,
		bestDestination.bag,
		bestDestination.slot
	)
	return NewSlotNumber(bestDestination.bag, bestDestination.slot)
end
