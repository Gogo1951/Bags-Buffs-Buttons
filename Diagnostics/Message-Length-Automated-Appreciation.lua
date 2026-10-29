local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local ShownText = ns.DiagnosticShownText

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

--[[
    Every whisper and macro TFTB can send or write, built through the add-on's
    own builders (ns.DIAGNOSTIC_MESSAGES), each with its byte length against its
    ceiling, OVER past it. It builds strings only: nothing is sent and no macro
    is written. Any notes the manifest returns follow the list.
]]
function ns:BuildBuffsMessageLengthReport()
	local rows, notes = ns.DIAGNOSTIC_MESSAGES()
	local lines = { GetClientHeader(), "" }
	for _, row in ipairs(rows) do
		local text = row.text or ""
		lines[#lines + 1] = string.format(
			"[%s] %s: %d / %d bytes",
			#text > row.ceiling and "OVER" or "OK",
			row.label,
			#text,
			row.ceiling
		)
		lines[#lines + 1] = "    " .. ShownText(text)
	end
	if notes and #notes > 0 then
		lines[#lines + 1] = ""
		for _, note in ipairs(notes) do
			lines[#lines + 1] = note
		end
	end
	return table.concat(lines, "\n")
end
