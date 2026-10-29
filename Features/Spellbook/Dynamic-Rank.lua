local _, ns = ...

-- Rewrites the Dynamic Rank macros as the target and the mouseover change (Features/Spellbook/Macro-Builder.lua builds them).

local MacroBody = ns.MacroBody

--[[
	The targetRank macros pick their ranks by the levels of the units they cast on, so a new target rewrites
	them all, and a new mouseover only those that also cast on the mouseover, each only while such a macro is
	on an action bar (see PlacedRankMacros). A burst of changes is rewritten
	once, on the next frame, the page's list built first when no page has built it yet. Out of combat only:
	in combat a macro keeps the ranks it last had, so a lower rank is only ever held while the low-level unit
	is still there. The game says when a new unit comes under the cursor but not when the cursor leaves one,
	so while a mouseover is out the rewrite watches for it to go and rewrites back to the highest rank; and
	entering combat rewrites every one at once, the last moment the macros can change, so combat starts on
	the highest rank wherever no low-level unit is targeted or under the cursor.
]]
local pendingRankRewrite -- nil, or "mouseover" or "all" while a rewrite waits for the next frame
local WatchMouseover

--[[
	Whether the WoW macros carry the targetRank bodies ns.macros holds. A rebuilt list's bodies were never
	written, so the next rewrite writes every one; after that only a body that changed is written, so most
	mouseovers don't read the macro list at all.
]]
local rankBodiesSynced = false

--[[
	Whether a Dynamic Rank WoW macro the add-on wrote is on an action bar ({any = true}), and whether one of
	those tries the mouseover too ({mouseover = true}). Buff spells take Dynamic Rank by default, so the
	setting alone is on for nearly every character, warriors included; without a placed macro to rewrite, a
	new target has nothing to do and the page's list isn't rebuilt for it, and without a placed one that tries
	the mouseover, neither has a new mouseover, nor is the mouseover watched. Read off the list the last time
	it was built and kept until the next build (ns.MarkRankBodiesStale), a new macro is written
	(ns.ForgetPlacedRankMacros) or a bar slot takes another macro (ns.OnRankBarSlotChanged), so dropping the
	list on SPELLS_CHANGED doesn't bring the rebuild back. nil until first read. barMacroNames is what the bars
	held when it was read, by slot.
]]
local placedRankMacros
local barMacroNames = {}

local function PlacedRankMacros()
	if placedRankMacros == nil then
		if #ns.macros == 0 then
			ns.CollectMacros()
		end
		local tags = ns.ReadMacroIndexes().tags
		barMacroNames = ns.BarMacroNames()
		local onBars = {}
		for _, name in pairs(barMacroNames) do
			onBars[name] = true
		end
		local placed = { any = false, mouseover = false }
		for _, macro in ipairs(ns.macros) do
			if ns.IsOptionOn(macro, "targetRank") and tags[ns.MacroTag(macro)] and onBars[ns.WowMacroName(macro)] then
				placed.any = true
				if ns.TriesUnit(macro, "mouseover") then
					placed.mouseover = true
					break
				end
			end
		end
		placedRankMacros = placed
	end
	return placedRankMacros
end

function ns.ForgetPlacedRankMacros()
	placedRankMacros = nil
end

-- scope "mouseover" needs a placed macro that tries the mouseover, any other a placed macro at all.
local function RanksRewritable(scope)
	if not (ns.db and ns.IsSpellbookEnabled() and not InCombatLockdown() and ns.AnyTargetRank()) then
		return false
	end
	local placed = PlacedRankMacros()
	return placed.any and (scope ~= "mouseover" or placed.mouseover)
end

local function RewriteRankMacros()
	local scope = pendingRankRewrite
	local mouseoverOnly = scope == "mouseover"
	pendingRankRewrite = nil
	if not RanksRewritable(scope) then
		return
	end
	if #ns.macros == 0 then
		ns.CollectMacros()
	end
	local writeAll = not rankBodiesSynced
	local changed = {}
	for _, macro in ipairs(ns.macros) do
		if
			ns.IsOptionOn(macro, "targetRank")
			and (writeAll or not mouseoverOnly or ns.TriesUnit(macro, "mouseover"))
		then
			local body = MacroBody(macro)
			if writeAll or body ~= macro.body then
				macro.body = body
				changed[#changed + 1] = macro
			end
		end
	end
	rankBodiesSynced = true
	if #changed > 0 then
		local indexes = ns.ReadMacroIndexes()
		for _, macro in ipairs(changed) do
			ns.SyncMacro(macro, indexes)
		end
	end
	WatchMouseover()
end

local function QueueRankRewrite(scope)
	if not RanksRewritable(scope) then
		return
	end
	if not pendingRankRewrite then
		C_Timer.After(0, RewriteRankMacros)
	end
	if scope == "all" or not pendingRankRewrite then
		pendingRankRewrite = scope
	end
end

local MOUSEOVER_POLL_SECONDS = 0.2
local watchingMouseover = false

-- Checks for the mouseover to have gone until it does, then rewrites the mouseover macros for no unit.
local function PollMouseover()
	if UnitExists("mouseover") and RanksRewritable("mouseover") then
		C_Timer.After(MOUSEOVER_POLL_SECONDS, PollMouseover)
		return
	end
	watchingMouseover = false
	QueueRankRewrite("mouseover")
end

function WatchMouseover()
	if not watchingMouseover and UnitExists("mouseover") and PlacedRankMacros().mouseover then
		watchingMouseover = true
		C_Timer.After(MOUSEOVER_POLL_SECONDS, PollMouseover)
	end
end

function ns:OnPlayerTargetChanged()
	QueueRankRewrite("all")
end

function ns:OnUpdateMouseoverUnit()
	QueueRankRewrite("mouseover")
end

-- Fires just before combat locks the macros, so the rewrite runs now rather than on the next frame.
function ns:OnPlayerRegenDisabled()
	if RanksRewritable("all") then
		pendingRankRewrite = "all"
		RewriteRankMacros()
	end
end

--[[
	A bar slot that now holds another macro, or none, may place or remove a Dynamic Rank macro; a macro
	rewritten in place keeps its name, so changes nothing here. Slot 0 stands for any slot. Where the last read
	found no placed macro trying the mouseover, the rewrites skipped have left the macros' ranks behind the
	units there now, so they are written for those units at once rather than on the next target change.
]]
function ns.OnRankBarSlotChanged(slot)
	if slot and slot > 0 and ns.ActionMacroName(slot) == barMacroNames[slot] then
		return
	end
	local missed = placedRankMacros and not placedRankMacros.mouseover
	placedRankMacros = nil
	if missed then
		QueueRankRewrite("all")
	end
end

-- A rebuilt list (ns.CollectMacros) holds bodies never written, so the next rewrite writes every one.
function ns.MarkRankBodiesStale()
	rankBodiesSynced = false
	placedRankMacros = nil
end
