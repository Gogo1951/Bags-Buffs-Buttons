local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    "Buff Duty" panel -- the click-to-cast list of group members missing a buff
    you can give (Features/Automated-Appreciation/Buff-Window.lua, data in this client's
    Data/{Game}/Buff-Window-Spells-{Game}.lua). The enable switch at the top,
    twinned on Thanks for the Buff's heading page, is the master; everything
    below it hides while it is off. Each optional row of the window has its
    switch here, Self Buffs and Weapon Buffs included, and so do the Buff
    Key's binding (Features/Automated-Appreciation/Buff-Window-Keys.lua); what each buff is offered
    to lives in three sub-panels of this one: Tracked Abilities
    (Options-Buff-Window-Buffs.lua), Self-Buffs
    (Options-Buff-Window-Self-Buffs.lua) and Weapon Buffs
    (Options-Buff-Window-Weapon-Buffs.lua).

    Every window setting's setter ends in ns.RefreshBuffWindow, which rebuilds
    the castable list and redraws the window. The key-binding rows write game
    bindings instead.
]]

function ns.BuildBuffWindowOptions()
	local function Settings()
		return ns.db.global.buffWindow
	end
	local function Hidden()
		return not Settings().enabled
	end

	local function Toggle(key, name, desc, order, width)
		return {
			type = "toggle",
			name = name,
			desc = desc,
			width = width or "full",
			order = order,
			hidden = Hidden,
			get = function()
				return Settings()[key]
			end,
			set = function(_, value)
				Settings()[key] = value
				ns.RefreshBuffWindow()
			end,
		}
	end

	--[[
	    The right half of a Buff Key's row: the same binding the game's Key
	    Bindings list shows under the add-on's own header, so setting it in either
	    place sets both. A key moved here leaves whatever it did before, and the
	    command's old key is let go. Bindings are locked in combat.
	]]
	local function KeyBinding(command, desc, order)
		return {
			type = "keybinding",
			name = "",
			desc = desc,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			hidden = Hidden,
			disabled = function()
				return InCombatLockdown()
			end,
			get = function()
				return GetBindingKey(command)
			end,
			set = function(_, key)
				if InCombatLockdown() then
					return
				end
				for _, old in ipairs({ GetBindingKey(command) }) do
					SetBinding(old)
				end
				if key and key ~= "" then
					SetBinding(key, command)
				end
				SaveBindings(GetCurrentBindingSet())
			end,
		}
	end

	--[[
	    A row under a Buff Key's row: what to put in a macro to press the same
	    key from an action bar, in a read-only box so it can be copied. The box
	    sits under the key button, beside its caption.
	]]
	local function MacroLine(macro, order)
		return {
			label = ns.OptionsRowLabel(GetColor("HELP") .. L["BUFF_KEY_MACRO_CAPTION"] .. "|r", order, nil, Hidden),
			box = {
				type = "input",
				name = "",
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = order + 0.05,
				hidden = Hidden,
				get = function()
					return macro
				end,
				set = function() end,
			},
		}
	end

	local keyMacro = MacroLine(ns.BUFF_KEY_MACRO, 22.2)

	--[[
	    The right half of a Solo or In Group row: where the window shows, Always
	    or In Instance. Like Return the Favor's, it appears only while the
	    toggle beside it is on.
	]]
	local whereValues = {}
	for _, value in ipairs(Data.BUFF_WINDOW_WHERE_ORDER) do
		whereValues[value] = L["BUFF_WINDOW_WHERE_" .. value]
	end
	local function Where(toggleKey, key, order)
		return {
			type = "select",
			name = "",
			desc = L["BUFF_WINDOW_WHERE_DESCRIPTION"],
			values = whereValues,
			sorting = Data.BUFF_WINDOW_WHERE_ORDER,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			hidden = function()
				return Hidden() or not Settings()[toggleKey]
			end,
			get = function()
				return Settings()[key]
			end,
			set = function(_, value)
				Settings()[key] = value
				ns.RefreshBuffWindow()
			end,
		}
	end

	local options = {
		name = L["TAB_BUFF_WINDOW"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["BUFF_WINDOW_DESCRIPTION"], 1),
			space0 = ns.OptionsSpacer(2),
			enable = ns.OptionsFeatureToggle(ns.GetFeatureSwitch("buffWindow"), 3),
			--[[
			    A status line, shown only on a class with nothing on the list: the
			    switch above is on, and the window will still never appear.
			]]
			noBuffs = {
				type = "description",
				name = GetColor("HELP") .. L["BUFF_WINDOW_NO_BUFFS"] .. "|r",
				fontSize = "medium",
				order = 4,
				hidden = function()
					return Hidden() or ns.BuffWindowHasClassRows()
				end,
			},
			space1 = ns.OptionsSpacer(5, Hidden),

			--[[
			    When the window may show at all: solo or in a group, and on
			    which classes. The class toggles are added to `classes` below.
			]]
			headerWhen = ns.OptionsHeader(L["BUFF_WINDOW_WHEN_HEADER"], 5.1, Hidden),
			spaceWhen0 = ns.OptionsSpacer(5.11, Hidden),
			descWhen = ns.OptionsDesc(L["BUFF_WINDOW_WHEN_DESCRIPTION"], 5.12, Hidden),
			spaceWhen1 = ns.OptionsSpacer(5.13, Hidden),
			showSolo = Toggle(
				"showSolo",
				L["BUFF_WINDOW_WHEN_SOLO"],
				L["BUFF_WINDOW_WHEN_SOLO_DESCRIPTION"],
				5.14,
				ns.OPTIONS_LABEL_WIDTH
			),
			showSoloWhere = Where("showSolo", "showSoloWhere", 5.15),
			spaceWhen2 = ns.OptionsSpacer(5.16, Hidden),
			showGroup = Toggle(
				"showGroup",
				L["BUFF_WINDOW_WHEN_GROUP"],
				L["BUFF_WINDOW_WHEN_GROUP_DESCRIPTION"],
				5.17,
				ns.OPTIONS_LABEL_WIDTH
			),
			showGroupWhere = Where("showGroup", "showGroupWhere", 5.18),
			spaceWhen3 = ns.OptionsSpacer(5.19, Hidden),
			descClasses = ns.OptionsDesc(L["BUFF_WINDOW_CLASSES_DESCRIPTION"], 5.2, Hidden),
			spaceClasses0 = ns.OptionsSpacer(5.21, Hidden),
			classes = {
				type = "group",
				name = "",
				order = 5.3,
				inline = true,
				hidden = Hidden,
				args = {},
			},
			spaceClasses1 = ns.OptionsSpacer(5.4, Hidden),

			--[[
			    The window's optional rows, in the order it shows them: your self
			    buffs above the group, the players outside it below.
			]]
			headerShow = ns.OptionsHeader(L["BUFF_WINDOW_SHOW_HEADER"], 6, Hidden),
			space2 = ns.OptionsSpacer(7, Hidden),
			descShow = ns.OptionsDesc(L["BUFF_WINDOW_SHOW_DESCRIPTION"], 7.3, Hidden),
			spaceShow = ns.OptionsSpacer(7.6, Hidden),
			selfEnabled = Toggle(
				"selfEnabled",
				L["BUFF_WINDOW_SELF_ENABLE"],
				L["BUFF_WINDOW_SELF_ENABLE_DESCRIPTION"],
				8
			),
			spaceWeapon = ns.OptionsSpacer(8.3, Hidden),
			weaponEnabled = Toggle(
				"weaponEnabled",
				L["BUFF_WINDOW_WEAPON_ENABLE"],
				L["BUFF_WINDOW_WEAPON_ENABLE_DESCRIPTION"],
				8.6
			),
			space3 = ns.OptionsSpacer(9, Hidden),
			favorEnabled = Toggle(
				"favorEnabled",
				L["BUFF_WINDOW_FAVOR_ENABLE"],
				L["BUFF_WINDOW_FAVOR_ENABLE_DESCRIPTION"],
				10,
				ns.OPTIONS_LABEL_WIDTH
			),
			--[[
			    The toggle and how long a stranger stays listed, on one row; the
			    dropdown appears only while the toggle is on. Labelled with the
			    client's own duration strings, so "1 Minute" reads right in every
			    locale without a string of ours.
			]]
			favorSeconds = {
				type = "select",
				name = "",
				desc = L["BUFF_WINDOW_FAVOR_SECONDS_DESCRIPTION"],
				values = function()
					local values = {}
					for _, seconds in ipairs(ns.Data.BUFF_WINDOW_FAVOR_CHOICES) do
						values[seconds] = ns.FormatDuration(seconds)
					end
					return values
				end,
				sorting = ns.Data.BUFF_WINDOW_FAVOR_CHOICES,
				width = ns.OPTIONS_CONTROL_WIDTH,
				order = 10.1,
				hidden = function()
					return Hidden() or not Settings().favorEnabled
				end,
				get = function()
					return Settings().favorSeconds
				end,
				set = function(_, value)
					Settings().favorSeconds = value
					ns.RefreshBuffWindow()
				end,
			},
			space4 = ns.OptionsSpacer(11, Hidden),
			targetEnabled = Toggle(
				"targetEnabled",
				L["BUFF_WINDOW_TARGET_ENABLE"],
				L["BUFF_WINDOW_TARGET_ENABLE_DESCRIPTION"],
				12
			),
			space5 = ns.OptionsSpacer(13, Hidden),

			headerWindow = ns.OptionsHeader(L["BUFF_WINDOW_HEADER"], 14, Hidden),
			space6 = ns.OptionsSpacer(15, Hidden),
			descWindow = ns.OptionsDesc(L["BUFF_WINDOW_WINDOW_DESCRIPTION"], 15.3, Hidden),
			spaceWindow = ns.OptionsSpacer(15.6, Hidden),
			locked = Toggle("locked", L["BUFF_WINDOW_LOCK"], L["BUFF_WINDOW_LOCK_DESCRIPTION"], 16),
			space7 = ns.OptionsSpacer(17, Hidden),
			hideInCombat = Toggle(
				"hideInCombat",
				L["BUFF_WINDOW_HIDE_IN_COMBAT"],
				L["BUFF_WINDOW_HIDE_IN_COMBAT_DESCRIPTION"],
				18
			),
			space8 = ns.OptionsSpacer(19, Hidden),

			headerKeys = ns.OptionsHeader(L["BUFF_KEYS_HEADER"], 20, Hidden),
			space9 = ns.OptionsSpacer(21, Hidden),
			descKeys = ns.OptionsDesc(L["BUFF_KEYS_DESCRIPTION"], 21.3, Hidden),
			spaceKeys = ns.OptionsSpacer(21.6, Hidden),
			keyLabel = ns.OptionsRowLabel(L["BUFF_KEY"], 22, nil, Hidden),
			key = KeyBinding(ns.BUFF_KEY_COMMAND, L["BUFF_KEY_DESCRIPTION"], 22.1),
			keyMacroLabel = keyMacro.label,
			keyMacro = keyMacro.box,
			space10 = ns.OptionsSpacer(23, Hidden),
		},
	}

	--[[
	    One toggle per class this client has, each with the game's class icon
	    beside its name, flowing three to a row in an unnamed inline group.
	    Unset reads as ticked, so a class the profile has never seen shows the
	    window.
	]]
	for index, class in ipairs(ns.OptionsClassList()) do
		options.args.classes.args[class] = {
			type = "toggle",
			name = ns.OptionsClassName(class),
			desc = L["BUFF_WINDOW_CLASS_DESCRIPTION"],
			image = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES",
			imageCoords = CLASS_ICON_TCOORDS[class],
			width = "normal",
			order = index,
			get = function()
				return Settings().showClasses[class] ~= false
			end,
			set = function(_, value)
				Settings().showClasses[class] = value
				ns.RefreshBuffWindow()
			end,
		}
	end

	return options
end
