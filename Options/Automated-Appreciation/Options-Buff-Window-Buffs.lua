local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    "Tracked Abilities" panel, under Buff Duty: who each buff you can give to others is
    offered to, and when a buff counts as missing. Lists every class, because
    these settings are account-wide. Not hidden
    behind the Buff Duty switch: these are choices worth making before
    turning the window on, and the parent panel says whether it is.
]]
function ns.BuildBuffWindowBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = ns.SubPanelTitle(L["TAB_BUFF_WINDOW"], L["TRACKED_HEADER"]),
		type = "group",
		args = {
			--[[
			    "Tanks" and "Healers" need saying once for every dropdown below,
			    rather than in each one's tooltip. The raid's Main Tank mark is
			    named in the client's own words.
			]]
			descBuffs = ns.OptionsDesc(L["BUFF_WINDOW_BUFFS_DESCRIPTION"]:format(MAINTANK), 1),
			space0 = ns.OptionsSpacer(2),
		},
	}
	--[[
	    Labelled with the client's own duration string, so "5 Minutes" reads right
	    in every locale without a string of ours.
	]]
	local refreshValues = {}
	for _, minutes in ipairs(Data.BUFF_WINDOW_REFRESH_CHOICES) do
		refreshValues[minutes] = D_MINUTES:format(minutes)
	end
	options.args.refreshLabel =
		ns.OptionsRowLabel(GetColor("TITLE") .. L["BUFF_WINDOW_REFRESH"] .. "|r", 26, ns.OPTIONS_ALIGNED_LABEL_WIDTH)
	options.args.refreshMinutes = {
		type = "select",
		name = "",
		desc = L["BUFF_WINDOW_REFRESH_DESCRIPTION"],
		values = refreshValues,
		sorting = Data.BUFF_WINDOW_REFRESH_CHOICES,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = 27,
		get = function()
			return Settings().refreshMinutes
		end,
		set = function(_, value)
			Settings().refreshMinutes = value
			ns.RefreshBuffWindow()
		end,
	}
	--[[
	    Count as Tanks: one row per class this client's data carries, then Pets,
	    each a caption beside a Never / When Not in a Group / Always dropdown.
	    It decides only for a player with no role of their own (RoleOf), so it
	    sits apart from the role note above rather than inside it. Captions take
	    the aligned width so the dropdowns line up with the boxed ones below.
	]]
	options.args.spaceTanks0 = ns.OptionsSpacer(28)
	options.args.headerTanks = ns.OptionsHeader(L["BUFF_WINDOW_TANKS_HEADER"], 29)
	options.args.spaceTanks1 = ns.OptionsSpacer(30)
	options.args.descTanks = ns.OptionsDesc(L["BUFF_WINDOW_TANKS_DESCRIPTION"], 30.3)
	options.args.spaceTanks2 = ns.OptionsSpacer(30.6)

	local tankValues = {}
	for _, value in ipairs(Data.TANK_WHEN_ORDER) do
		tankValues[value] = L["BUFF_WINDOW_TANKS_" .. value]
	end
	local function TankRow(key, caption, desc, order)
		options.args["tankLabel_" .. key] = ns.OptionsRowLabel(caption, order, ns.OPTIONS_ALIGNED_LABEL_WIDTH)
		options.args["tankWhen_" .. key] = {
			type = "select",
			name = "",
			desc = desc,
			values = tankValues,
			sorting = Data.TANK_WHEN_ORDER,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order + 0.5,
			get = function()
				return Settings().tankWhen[key] or Data.TANK_WHEN.NEVER
			end,
			set = function(_, value)
				Settings().tankWhen[key] = value
				ns.RefreshBuffWindow()
			end,
		}
	end

	local tankOrder = 31
	for _, class in ipairs(ns.OptionsClassList()) do
		TankRow(class, ns.OptionsClassName(class), L["BUFF_WINDOW_TANKS_CLASS_DESCRIPTION"], tankOrder)
		tankOrder = tankOrder + 1
	end
	TankRow(Data.TANK_WHEN_PET, L["BUFF_WINDOW_TANKS_PETS"], L["BUFF_WINDOW_TANKS_PETS_DESCRIPTION"], tankOrder)
	options.args.spaceTanks3 = ns.OptionsSpacer(tankOrder + 1)

	local audienceValues = {}
	for _, value in ipairs(Data.BUFF_AUDIENCE_ORDER) do
		audienceValues[value] = L["BUFF_WINDOW_AUDIENCE_" .. value]
	end

	-- After Count as Tanks, which takes up to one order number per class.
	local categoryOrder = 60
	for _, category in ipairs(ns.BuffWindowCategories or {}) do
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
			ns.DefineSpellSelectRow(
				options.args[groupKey].args,
				entry,
				entryOrder,
				L["BUFF_WINDOW_AUDIENCE_DESCRIPTION"]:format(entry.spellName),
				{
					values = audienceValues,
					sorting = Data.BUFF_AUDIENCE_ORDER,
					get = function()
						return Settings().audience[entry.key]
					end,
					set = function(_, value)
						Settings().audience[entry.key] = value
						ns.RefreshBuffWindow()
					end,
				}
			)
			entryOrder = entryOrder + 1
		end

		categoryOrder = categoryOrder + 1
	end

	return options
end
