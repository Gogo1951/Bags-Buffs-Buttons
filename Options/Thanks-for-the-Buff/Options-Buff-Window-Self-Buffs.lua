local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    "Self-Buffs" panel, under Buff Duty: one dropdown per self buff by class
    picking when it shows -- Off, When Missing, or a few minutes before it runs
    out. Its own time rather than the Tracked Abilities panel's one "Refresh Under", since a
    30-minute armor and a 10-minute shield want different warnings. Every class
    is listed, because the default profile is shared account-wide.

    The switch for the window's Self-Buffs row lives on the Buff Duty panel with
    the window's other rows. Like the Tracked Abilities panel, nothing here hides behind it:
    these are choices worth making before turning the row on. Weapons have a
    panel of their own (Options-Buff-Window-Weapon-Buffs.lua).
]]

--[[
    "Hunter · any one aspect counts": a class with two or more self buffs from
    one exclusive family says so after its name, since any one of them up is
    enough. A family of one (Lightning Shield alone) needs no note.
]]
local function CategoryName(category)
	local counts, families = {}, {}
	for _, entry in ipairs(category.entries) do
		local family = entry.exclusive
		if family then
			counts[family] = (counts[family] or 0) + 1
			if counts[family] == 2 then
				families[#families + 1] = family
			end
		end
	end
	table.sort(families)

	local name = category.name
	for _, family in ipairs(families) do
		local note = L["BUFF_WINDOW_SELF_NOTE_" .. family]
		if note then
			name = name .. " " .. GetColor("MUTED") .. "· " .. note .. "|r"
		end
	end
	return name
end

function ns.BuildBuffWindowSelfBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = ns.SubPanelTitle(L["TAB_BUFF_WINDOW"], L["BUFF_WINDOW_SELF_HEADER"]),
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["BUFF_WINDOW_SELF_DESCRIPTION"], 1),
			spaceIntro = ns.OptionsSpacer(2),
		},
	}

	local refreshValues = ns.BuffWindowRefreshValues(Data.SELF_REFRESH_CHOICES)
	local selfOrder = 10
	for _, category in ipairs(ns.BuffWindowSelfCategories or {}) do
		local groupKey = "self_" .. category.id
		options.args[groupKey] = {
			type = "group",
			name = CategoryName(category),
			order = selfOrder,
			inline = true,
			args = {},
		}

		local entryOrder = 1
		for _, entry in ipairs(ns.SortedEntries(category.entries)) do
			ns.DefineSpellSelectRow(
				options.args[groupKey].args,
				entry,
				entryOrder,
				L["BUFF_WINDOW_SELF_REFRESH_DESCRIPTION"]:format(entry.spellName),
				{
					values = refreshValues,
					sorting = Data.SELF_REFRESH_CHOICES,
					get = function()
						return Settings().selfRefresh[entry.key]
					end,
					set = function(_, value)
						Settings().selfRefresh[entry.key] = value
						ns.RefreshBuffWindow()
					end,
				}
			)
			entryOrder = entryOrder + 1
		end

		selfOrder = selfOrder + 1
	end

	return options
end
