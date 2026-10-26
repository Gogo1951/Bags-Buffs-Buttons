local _, ns = ...

-- Rewrites the Dynamic Rank macros as the target and the mouseover change (Features/Macro-Builder.lua builds them).

local MacroBody = ns.MacroBody

--[[
	The targetRank macros pick their ranks by the levels of the units they cast on, so a new target rewrites
	them all, and a new mouseover only those that also cast on the mouseover. A burst of changes is rewritten
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
	Whether any WoW macro the add-on wrote is a Dynamic Rank one. Buff spells take Dynamic Rank by default, so
	the setting alone is on for nearly every character, warriors included; without a macro to rewrite, a new
	target or mouseover has nothing to do and the page's list isn't rebuilt for it. Read off the list the last
	time it was built and kept until the next build (ns.MarkRankBodiesStale) or a new macro is written
	(ns.ForgetPlacedRankMacros), so dropping the list on SPELLS_CHANGED doesn't bring the rebuild back. nil
	until first read.
]]
local placedRankMacros

local function AnyPlacedRankMacro()
	if placedRankMacros == nil then
		if #ns.macros == 0 then
			ns.CollectMacros()
		end
		local tags = ns.ReadMacroIndexes().tags
		placedRankMacros = false
		for _, macro in ipairs(ns.macros) do
			if ns.IsOptionOn(macro, "targetRank") and tags[ns.MacroTag(macro)] then
				placedRankMacros = true
				break
			end
		end
	end
	return placedRankMacros
end

function ns.ForgetPlacedRankMacros()
	placedRankMacros = nil
end

local function RanksRewritable()
	return ns.db and not InCombatLockdown() and ns.AnyTargetRank() and AnyPlacedRankMacro()
end

local function RewriteRankMacros()
	local mouseoverOnly = pendingRankRewrite == "mouseover"
	pendingRankRewrite = nil
	if not RanksRewritable() then
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
	if not RanksRewritable() then
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
	if UnitExists("mouseover") and RanksRewritable() then
		C_Timer.After(MOUSEOVER_POLL_SECONDS, PollMouseover)
		return
	end
	watchingMouseover = false
	QueueRankRewrite("mouseover")
end

function WatchMouseover()
	if not watchingMouseover and UnitExists("mouseover") then
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
	if RanksRewritable() then
		pendingRankRewrite = "all"
		RewriteRankMacros()
	end
end

-- A rebuilt list (ns.CollectMacros) holds bodies never written, so the next rewrite writes every one.
function ns.MarkRankBodiesStale()
	rankBodiesSynced = false
	placedRankMacros = nil
end
