local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    "Weapon Buffs" panel, under Buff Duty after Self-Buffs: one Reapply
    timing for everything at the top, then a grid of checkboxes -- a row per
    choice, a Main Hand and an Off Hand column. A rogue's poisons and a
    shaman's imbues come first, then the oils, stones and lures any class can
    use, strongest first. Everything is listed, whatever is in your bags (these settings
    are account-wide); the window offers only what you have and can
    use. ns.OnBuffWindowItemInfo repaints the panel as item names load.

    The switch for the window's weapon rows lives on the Buff Duty panel with
    the window's other rows.
]]

-- Each column's share of a boxed row's control width, so the two sit where a dropdown would.
local COLUMN_WIDTH = ns.OPTIONS_CONTROL_WIDTH / 2

--[[
    A poison or weapon item is named by its line's first item, an imbue by
    its spell. An item the client hasn't cached yet shows its placeholder
    until it loads.
]]
local function WeaponChoiceName(entry)
	local id = entry.ids[1]
	if entry.items then
		return C_Item.GetItemInfo(id) or L["TRACKED_ITEM_PENDING"]:format(id)
	end
	return C_Spell.GetSpellName(id) or L["TRACKED_SPELL_PENDING"]:format(id)
end

local function WeaponChoiceIcon(entry)
	if entry.items then
		return C_Item.GetItemIconByID(entry.ids[1])
	end
	return C_Spell.GetSpellTexture(entry.ids[1])
end

--[[
    A box of choices: the column captions, then a row per choice -- its name,
    whose hover shows the game tooltip (a poison line's best item, an oil's
    own, or the imbue's spell), and a checkbox per hand. `hands` is which
    columns this box has; `handKey(hand)` names the hand's table in `list()`.
]]
local function DefineGrid(args, choices, hands, list, handKey)
	local has = {}
	for _, hand in ipairs(hands) do
		has[hand] = true
	end

	args.columnsSpace = ns.OptionsRowLabel("", 1, ns.OPTIONS_INLINE_LABEL_WIDTH)
	for index, hand in ipairs(Data.WEAPON_HAND_ORDER) do
		if has[hand] then
			args["column_" .. hand] = ns.OptionsRowLabel(ns.WEAPON_HAND_LABELS[hand], 1 + index / 10, COLUMN_WIDTH)
		end
	end

	for index, entry in ipairs(choices) do
		local order = 10 + index
		local link = entry.items and ("item:" .. entry.items[1].id) or ns.SpellTooltipLink(entry.ids)
		args["label_" .. entry.key] = ns.OptionsAbilityLabel(function()
			local icon = WeaponChoiceIcon(entry)
			local name = WeaponChoiceName(entry)
			return icon and ("|T" .. icon .. ":16|t " .. name) or name
		end, order, ns.OPTIONS_INLINE_LABEL_WIDTH, link)

		for handIndex, hand in ipairs(Data.WEAPON_HAND_ORDER) do
			if has[hand] then
				local handName = ns.WEAPON_HAND_LABELS[hand]
				args["toggle_" .. entry.key .. "_" .. hand] = {
					type = "toggle",
					name = "",
					desc = function()
						return L["BUFF_WINDOW_WEAPON_PICK_DESCRIPTION"]:format(WeaponChoiceName(entry), handName)
					end,
					width = COLUMN_WIDTH,
					order = order + handIndex / 10,
					get = function()
						return ns.BuffWindow.WeaponChoiceOn(list(), handKey(hand), entry.key)
					end,
					set = function(_, value)
						local settings = list()
						local key = handKey(hand)
						settings[key] = settings[key] or {}
						settings[key][entry.key] = value
						ns.RefreshBuffWindow()
					end,
				}
			end
		end
	end
end

local function Box(name, order)
	return { type = "group", name = name, order = order, inline = true, args = {} }
end

function ns.BuildBuffWindowWeaponBuffsOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end

	local options = {
		name = ns.SubPanelTitle(L["TAB_BUFF_WINDOW"], L["BUFF_WINDOW_WEAPON_PANEL_HEADER"]),
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["BUFF_WINDOW_WEAPON_DESCRIPTION"], 1),
			spaceIntro = ns.OptionsSpacer(2),
			-- One timing for every choice below, lined up with the boxes' columns.
			refreshLabel = ns.OptionsRowLabel(L["BUFF_WINDOW_WEAPON_REFRESH"], 3, ns.OPTIONS_ALIGNED_LABEL_WIDTH),
			refresh = {
				type = "select",
				name = "",
				desc = L["BUFF_WINDOW_WEAPON_REFRESH_DESCRIPTION"],
				values = ns.BuffWindowRefreshValues(Data.WEAPON_REFRESH_CHOICES),
				sorting = Data.WEAPON_REFRESH_CHOICES,
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 3.1,
				get = function()
					return Settings().weaponRefresh
				end,
				set = function(_, value)
					Settings().weaponRefresh = value
					ns.RefreshBuffWindow()
				end,
			},
			spaceRefresh = ns.OptionsSpacer(4),
		},
	}

	local function Picks()
		return Settings().weaponPicks
	end
	local function Items()
		return Settings().weaponItems
	end

	-- Rogues and shamans first, each class's choices sorted by name.
	local byClass, classes = {}, {}
	for _, entry in ipairs(ns.BuffWindow.weaponEntries) do
		local class = entry.row.class
		if not byClass[class] then
			byClass[class] = {}
			classes[#classes + 1] = class
		end
		table.insert(byClass[class], entry)
	end
	table.sort(classes)

	local boxOrder = 10
	for _, class in ipairs(classes) do
		local choices = byClass[class]
		table.sort(choices, function(a, b)
			return WeaponChoiceName(a) < WeaponChoiceName(b)
		end)
		local box = Box(ns.ClassName(class), boxOrder)
		DefineGrid(box.args, choices, ns.BUFF_WINDOW_WEAPON_HANDS[class] or {}, Picks, function(hand)
			return class .. "_" .. hand
		end)
		options.args["class_" .. class] = box
		boxOrder = boxOrder + 1
	end

	--[[
	    Then Oils, Stones and Lures, each strongest first by item level (Solid
	    Sharpening Stone above Rough), then by name.
	]]
	local byKind = {}
	for _, entry in ipairs(ns.BuffWindow.weaponItemEntries) do
		byKind[entry.kind] = byKind[entry.kind] or {}
		table.insert(byKind[entry.kind], entry)
	end
	for _, kind in ipairs(Data.WEAPON_ITEM_KINDS) do
		if byKind[kind] then
			table.sort(byKind[kind], function(a, b)
				if a.itemLevel ~= b.itemLevel then
					return a.itemLevel > b.itemLevel
				end
				return WeaponChoiceName(a) < WeaponChoiceName(b)
			end)
			local box = Box(L["BUFF_WINDOW_WEAPON_KIND_" .. kind], boxOrder)
			local hands = Data.WEAPON_ITEM_KIND_HANDS[kind] or Data.WEAPON_HAND_ORDER
			DefineGrid(box.args, byKind[kind], hands, Items, function(hand)
				return hand
			end)
			options.args["kind_" .. kind] = box
			boxOrder = boxOrder + 1
		end
	end

	return options
end
