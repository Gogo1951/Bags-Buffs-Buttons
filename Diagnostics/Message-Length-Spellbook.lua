local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local ShownText = ns.DiagnosticShownText

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

--[[
	Every macro the page lists for this class, built through the add-on's own builder with every option it
	offers turned on and every equipped Use: item ticked, the longest each can get, and its byte length
	against the macro limit. The builder reads the options through ns.IsOptionOn and ns.UseItemSlots, so the
	report stands in for those two (and for ns.WarnOnce, so a macro too long to write prints nothing) for one
	build, then puts them and the
	page's list back as they were. Nothing is written to the saved settings or to any WoW macro.
]]
local function OfferedOption(macro, key)
	return ns.OffersOption(macro, key)
end

local function BuildLongestMacros()
	local saved = {}
	for index, macro in ipairs(ns.macros) do
		saved[index] = macro
	end
	local isOptionOn, useItemSlots, warnOnce = ns.IsOptionOn, ns.UseItemSlots, ns.WarnOnce
	local slots = {}
	for _, entry in ipairs(ns.UsableSlots()) do
		slots[#slots + 1] = entry.slot
	end
	ns.IsOptionOn = OfferedOption
	ns.UseItemSlots = function(macro)
		return ns.OffersUseItems(macro) and slots or {}
	end
	ns.WarnOnce = function() end
	local ok, problem = pcall(ns.CollectMacros)
	local built = {}
	for index, macro in ipairs(ns.macros) do
		built[index] = macro
	end
	ns.IsOptionOn, ns.UseItemSlots, ns.WarnOnce = isOptionOn, useItemSlots, warnOnce
	wipe(ns.macros)
	for index, macro in ipairs(saved) do
		ns.macros[index] = macro
	end
	if not ok then
		error(problem, 0)
	end
	return built
end

function ns:BuildSpellbookMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	if not ns.db then
		lines[#lines + 1] = "(database not loaded)"
		return table.concat(lines, "\n")
	end
	local maxBody = ns.MACRO_BODY_MAX_LENGTH
	local built = BuildLongestMacros()
	lines[#lines + 1] = string.format("Macro limit: %d bytes. %d macros built.", maxBody, #built)
	lines[#lines + 1] = ""
	table.sort(built, function(a, b)
		return #a.body > #b.body
	end)
	for _, macro in ipairs(built) do
		lines[#lines + 1] = string.format(
			"[%s] %s: %d bytes",
			#macro.body > maxBody and "OVER" or "OK",
			ShownText(macro.macroName),
			#macro.body
		)
		lines[#lines + 1] = "    " .. ShownText(macro.body)
	end
	return table.concat(lines, "\n")
end
