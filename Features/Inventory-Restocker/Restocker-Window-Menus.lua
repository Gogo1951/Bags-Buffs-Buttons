local _, ns = ...
local L = ns.L
local AceGUI = LibStub("AceGUI-3.0")

--[[
    The Restock List's two menus: the standings menu a row's reputation cell
    opens, and the menu a toggle column's heading opens to set that column on
    every row shown. The cells that open them are Restocker-Window-Rows.lua,
    the headings Restocker-Window-Columns.lua.
]]
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS
local ReputationMenuText = ns.RestockReputationMenuText
local COLUMN_STATE = ns.RESTOCK_COLUMN_STATE
local CELL_NOT_APPLICABLE = ns.RESTOCK_CELL_NOT_APPLICABLE

--------------------------------------------------------------------------------
-- Reputation Menu
--------------------------------------------------------------------------------

--[[
    The standings menu, built on AceGUI's own pullout rather than Blizzard's
    UIDropDownMenu. Blizzard's version drives shared global frames that its own
    secure code also uses, so an add-on running through them leaves taint behind;
    AceGUI's pullout owns its frames outright. It also raises itself to TOOLTIP
    strata, which keeps it in front of the window.

    A hand-created pullout closes only when we close it. The widget installs no
    OnHide script, and SetHideOnLeave writes a flag AceGUI-3.0 never reads, so
    every close path is one of ours: opening another menu, clicking the open
    menu's own cell again, picking a standing, the window hiding, and
    ns.UpdateRestockList.

    Update is the load-bearing one. Rows come from a pool, so any redraw can put a
    different item under an open menu -- and the menu has to be gone before that
    row is rebound, or a pick lands on an item the player never opened.

    The callback is pinned to the item the menu was opened for as a second guard,
    so a close that is ever missed writes nothing rather than writing to whatever
    row drifted underneath.
]]
local openReputationPullout = nil
local openReputationCell = nil

local function CloseReputationMenu()
	if not openReputationPullout then
		return
	end
	local pullout = openReputationPullout
	openReputationPullout = nil
	openReputationCell = nil
	pullout:Close()
	AceGUI:Release(pullout)
end

ns.CloseReputationMenu = CloseReputationMenu

local function OpenReputationMenu(cell, row)
	-- A click on the open menu's own cell closes it rather than reopening it.
	if openReputationPullout and openReputationCell == cell then
		CloseReputationMenu()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()

	local openedForItem = cell.item
	if not openedForItem then
		return
	end

	local pullout = AceGUI:Create("Dropdown-Pullout")
	openReputationPullout = pullout
	openReputationCell = cell

	local title = AceGUI:Create("Dropdown-Item-Header")
	title:SetText(L["RESTOCKER_REPUTATION_MENU_TITLE"])
	pullout:AddItem(title)

	for _, standing in ipairs(REPUTATION_STANDINGS) do
		local entry = AceGUI:Create("Dropdown-Item-Toggle")
		entry:SetText(ReputationMenuText(standing))
		entry:SetValue((openedForItem.reaction or 0) == standing.value)
		entry:SetCallback("OnValueChanged", function()
			if cell.item == openedForItem then
				-- Store nil for "Any" so nothing is persisted; otherwise the standing code.
				openedForItem.reaction = (standing.value > 0) and standing.value or nil
				ns.UpdateRestockListRow(row, openedForItem)
			end
			-- A toggle item does not close its own pullout, unlike an execute item.
			CloseReputationMenu()
		end)
		pullout:AddItem(entry)
	end

	pullout:SetCallback("OnClose", function()
		openReputationPullout = nil
		openReputationCell = nil
	end)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	pullout:Open("TOPLEFT", cell, "BOTTOMLEFT", 0, 0)
end

ns.OpenRestockReputationMenu = OpenReputationMenu

--------------------------------------------------------------------------------
-- Column Menus
--------------------------------------------------------------------------------

--[[
    Writing one flag outright, for the column menus, which set a whole column
    rather than flipping each row. Always an explicit boolean: the nil defaults
    COLUMN_STATE reads (Restocker-Window-Rows.lua) mean "unset", and a column
    the player just set is not unset.
]]
local COLUMN_SET = {
	withdraw = function(item, isOn)
		item.restockFromBank = isOn
	end,
	deposit = function(item, isOn)
		item.stashToBank = isOn
	end,
	buy = function(item, isOn)
		item.buyFromMerchant = isOn
	end,
	extra = function(item, isOn)
		item.buyExtra = isOn
	end,
	upgrade = function(item, isOn)
		item.upgrade = isOn
	end,
}

--[[
    A toggle column's heading opens this: switch the column on, or off, for every
    row shown. With a category picked or the filter typed in, that is "stop
    buying every quest item" in two clicks rather than one per row.

    Rows where the column cannot apply are left alone and left out of the count,
    so the number on the menu is the number of rows it will change the state of
    or confirm: an item with no upgrade ladder has nothing to switch, and Extra
    rides on Buy.

    An AceGUI pullout like the reputation menu's, for the same reason (no shared
    Blizzard dropdown frames, so no taint), and closed by the same events: a
    second click on its heading, a pick, the window hiding, and any redraw.

    ONE pullout, built on first use and cleared at each open, as the list menu
    does (Restocker-Window-List-Bar.lua) and for its reason: these entries are
    Execute items, which close their own pullout after their OnClick returns, so
    a pullout released by the redraw that OnClick causes would be freed with its
    own item's handler still running.
]]
local COLUMN_MENU_WIDTH = 200 -- holds the longer of the two lines, whatever the heading's width

local columnPullout
local columnPulloutAnchor = nil

local function CloseColumnMenu()
	if columnPullout and columnPulloutAnchor then
		columnPulloutAnchor = nil
		columnPullout:Close()
	end
end

ns.CloseRestockColumnMenu = CloseColumnMenu

-- How many of the rows shown this column can be set on.
local function CountSettableRows(key)
	local count = 0
	for _, item in ipairs(ns.GetRestockShownItems()) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			count = count + 1
		end
	end
	return count
end

--[[
    Set one column on every row shown. Each column writes only its own flag, and
    whether it applies is read from the row as it stands before the write: Extra
    applies only where Buy is already on.
]]
local function SetColumnOnShownRows(key, isOn)
	for _, item in ipairs(ns.GetRestockShownItems()) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			COLUMN_SET[key](item, isOn)
		end
	end
	ns.UpdateRestockList()
end

function ns.OpenRestockColumnMenu(column, anchor)
	-- A click on the open menu's own heading closes it rather than reopening it.
	if columnPulloutAnchor == anchor then
		CloseColumnMenu()
		return
	end
	ns.CloseRestockMenus()

	if not columnPullout then
		columnPullout = AceGUI:Create("Dropdown-Pullout")
		columnPullout:SetCallback("OnClose", function()
			columnPulloutAnchor = nil
		end)
	end
	columnPullout:Clear()

	local title = AceGUI:Create("Dropdown-Item-Header")
	title:SetText(L[column.title])
	columnPullout:AddItem(title)

	local count = CountSettableRows(column.key)
	local choices = {
		{ label = "RESTOCKER_BULK_ON", isOn = true },
		{ label = "RESTOCKER_BULK_OFF", isOn = false },
	}
	for _, choice in ipairs(choices) do
		local entry = AceGUI:Create("Dropdown-Item-Execute")
		entry:SetText(string.format(L[choice.label], count))
		entry:SetDisabled(count == 0)
		entry:SetCallback("OnClick", function()
			SetColumnOnShownRows(column.key, choice.isOn)
		end)
		columnPullout:AddItem(entry)
	end

	columnPulloutAnchor = anchor
	columnPullout:SetWidth(COLUMN_MENU_WIDTH)
	-- The control's own tooltip would sit over the menu it opened.
	GameTooltip:Hide()
	columnPullout:Open("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
end
