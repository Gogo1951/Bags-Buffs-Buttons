local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent drops before recording. The dispatcher only ever hands
    LogEvent the events the add-on registers (Core's ns.EVENT_NAMES), and the buff
    engine writes the signal firings of both entries itself, decoded, through
    ns:LogEventNow:

    - COMBAT_LOG_EVENT_UNFILTERED, registered on every flavor but Forever: raw
      combat-log traffic would bury the signal, so every aura landing on you
      and every cast or revive Thanks for the Buff tracks is logged in full instead, and every
      other cast is counted by spell id in the summary (see ns:LogCombatCast).
    - UNIT_AURA, registered on every flavor for every unit (the Buff Window
      reads the whole group): its update table can't be logged as text, and on
      Forever each added aura on you is logged with the gate that decided it
      instead (see ns:LogAuraUpdate). The Buff Window's own reads show on the
      Buff Window Context report.

    SPELL_UPDATE_COOLDOWN is dropped outright: it fires on every global
    cooldown and carries no id to classify by, and all it drives is the Buff
    Window's cooldown swipes, which show on the window itself.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	COMBAT_LOG_EVENT_UNFILTERED = true,
	UNIT_AURA = true,
	SPELL_UPDATE_COOLDOWN = true,
}

--[[
    Events that carry an id worth classifying, and the argument position it
    arrives in, for ns:SuppressUncorrelatedMessage to classify per firing
    rather than drop wholesale. A firing logs in full when a feature
    correlates it (Thanks for the Buff's ns.IsCorrelatedMessage, or
    Connoisseur's checks below), and every other firing is counted.

    - UNIT_SPELLCAST_SUCCEEDED fires for every unit the client tracks, so in a
      group or a city it is a firehose; its id is the spell id.
    - GET_ITEM_INFO_RECEIVED fires for every item any add-on or the game's own
      UI loads, so a bag or auction add-on can send hundreds; its id is the
      item id, and only a tracked item's or a consumable's matters.
    - UI_ERROR_MESSAGE fires on every red error the game shows; its id is the
      error type. "A more powerful spell is already active" matters, which
      Buff Duty acts on, and so do the two the consumable macros read by text.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	UNIT_SPELLCAST_SUCCEEDED = 3,
	GET_ITEM_INFO_RECEIVED = 1,
	UI_ERROR_MESSAGE = 1,
}

-- The counter id a secret id (WoW Forever) folds into, since a secret can't key a table.
local SECRET_ID = 0

-- The counter id a gated firehose's ignored firings fold into, with the reason as their text.
local GATED_ID = -1

--[[
    Firehoses that carry no id, each with the test its handler makes before
    acting on a firing. A firing the handler would ignore folds into the
    counters under GATED_ID with the reason; one it acts on logs in full.
    UPDATE_MOUSEOVER_UNIT fires for every unit the cursor crosses, and Macro
    Spellbook's Features/Spellbook/Dynamic-Rank.lua queues a rewrite
    only out of combat while any macro has Dynamic Rank on, by its own setting
    or its kind's default (its RanksRewritable), so the test makes that same
    call.
]]
local GATED_EVENTS = {
	UPDATE_MOUSEOVER_UNIT = {
		reason = "out of combat with no Dynamic Rank macro, or in combat",
		acts = function()
			return ns.db ~= nil and not InCombatLockdown() and ns.AnyTargetRank()
		end,
	},
}

--[[
    Connoisseur & Restocker's correlations, beside Thanks for the Buff's
    ns.IsCorrelatedMessage, each the exact test its live handler makes: the
    two errors the consumable macros read by text, ERR_ITEM_WRONG_ZONE
    (Features/Connoisseur/Macros/Runtime.lua) and SPELL_FAILED_TARGETS_DEAD
    (Features/Connoisseur/Macros/Tools-Hunters.lua); a consumable's item info,
    which can change a macro (ns.HasRawData); and a cast of the player's that
    changes what a macro holds (ns.SpellCastChangesMacros).
]]
local function ConnoisseurCorrelates(event, id, text)
	if event == "UI_ERROR_MESSAGE" then
		return ns.IsPlain(text) and (text == ERR_ITEM_WRONG_ZONE or text == SPELL_FAILED_TARGETS_DEAD)
	end
	if event == "GET_ITEM_INFO_RECEIVED" then
		return ns.HasRawData(id)
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		return ns.SpellCastChangesMacros(id)
	end
	return false
end

--[[
    Folds one uncorrelated firing into its counter: the first-seen text plus a
    count, rendered as one block at the end of the report. Counters are keyed
    by event, then id, so one id arriving on two events stays two rows. A
    secret id counts under SECRET_ID with the text <secret>. Counts only while
    logging, like ns:LogEventNow.
]]
function ns:CountUncorrelated(event, id, text)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed or not ns.diagnostics.logging then
		return
	end
	if not ns.IsPlain(id) then
		id, text = SECRET_ID, "<secret>"
	elseif not ns.IsPlain(text) then
		text = "<secret>"
	end
	local counters = suppressed[event]
	if not counters then
		counters = {}
		suppressed[event] = counters
	end
	local entry = counters[id]
	if entry then
		entry.count = entry.count + 1
		return
	end
	local raw = string.sub(tostring(text or ""), 1, EVENT_LOG_MAX_ARG_LENGTH)
	counters[id] = { text = (raw:gsub("|", "||")), count = 1 }
end

--[[
    Per-firing filter for the events above. A firing whose id the add-on
    correlates (ns.IsCorrelatedMessage) logs in full; any other folds into its
    counter, so firehose traffic can't evict the entries the log exists to
    carry. A secret id counts too. A plain firing carrying no numeric id in the
    filtered position is unclassifiable, and unclassifiable is signal: it logs
    verbatim. The counter's text is the argument after the id, or blank when
    none follows.

    Returns true when the firing was counted and must not reach the buffer.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local gated = GATED_EVENTS[event]
	if gated then
		if gated.acts() then
			return false
		end
		ns:CountUncorrelated(event, GATED_ID, gated.reason)
		return true
	end
	local idPosition = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	if not idPosition then
		return false
	end
	local messageID = select(idPosition, ...)
	local text
	if select("#", ...) > idPosition then
		text = select(idPosition + 1, ...)
	end
	if ns.IsPlain(messageID) then
		if type(messageID) ~= "number" then
			return false
		end
		if ns.IsCorrelatedMessage(event, messageID) or ConnoisseurCorrelates(event, messageID, text) then
			return false
		end
	end
	ns:CountUncorrelated(event, messageID, text)
	return true
end

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
    One entry in the buffer, for ns:LogEvent and ns:LogEventNow below.
    Snapshots arguments to strings immediately -- never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and per-argument byte length so a single entry can't run away.
    A secret argument (WoW Forever) can't be turned into text, so it records as
    <secret>.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox instead of rendering as a clickable item
    swatch. Escaping last also means the cut can never leave a dangling pipe that
    would eat the following ", " separator.
]]
local function AppendEntry(event, ...)
	local log = ns.diagnostics.log
	if not log then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		local value = select(index, ...)
		if ns.IsPlain(value) then
			local raw = string.sub(tostring(value), 1, EVENT_LOG_MAX_ARG_LENGTH)
			parts[index] = (raw:gsub("|", "||"))
		else
			parts[index] = "<secret>"
		end
	end
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

-- Called by Core's central dispatcher for every event while logging is active.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	if ns:SuppressUncorrelatedMessage(event, ...) then
		return
	end
	AppendEntry(event, ...)
end

--[[
    The way back in for an excluded firehose that is sometimes signal: the
    handler that decides a firing mattered calls this with the event and its
    arguments, and it is recorded as the dispatcher would have, past the
    exclude list. Feature code calls it, so it carries the dispatcher's own
    single boolean check before any work.
]]
function ns:LogEventNow(event, ...)
	if not ns.diagnostics.logging then
		return
	end
	AppendEntry(event, ...)
end

--[[
    Renders the suppressed-traffic counters as one compact block, biggest
    offender first. This is also how a tester discovers a message id the add-on
    should be correlating but isn't.
]]
local function AppendSuppressedSummary(lines)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local rows = {}
	for event, counters in pairs(suppressed) do
		for id, entry in pairs(counters) do
			rows[#rows + 1] = { event = event, id = id, entry = entry }
		end
	end
	if #rows == 0 then
		return
	end
	table.sort(rows, function(a, b)
		if a.entry.count ~= b.entry.count then
			return a.entry.count > b.entry.count
		end
		if a.event ~= b.event then
			return a.event < b.event
		end
		return a.id < b.id
	end)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Suppressed uncorrelated traffic:"
	for _, row in ipairs(rows) do
		if row.id == SECRET_ID then
			lines[#lines + 1] = string.format("%s(<secret>) x%d", row.event, row.entry.count)
		else
			lines[#lines + 1] = string.format("%s(%d, %s) x%d", row.event, row.id, row.entry.text, row.entry.count)
		end
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	AppendSuppressedSummary(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
    The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
    both blocked actions and accesses to tainted globals; 0 is off. This is the
    only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
