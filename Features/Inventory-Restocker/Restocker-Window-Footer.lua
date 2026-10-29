local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Status Line
--------------------------------------------------------------------------------

--[[
    (list controls) ...                                  7 restocking orders outstanding.

    The right of the window's bottom line, under the list; its left holds the
    list controls (Restocker-Window-List-Bar.lua). The undo offer is built here
    too, though it sits above the list (Undo Offer, below).

    At the right end is the answer the list exists to give: how many restocking orders
    are outstanding, in the words the merchant and bank reminders print
    (ns.RestockShortfallHeadline). Hovering it lists the orders the way the
    mini-map's Restocker Report does -- icon, name, have/wanted -- capped, so a
    long list cannot run the tooltip off the screen.

    It is read straight off ns.BuildGroceryList, like the mini-map tooltip and
    every reminder, so none of them can disagree about what is outstanding. An
    order is a row with Buy on that the bags are short of, and the count is
    drawn in the yellow of the Keep marks it counts (KEEP_SHORT in
    Data/Data.lua): the line is where a player learns what a yellow Keep
    number means. Red is kept for errors, and being short of something is not
    one.

    The Keep marks in the list are every short row, Buy or not, so with Buy
    off on a short row there is a mark and no order -- and the line says "no
    orders", in plain white, rather than congratulating a list that is visibly
    short of something. The congratulation is kept for a list with no mark on
    it at all.

    An empty list says nothing here: the invitation in its place already does.

    Anchor footer controls to the row, never to the WINDOW: a control anchored
    to the window lands at its middle and disappears behind the list.
]]
-- Centred in the window's footer band (ns.RESTOCK_WINDOW_BANDS), as the Spell Book's legend is.
local FOOTER_X = 12
local FOOTER_RIGHT_INSET = 26 -- clear of the resize grip
local FOOTER_ROW_HEIGHT = 22
local FOOTER_Y = ns.RESTOCK_WINDOW_BANDS.FRAME_BORDER + (ns.RESTOCK_WINDOW_BANDS.FOOTER_HEIGHT - FOOTER_ROW_HEIGHT) / 2
local UNDO_GAP = 10 -- "Removed [item]." to the Undo button
local UNDO_HEIGHT = 20

-- The most orders the hover lists one per row; past it, one closing line counts the rest.
local ORDERS_TOOLTIP_MAX_ROWS = 20

-- Forward-declared: the status repaint and the undo offer's resize handler both call it, and it is defined below them.
local FitUndoOffer

local TITLE = ns.COLORS_RGB.TITLE
-- The Keep marks' own color, as an escape for the orders count. Append |r at the point of use.
local SHORT = "|cff" .. ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT

--------------------------------------------------------------------------------
-- Orders Tooltip
--------------------------------------------------------------------------------

--[[
    An item as this line and its tooltip name one: its icon, then its name in
    its quality color, with no brackets (ns.GetItemLabel, which names an item
    even while the cache is cold). A name-only row has no ID to look an icon up
    by, so it shows the question mark the list itself uses.
]]
local UNKNOWN_ICON = "Interface\\ICONS\\INV_Misc_QuestionMark"

local function ItemWithIcon(itemID, itemName)
	local icon = itemID and C_Item.GetItemIconByID(itemID) or UNKNOWN_ICON
	return string.format("|T%s:14:14|t %s", icon, ns.GetItemLabel(itemID, itemName))
end

--[[
    The orders themselves, in the mini-map Restocker Report's own form and under
    its own title: the item, then have/wanted, the ratio the verbose reminder
    prints.

    Built on hover rather than kept, so it is as current as the bags are.
    Nothing to list draws no tooltip: the line above has already said so.
]]
local function ShowOrdersTooltip(owner)
	local groceries = ns.BuildGroceryList()
	if #groceries == 0 then
		return
	end

	GameTooltip:SetOwner(owner, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(L["MINIMAP_RESTOCKER_REPORT"], TITLE.r, TITLE.g, TITLE.b)
	for index = 1, math.min(#groceries, ORDERS_TOOLTIP_MAX_ROWS) do
		local entry = groceries[index]
		GameTooltip:AddDoubleLine(
			ItemWithIcon(entry.itemID, entry.itemName),
			GetColor("BODY") .. string.format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted) .. "|r"
		)
	end
	if #groceries > ORDERS_TOOLTIP_MAX_ROWS then
		GameTooltip:AddLine(
			GetColor("MUTED") .. string.format(L["RESTOCKER_REPORT_MORE"], #groceries - ORDERS_TOOLTIP_MAX_ROWS) .. "|r"
		)
	end
	GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Status Text
--------------------------------------------------------------------------------

-- Is any row on the list short in the bags, Buy or not? The rows' Keep marks ask the same of each row.
local function AnyRowShort(list)
	for _, item in pairs(list) do
		if ns.IsRestockItemShort(item) then
			return true
		end
	end
	return false
end

local function StatusText(list)
	if next(list) == nil then
		return ""
	end

	local orders = #ns.BuildGroceryList()
	if orders > 0 then
		return SHORT .. ns.RestockShortfallHeadline(orders) .. "|r"
	end
	if AnyRowShort(list) then
		return L["RESTOCKER_NO_ORDERS"]
	end
	return GetColor("ON") .. L["MINIMAP_RESTOCKER_STOCKED"] .. "|r"
end

--[[
    Repaint the line. Called at the end of every redraw, and on its own wherever
    the count can move without the rows moving: a Buy cell clicked, a Keep amount
    typed, the bags changing with the window open.

    The count's button is sized to its text, so the hover is over the words
    and not over the empty run of footer beside them. The "Used by" line on
    the left then ends short of it. The undo offer is repainted here too, as
    a removal is one of the things that moves the count.
]]
function ns.UpdateRestockStatus()
	local window = ns.restockWindow
	local footer = window.footer
	local settings = ns.restockSettings

	local text = StatusText(settings.lists[settings.currentList])
	footer.statusText:SetText(text)
	footer.status:SetWidth(math.max(1, footer.statusText:GetStringWidth()))
	ns.SetRestockUsersLineEnd((text ~= "") and footer.status or nil)

	local removed = ns.restockLastRemoved
	window.removedText:SetShown(removed ~= nil)
	window.undo:SetShown(removed ~= nil)
	if removed then
		window.removedText:SetText(
			string.format(L["RESTOCKER_REMOVED_ITEM"], ItemWithIcon(removed.item.itemID, removed.item.itemName))
		)
		-- Sized here rather than when built: a font not yet resolved at login measures as nothing.
		ns.FitRestockButton(window.undo)
		FitUndoOffer(window)
	end
end

--------------------------------------------------------------------------------
-- Undo Offer
--------------------------------------------------------------------------------

--[[
    Removed (icon) Major Mana Potion. [Undo]           Bank        Merchant
                                     Item        Keep  Take Store  Buy ...

    The offer to take back the last removal (ns.UndoRestockRemove in
    Restocker-Window-Rows.lua): a sentence naming what went, by its icon and
    its name, and an Undo button. It sits on the group bands' line, starting
    where the category pane's type names start and running right, through
    the empty corner over the pane and on over Item and Keep, so it is beside
    the rows it belongs to and never crowds the footer.

    The button follows the sentence. A name too long for the room truncates,
    and stops short of Keep's right edge, where the Bank band begins.
]]
local function CreateUndoOffer(addonFrame)
	local header = ns.restockColumnHeader
	--[[
	    The room it has: the bands' line, from the pane's left edge to the Keep
	    heading's right. Two corners, each from its own frame; the left one is
	    set again on every repaint (FitUndoOffer), as the pane's width is
	    measured rather than fixed.
	]]
	local tier = CreateFrame("Frame", nil, header.bandRow)
	tier:SetPoint("BOTTOMRIGHT", header.amountCaption, "TOPRIGHT", 0, 0)

	local removedText = tier:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	removedText:SetPoint("LEFT", tier, "LEFT", ns.RESTOCK_GROUP_ROW_INSET, 0)
	removedText:SetJustifyH("LEFT")
	removedText:SetWordWrap(false)
	removedText:Hide()

	--[[
	    Undo is a panel button, as everything a click acts on in this window is.
	    A word in the interaction blue reads as information, not as something to
	    press.
	]]
	local undo = CreateFrame("Button", nil, tier, "UIPanelButtonTemplate")
	undo:SetPoint("LEFT", removedText, "RIGHT", UNDO_GAP, 0)
	undo:SetHeight(UNDO_HEIGHT)
	undo:SetText(L["RESTOCKER_UNDO"])
	ns.FitRestockButton(undo)
	ns.SetRestockControlClick(undo, function()
		-- The click hides the button under the mouse, which would leave its tooltip up.
		GameTooltip:Hide()
		ns.UndoRestockRemove()
	end)
	ns.SetupRestockerTooltip(undo, L["RESTOCKER_UNDO_TOOLTIP"])
	undo:Hide()

	-- A drag on the resize grip moves Keep, and the room with it.
	tier:SetScript("OnSizeChanged", function()
		if undo:IsShown() then
			FitUndoOffer(addonFrame)
		end
	end)

	addonFrame.undoTier = tier
	addonFrame.removedText = removedText
	addonFrame.undo = undo
end

--[[
    Set the undo offer's left edge to the pane's, and the sentence to its own
    width or the room left beside the button, whichever is less. The room is
    unknown until the window has been laid out once, and then the sentence is
    left at its own width.
]]
function FitUndoOffer(window)
	local tier, text = window.undoTier, window.removedText
	tier:SetPoint(
		"TOPLEFT",
		ns.restockColumnHeader.bandRow,
		"TOPLEFT",
		-(ns.restockGroupPaneWidth + ns.RESTOCK_GROUP_PANE_GAP),
		0
	)
	text:SetWidth(0)
	local natural = text:GetUnboundedStringWidth()
	local room = (tier:GetWidth() or 0) - ns.RESTOCK_GROUP_ROW_INSET - UNDO_GAP - window.undo:GetWidth()
	if room > 0 and natural > room then
		text:SetWidth(room)
	end
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

function ns.CreateRestockWindowFooter(addonFrame)
	local footer = CreateFrame("Frame", nil, addonFrame)
	footer:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, FOOTER_Y)
	footer:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -FOOTER_RIGHT_INSET, FOOTER_Y)
	footer:SetHeight(FOOTER_ROW_HEIGHT)

	--[[
	    A button only so it can be hovered: a FontString takes no mouse. A click
	    does nothing but take an item dropped on it.
	]]
	local status = CreateFrame("Button", nil, footer)
	status:SetPoint("RIGHT", footer, "RIGHT", 0, 0)
	status:SetHeight(FOOTER_ROW_HEIGHT)
	local statusText = status:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	statusText:SetPoint("RIGHT", status, "RIGHT", 0, 0)
	status:SetScript("OnEnter", ShowOrdersTooltip)
	status:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	ns.SetRestockControlClick(status)

	footer.status = status
	footer.statusText = statusText
	addonFrame.footer = footer
	CreateUndoOffer(addonFrame)
	return footer
end
