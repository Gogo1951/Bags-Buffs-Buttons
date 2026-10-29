local _, ns = ...
local L = ns.L

--[[
    The Restock List's redraw: the list in use gathered, narrowed to the rows
    shown and laid out on pooled rows. The rows themselves are built and
    painted by Restocker-Window-Rows.lua, which loads first.
]]
local PaintKeep = ns.PaintRestockKeep
local RefreshItemName = ns.RefreshRestockItemName

-- Scratch list rebuilt on every render; never escapes this file.
local restockItemList = {}

--[[
    The items the last render drew, in order. A column heading's menu acts on
    exactly these -- "every item shown" has to mean what the player is looking
    at, category and filter included -- so it is kept from the render rather than
    rebuilt when the menu opens.
]]
local shownItems = {}

-- Read by the column menus (Restocker-Window-Menus.lua). Don't modify it.
function ns.GetRestockShownItems()
	return shownItems
end

--------------------------------------------------------------------------------
-- Update
--------------------------------------------------------------------------------

--[[
    Repaint what the bags decide and nothing else: each shown row's Keep box, and
    the orders counted under the list. For the moments the bags change with the
    window open -- a merchant or bank visit filling them, a Keep amount being
    typed -- where the rows themselves have not moved and a full redraw would
    close an open menu for nothing.
]]
function ns.RefreshRestockShortfall()
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse then
			PaintKeep(row.amountBox, row.item)
		end
	end
	ns.UpdateRestockStatus()
end

--[[
    Use Restock List Food & Water Last reads which items the list in use holds,
    so a redraw that changed them asks for a macro rebuild. Most redraws change
    nothing: a filter keystroke, a category click, the window opening.
]]
local lastListName
local lastListMembers = {}

local function ListMembershipChanged(listName, list)
	local changed = listName ~= lastListName
	local count = 0
	for itemID in pairs(list) do
		count = count + 1
		if not lastListMembers[itemID] then
			changed = true
		end
	end
	for _ in pairs(lastListMembers) do
		count = count - 1
	end
	if not changed and count == 0 then
		return false
	end

	lastListName = listName
	wipe(lastListMembers)
	for itemID in pairs(list) do
		lastListMembers[itemID] = true
	end
	return true
end

-- A row drawn before the client had its item, repainted in place once the answer lands.
function ns.RepaintRestockRows(itemID)
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse and row.item and row.item.itemID == itemID then
			ns.UpdateRestockListRow(row, row.item)
		end
	end
end

function ns.UpdateRestockList()
	--[[
	    Rows are about to be released to the pool and rebound to different items, so
	    an open reputation menu has to go first -- it is anchored to a cell, and its
	    pick would land on whatever item that cell ends up holding. A column menu
	    goes with it: its count is of the rows shown, which are about to change.
	    So does the bag menu, which offers what the list lacks and would go on
	    offering it after the list, or the list in use, has changed.
	]]
	ns.CloseReputationMenu()
	ns.CloseRestockColumnMenu()
	ns.CloseRestockBagMenu()

	local settings = ns.restockSettings
	local currentList = settings.lists[settings.currentList]

	-- Every list edit redraws through here.
	if ListMembershipChanged(settings.currentList, currentList) and ns.db.profile.useRestockLast then
		ns.RequestUpdate()
	end

	--[[
	    Gather items (the list is keyed by itemID, so walk it with pairs), each
	    under the client's current name. A row the client cannot name yet is
	    watched while the window is open, and repainted as its answer arrives.
	]]
	local watchColdRows = ns.restockWindow and ns.restockWindow:IsShown()
	local wasWatching = next(ns.restockColdRows) ~= nil
	wipe(ns.restockColdRows)
	wipe(restockItemList)
	for _, item in pairs(currentList) do
		if not RefreshItemName(item) and watchColdRows then
			ns.restockColdRows[item.itemID] = true
		end
		table.insert(restockItemList, item)
	end
	if wasWatching ~= (next(ns.restockColdRows) ~= nil) then
		ns.SyncRestockItemInfoSubscription()
	end

	--[[
	    One view per redraw: each item's group resolved once and the filter lowered
	    once, shared by the category pane and the render list.
	]]
	local view = ns.BuildRestockView(restockItemList)
	ns.UpdateRestockGroupPane(restockItemList, view)
	local renderList = ns.BuildRestockRenderList(restockItemList, view)

	--[[
	    Release every pooled item row back to the hidden frame. A row can come back
	    bound to another item, so its Keep box lets go of its item and its focus
	    first, or the next keystroke would set that other item's amount; the box
	    now showing the item being typed into takes the focus back below.
	]]
	local typingItem
	for _, row in ipairs(ns.restockRowPool) do
		if row.amountBox:HasFocus() then
			typingItem = row.amountBox.item
			row.amountBox:ClearFocus()
		end
		row.amountBox.item = nil
		row.isInUse = false
		row:SetParent(ns.restockHiddenFrame)
		row:Hide()
	end

	--[[
	    Every entry is one row tall, so the running offset is just an accumulator.
	    It also gives the scroll child its height, which is what keeps the scroll
	    bar's range honest.
	]]
	local scrollChild = ns.restockWindow.scrollChild
	local offset = 0
	-- A late column measurement lands here first; the rows pick it up below.
	ns.RefreshRestockColumnHeader()
	wipe(shownItems)
	for index, entry in ipairs(renderList) do
		local row = ns.AcquireRestockListRow(entry.item)

		shownItems[index] = entry.item
		row.isInUse = true
		row:SetParent(scrollChild)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -offset)
		row:SetSize(scrollChild:GetWidth(), ns.restockRowHeight)
		-- Every second row, counting the first as bare so the list starts flush.
		row.stripe:SetShown(index % 2 == 0)
		ns.UpdateRestockListRow(row, entry.item)
		row:Show()
		if typingItem and entry.item == typingItem then
			row.amountBox:SetFocus()
		end
		offset = offset + ns.restockRowHeight
	end

	scrollChild:SetHeight(math.max(1, offset))

	--[[
	    What stands in for the rows when there are none to draw: the empty list's
	    invitation, or one line saying why a list that has items is showing none of
	    them -- the filter, or a category whose last item just left.
	]]
	local nothingShown = nil
	if #renderList == 0 and #restockItemList > 0 then
		nothingShown = view.filter and L["RESTOCKER_NO_MATCH_FILTER"] or L["RESTOCKER_NO_MATCH_GROUP"]
	end
	ns.UpdateRestockEmptyState(#restockItemList == 0, nothingShown)
	ns.UpdateRestockStatus()
end

--------------------------------------------------------------------------------
-- Row Pool
--------------------------------------------------------------------------------

function ns.AcquireRestockListRow(item)
	for _, frame in ipairs(ns.restockRowPool) do
		if not frame.isInUse then
			return frame
		end
	end
	return ns.CreateRestockListRow(item)
end
