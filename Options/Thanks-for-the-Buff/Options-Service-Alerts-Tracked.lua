local _, ns = ...
local L = ns.L

--[[
    "Tracked Abilities" panel, under Service Alerts: one flat list, since
    services are a single category with no inner headers. Not hidden behind the
    Service Alerts switch, like Buff Duty's sub-panels: the parent panel says
    whether it is on. Registered as a function so the list is rebuilt on open,
    once lazily-loaded item names are cached.
]]
function ns.BuildServicesTrackedOptions()
	local options = {
		name = ns.SubPanelTitle(L["TAB_SERVICES"], L["TRACKED_HEADER"]),
		type = "group",
		args = {},
	}

	local entryOrder = 1
	for _, entry in ipairs(ns.SortedEntries(ns.ServiceEntries or {})) do
		options.args["entry_" .. entry.ids[1]] = ns.DefineEntryToggle(entry, entryOrder)
		entryOrder = entryOrder + 1
	end

	return options
end
