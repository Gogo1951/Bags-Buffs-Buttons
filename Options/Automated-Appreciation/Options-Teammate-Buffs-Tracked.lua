local _, ns = ...
local L = ns.L

--[[
    "Tracked Abilities" panel, under Teammate Buffs: one inline group of toggles
    per class category (each class, then Items), built at login. Not hidden
    behind the Teammate Buffs switch, like Buff Duty's sub-panels: these are
    choices worth making before turning the feature on, and the parent panel
    says whether it is. Registered as a function so the list is rebuilt and
    re-sorted on open, once lazily-loaded item names are cached.
]]
function ns.BuildTeammatesTrackedOptions()
	local options = {
		name = ns.SubPanelTitle(L["TAB_TEAMMATES"], L["TRACKED_HEADER"]),
		type = "group",
		args = {},
	}

	local categoryOrder = 1
	for _, category in ipairs(ns.TeammateCategories or {}) do
		local groupKey = "cat_" .. category.id
		options.args[groupKey] = {
			type = "group",
			name = category.name,
			order = categoryOrder,
			inline = true,
			args = {},
		}

		local entryOrder = 1
		for _, entry in ipairs(ns.SortedEntries(category.entries)) do
			options.args[groupKey].args["entry_" .. entry.ids[1]] = ns.DefineEntryToggle(entry, entryOrder)
			entryOrder = entryOrder + 1
		end

		categoryOrder = categoryOrder + 1
	end

	return options
end
