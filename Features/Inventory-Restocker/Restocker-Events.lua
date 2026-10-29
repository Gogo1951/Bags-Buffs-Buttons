local _, ns = ...

ns.restockerLoaded = false

--[[
    Handlers keyed by event name, read by the Restocker's dispatcher at the end
    of this file. Each takes the event's own arguments with no leading
    event-name. Filled by ns.InitializeRestockerEvents. GET_ITEM_INFO_RECEIVED
    is the one exception: the item cache's owner hands it on in a fixed order
    (Features/Macros-for-Consumables/Macros-for-Consumables-Core.lua).
]]
ns.restockerEventHandlers = {}

--[[
    A table from the first frame, so the options panel's guarded accessors index
    something rather than nil before login. ns.InitializeRestocker below replaces
    it with the real ns.db.global.restocker.
]]
ns.restockSettings = {}

--[[
    Called from the dispatcher's PLAYER_LOGIN branch below, after ns.db exists
    and before the Inventory Report, which reads the Restock Lists.
]]
function ns.InitializeRestocker()
	ns.restockerLoaded = false

	--[[
	    The subsystem's lists and settings live on ns.db.global.restocker: named
	    shopping lists keyed by itemID, shared by every character. Which list a
	    character uses is its own choice (listChoices on the same table), so a
	    Warrior and a Priest see separate lists. AceDB has already applied the
	    defaults from Data/Default-Settings.lua by this point, so nothing is
	    filled in by hand here.
	]]
	ns.restockSettings = ns.db.global.restocker
	-- MIGRATION (remove after 2026-11-25): the staples window's retired don't-show-again answers.
	ns.restockSettings.starterListDismissed = nil

	ns.restockRowPool = {}
	ns.restockCategoryRowPool = {} -- category pane rows
	ns.restockHiddenFrame = CreateFrame("Frame", nil, UIParent)
	ns.restockHiddenFrame:Hide()

	--[[
	    Unpack the one-line string entries into in-memory tables (and tolerate any tables
	    left by a crash or pasted in by hand).
	]]
	ns.InflateSavedRestockItems(ns.restockSettings)

	-- Select the list this character uses (creating one if it has chosen none)
	ns.InitializeCharacterRestockList()

	-- Drop leftover empty orphan lists (e.g. an old shared "default")
	ns.PruneEmptyOrphanRestockLists(ns.restockSettings)
	--[[
	    (Re-packing into the one-line form happens in ns.OnRestockerLogout, which calls
	    ns.DeflateRestockItemsForSave just before WoW writes the SavedVariables file.)
	]]

	ns.InitializeRestockerEvents()

	--[[
	    The two modules with real one-time setup, called by name so it stays
	    plain which two they are.
	]]
	ns.InitializeRestockBagDefinitions()
	ns.SetupCraftingRecipes()

	if not ns.restockWindow then
		ns.CreateRestockWindow()
	end

	ns.restockerLoaded = true
end

--------------------------------------------------------------------------------
-- Merchant And Bank Windows
--------------------------------------------------------------------------------

function ns.OnRestockerMerchantShow()
	ns.merchantIsOpen = true

	if IsShiftKeyDown() then
		ns.merchantBuyingSkipped = true
		return
	end

	ns.merchantBuyingSkipped = false
	ns.RestockFromMerchant() -- each item can be individually enabled to restock from merchant
end

--[[
    Leaving a merchant or a bank is the last moment you can still do something
    about a short list, so both report what is left on the way out. Silent when
    nothing is short -- a report with nothing in it is just noise.

    The short delay is for bag counts. Purchases and bank moves settle on
    BAG_UPDATE, which can land after the window closes; reading the shortfall on
    the same frame would count items you are already holding as missing.

    The client fires MERCHANT_CLOSED and BANKFRAME_CLOSED on loading-screen
    teardown (boat crossings included) with no matching open -- and can double-fire
    them -- so each close handler keys the reminder, and closing the Restock
    window, off its tracked open flag: a _CLOSED event alone does not mean a
    window was ever open. The Restock window then closes only if that visit
    opened it (ns.ShowRestockWindowForVisit).
]]
local SETTLE_DELAY = 0.3

local function RemindOnClose(enabled, mode)
	if not enabled then
		return
	end
	C_Timer.After(SETTLE_DELAY, function()
		local groceries = ns.BuildGroceryList()
		if #groceries == 0 then
			return
		end
		ns.PrintRestockShortfall(ns.RestockShortfallHeadline(#groceries), mode, groceries)
	end)
end

function ns.OnRestockerMerchantClose()
	local merchantWasOpen = ns.merchantIsOpen
	ns.merchantIsOpen = false
	ns.merchantBuyingSkipped = false
	ns.ResetMerchantRestockThrottle()
	if merchantWasOpen then
		ns.HideRestockWindowAfterVisit()
	end

	local settings = ns.restockSettings
	if settings and merchantWasOpen then
		RemindOnClose(settings.merchantReminder, settings.merchantReminderMode)
	end
end

--[[
    One bank visit: a Shift held as the bank opens skips its run for the whole
    visit, and the close reminder follows only a visit whose run started.
]]
local bankRestockSkipped = false
local bankRestockStarted = false

function ns.OnRestockerBankFrameOpened()
	ns.bankIsOpen = true
	bankRestockSkipped = IsShiftKeyDown()
	bankRestockStarted = false
	ns.OnRestockerBankOpen()
end

-- Also run while the bank is open, when the list in use or a Keep amount changes.
function ns.OnRestockerBankOpen()
	ns.LoadRestockBankBags()

	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]

	-- An empty list has nothing to move, so the run would only announce a restock that never happened.
	if bankRestockSkipped or list == nil or next(list) == nil then
		return
	end

	if settings.autoOpenAtBank then
		ns.ShowRestockWindowForVisit()
	end

	bankRestockStarted = true
	ns.RestartBankRestock()
end

function ns.OnRestockerBankClose()
	local bankWasOpen = ns.bankIsOpen
	local restockStarted = bankRestockStarted
	ns.bankIsOpen = false
	bankRestockSkipped = false
	bankRestockStarted = false
	ns.StopBankRestock()
	if bankWasOpen then
		ns.HideRestockWindowAfterVisit()
	end

	local settings = ns.restockSettings
	if settings and restockStarted then
		RemindOnClose(settings.bankReminder, settings.bankReminderMode)
	end
end

--------------------------------------------------------------------------------
-- Bags
--------------------------------------------------------------------------------

--[[
    The open window's yellow Keep marks and the orders counted under its list are
    read from the bags, so they follow the bags: a merchant or bank visit fills
    them with the window up, and the marks should clear as it does. A repaint of
    those two things only (ns.RefreshRestockShortfall), and nothing at all while
    the window is shut -- it redraws itself on the way back in.
]]
function ns.OnRestockerBagUpdate()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		ns.RefreshRestockShortfall()
	end
end

--------------------------------------------------------------------------------
-- Level, Logout And Errors
--------------------------------------------------------------------------------

--[[
    A ding is the usual thing that moves a staple onto its next tier. The new
    level is handed on rather than read back off the player: UnitLevel("player")
    still returns the PREVIOUS level during this event (see
    ns.UpgradeRestockList), so reading it here makes the ding a no-op.

    Classic Era's ladders top out at level 60, so a Classic character sees this a
    handful of times and then never again: each flavor folder holds only the tiers
    its own client sells.
]]
function ns.OnRestockerLevelUp(newLevel)
	ns.UpgradeRestockList(newLevel)
end

function ns.OnRestockerLogout()
	-- Position and size together, the same call the drag and resize handlers use.
	ns.SaveRestockWindowGeometry()

	--[[
	    Pack items into the compact one-line-per-item form for the SavedVariables
	    file. Must be last: every list entry is a string from here to the end of the
	    session, so nothing may read one as a table after this runs.
	]]
	ns.DeflateRestockItemsForSave()
end

--------------------------------------------------------------------------------
-- Entering The World
--------------------------------------------------------------------------------

-- The one PLAYER_ENTERING_WORLD handler: the arrival check, the Starter List pop-up and the upgrade catch-up.
function ns.OnRestockerEnteringWorld(isInitialLogin, isReloadingUi)
	ns.OnRestockerArrival(isInitialLogin, isReloadingUi)
	ns.OnStarterListEnteringWorld(isInitialLogin, isReloadingUi)

	--[[
	    Catch-up for a list that is behind the player's level. A ding is not the
	    only way that happens -- levels gained with the add-on disabled, a list
	    copied off a higher character, a ding that arrived while the list was
	    mid-load -- and without this, a single missed level-up would strand the
	    entry for good, since nothing else re-checks.

	    Safe here: ns.InflateSavedRestockItems has already turned the saved one-line entries back
	    into tables (it runs at PLAYER_LOGIN, ahead of this event), and the check
	    is silent and free once nothing is behind, so the zone-in case costs a walk
	    of the list. A cold item cache at login needs no special handling: the move
	    defers and rides GET_ITEM_INFO_RECEIVED like any other.
	]]
	ns.UpgradeRestockList()
end

--------------------------------------------------------------------------------
-- Master Switch
--------------------------------------------------------------------------------

function ns.IsRestockerEnabled()
	return ns.db ~= nil and ns.db.global.restockerEnabled
end

--[[
    Off stops every part of the Restocker. A visit in progress ends here
    rather than at its _CLOSED event, which the switched-off handlers no longer
    see, so no flag is left saying a merchant or bank is open.
]]
function ns.SetRestockerEnabled(value)
	ns.db.global.restockerEnabled = value
	if value then
		-- What a loading screen would have done while the switched-off handlers slept.
		ns.ArmRestockerReminders()
		ns.UpgradeRestockList()
		return
	end
	ns.CloseStarterListPopup()
	ns.StopBankRestock()
	ns.bankIsOpen = false
	bankRestockSkipped = false
	bankRestockStarted = false
	ns.merchantIsOpen = false
	ns.merchantBuyingSkipped = false
	ns.HideRestockWindow()
end

-- A handler that runs only while the Restocker is on.
local function WhileEnabled(handler)
	return function(...)
		if ns.IsRestockerEnabled() then
			return handler(...)
		end
	end
end

--[[
    This table holds ONE handler per event name, so anything else wanting an
    event already in it shares the existing entry rather than adding a second
    one. That is why the arrival check, the Starter List pop-up and the
    upgrade catch-up all hang off ns.OnRestockerEnteringWorld: each is called from
    inside that handler rather than registering a second one of its own.

    Every handler but one stops while the Restocker is off: the logout handler
    still packs the lists for the saved-variables file. Item answers reach the
    Restocker through Features/Item-Info.lua, not this table.
]]
function ns.InitializeRestockerEvents()
	ns.restockerEventHandlers = {
		MERCHANT_SHOW = WhileEnabled(ns.OnRestockerMerchantShow),
		MERCHANT_CLOSED = WhileEnabled(ns.OnRestockerMerchantClose),
		BANKFRAME_OPENED = WhileEnabled(ns.OnRestockerBankFrameOpened),
		BANKFRAME_CLOSED = WhileEnabled(ns.OnRestockerBankClose),
		BAG_UPDATE_DELAYED = WhileEnabled(ns.OnRestockerBagUpdate),
		PLAYER_LOGOUT = ns.OnRestockerLogout,
		PLAYER_UPDATE_RESTING = WhileEnabled(ns.OnRestockerUpdateResting),
		PLAYER_CONTROL_GAINED = WhileEnabled(ns.OnRestockerControlGained),
		PLAYER_LEVEL_UP = WhileEnabled(ns.OnRestockerLevelUp),
		PLAYER_ENTERING_WORLD = WhileEnabled(ns.OnRestockerEnteringWorld),
	}
	ns.SyncRestockItemInfoSubscription()
end

--------------------------------------------------------------------------------
-- Event Dispatch
--------------------------------------------------------------------------------

local MODULE = "Restocker"

-- Every event the Restocker and the Inventory Report handle, each subscribed for as long as the add-on runs.
local EVENTS = {
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"BANKFRAME_OPENED",
	"MERCHANT_CLOSED",
	"MERCHANT_SHOW",
	"PLAYER_CONTROL_GAINED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_LOGOUT",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_UPDATE_RESTING",
}

--[[
    The Restocker's dispatcher. Features/Core.lua hands it every event it
    subscribed to, after Core's own handling: by PLAYER_LOGIN the database
    exists. Nothing here touches a protected function -- a merchant or bank
    window cannot open in combat, and a logout mid-combat must still pack the
    Restock List and this character's bags for the saved-variables file -- so
    there is no combat guard.
]]
ns.RegisterEventModule(MODULE, function(event, ...)
	if event == "PLAYER_LOGIN" then
		ns.InitializeRestocker()
		--[[
		    After the Restocker, whose settings the report reads for a list
		    item's Keep amount. Tested for: the client reads a TOC's file list
		    only at startup, so a player who updates with the game running and
		    reloads gets this file without Inventory-Report-Recording.lua until the next
		    restart. The report just stays off until then.
		]]
		if ns.InitializeInventoryReport then
			ns.InitializeInventoryReport()
		end
		return
	end

	local handler = ns.restockerEventHandlers[event]
	if handler then
		handler(...)
	end

	-- The Inventory Report's recorders only read containers and write saved variables.
	local inventoryHandler = ns.inventoryEventHandlers and ns.inventoryEventHandlers[event]
	if inventoryHandler then
		inventoryHandler(...)
	end
end)

for _, event in ipairs(EVENTS) do
	ns.SetModuleEvent(MODULE, event, true)
end
