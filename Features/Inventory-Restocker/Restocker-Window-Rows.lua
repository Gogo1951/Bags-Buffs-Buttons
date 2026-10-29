local _, ns = ...
local L = ns.L

--[[
    The controls that fill the Restock List grid: the Keep box, the toggle cells,
    the reputation cell, the remove button and its undo, and the pooled rows
    holding them.

    The grid itself -- column definitions, widths, shared colors and the header --
    is Restocker-Window-Columns.lua, which loads first. The reputation and column
    menus are Restocker-Window-Menus.lua, and the render loop that lays these rows
    out is Restocker-Window-Render.lua.
]]
local COLUMNS = ns.RESTOCK_COLUMNS
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local REMOVE_ICON_SIZE = ns.RESTOCK_REMOVE_ICON_SIZE
local COLUMN_MIN_WIDTH = ns.RESTOCK_COLUMN_MIN_WIDTH
local ROW_INSET = ns.RESTOCK_ROW_INSET
local ICON_SIZE = ns.RESTOCK_ICON_SIZE
local ICON_TEXT_GAP = ns.RESTOCK_ICON_TEXT_GAP
local NAME_COLUMN_GAP = ns.RESTOCK_NAME_COLUMN_GAP
local KEEP_GAP = ns.RESTOCK_KEEP_GAP
local GOLD = ns.RESTOCK_CELL_GOLD
local WHITE = ns.RESTOCK_CELL_WHITE
local DASH_OFF = ns.RESTOCK_CELL_DASH_OFF
local DASH_NOT_APPLICABLE = ns.RESTOCK_CELL_DASH_NOT_APPLICABLE
local REPUTATION_SET = ns.RESTOCK_CELL_REPUTATION_SET
local KEEP_SHORT = ns.RESTOCK_CELL_KEEP_SHORT
local CELL_HIGHLIGHT = ns.RESTOCK_CELL_HIGHLIGHT
local CELL_HIGHLIGHT_ALPHA = ns.RESTOCK_CELL_HIGHLIGHT_ALPHA
local LayoutColumns = ns.LayoutRestockColumns
local ApplyColumnWidths = ns.ApplyRestockColumnWidths
local TooltipBody = ns.RestockColumnTooltipBody
local ReputationStandingByValue = ns.RestockReputationStandingByValue

--[[
    Zebra stripe alpha. Deliberately faint: the row already carries quality-coloured
    item names and gold check glyphs, and a stripe strong enough to notice on its own
    competes with both. It only has to make the eye's path across seven cells hold
    its line.
]]
local ROW_STRIPE_ALPHA = 0.045

--[[
    An item carried onto a row is being dropped on the list, not aimed at the
    control under it, so every control on a row hands the cursor to the add path
    (ns.AddRestockItemFromCursor in Restocker-Window-Widgets.lua) and acts as itself only
    when the cursor holds no item. This is the drag-release half; each click
    handler makes the same call first.
]]
local function TakeCursorItem()
	ns.AddRestockItemFromCursor()
end

--[[
    A Keep amount is yellow while the bags hold fewer: the grocery list's line
    not yet crossed off. ns.IsRestockItemShort (Restocker-Shortfall.lua) is the
    test, so the mark goes by the same bag count the merchant restock and the
    orders under the list do -- and by nothing else: a row with Buy off, which
    the bank is meant to fill, is just as short until it has been. The orders
    count under the list is drawn in the same yellow (Restocker-Window-Footer.lua).
]]
local function PaintKeep(editBox, item)
	local tone = ns.IsRestockItemShort(item) and KEEP_SHORT or WHITE
	editBox:SetTextColor(tone.r, tone.g, tone.b)
end

ns.PaintRestockKeep = PaintKeep

--[[
    The Keep box: how many of this item the list keeps in the bags. The caller
    places it and sets its width, since the row lays its controls out from the
    right edge inward and this one hangs off the leftmost column.
]]
local function CreateAmountEditBox(frame)
	local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")

	editBox:SetHeight(ns.restockButtonHeight - 2)
	editBox:SetAutoFocus(false)
	--[[
	    Digits only, and every read still falls back to 0: item.amount is compared
	    against bag counts by the bank restock loop, where a nil target throws and
	    aborts the whole run.
	]]
	editBox:SetNumeric(true)
	--[[
	    Both handlers read self.item, rebound by ns.UpdateRestockListRow like every
	    other row control -- never GetParent().item, which can point at another
	    item once the row is reused, and removal then fails silently.
	]]
	editBox:SetScript("OnEnterPressed", function(self)
		local amount = tonumber(self:GetText()) or 0

		if self.item then
			self.item.amount = amount
		end
		editBox:ClearFocus()
		self:SetText(tostring(amount))
		ns.UpdateRestockList()
		if ns.bankIsOpen then
			ns.OnRestockerBankOpen()
		end
	end)
	editBox:SetScript("OnKeyUp", function(self)
		if self.item then
			self.item.amount = tonumber(self:GetText()) or 0
			--[[
			    Saved as the player types, so closing the window without
			    pressing Enter keeps what the box holds, and an emptied box
			    saves 0 (store all of it at the bank). The amount is live from
			    here, so its mark and the count under the list follow it.
			]]
			PaintKeep(self, self.item)
			ns.UpdateRestockStatus()
		end
	end)
	--[[
	    An item carried onto the box joins the list, like one dropped anywhere
	    else on the window. The click that dropped it also focused the box, and
	    the redraw may have handed the box a different row, so the focus goes.
	]]
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	editBox:SetScript("OnMouseUp", TakeDroppedItem)
	editBox:SetScript("OnReceiveDrag", TakeDroppedItem)

	-- No "press Enter" line: OnKeyUp above has already saved the amount.
	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])

	return editBox
end

--[[
    The row a remove click just took off the list, kept so the status line can
    offer it back (ns.UndoRestockRemove): the button sits beside the last
    column, and a row's Keep amount and flags go with it. One step deep -- a
    second removal replaces it -- and dropped with the "New" flags, whenever the
    window closes or the list changes (ns.ClearRestockNewItems).
]]
ns.restockLastRemoved = nil

--[[
    A remove redraws the list at once, so by a double-click's second click the
    pooled button under the cursor belongs to the next row. A remove this soon
    after the last one is that second click, and is ignored.
]]
local DOUBLE_CLICK_GUARD_SECONDS = 0.4
local lastRemoveTime = -math.huge

-- Reads self.item, which UpdateRestockListRow rebinds like every other row control, never GetParent().item.
local function OnDeleteButtonClick(self)
	-- An item carried onto the button is being dropped on the list, not aimed at this row.
	if ns.AddRestockItemFromCursor() then
		return
	end

	local now = GetTime()
	if now - lastRemoveTime < DOUBLE_CLICK_GUARD_SECONDS then
		return
	end

	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]
	local item = self.item

	if item and item.itemID then
		-- Lists are keyed by itemID, so removal is a direct delete
		list[item.itemID] = nil
		lastRemoveTime = now
		ns.restockLastRemoved = { item = item, listName = settings.currentList }
		ns.UpdateRestockList()
	end
end

--[[
    Put the last removed row back exactly as it was. Refused quietly when the
    list it came from is gone or already holds that item again -- added back by
    hand, which is the newer intent -- and either way the offer is spent.
]]
function ns.UndoRestockRemove()
	local removed = ns.restockLastRemoved
	ns.restockLastRemoved = nil
	if not removed then
		return
	end

	local list = ns.restockSettings.lists[removed.listName]
	if list and list[removed.item.itemID] == nil then
		list[removed.item.itemID] = removed.item
	end
	ns.UpdateRestockList()
end

--[[
    The group-loot pass mark is the game's own "get rid of this" icon, and the
    same texture the options panels' item lists (Options/Options-Utilities.lua)
    use for their remove column -- so removal looks the same everywhere. Never a
    UIPanelCloseButton: its red X reads as "close the window" on a row, and its
    30px frame is mostly transparent padding.

    The highlight is the normal texture blended additively rather than a separate
    file, which glows on hover without depending on a second art path.
]]
local REMOVE_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local REMOVE_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

local function CreateDeleteButton(frame)
	local button = CreateFrame("Button", nil, frame)

	button:SetPoint("RIGHT", frame, "RIGHT", -ROW_INSET, 0)
	button:SetSize(REMOVE_ICON_SIZE, REMOVE_ICON_SIZE)
	button:SetNormalTexture(REMOVE_ICON)
	button:SetPushedTexture(REMOVE_ICON_DOWN)
	button:SetHighlightTexture(REMOVE_ICON, "ADD")
	button:SetScript("OnClick", OnDeleteButtonClick)
	button:SetScript("OnReceiveDrag", TakeCursorItem)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_REMOVE_TOOLTIP"], L["RESTOCKER_REMOVE_TOOLTIP_UNDO"])
	return button
end

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

local CELL_ON, CELL_OFF, CELL_NOT_APPLICABLE = "on", "off", "na"

local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local CHECK_SIZE = 16
local DASH_WIDTH = 7
local DASH_HEIGHT = 2

--[[
    Reading and writing one item flag per column, so a cell needs no knowledge of
    which one it is beyond its key.

    The nil defaults are load-bearing and differ per flag: buyFromMerchant and
    upgrade default ON when unset, buyExtra defaults OFF. A plain `not` on the
    first two would read nil as false and switch them on, which is backwards.
]]
local COLUMN_STATE = {
	withdraw = function(item)
		return item.restockFromBank and CELL_ON or CELL_OFF
	end,
	deposit = function(item)
		return item.stashToBank and CELL_ON or CELL_OFF
	end,
	buy = function(item)
		return (item.buyFromMerchant == nil or item.buyFromMerchant) and CELL_ON or CELL_OFF
	end,
	extra = function(item)
		--[[
		    Extra rides on top of Buy: ns.RestockFromMerchant never reaches an item
		    with Buy off, so the cell says "not applicable" rather than "off".
		]]
		if not (item.buyFromMerchant == nil or item.buyFromMerchant) then
			return CELL_NOT_APPLICABLE
		end
		return item.buyExtra and CELL_ON or CELL_OFF
	end,
	upgrade = function(item)
		--[[
		    Only vendor-sold staples sit on a ladder; most of a real list cannot
		    upgrade at all, which is not the same as choosing not to.
		]]
		if not ns.CanUpgradeRestockItem(item.itemID) then
			return CELL_NOT_APPLICABLE
		end
		return (item.upgrade ~= false) and CELL_ON or CELL_OFF
	end,
}

-- Read by the column menus (Restocker-Window-Menus.lua), which set a column only where it applies.
ns.RESTOCK_COLUMN_STATE = COLUMN_STATE
ns.RESTOCK_CELL_NOT_APPLICABLE = CELL_NOT_APPLICABLE

local COLUMN_TOGGLE = {
	withdraw = function(item)
		item.restockFromBank = not item.restockFromBank
	end,
	deposit = function(item)
		item.stashToBank = not item.stashToBank
	end,
	buy = function(item)
		if item.buyFromMerchant == nil then
			item.buyFromMerchant = false -- nil defaults to true, so toggle to false
		else
			item.buyFromMerchant = not item.buyFromMerchant
		end
	end,
	extra = function(item)
		item.buyExtra = not item.buyExtra -- nil defaults to false
	end,
	upgrade = function(item)
		if item.upgrade == nil then
			item.upgrade = false -- nil defaults to true, so toggle to false
		else
			item.upgrade = not item.upgrade
		end
	end,
}

-- Attach the shared hover highlight used by every clickable cell.
local function AddCellHighlight(cell)
	cell:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
	end
end

--[[
    Why a cell cannot be set on its row, by column. A dead cell's tooltip says
    this in place of the column's general explanation, which would describe a
    switch the row does not have.
]]
local NOT_APPLICABLE_REASON = {
	extra = "RESTOCKER_EXTRA_NOT_APPLICABLE",
	reputation = "RESTOCKER_REPUTATION_NOT_APPLICABLE",
	upgrade = "RESTOCKER_UPGRADE_NOT_APPLICABLE",
}

--[[
    The part of a cell's state every column shares: whether it takes clicks, and
    the dash's tone. The cell's tooltip reads the same flag, to give the reason
    above in place of the column's explanation (SetupCellTooltip).

    Alpha rather than Disable() on the highlight: a dead cell still has to answer
    "why can this not be set?", and Disable() would take the tooltip away with the
    clicks.
]]
local function SetCellActive(cell, isActive)
	cell.isActive = isActive
	local tone = isActive and DASH_OFF or DASH_NOT_APPLICABLE
	cell.dash:SetColorTexture(tone.r, tone.g, tone.b, 1)
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetAlpha(isActive and 1 or 0)
	end
end

-- Paint a glyph cell for one of the three states.
local function SetCell(cell, state)
	cell.check:SetShown(state == CELL_ON)
	cell.dash:SetShown(state ~= CELL_ON)
	SetCellActive(cell, state ~= CELL_NOT_APPLICABLE)
end

--[[
    Paint the reputation cell. It names its standing only when one is set, in
    amber so a gated row stands out. With none it draws the dash every other
    column draws for off, rather than a word: "Any" is the absence of a
    requirement, and a column of thirty identical words buries the one row that
    sets one.

    It rides on Buy the way Extra does -- a standing only gates buying -- so with
    Buy off it is not applicable: the dimmer dash, and no menu. The standing
    itself stays on the row, and shows again when Buy comes back on.
]]
local function SetReputationCell(cell, item)
	local buys = item.buyFromMerchant == nil or item.buyFromMerchant
	local isSet = buys and (item.reaction or 0) > 0
	cell.text:SetShown(isSet)
	cell.dash:SetShown(not isSet)
	if isSet then
		cell.text:SetText(ns.GetStandingLabel(ReputationStandingByValue(item.reaction).value))
		cell.text:SetTextColor(REPUTATION_SET.r, REPUTATION_SET.g, REPUTATION_SET.b)
	end
	SetCellActive(cell, buys)
end

--[[
    A cell's tooltip: its column's title and explanation, or -- on a row where the
    cell cannot be set -- the title and the reason why not.
]]
local function SetupCellTooltip(cell, column)
	local reason = NOT_APPLICABLE_REASON[column.key]
	cell:SetScript("OnEnter", function(self)
		if reason and not self.isActive then
			ns.ShowRestockerTooltip(self, L[column.title], L[reason])
		else
			ns.ShowRestockerTooltip(self, L[column.title], unpack(TooltipBody(column)))
		end
	end)
	cell:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

local function CreateGlyphCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)

	local check = cell:CreateTexture(nil, "ARTWORK")
	check:SetTexture(CHECK_TEXTURE)
	check:SetSize(CHECK_SIZE, CHECK_SIZE)
	check:SetPoint("CENTER")
	check:SetVertexColor(GOLD.r, GOLD.g, GOLD.b)
	cell.check = check

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	local toggle = COLUMN_TOGGLE[column.key]
	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		-- Reads self.item, rebound by UpdateRestockListRow like every other control
		if not (self.isActive and self.item) then
			return
		end
		toggle(self.item)
		ns.UpdateRestockListRow(row, self.item)
		-- Buy decides whether a short row is an order, so the count under the list can move.
		ns.UpdateRestockStatus()
	end)
	cell:SetScript("OnReceiveDrag", TakeCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

--[[
    The reputation cell. A menu, not a toggle, so it names the standing it
    requires and opens the standings list on click. SetReputationCell above
    paints it.
]]
local function CreateReputationCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)
	cell.isActive = true

	local fontString = cell:CreateFontString(nil, "ARTWORK", BUTTON_FONT)
	fontString:SetPoint("CENTER")
	cell.text = fontString

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		if not (self.isActive and self.item) then
			return
		end
		ns.OpenRestockReputationMenu(self, row)
	end)
	cell:SetScript("OnReceiveDrag", TakeCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

function ns.CreateRestockListRow(item)
	--[[
	    Born parented to the hidden frame and positioned by ns.UpdateRestockList, which
	    places every row by absolute index rather than chaining them to each other.
	]]
	local frame = CreateFrame("Frame", nil, ns.restockHiddenFrame)
	frame:SetSize(ns.restockWindow.scrollChild:GetWidth(), ns.restockRowHeight)
	frame.item = item

	--[[
	    The stripe belongs to the POSITION, not the item: rows come from a pool and
	    are reused at whatever index the next render puts them at, so every row owns
	    a stripe and ns.UpdateRestockList decides which ones show.
	]]
	local stripe = frame:CreateTexture(nil, "BACKGROUND")
	stripe:SetAllPoints(frame)
	stripe:SetColorTexture(WHITE.r, WHITE.g, WHITE.b, ROW_STRIPE_ALPHA)
	frame.stripe = stripe

	-- ICON, with an invisible button over it that shows the item tooltip on hover
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", frame, "LEFT", ROW_INSET, 0)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim the default icon border
	frame.icon = icon

	-- RIGHT EDGE: the remove control, then the columns walking left from it.
	frame.removeButton = CreateDeleteButton(frame)
	frame.cells, frame.firstCell = LayoutColumns(frame.removeButton, function(column)
		if column.isText then
			return CreateReputationCell(frame, column)
		end
		return CreateGlyphCell(frame, column)
	end)

	-- The Keep box hangs off the leftmost column, beside the name it belongs to.
	frame.amountBox = CreateAmountEditBox(frame)
	frame.amountBox:SetPoint("RIGHT", frame.firstCell, "LEFT", -KEEP_GAP, 0)
	frame.amountBox:SetWidth(ns.restockAmountWidth)

	--[[
	    ITEM NAME fills whatever the controls leave. Anchored on both sides with no
	    word wrap, so a long name truncates instead of running under the Keep box.
	]]
	local text = frame:CreateFontString(nil, "OVERLAY", nil)
	text:SetFontObject("GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(false)
	text:SetPoint("LEFT", icon, "RIGHT", ICON_TEXT_GAP, 0)
	text:SetPoint("RIGHT", frame.amountBox, "LEFT", -NAME_COLUMN_GAP, 0)
	frame.text = text

	--[[
	    The icon and the name together are the row's tooltip target: a FontString
	    takes no mouse, so an invisible button covers both. It shows the item
	    tooltip, and takes an item dropped on it like the rest of the window does;
	    there is nothing else for a row click to open.
	]]
	local nameButton = CreateFrame("Button", nil, frame)
	nameButton:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	nameButton:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", 0, 0)
	nameButton:SetScript("OnClick", TakeCursorItem)
	nameButton:SetScript("OnReceiveDrag", TakeCursorItem)
	nameButton:SetScript("OnEnter", function(button)
		local rowItem = frame.item
		if not (rowItem and rowItem.itemID) then
			return
		end
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		-- Prefer the cached colored link; fall back to a bare item: link (always valid)
		local info = ns.GetItemData(rowItem.itemID)
		GameTooltip:SetHyperlink((info and info.itemLink) or ("item:" .. rowItem.itemID))
		GameTooltip:Show()
	end)
	nameButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.nameButton = nameButton

	table.insert(ns.restockRowPool, frame)
	return frame
end

--[[
    The client's name for the item whenever it has one, written onto the row so the
    filter and the sort read it too; the saved name stands in only while the item
    is still loading. Returns the client's item data, or nil while it loads.
]]
local function RefreshItemName(item)
	local info = ns.GetItemData(item.itemID)
	if info and info.itemName and info.itemName ~= "" then
		item.itemName = info.itemName
	end
	return info
end

ns.RefreshRestockItemName = RefreshItemName

function ns.UpdateRestockListRow(row, item)
	row.item = item
	-- Every control carries its own item rather than resolving through a parent.
	row.removeButton.item = item
	row.amountBox.item = item
	for _, cell in pairs(row.cells) do
		cell.item = item
	end

	--[[
	    Column widths can resolve after a row was built (see
	    ns.RefreshRestockColumnHeader), so re-read them here rather than only at
	    creation -- the Keep box's too, since the item name stops at its left
	    edge. Guarded on a serial, which makes this seven SetWidth calls once and
	    a single comparison thereafter.
	]]
	if row.columnSerial ~= ns.restockColumnWidthSerial then
		row.columnSerial = ns.restockColumnWidthSerial
		row.amountBox:SetWidth(ns.restockAmountWidth)
		ApplyColumnWidths(row.cells)
	end

	for _, column in ipairs(COLUMNS) do
		if not column.isText then
			SetCell(row.cells[column.key], COLUMN_STATE[column.key](item))
		end
	end
	SetReputationCell(row.cells.reputation, item)

	-- Icon + quality-colored name (from the item cache; falls back until it is known)
	local info = RefreshItemName(item)
	if info then
		row.icon:SetTexture(info.itemTexture)
		local quality = ITEM_QUALITY_COLORS[info.itemRarity or 1]
		if quality then
			row.text:SetTextColor(quality.r, quality.g, quality.b)
		else
			row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
		end
	else
		row.icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
	end

	row.text:SetText(item.itemName)
	row.amountBox:SetText(tostring(item.amount or 0))
	PaintKeep(row.amountBox, item)
end
