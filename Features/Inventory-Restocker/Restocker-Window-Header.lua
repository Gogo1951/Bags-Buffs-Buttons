local _, ns = ...
local L = ns.L

--[[
    The Restock window's header: the bar itself, the filter box it opens with,
    Pick Staples at its right end, and the adders chained leftward from Pick
    Staples (the bag menu, then the add box and its Add button), with the
    notices the add box shows in place of its hint. Restocker-Window.lua
    builds the window and places these in it; the footer's list controls are
    Restocker-Window-List-Bar.lua's.
]]

--[[
    The header bar and the footer's list controls share a height and a right
    inset, so both are set here and Restocker-Window-List-Bar.lua reads them
    off ns.
]]
local BAR_HEIGHT = 22
local BAR_INSET_LEFT = 6 -- past the portrait's clearance, as the Spell Book's filter sits
local BAR_INSET_RIGHT = 10
ns.RESTOCK_BAR_HEIGHT = BAR_HEIGHT
ns.RESTOCK_BAR_INSET_RIGHT = BAR_INSET_RIGHT

--[[
    A text box takes a dropped item too, though it reports no click: on the
    mouse-up of the click that brought the item, or a drag let go over it. That
    click also focused the box, so once the drop is taken the keyboard goes back
    to the game.
]]
local function SetBoxTakesDrops(box)
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	box:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			TakeDroppedItem(self)
		end
	end)
	box:SetScript("OnReceiveDrag", TakeDroppedItem)
end

local EDIT_BOX_HEIGHT = 18 -- all three fields, shorter than the header's buttons so they centre beside them
--[[
    Each field is only as wide as its job takes, since all of them share the
    header with its buttons and must fit at the window's narrowest. The filter
    holds a word or two of an item's name. The bag menu holds its caption and
    its arrow. The add box holds its hint, the longest text in the header, and
    an add notice is written in that same space; both are kept to a phrase (see
    their locale keys), because the header cannot pay for a field the width of
    a sentence.

    None of them absorbs a wider window: the filter holds the left end, the
    adders chain leftward from Pick Staples, and the slack collects between.

    A placeholder is a FontString rather than editbox content, so nothing clips
    it for you: with only a left anchor, the add hint runs out over the Add
    button. Each is anchored on both sides, so a hint that outgrows its field
    truncates inside it instead of over its neighbour.
]]
local FILTER_BOX_WIDTH = 170
local BAG_MENU_WIDTH = 160
local ADD_BOX_WIDTH = 170
--[[
    Between the bag menu and the add box. An InputBoxTemplate field draws its
    border some 4px left of its own edge, which eats into the gap, so it is
    wider than the 20 it draws as (measured in the Forever client).
]]
local CONTROL_ITEM_GAP = 25
local ADD_BUTTON_WIDTH = 60
local STAPLES_GAP = 8 -- between the header's buttons, and between the add box and Add

--[[
    Where SearchBoxTemplate is missing, the filter is a plain field with the
    pieces the template would have drawn: the magnifying glass beside it, and a
    clear button inside its right edge, shown only while there is text to
    clear. The glass takes no mouse, so there is no dead click target beside a
    box you type into. The clear mark is the group-loot pass the item rows
    already use for "get rid of this", so removal looks the same everywhere.
]]
local ROW_ICON_SIZE = 16
local ROW_ICON_GAP = 8
local FILTER_ICON = "Interface\\Common\\UI-Searchbox-Icon"
local CLEAR_BUTTON_SIZE = 14
local CLEAR_BUTTON_INSET = 4
local CLEAR_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local CLEAR_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

--[[
    Every way of typing or picking an item onto the list sits in the header,
    chained leftward from Pick Staples: the bag menu, then the add box with its
    Add button. Add is bolted to the add box so that pair reads as one control
    rather than one more field. Left to right the adders run from the least
    typing to the most: pick what is already in the bags, then drop or type
    anything else, then Pick Staples, which opens a window of its own.
]]

--[[
    A text filter opening the header, as the Spell Book's does. Once 2+
    characters are typed, the list shows only items whose name, type or item ID
    contains the text; clearing it shows everything. It narrows the whole view
    under it: the category pane's counts answer to it as well as the item rows.

    SearchBoxTemplate draws the magnifying glass, the hint and the clear button
    itself, as the Spell Book's filter does; its hint is white, readable on the
    dark box ElvUI or the default art gives it. Built in the header bar, first
    of its controls (ns.CreateRestockHeader, below).
]]
local function ApplyFilter(text)
	ns.restockListFilter = text
	ns.UpdateRestockList()
end

local function CreateSearchFilterBox(bar)
	local box = CreateFrame("EditBox", nil, bar, "SearchBoxTemplate")
	box:SetSize(FILTER_BOX_WIDTH, EDIT_BOX_HEIGHT + 2)
	box:SetPoint("LEFT", bar, "LEFT", 0, 0)
	box:SetAutoFocus(false)
	local hint = box.Instructions
	if hint then
		hint:SetText(L["RESTOCKER_FILTER_PLACEHOLDER"])
		hint:SetTextColor(1, 1, 1)
	end
	box:HookScript("OnTextChanged", function(self)
		ApplyFilter(self:GetText() or "")
	end)
	return box
end

local function CreatePlainFilterBox(bar)
	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
	icon:SetPoint("LEFT", bar, "LEFT", 0, 0)
	icon:SetTexture(FILTER_ICON)

	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", icon, "RIGHT", ROW_ICON_GAP, 0)
	box:SetSize(FILTER_BOX_WIDTH, EDIT_BOX_HEIGHT)
	box:SetAutoFocus(false)
	-- Keep typed text off the clear button below; the placeholder never meets it.
	box:SetTextInsets(0, CLEAR_BUTTON_SIZE + CLEAR_BUTTON_INSET, 0, 0)

	--[[
	    Clearing the box fires OnTextChanged below, which is what empties the
	    filter and repaints the list -- so this handler only has to blank the
	    text, and the two paths out of a filter cannot drift apart.
	]]
	local clearButton = CreateFrame("Button", nil, box)
	clearButton:SetSize(CLEAR_BUTTON_SIZE, CLEAR_BUTTON_SIZE)
	clearButton:SetPoint("RIGHT", box, "RIGHT", -CLEAR_BUTTON_INSET, 0)
	clearButton:SetNormalTexture(CLEAR_ICON)
	clearButton:SetPushedTexture(CLEAR_ICON_DOWN)
	clearButton:SetHighlightTexture(CLEAR_ICON, "ADD")
	clearButton:Hide()
	ns.SetRestockControlClick(clearButton, function()
		box:SetText("")
		box:ClearFocus()
	end)
	ns.SetupRestockerTooltip(clearButton, L["RESTOCKER_FILTER_CLEAR_TOOLTIP"])

	-- Anchored on both sides with no wrap, so a hint longer than the field truncates inside it.
	local placeholder = box:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisableSmall")
	placeholder:SetPoint("LEFT", box, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", box, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_FILTER_PLACEHOLDER"])

	box:SetScript("OnTextChanged", function(self)
		local text = self:GetText() or ""
		placeholder:SetShown(text == "")
		clearButton:SetShown(text ~= "")
		ApplyFilter(text)
	end)
	box:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	return box
end

local function CreateFilterBox(addonFrame, bar)
	local box = ns.HasTemplate("SearchBoxTemplate") and CreateSearchFilterBox(bar) or CreatePlainFilterBox(bar)
	box:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	SetBoxTakesDrops(box)
	addonFrame.filterBox = box
	return box
end

--[[
    Pick Staples, the same staples window a fresh character is offered at login
    (Features/Inventory-Restocker/Restocker-Starter-Window.lua). Reachable from here as
    well so it is a tool the player can come back to rather than a one-off
    greeting they either caught or missed.

    It opens over this window, which stays open: each staple checked lands in
    the New group behind it, and closing it leaves the player where they were.
]]
local function CreateStaplesButton(header)
	local button = ns.CreateRestockerHeaderButton(header, L["RESTOCKER_PICK_STAPLES_BUTTON"])
	button:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_PICK_STAPLES_BUTTON"], L["RESTOCKER_PICK_STAPLES_TOOLTIP"])
	header.staplesButton = button
end

--[[
    The header bar, on the dark frame under the title like the Spell Book's
    controls row, with the filter at its left end and Pick Staples at its
    right. Returns the bar; the adders are placed in it afterwards
    (ns.CreateRestockAddButton and the two after it), chained off Pick Staples.

    Every control is a child of the bar, never of the window: a control
    anchored to the window lands at its middle and disappears behind the list.
]]
function ns.CreateRestockHeader(addonFrame)
	local bands = ns.RESTOCK_WINDOW_BANDS
	local top = ns.RESTOCK_HEADER_CENTER_Y + BAR_HEIGHT / 2
	local header = CreateFrame("Frame", nil, addonFrame)
	header:SetPoint("TOPLEFT", addonFrame, "TOPLEFT", bands.CONTROLS_LEFT + BAR_INSET_LEFT, top)
	header:SetPoint("TOPRIGHT", addonFrame, "TOPRIGHT", -BAR_INSET_RIGHT, top)
	header:SetHeight(BAR_HEIGHT)
	header.leading = CreateFilterBox(addonFrame, header)
	CreateStaplesButton(header)

	addonFrame.header = header
	return header
end

local function CreateAddButton(addonFrame, header)
	local addButton = ns.CreateRestockerHeaderButton(header, L["RESTOCKER_ADD_BUTTON"])
	addButton:SetPoint("RIGHT", header.staplesButton, "LEFT", -STAPLES_GAP, 0)
	addButton:SetWidth(math.max(ADD_BUTTON_WIDTH, addButton:GetWidth()))
	--[[
	    The add box is captured, never resolved through GetParent: this button is
	    parented to the header and the box is not its child, so walking the chain
	    is both fragile and exactly the trap the row controls warn about.
	]]
	ns.SetRestockControlClick(addButton, function()
		local editBox = addonFrame.editBox
		local text = editBox:GetText()

		ns.AddRestockItem(text)

		editBox:SetText("")
		editBox:ClearFocus()
	end)
	--[[
	    The same tooltip the edit box shows: the button and the box are two
	    halves of one control, and either is a fair place to hover.
	]]
	ns.SetupRestockerTooltip(addButton, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.addButton = addButton
	return addButton
end

ns.CreateRestockAddButton = CreateAddButton

--[[
    The add box's placeholder doubles as its notice line (see Add Notices
    below): these are the tone a notice takes, and the placeholder's own, read
    back from its font when the box is built.
]]
local NOTICE_TONE = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ADD_NOTICE)
local placeholderTone

local function CreateEditBox(addonFrame, header)
	local editBox = CreateFrame("EditBox", nil, header, "InputBoxTemplate")
	--[[
	    Left of the Add button, spaced as the header's buttons are: flush, the
	    box's border art meets the button's and the pair reads as a clash rather
	    than as one control.
	]]
	editBox:SetPoint("RIGHT", addonFrame.addButton, "LEFT", -STAPLES_GAP, 0)
	editBox:SetWidth(ADD_BOX_WIDTH)
	editBox:SetAutoFocus(false)
	editBox:SetHeight(EDIT_BOX_HEIGHT)
	--[[
	    A typed item ID, or an item dragged onto the box or anywhere else on
	    the window. Never a Shift + Click: every client routes it through
	    ChatFrameUtil.InsertLink, which an add-on cannot claim without
	    overwriting a Blizzard function.
	]]
	editBox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		ns.AddRestockItem(text)
		self:SetText("")
		self:ClearFocus()
	end)
	SetBoxTakesDrops(editBox)

	--[[
	    Greyed-out placeholder, shown only while the box is empty -- the same
	    arrangement as the filter box, both ends anchored and no wrap included.
	    This is the longest hint on the row and the one ADD_BOX_WIDTH is sized
	    to; with only a left anchor it overruns the field and draws under the
	    Add button.
	]]
	local placeholder = editBox:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisableSmall")
	placeholder:SetPoint("LEFT", editBox, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", editBox, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	addonFrame.addPlaceholder = placeholder
	-- The grey its font object draws in, kept for ns.ClearRestockAddNotice to put back.
	placeholderTone = { placeholder:GetTextColor() }
	editBox:SetScript("OnTextChanged", function(self)
		local isEmpty = (self:GetText() or "") == ""
		--[[
		    Typing again answers a notice, so it goes. Emptying the box does not:
		    both add paths clear the box right after the add that raised it.
		]]
		if not isEmpty then
			ns.ClearRestockAddNotice()
		end
		placeholder:SetShown(isEmpty)
	end)

	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.editBox = editBox
	return editBox
end

ns.CreateRestockAddBox = CreateEditBox

-- The Add Item From Bags menu (Restocker-Window-Bag-Menu.lua builds it), the chain's left end.
local function PlaceBagMenu(addonFrame, header)
	local bagMenu = ns.CreateRestockBagMenu(addonFrame, header)
	bagMenu:SetPoint("RIGHT", addonFrame.editBox, "LEFT", -CONTROL_ITEM_GAP, 0)
	bagMenu:SetSize(BAG_MENU_WIDTH, EDIT_BOX_HEIGHT)
	addonFrame.bagMenu = bagMenu
	return bagMenu
end

ns.PlaceRestockBagMenu = PlaceBagMenu

--------------------------------------------------------------------------------
-- Add Notices
--------------------------------------------------------------------------------

--[[
    An add that did not go through says why in the add box itself, in place of
    its placeholder: the box has just been emptied, it is where the player is
    looking, and a chat line is easy to miss behind the window. The notice stays
    until the player types again or the window closes.

    With the window shut there is no box to write in, so the same line goes to
    chat instead.
]]
local addNoticeShown = false

function ns.ShowRestockAddNotice(message)
	local window = ns.restockWindow
	if not (window and window:IsShown()) then
		ns:PrintMessage(message)
		return
	end
	addNoticeShown = true
	window.addPlaceholder:SetText(message)
	window.addPlaceholder:SetTextColor(NOTICE_TONE.r, NOTICE_TONE.g, NOTICE_TONE.b)
end

function ns.ClearRestockAddNotice()
	if not addNoticeShown then
		return
	end
	addNoticeShown = false
	local placeholder = ns.restockWindow.addPlaceholder
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	placeholder:SetTextColor(unpack(placeholderTone))
end
