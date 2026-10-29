local _, ns = ...
local Refresh = ns.RefreshSpellbookPage
local UpdateMacroCount = ns.UpdateSpellbookMacroCount
local pages = ns.spellbookPages

--[[
	Redraws the Spell Book page, and rewrites its macros, as the game changes around it: spells learned, gear
	worn, spell data arriving, actions placed and macros made. Features/Spellbook/Spellbook-Page.lua builds the
	page, and lists every page built in ns.spellbookPages.
]]

--------------------------------------------------------------------------------
-- Refresh
--------------------------------------------------------------------------------

--[[
	Redraws whichever page is open, after a change made outside it (the options panel, a profile change).
	Returns whether a page was open.
]]
function ns:RefreshOpenPages()
	local refreshed = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			Refresh(page)
			refreshed = true
		end
	end
	return refreshed
end

--[[
	Brings the macros the add-on made in step with a change made outside the page, whether or not a page is
	open. In combat the rewrite waits for combat to end (ns.SyncAllMacros).
]]
function ns:RefreshMacros()
	if ns:RefreshOpenPages() then
		return
	end
	ns.CollectMacros()
	ns.SyncAllMacros()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
	A learned spell or the gear worn changes the page's list; redraw the open page, once per burst, since
	SPELLS_CHANGED fires several times in a row. With no page open, the list is dropped, so the targetRank
	macros rebuild it, new ranks and all, before their next rewrite; but a spell learned that takes over a
	replaced spell's macro (ns.HandOverDue) or that a grouped macro moves up to (ns.GroupSpellLearned)
	rebuilds and rewrites now, so that macro works straight away.
]]
local spellsPending = false

local function RefreshForSpells()
	spellsPending = false
	local groupChanged = ns.GroupSpellLearned()
	if not ns:RefreshOpenPages() then
		wipe(ns.macros)
		if ns.db and (groupChanged or ns.HandOverDue()) then
			ns:RefreshMacros()
		end
	end
end

function ns:OnSpellsChanged()
	if not spellsPending then
		spellsPending = true
		C_Timer.After(0, RefreshForSpells)
	end
end

--[[
	The gear worn changes the Use Items choices, and which ranged attack the Shoot macro casts, so rebuild and
	rewrite the macros, page open or not, once per burst: a gear set swap fires once per slot.
]]
local gearPending = false

function ns:OnPlayerEquipmentChanged()
	ns:InvalidateUsableSlots()
	if gearPending or not ns.db then
		return
	end
	gearPending = true
	C_Timer.After(0, function()
		gearPending = false
		-- In combat nothing can be written, so only an open page redraws; the rest waits for combat to end.
		if InCombatLockdown() then
			if not ns:RefreshOpenPages() then
				ns.QueueMacroSync()
			end
			return
		end
		ns:RefreshMacros()
	end)
end

--[[
	Unlearned spells and unlearned ranks whose names weren't loaded were skipped; redraw once a burst of them
	arrives. Only the spells this add-on asked for count, not every load another add-on or a tooltip causes.
	It can fire before PLAYER_LOGIN creates the database.
]]
local refreshPending = false

function ns:OnSpellDataLoadResult(spellID)
	local pendingRank = ns.TakePendingRank(spellID)
	local wasRequested = ns.TakeRequestedSpell(spellID)
	if not ns.db or not (pendingRank or (wasRequested and ns.ShowsUnlearned())) or refreshPending then
		return
	end
	refreshPending = true
	C_Timer.After(0, function()
		refreshPending = false
		ns:RefreshOpenPages()
	end)
end

-- Placing or removing an action only changes the glows; redraw them once per burst.
local glowsPending = false

local function RedrawGlows()
	glowsPending = false
	local bars
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			bars = bars or ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.UpdateMacroGlow(page.buttons[i], bars)
			end
		end
	end
end

function ns:OnActionbarSlotChanged(slot)
	if slot then
		ns.OnRankBarSlotChanged(slot)
	end
	if not glowsPending then
		glowsPending = true
		C_Timer.After(0, RedrawGlows)
	end
end

--[[
	A macro made, renamed or deleted, here or in the macro window, changes the slot counts and the glows;
	redraw the open page's tiles once per burst, since syncing fires one per macro.
]]
local macrosPending = false

local function RedrawButtons()
	macrosPending = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			local bars = ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.SetMacroButton(page.buttons[i], page.buttons[i].macro, bars)
			end
			UpdateMacroCount(page)
		end
	end
end

function ns:OnUpdateMacros()
	if not macrosPending then
		macrosPending = true
		C_Timer.After(0, RedrawButtons)
	end
end
