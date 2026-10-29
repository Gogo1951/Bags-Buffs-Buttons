local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- List Bar
--------------------------------------------------------------------------------

--[[
    Header:  [filter] ...... [Add Item From Bags v]  [add box....] [Add] [Pick Staples]
    Footer:  List [selector....v] [Manage Lists] Used by Mossbark, Thornhoof ...   (the orders, at the right)

      Restocker-Window-Header.lua   the whole header: the bar, the filter, the
                                    bag menu's place, the add box, Add, and
                                    Pick Staples (the bag menu itself is
                                    Restocker-Window-Bag-Menu.lua's)
      this file                     the footer's list controls: the label, the
                                    selector, Manage Lists, "Used by", and the
                                    rename field with its two buttons
      Restocker-Window-Footer.lua   the orders at the footer's right, and the
                                    undo offer

    The window's list management lives along the bottom-left of its footer:
    which Restock List this character is on, the button that acts on a whole
    list, and who else is on it.

    "Used by" is the line that makes a shared list visible. Lists are shared on
    purpose (one Druid list for every Druid), and sharing is silent everywhere
    else: nothing on a row says an edit here lands on another character too.
    It takes whatever the footer has left between Manage Lists and the orders
    at its right, and truncates first.

    New, Copy, Rename and Delete sit behind one Manage Lists button rather than
    out as four. They are rare, they act on the whole list, and Delete in
    particular should not be one stray click from the controls used every
    visit.

    The list selector is an InputBoxTemplate field, not an AceGUI Dropdown.
    Every other control in this window is a Blizzard template, so the one
    AceGUI widget read as foreign -- and skins that restyle AceGUI globally
    (ElvUI ships one) restyle it and nothing around it, which made the mismatch
    worse and moved the geometry its neighbours were positioned against.

    It opens an AceGUI Dropdown-Pullout on click, the same way the reputation
    column's menu in Restocker-Window-Menus.lua does: Blizzard's UIDropDownMenu drives
    shared global frames its own secure code uses and leaves taint behind, so
    the pullout stays. Manage Lists opens one the same way.
]]
local BAR_HEIGHT = ns.RESTOCK_BAR_HEIGHT -- the header's, so the two bars match (Restocker-Window-Header.lua)
local BAR_INSET_RIGHT = ns.RESTOCK_BAR_INSET_RIGHT
local FOOTER_X = 12 -- the footer's own left inset, as the Spell Book's legend sits
local LIST_SELECTOR_WIDTH = 190 -- holds a full Name-Realm, which an old list can be named
local SELECTOR_ARROW_SIZE = 18
local BAR_ITEM_GAP = 12
local BUTTON_GAP = 4
local LIST_MENU_WIDTH = 300 -- a list's name with its characters beside it
local MANAGE_MENU_WIDTH = 280 -- holds "Copy This List into a New One" whole

--------------------------------------------------------------------------------
-- Used By
--------------------------------------------------------------------------------

--[[
    A list's characters as one run of text, each name in its class color, or
    nil when no character is on it. A character is its class color wherever the
    add-on names one (the Inventory Report does the same), which is what lets a
    list's line be read at a glance.

    plain is the color the run sits in. It draws the separators, and any name
    whose class the add-on has not recorded yet (ns.GetRestockListUsers), so
    each caller says what an uncolored name looks like beside its own text.
]]
local function JoinUsers(users, plain)
	if #users == 0 then
		return nil
	end
	local names = {}
	for index, user in ipairs(users) do
		names[index] = (ns.GetClassColor(user.class) or plain) .. user.name .. "|r"
	end
	return table.concat(names, plain .. L["LIST_SEPARATOR"] .. "|r")
end

--[[
    The bar's "Used by" line for the list in use. Never empty: the window only
    shows the list this character is on, so the character is always among them.
]]
local function UsedByText(listName)
	local names = JoinUsers(ns.GetRestockListUsers(listName), GetColor("TEXT"))
	-- Muted is opened again behind the names, for whatever a locale's wording puts after them.
	return GetColor("MUTED") .. string.format(L["RESTOCKER_USED_BY"], names .. GetColor("MUTED")) .. "|r"
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

--[[
    Two pullouts, each built on first use and reused, which is how AceGUI's own
    Dropdown treats its pullout. Creating and releasing one per open would leak
    here: an Execute item closes its own pullout from inside its OnClick, so a
    release driven off OnClose would free the very item whose handler is still
    running. Reuse sidesteps that entirely -- items are cleared at open, not at
    close.

    Both live as long as the window, which is built once per session and only
    ever hidden.
]]
local listPullout
local listPulloutOpen = false
local managePullout
local managePulloutOpen = false

local function CloseListMenus()
	if listPullout and listPulloutOpen then
		listPulloutOpen = false
		listPullout:Close()
	end
	if managePullout and managePulloutOpen then
		managePulloutOpen = false
		managePullout:Close()
	end
end

ns.CloseRestockListMenus = CloseListMenus

--[[
    The selector's menu: every saved list with the characters on it, then a
    rule, then New List.

    Rebuilt on every open rather than cached, so a rename or a delete needs
    nothing kept in sync -- the next open reads the lists as they now are.

    The characters ride beside each name because they are what a list's name
    leaves out: "Druid" and "Druid (2)" say nothing about whose each one is,
    and switching onto a list another character uses means editing theirs.
    Each is in its class color, and muted until its class is known, so a name
    never reads as part of the list's own, which is white.
]]
local function OpenListPullout(anchor)
	local settings = ns.restockSettings

	if not listPullout then
		listPullout = AceGUI:Create("Dropdown-Pullout")
		listPullout:SetCallback("OnClose", function()
			listPulloutOpen = false
		end)
	end
	listPullout:Clear()

	-- In the shared A-to-Z order, whose first entry is also where a delete lands (ns.GetRestockListAfterDelete).
	for _, name in ipairs(ns.GetRestockListNames()) do
		local entry = AceGUI:Create("Dropdown-Item-Toggle")
		local users = JoinUsers(ns.GetRestockListUsers(name), GetColor("MUTED"))
		entry:SetText(users and (name .. "  " .. users) or name)
		entry:SetValue(name == settings.currentList)
		entry:SetCallback("OnValueChanged", function()
			-- A toggle item does not close its own pullout, unlike an execute item.
			CloseListMenus()
			-- The list already in use only closes the menu: a switch would clear New and rerun the restock.
			if name ~= ns.restockSettings.currentList then
				ns.SwitchRestockList(name)
			end
		end)
		listPullout:AddItem(entry)
	end

	--[[
	    A rule between the lists and the action under them. Inert by construction:
	    AceGUI's ItemBase gives every item only OnEnter and OnLeave, and Separator
	    is the one item type that never adds an OnClick, so the line cannot be
	    picked and needs no handler of its own.
	]]
	listPullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))

	--[[
	    New List is an Execute, not a Toggle: it performs an action rather than
	    selecting a value, so it draws no tick beside it and closes the menu itself.
	]]
	local newList = AceGUI:Create("Dropdown-Item-Execute")
	newList:SetText(L["RESTOCKER_NEW_PROFILE"])
	newList:SetCallback("OnClick", function()
		ns.CreateRestockList()
	end)
	listPullout:AddItem(newList)

	listPulloutOpen = true
	listPullout:SetWidth(LIST_MENU_WIDTH)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	-- Opening upward: the selector sits in the footer, so a menu below it would leave the window.
	listPullout:Open("BOTTOMLEFT", anchor, "TOPLEFT", 0, 0)
end

-- The selector and its arrow open the menu, and close it again when it is already open.
local function ToggleListPullout(anchor)
	if listPulloutOpen then
		CloseListMenus()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()
	OpenListPullout(anchor)
end

--------------------------------------------------------------------------------
-- Delete
--------------------------------------------------------------------------------

--[[
    Confirmation for the Manage Lists menu's Delete. The whole message is composed at show
    time and handed in as text_arg1, because how much it has to say depends on
    the list: who else is on it, and the list this character lands on
    afterwards. StaticPopup_Show's fourth argument carries the list's name
    through as the dialog's data, and OnAccept deletes THAT name rather than
    re-reading currentList.

    Load-bearing: the dialog does not lock the window behind it, so a list
    switched in the selector while the confirm is open would otherwise redirect
    the delete onto a list the player was never asked about -- and a Restock
    List has no undo. ns.DeleteRestockList ignores a nil or already-deleted
    name, and moves the character only when the list deleted is the one in use.
]]
StaticPopupDialogs["BAGSBUFFSBUTTONS_RESTOCKER_DELETE_LIST"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(_self, data)
		ns.DeleteRestockList(data)
		ns.UpdateRestockList()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

--[[
    What the confirm says, a paragraph to a fact: the question, the list's name
    in gold, what happens next, and that it is final.

    "What happens next" must be said before the player agrees. Every other
    character pointed at the list starts its next login on an empty list of the
    same name (ns.InitializeCharacterRestockList recreates a missing one), so they are
    named here while the player can still say no. This character's own landing
    place is named with them: the top list, which may be one another character
    uses and so is worth seeing before agreeing, or -- when this is the last
    list -- a new, empty one.
]]
local function DeleteConfirmText(listName)
	local consequences = {}
	local others = ns.GetRestockListUsers(listName, true)
	if #others > 0 then
		local key = (#others == 1) and "RESTOCKER_DELETE_LIST_SHARED_ONE" or "RESTOCKER_DELETE_LIST_SHARED_MANY"
		consequences[#consequences + 1] = string.format(L[key], JoinUsers(others, GetColor("TEXT")))
	end
	local landing = ns.GetRestockListAfterDelete(listName)
	if landing then
		consequences[#consequences + 1] =
			string.format(L["RESTOCKER_DELETE_LIST_SWITCH"], GetColor("TITLE") .. landing .. "|r")
	else
		consequences[#consequences + 1] = L["RESTOCKER_DELETE_LIST_LAST"]
	end

	return table.concat({
		L["RESTOCKER_DELETE_LIST_QUESTION"],
		GetColor("TITLE") .. listName .. "|r",
		table.concat(consequences, " "),
		L["RESTOCKER_DELETE_LIST_FINAL"],
	}, "|n|n")
end

local function ConfirmDeleteCurrentList()
	local listName = ns.restockSettings.currentList
	if not listName then
		return
	end
	StaticPopup_Show("BAGSBUFFSBUTTONS_RESTOCKER_DELETE_LIST", DeleteConfirmText(listName), nil, listName)
end

--------------------------------------------------------------------------------
-- Manage Lists Menu
--------------------------------------------------------------------------------

--[[
    Every entry is an Execute: each performs an action and closes the menu.
    Delete sits under a rule of its own, the way a destructive entry does in
    the game's own menus.
]]
local MANAGE_ENTRIES = {
	{
		label = "RESTOCKER_NEW_PROFILE",
		run = function()
			ns.CreateRestockList()
		end,
	},
	{
		label = "RESTOCKER_MANAGE_COPY",
		run = function()
			ns.CloneCurrentRestockList()
		end,
	},
	{
		label = "RESTOCKER_RENAME_PROFILE",
		run = function()
			ns.BeginRestockListRename()
		end,
	},
	{ isRule = true },
	{ label = "RESTOCKER_MANAGE_DELETE", run = ConfirmDeleteCurrentList },
}

local function OpenManagePullout(anchor)
	if not managePullout then
		managePullout = AceGUI:Create("Dropdown-Pullout")
		managePullout:SetCallback("OnClose", function()
			managePulloutOpen = false
		end)
	end
	managePullout:Clear()

	for _, entry in ipairs(MANAGE_ENTRIES) do
		if entry.isRule then
			managePullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))
		else
			local item = AceGUI:Create("Dropdown-Item-Execute")
			item:SetText(L[entry.label])
			item:SetCallback("OnClick", entry.run)
			managePullout:AddItem(item)
		end
	end

	managePulloutOpen = true
	managePullout:SetWidth(MANAGE_MENU_WIDTH)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	-- Opening upward, as the list menu does from the footer.
	managePullout:Open("BOTTOMLEFT", anchor, "TOPLEFT", 0, 0)
end

local function ToggleManagePullout(anchor)
	if managePulloutOpen then
		CloseListMenus()
		return
	end
	ns.CloseRestockMenus()
	OpenManagePullout(anchor)
end

--------------------------------------------------------------------------------
-- Rename
--------------------------------------------------------------------------------

--[[
    Renaming swaps the selector for a field holding the list's name, selected
    and ready to type over, with Rename and Cancel beside it. The field exists
    only while a rename is under way, so text sitting in it can never be
    mistaken for the name the list actually has.

    Enter and the Rename button commit. Escape, Cancel and clicking away
    discard, and so does any list event, since ns.RefreshRestockListBar ends
    the rename before it repaints. A Button click does not pull keyboard focus
    off an EditBox, so pressing Rename does not trip the discard -- its OnClick
    reads what was typed.

    New List and Copy both land here: each makes a list under a generated name
    and opens the rename over it, so the real name is one line of typing away.
    They pass the list the character was on, and Escape or Cancel then takes
    the made list back off and returns there, so backing out of a new list
    leaves nothing behind. Clicking away only ends the rename and keeps the
    list under its generated name, the way it keeps a plain rename's old name.
]]
local isRenaming = false
local madeFromList

-- The rename field and its buttons take the selector's place and Manage Lists' room; "Used by" steps aside too.
local function SetRenameShown(bar, shown)
	bar.selector:SetShown(not shown)
	bar.manageButton:SetShown(not shown)
	bar.users:SetShown(not shown)
	bar.renameBox:SetShown(shown)
	bar.renameButton:SetShown(shown)
	bar.cancelButton:SetShown(shown)
end

local function EndRename()
	if not isRenaming then
		return
	end
	isRenaming = false
	madeFromList = nil
	SetRenameShown(ns.restockWindow.listBar, false)
end

ns.EndRestockListRename = EndRename

-- Escape and Cancel: a list New List or Copy just made goes again, and the character returns to its list.
local function CancelRename()
	local previousList = madeFromList
	EndRename()
	if previousList then
		ns.DiscardMadeRestockList(previousList)
	end
end

-- previousList is the list the character was on when New List or Copy made the current one; nil for a plain rename.
function ns.BeginRestockListRename(previousList)
	local bar = ns.restockWindow.listBar
	ns.CloseRestockMenus()
	isRenaming = true
	madeFromList = previousList
	SetRenameShown(bar, true)
	bar.renameBox:SetText(ns.restockSettings.currentList or "")
	bar.renameBox:SetFocus()
	bar.renameBox:HighlightText()
end

-- Every path through ns.RenameCurrentRestockList repaints the bar, which ends the rename.
local function CommitRename()
	ns.RenameCurrentRestockList(ns.restockWindow.listBar.renameBox:GetText())
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

--[[
    The closed selector: the window's menu field (ns.CreateRestockMenuField in
    Restocker-Window-Widgets.lua), showing the active list as its text.
]]
local function CreateListSelector(bar)
	local label = bar:CreateFontString(nil, "OVERLAY")
	label:SetPoint("LEFT", bar, "LEFT", 0, 0)
	label:SetFontObject("GameFontNormal")
	label:SetText(L["RESTOCKER_PROFILE_LABEL"])
	bar.label = label

	local selector = ns.CreateRestockMenuField(bar, SELECTOR_ARROW_SIZE, ToggleListPullout)
	selector:SetPoint("LEFT", label, "RIGHT", BAR_ITEM_GAP, 0)
	selector:SetWidth(LIST_SELECTOR_WIDTH)
	selector:SetHeight(20)

	ns.SetupRestockerTooltip(selector, L["RESTOCKER_PROFILE_LABEL"], L["RESTOCKER_PROFILE_TOOLTIP"])
	bar.selector = selector
end

-- Beside the selector, the list it acts on.
local function CreateManageButton(bar)
	local button = ns.CreateRestockerHeaderButton(bar, L["RESTOCKER_MANAGE"])
	button:SetPoint("LEFT", bar.selector, "RIGHT", BAR_ITEM_GAP, 0)
	ns.SetRestockControlClick(button, function(self)
		ToggleManagePullout(self)
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_MANAGE"], L["RESTOCKER_MANAGE_TOOLTIP"])
	bar.manageButton = button
end

--[[
    Anchored on both sides with no wrap, the way a row's item name is: the line
    takes the room between Manage Lists and the footer's orders, and a list
    with more characters than fit truncates instead of running under them.
    ns.SetRestockUsersLineEnd moves its right end as the orders change width.
]]
local function CreateUsersLine(bar)
	local users = bar:CreateFontString(nil, "OVERLAY")
	users:SetFontObject("GameFontHighlightSmall")
	users:SetJustifyH("LEFT")
	users:SetWordWrap(false)
	users:SetPoint("LEFT", bar.manageButton, "RIGHT", BAR_ITEM_GAP, 0)
	users:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	bar.users = users
end

-- Ends the "Used by" line short of edge, the leftmost thing on the footer's right; nil ends it at the footer's end.
function ns.SetRestockUsersLineEnd(edge)
	local bar = ns.restockWindow and ns.restockWindow.listBar
	if not bar then
		return
	end
	bar.users:ClearAllPoints()
	bar.users:SetPoint("LEFT", bar.manageButton, "RIGHT", BAR_ITEM_GAP, 0)
	if edge then
		bar.users:SetPoint("RIGHT", edge, "LEFT", -BAR_ITEM_GAP * 2, 0)
	else
		bar.users:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	end
end

-- The rename field and its two buttons, in the selector's place; hidden until a rename begins.
local function CreateRenameControls(bar)
	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", bar.label, "RIGHT", BAR_ITEM_GAP, 0)
	box:SetWidth(LIST_SELECTOR_WIDTH)
	box:SetHeight(20)
	box:SetAutoFocus(false)
	box:SetScript("OnEnterPressed", CommitRename)
	box:SetScript("OnEscapePressed", CancelRename)
	box:SetScript("OnEditFocusLost", EndRename)

	local renameButton = ns.CreateRestockerHeaderButton(bar, L["RESTOCKER_RENAME_LABEL"])
	renameButton:SetPoint("LEFT", box, "RIGHT", BUTTON_GAP + 4, 0)
	ns.SetRestockControlClick(renameButton, CommitRename)
	ns.SetupRestockerTooltip(renameButton, L["RESTOCKER_RENAME_LABEL"], L["RESTOCKER_RENAME_TOOLTIP"])

	local cancelButton = ns.CreateRestockerHeaderButton(bar, CANCEL)
	cancelButton:SetPoint("LEFT", renameButton, "RIGHT", BUTTON_GAP, 0)
	ns.SetRestockControlClick(cancelButton, CancelRename)

	bar.renameBox = box
	bar.renameButton = renameButton
	bar.cancelButton = cancelButton
end

--[[
    Show the active list and its characters, ending any rename in progress.
    Called whenever a list is added, renamed, copied, deleted or switched
    (ns.UpdateRestockListWidgets in Restocker-Saved-Lists.lua).
]]
function ns.RefreshRestockListBar()
	local bar = ns.restockWindow.listBar
	local listName = ns.restockSettings.currentList or ""
	EndRename()
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

--[[
    The footer's list controls in one call, so Restocker-Window.lua assembles
    the window from parts (the header is ns.CreateRestockHeader's, in
    Restocker-Window-Header.lua). Returns the bar, which is also
    addonFrame.listBar.

    Every control is a child of the bar, never of the window: a control
    anchored to the window lands at its middle and disappears behind the list.
]]
function ns.CreateRestockListBar(addonFrame)
	local bands = ns.RESTOCK_WINDOW_BANDS

	-- The footer's left run, centred in its band as the Spell Book's legend is.
	local bottom = bands.FRAME_BORDER + (bands.FOOTER_HEIGHT - BAR_HEIGHT) / 2
	local bar = CreateFrame("Frame", nil, addonFrame)
	bar:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, bottom)
	bar:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -BAR_INSET_RIGHT, bottom)
	bar:SetHeight(BAR_HEIGHT)
	CreateListSelector(bar)
	CreateManageButton(bar)
	CreateUsersLine(bar)
	CreateRenameControls(bar)
	SetRenameShown(bar, false)

	--[[
	    Painted by hand this once: ns.RefreshRestockListBar reads the bar back off
	    ns.restockWindow, which is not set until the whole window is assembled.
	]]
	local listName = ns.restockSettings.currentList or ""
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))

	addonFrame.listBar = bar
	return bar
end
