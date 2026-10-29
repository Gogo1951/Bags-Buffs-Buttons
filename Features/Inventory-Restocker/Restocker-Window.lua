local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Window Geometry
--------------------------------------------------------------------------------

--[[
    Size and position both live in ns.db.global.restocker.framePosition. That is the
    account-wide half of the AceDB database, so one window layout follows the
    player across every character and no profile switch can move it.

    Both width numbers are set by the LIST, not the rows above and below it, and
    they are the sum of two things that each have their own floor:

      the category pane   its widest ALLOWED width (180) plus the gap (8)
      the table           591, which holds the item name at its readable floor
      window chrome       the inset (2 + 4), its padding (8), the scroll bar (26)

    which is where MIN_WIDTH comes from. (The name has 14 pixels over that floor,
    which stays where players' saved sizes already respect it.) The pane sizes itself to the longest type
    name it actually has to draw (see ns.ResolveRestockGroupPaneWidth) and is capped so this
    number stays honest: MIN_WIDTH is set against the CAP rather than the usual
    width, so the item name keeps its floor even on a client whose type names run
    long. Raising that cap means raising this. The header's own floor (the
    portrait's clearance, the filter, the selector and the two buttons, with the
    "Used by" line between them free to truncate) sits under it by about 60
    pixels in English, which is the room longer button captions have.

    DEFAULT_WIDTH is a step above the floor so a fresh window opens with room for
    a long consumable name rather than at the edge of truncation. MAX_* is a
    sanity ceiling for a corrupt saved value, not a real limit.

    Both height numbers include the title and the header above the list.
]]
local DEFAULT_WIDTH = 870
local DEFAULT_HEIGHT = 440
local MIN_WIDTH = 819
local MIN_HEIGHT = 300
local MAX_WIDTH = 1600
local MAX_HEIGHT = 1200

local function Clamp(value, minimum, maximum, fallback)
	value = tonumber(value)
	if not value then
		return fallback
	end
	return math.max(minimum, math.min(maximum, value))
end

-- Written whole: AceDB can clear an empty framePosition at logout before this runs.
function ns.SaveRestockWindowGeometry()
	local frame = ns.restockWindow
	if not frame then
		return
	end
	local point, _, relativePoint, xOffset, yOffset = frame:GetPoint(frame:GetNumPoints())
	ns.restockSettings.framePosition = {
		point = point,
		relativePoint = relativePoint,
		xOffset = xOffset,
		yOffset = yOffset,
		width = math.floor(frame:GetWidth() + 0.5),
		height = math.floor(frame:GetHeight() + 0.5),
	}
end

--[[
    Forward-declared: CreateAddonFrame's OnSizeChanged closure names it, and a
    local that is not yet in scope on that line compiles as a nil global instead.
]]
local RelayoutFrame

local function CreateAddonFrame()
	local settings = ns.restockSettings
	local addonFrame = ns.CreateRestockerPortraitFrame("BagsBuffsButtonsRestockFrame", L["RESTOCKER_WINDOW_TITLE"])
	addonFrame.width = Clamp(settings.framePosition.width, MIN_WIDTH, MAX_WIDTH, DEFAULT_WIDTH)
	addonFrame.height = Clamp(settings.framePosition.height, MIN_HEIGHT, MAX_HEIGHT, DEFAULT_HEIGHT)
	addonFrame:SetSize(addonFrame.width, addonFrame.height)
	addonFrame:SetPoint(
		settings.framePosition.point or "RIGHT",
		UIParent,
		settings.framePosition.relativePoint or "RIGHT",
		settings.framePosition.xOffset or -5,
		settings.framePosition.yOffset or 0
	)
	addonFrame:SetFrameStrata("HIGH")
	-- A saved position from another resolution or UI scale must not open off-screen.
	addonFrame:SetClampedToScreen(true)
	addonFrame:SetMovable(true)
	addonFrame:SetResizable(true)
	addonFrame:EnableMouse(true)
	addonFrame:RegisterForDrag("LeftButton")
	addonFrame:SetScript("OnDragStart", addonFrame.StartMoving)
	addonFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ns.SaveRestockWindowGeometry()
	end)

	addonFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)

	--[[
	    Children are anchored to two corners rather than given a size, so the whole
	    layout follows the window on its own. Only the scroll child and the pooled
	    rows need telling -- a scroll child is sized, not anchored -- which is what
	    RelayoutFrame does.
	]]
	addonFrame:SetScript("OnSizeChanged", function(self)
		RelayoutFrame(self)
	end)

	--[[
	    Redrawn on the way in, whichever route opened it (the slash command, the
	    mini-map button, a bank or merchant visit): the yellow Keep marks and the
	    orders under the list are read from the bags, which nothing repaints while
	    the window is hidden.
	]]
	addonFrame:SetScript("OnShow", function()
		ns.UpdateRestockList()
	end)

	--[[
	    The "New" group lasts exactly as long as the window is open, and an open
	    menu is parented to UIParent rather than to the window, so it would outlive
	    it. Hooked on OnHide rather than in ns.HideRestockWindow because the frame
	    also closes by routes that never reach it -- the title bar's X, and Escape
	    via UISpecialFrames.
	]]
	addonFrame:SetScript("OnHide", function()
		ns.CloseRestockMenus()
		ns.EndRestockListRename()
		ns.ClearRestockAddNotice()
		ns.ClearRestockNewItems()
		ns.ClearRestockGroupSelection()
		ns.restockWindowOpenedByVisit = false
		if next(ns.restockColdRows) ~= nil then
			wipe(ns.restockColdRows)
			ns.SyncRestockItemInfoSubscription()
		end
	end)

	--[[
	    An item dropped on any bare part of the window joins the list, so the add
	    box is one target rather than the only one. Every control takes the mouse
	    before the window does, and each makes this same call: the rows' own
	    (Restocker-Window-Rows.lua), and the rest through ns.SetRestockControlClick
	    (Restocker-Window-Widgets.lua).
	]]
	local function TakeCursorItem()
		ns.AddRestockItemFromCursor()
	end
	addonFrame:SetScript("OnMouseUp", TakeCursorItem)
	addonFrame:SetScript("OnReceiveDrag", TakeCursorItem)
	return addonFrame
end

--[[
    Push the current window size down into the parts that cannot follow it by
    anchoring alone. Cheap enough to run on every frame of a resize drag: it
    sets widths and never rebuilds the list.
]]
function RelayoutFrame(addonFrame)
	local scrollChild = addonFrame.scrollChild
	if not scrollChild then
		return -- still being built; ns.CreateRestockWindow lays out once at the end
	end

	addonFrame.width = addonFrame:GetWidth()
	addonFrame.height = addonFrame:GetHeight()
	addonFrame.listInset.width = addonFrame.listInset:GetWidth()
	addonFrame.listInset.height = addonFrame.listInset:GetHeight()

	--[[
	    Only the table's rows follow the window: the category pane is a fixed width
	    (see WINDOW GEOMETRY), so nothing in it needs resizing on a drag.
	]]
	local rowWidth = addonFrame.scrollFrame:GetWidth()
	scrollChild:SetWidth(rowWidth)
	for _, row in ipairs(ns.restockRowPool) do
		row:SetWidth(rowWidth)
	end
end

--[[
    The corner grip that resizes the window. A child button, so it takes the
    mouse before the frame-wide drag-to-move handler sees it.
]]
local function CreateResizeGrip(addonFrame)
	local grip = CreateFrame("Button", nil, addonFrame)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -4, 4)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetScript("OnMouseDown", function()
		addonFrame:StartSizing("BOTTOMRIGHT")
	end)
	grip:SetScript("OnMouseUp", function()
		addonFrame:StopMovingOrSizing()
		RelayoutFrame(addonFrame)
		ns.SaveRestockWindowGeometry()
	end)
	addonFrame.resizeGrip = grip
	return grip
end

-- Two corners instead of a size (ns.CreateRestockerBodyInset): the inset then tracks the window by itself.
local function CreateListInset(addonFrame)
	local listInset = ns.CreateRestockerBodyInset(addonFrame)
	listInset.width = listInset:GetWidth()
	listInset.height = listInset:GetHeight()
	addonFrame.listInset = listInset
	return listInset
end

-- Clear space between the inset's top edge and the list's column headings.
local LIST_TOP_GAP = 10
local LIST_BOTTOM_MARGIN = 8 -- nothing else shares the list's inset

--[[
    How far below the inset's top edge the list area starts, and with it the
    empty list's invitation, which takes that whole area over.
]]
local function ListAreaTop()
	return LIST_TOP_GAP
end

--[[
    How far below the inset's top edge both panes start: the top of the list
    area, then the column header's own height. Shared so the category rows and
    the item rows sit on the same baseline.
]]
local function ListTopInset()
	return ListAreaTop() + ns.restockColumnHeaderHeight + 4
end

--[[
    How far above the inset's bottom edge both panes stop. Everything the player
    types into sits in the header, so this is a plain margin rather than a
    reserved band. Read by the category pane too
    (Restocker-Window-Categories.lua), so the two halves end on the same line.
]]
ns.RESTOCK_LIST_BOTTOM_INSET = LIST_BOTTOM_MARGIN

local function CreateScrollFrame(addonFrame, listInset)
	local scrollFrame = CreateFrame("ScrollFrame", nil, addonFrame, "UIPanelScrollFrameTemplate")
	--[[
	    The category pane owns the left of the inset, so the table starts past it.
	    26 on the right for the scroll bar, and the plain bottom margin
	    (ns.RESTOCK_LIST_BOTTOM_INSET). The column header is anchored to this
	    frame's top corners rather than measured against the inset, so it
	    inherits the same right edge the rows lay out from.
	]]
	local left = 8 + ns.restockGroupPaneWidth + ns.RESTOCK_GROUP_PANE_GAP
	scrollFrame:SetPoint("TOPLEFT", listInset, "TOPLEFT", left, -ListTopInset())
	scrollFrame:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -26, ns.RESTOCK_LIST_BOTTOM_INSET)
	scrollFrame.width = scrollFrame:GetWidth()
	scrollFrame.height = scrollFrame:GetHeight()
	addonFrame.scrollFrame = scrollFrame
	return scrollFrame
end

local function CreateScrollChild(scrollFrame, addonFrame)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild.width = scrollFrame:GetWidth()
	scrollChild.height = scrollFrame:GetHeight()
	scrollChild:SetWidth(scrollChild.width)
	scrollChild:SetHeight(scrollChild.height - 10)
	addonFrame.scrollChild = scrollChild

	scrollFrame:SetScrollChild(scrollChild)
	return scrollChild
end

--------------------------------------------------------------------------------
-- Empty List
--------------------------------------------------------------------------------

--[[
    What an empty list shows in place of the grid: a short body and one button.
    A bare header over no rows, with "All Items 0" beside it, reads as a window
    that failed to load; this says the list is empty and what to do about it.

    The block is centred on the list area as a stack hung from its title, so a
    body that wraps to another line in another locale pushes the button down
    rather than running under it. The body is capped in width for the same
    reason a paragraph is: a sentence spanning the whole window is hard to read.
    In English it wraps to three lines, which is what the title's offset
    centres the stack for.

    It takes no mouse, so an item dropped on it falls through to the window's
    own drop handler like a drop on any other bare part of the window.
]]
local EMPTY_BODY_WIDTH = 440
local EMPTY_TITLE_OFFSET = 48 -- the title's foot above the area's centre, which centres the stack
local EMPTY_GAP = 10
local EMPTY_BUTTON_WIDTH = 140
local EMPTY_BUTTON_HEIGHT = 28

local function CreateEmptyState(addonFrame, listInset)
	local panel = CreateFrame("Frame", nil, addonFrame)
	panel:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -ListAreaTop())
	panel:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -8, ns.RESTOCK_LIST_BOTTOM_INSET)
	panel:Hide()

	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("BOTTOM", panel, "CENTER", 0, EMPTY_TITLE_OFFSET)
	title:SetText(L["RESTOCKER_EMPTY_TITLE"])

	local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	body:SetPoint("TOP", title, "BOTTOM", 0, -EMPTY_GAP)
	body:SetWidth(EMPTY_BODY_WIDTH)
	body:SetJustifyH("CENTER")
	body:SetText(L["RESTOCKER_EMPTY_BODY"])

	local button = ns.CreateRestockerHeaderButton(panel, L["RESTOCKER_PICK_STAPLES_BUTTON"])
	button:SetPoint("TOP", body, "BOTTOM", 0, -EMPTY_GAP - 4)
	-- The screen's one action, so it stays larger than the header's buttons.
	button:SetSize(math.max(EMPTY_BUTTON_WIDTH, button:GetWidth()), EMPTY_BUTTON_HEIGHT)
	panel.button = button
	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)

	local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOP", button, "BOTTOM", 0, -EMPTY_GAP)
	hint:SetText(L["RESTOCKER_EMPTY_DROP_HINT"])

	addonFrame.emptyState = panel
	return panel
end

--[[
    The one line a list with items shows when none of them is drawn: the filter
    matches nothing, or the selected category just lost its last item. On the
    scroll frame, so it sits where the first row would.
]]
local function CreateNothingShownText(addonFrame)
	local text = addonFrame.scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	text:SetPoint("TOP", addonFrame.scrollFrame, "TOP", 0, -16)
	text:Hide()
	addonFrame.nothingShownText = text
	return text
end

--[[
    Swap the grid for the empty list's invitation and back, and set the
    nothing-shown line. Called by ns.UpdateRestockList at the end of every
    redraw, with what it just found: whether the list holds anything at all,
    and the line to show when it does but no row was drawn (nil otherwise).

    The column header and the category pane are siblings of the scroll frame
    rather than children of it, so each is switched by name.
]]
function ns.UpdateRestockEmptyState(listIsEmpty, nothingShown)
	local window = ns.restockWindow
	window.emptyState:SetShown(listIsEmpty)
	window.scrollFrame:SetShown(not listIsEmpty)
	ns.restockColumnHeader:SetShown(not listIsEmpty)
	ns.restockGroupPane:SetShown(not listIsEmpty)

	window.nothingShownText:SetShown(nothingShown ~= nil)
	if nothingShown then
		window.nothingShownText:SetText(nothingShown)
	end
end

--[[
    Escape closes the window through UISpecialFrames. The staples pop-up takes
    the window off that list while it is open: both are on it, and one press
    of Escape closes every window on the list, so it would otherwise close both.
]]
function ns.SetRestockWindowClosesOnEscape(closes)
	for index = #UISpecialFrames, 1, -1 do
		if UISpecialFrames[index] == "BagsBuffsButtonsRestockFrame" then
			table.remove(UISpecialFrames, index)
		end
	end
	if closes then
		table.insert(UISpecialFrames, "BagsBuffsButtonsRestockFrame")
	end
end

function ns.CreateRestockWindow()
	-- Row and button heights come from the font, so measure before anything is built.
	ns.RefreshRestockRowMetrics()
	-- The table's left edge is anchored past the category pane, so size it first.
	ns.ResolveRestockGroupPaneWidth()

	local addonFrame = CreateAddonFrame()
	local listInset = CreateListInset(addonFrame)
	local scrollFrame = CreateScrollFrame(addonFrame, listInset)
	CreateScrollChild(scrollFrame, addonFrame)
	ns.CreateRestockColumnHeader(addonFrame, scrollFrame)
	ns.CreateRestockGroupPane(addonFrame, listInset, ListTopInset())
	CreateEmptyState(addonFrame, listInset)
	CreateNothingShownText(addonFrame)
	-- The header bar with the filter and Pick Staples in it (Restocker-Window-Header.lua).
	local header = ns.CreateRestockHeader(addonFrame)
	addonFrame.staplesButton = header.staplesButton

	-- Order matters, and the adders chain right to left: Add off Pick Staples, the add box off Add, the bag menu off the box.
	ns.CreateRestockAddButton(addonFrame, header)
	ns.CreateRestockAddBox(addonFrame, header)
	ns.PlaceRestockBagMenu(addonFrame, header)
	-- The footer's list controls (Restocker-Window-List-Bar.lua).
	local bar = ns.CreateRestockListBar(addonFrame)
	--[[
	    Settings live in the add-on's options panel (the mini-map tooltip, /bbb);
	    the frame deliberately has no Settings button.
	]]
	ns.CreateRestockWindowFooter(addonFrame)
	CreateResizeGrip(addonFrame)
	ns.ApplyRestockerElvUISkin({
		addonFrame.filterBox,
		bar.selector,
		bar.renameBox,
		addonFrame.bagMenu,
		addonFrame.editBox,
	}, {
		bar.manageButton,
		header.staplesButton,
		bar.renameButton,
		bar.cancelButton,
		addonFrame.addButton,
		addonFrame.undo,
		addonFrame.emptyState.button,
	})

	ns.SetRestockWindowClosesOnEscape(true)
	addonFrame:Hide()

	ns.restockWindow = addonFrame
	-- Now that scrollChild exists, settle the sizes the anchors could not carry.
	RelayoutFrame(addonFrame)
	return ns.restockWindow
end

--[[
    The player's ways to open the window end here or in ns.ToggleRestockWindow,
    so both answer the master switch. Restocker-Saved-Lists.lua shows it
    directly after adding or copying a list, which only a switched-on
    Restocker can reach.
]]
local function RestockerSwitchedOff()
	if ns.IsRestockerEnabled() then
		return false
	end
	ns:PrintMessage(L["RESTOCKER_DISABLED"])
	return true
end

function ns.ShowRestockWindow()
	if RestockerSwitchedOff() then
		return
	end
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		-- Opening redraws by itself (OnShow); a window already open is redrawn here.
		if menu:IsShown() then
			return ns.UpdateRestockList()
		end
		menu:Show()
	end
end

function ns.HideRestockWindow()
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		return menu:Hide()
	end
end

--[[
    A merchant or bank visit closes the window only when that visit opened it:
    a window the player opened stays open, and a loading screen, which fires the
    _CLOSED events with nothing open, never closes it. OnHide clears the flag.
]]
ns.restockWindowOpenedByVisit = false

function ns.ShowRestockWindowForVisit()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		return
	end
	ns.ShowRestockWindow()
	ns.restockWindowOpenedByVisit = ns.restockWindow ~= nil and ns.restockWindow:IsShown()
end

function ns.HideRestockWindowAfterVisit()
	if ns.restockWindowOpenedByVisit then
		ns.HideRestockWindow()
	end
end

function ns.ToggleRestockWindow()
	if RestockerSwitchedOff() then
		return false
	end
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		return menu:SetShown(not menu:IsShown()) or false
	end
end
