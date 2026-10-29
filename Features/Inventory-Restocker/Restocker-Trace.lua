local _, ns = ...

--------------------------------------------------------------------------------
-- Restock Trace
--------------------------------------------------------------------------------

--[[
    The bank restock's step-by-step trace, written into the Diagnostic Tools
    Event Log as RESTOCKER_TRACE entries, never into chat. Gated on the log's
    runtime flag, which lives in memory and starts false at every login, so a
    player can never leave this on -- and the boolean is read before any string
    work, so a run with logging off pays one comparison per call.

    Developer-facing, so the text stays plain English and out of Locales/: each
    message is a TRACE_* format in ns.DiagnosticsStrings (Diagnostics/Diagnostics-Core.lua),
    passed here by key and looked up only once the gate is open.

    Restocker-Bags.lua and Restocker-Bank.lua both call it.

    Takes the format's arguments rather than a pre-concatenated string, so the
    (potentially expensive) build only happens when the gate is open: prefer
    ns.RestockerDebug("TRACE_X", v) over building the text at the call site.
]]
function ns.RestockerDebug(key, ...)
	if not (ns.diagnostics and ns.diagnostics.logging) then
		return
	end
	local message = ns.DiagnosticsStrings[key]
	if select("#", ...) > 0 then
		message = string.format(message, ...)
	end
	ns:LogEventNow("RESTOCKER_TRACE", tostring(message))
end
