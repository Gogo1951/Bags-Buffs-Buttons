local _, ns = ...
local L = ns.L

--[[
    "Tracked Abilities" panel, under Send Good News: the class categories of
    ns.GoodNewsCategories, with toggles bound to the independent
    goodNews.watched list, so "thank for it" and "announce it" stay separate
    choices on the same ids. Not hidden behind the Good News switch, like Buff
    Duty's sub-panels: the parent panel says whether it is on. Registered as a
    function so the list is rebuilt on open, once lazily-loaded item names are
    cached.
]]
function ns.BuildGoodNewsTrackedOptions()
	local function GivenWatched()
		return ns.db.global.goodNews.watched
	end

	local options = {
		name = ns.SubPanelTitle(L["TAB_GOOD_NEWS"], L["TRACKED_HEADER"]),
		type = "group",
		args = {},
	}

	local categoryOrder = 1
	for _, category in ipairs(ns.GoodNewsCategories or {}) do
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
			options.args[groupKey].args["entry_" .. entry.ids[1]] =
				ns.DefineEntryToggle(entry, entryOrder, GivenWatched)
			entryOrder = entryOrder + 1
		end

		categoryOrder = categoryOrder + 1
	end

	return options
end
