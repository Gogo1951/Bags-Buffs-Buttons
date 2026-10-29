local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    The whisper row: a caption-sized label, the message box and the Reset button,
    together one row, so a full sentence stays readable while it is being edited.
    The emote and icon rows have no button, so their dropdowns take the rest of
    the row.
]]
local WHISPER_LABEL_WIDTH = 0.9
local RESET_WIDTH = 0.5
local WHISPER_INPUT_WIDTH = ns.OPTIONS_ROW_WIDTH - WHISPER_LABEL_WIDTH - RESET_WIDTH
local EMOTE_SELECT_WIDTH = ns.OPTIONS_ROW_WIDTH - WHISPER_LABEL_WIDTH

--------------------------------------------------------------------------------
-- Options Table
--------------------------------------------------------------------------------

--[[
    The dropdown's contents: every emote the client has, plus an explicit "none",
    ordered by slash command. Built from ns.GetEmoteCatalog rather than
    Data.EMOTES -- these buttons are a free choice from the whole client set, not
    from the twelve the praise panels curate.

    Cached: the catalog cannot change during a session, and this table is rebuilt
    on every panel open otherwise.
]]
local emoteValues, emoteSorting
local function EmoteChoices()
	if not emoteValues then
		emoteValues = { [""] = L["BUTTON_EMOTE_NONE"] }
		emoteSorting = { "" }
		for _, emote in ipairs(ns.GetEmoteCatalog()) do
			emoteValues[emote.token] = emote.command
			emoteSorting[#emoteSorting + 1] = emote.token
		end
	end
	return emoteValues, emoteSorting
end

--[[
    The Icon dropdown: the macros' own icon as Default first, then this
    client's ns.THANK_YOU_MACRO_ICONS in list order, each its picture alone, since
    the client gives an icon no name. Values are texture file IDs, the same number
    the macro is created with. Cached: the list can't change during a session.
]]
local iconValues, iconSorting
local function IconChoices()
	if not iconValues then
		local function Picture(texture)
			return "|T" .. texture .. ":16|t"
		end
		local default = Data.THANK_YOU_DEFAULT_ICON
		iconValues = { [default] = Picture(default) .. " " .. L["BUTTON_ICON_DEFAULT"] }
		iconSorting = { default }
		for _, icon in ipairs(ns.THANK_YOU_MACRO_ICONS) do
			iconValues[icon[1]] = Picture(icon[1])
			iconSorting[#iconSorting + 1] = icon[1]
		end
	end
	return iconValues, iconSorting
end

--[[
    One section per entry in Data.THANK_YOU_BUTTONS, all built from the same
    block. Orders are spaced a hundred apart so a section owns its own range and
    adding a control to one never renumbers the next.

    Every control binds through the button's own profile key, and Reset restores
    that button's declared default rather than a hard-coded string -- which is
    what keeps button 1 resetting to the friendly default text while buttons 2
    through 5 reset to empty, with the defaults file remaining the only place
    that decides.
]]
local function AddButtonSection(args, button, index)
	local key = button.profileKey
	local base = index * 100

	local function config()
		return ns.db.global[key]
	end

	--[[
	    Everything below the macro toggle follows it, so a switched-off button
	    collapses to one line instead of five rows nobody is currently using. The
	    settings are hidden, not disabled: this button's slash command still fires
	    with whatever is stored, macro or no macro.
	]]
	local function sectionHidden()
		return not config().createMacro
	end

	--[[
	    Spacer on BOTH sides of the header: below it separates the rule from the
	    first control, above it keeps the rule off the previous section's emote box
	    (and, for button 1, off the panel description).
	]]
	args["space_top" .. index] = ns.OptionsSpacer(base)
	args["header" .. index] = ns.OptionsHeader(string.format(L["BUTTON_SECTION"], index), base + 1)
	args["space_a" .. index] = ns.OptionsSpacer(base + 2)

	args["createMacro" .. index] = {
		type = "toggle",
		--[[
		    The macro's name is in the label, not just the tooltip: with five of
		    these stacked, "which macro is this one?" should not need a hover.
		]]
		name = string.format(L["BUTTON_MACRO_ENABLE"], button.macroName),
		desc = string.format(L["BUTTON_MACRO_ENABLE_DESCRIPTION"], GetColor("TITLE") .. button.macroName .. "|r"),
		width = "full",
		order = base + 3,
		get = function()
			return config().createMacro
		end,
		set = function(_, value)
			config().createMacro = value
			--[[
			    The toggle owns the macro's existence in both directions: ticking it
			    creates the macro now rather than next login, unticking removes it.
			    Leaving a switched-off button's macro sitting on the bars would make
			    the checkbox a lie.
			]]
			if value then
				if ns.CreateAutoMacro then
					ns:CreateAutoMacro()
				end
			elseif ns.DeleteAutoMacro then
				ns:DeleteAutoMacro(button)
			end
		end,
	}

	args["space_b" .. index] = ns.OptionsSpacer(base + 4, sectionHidden)
	args["whisperLabel" .. index] =
		ns.OptionsRowLabel(L["WHISPER_MESSAGE"], base + 5, WHISPER_LABEL_WIDTH, sectionHidden)
	args["whisperMsg" .. index] = {
		type = "input",
		name = "",
		desc = L["BUTTON_WHISPER_DESCRIPTION"],
		width = WHISPER_INPUT_WIDTH,
		order = base + 6,
		hidden = sectionHidden,
		get = function()
			return config().message
		end,
		set = function(_, value)
			config().message = ns.TrimToBytes(value or "", ns.CHAT_MESSAGE_MAX_LENGTH)
		end,
	}
	args["resetMsg" .. index] = {
		type = "execute",
		name = L["WHISPER_MESSAGE_RESET"],
		desc = L["WHISPER_MESSAGE_RESET_DESCRIPTION"],
		width = RESET_WIDTH,
		order = base + 7,
		hidden = sectionHidden,
		func = function()
			config().message = ns.DATABASE_DEFAULTS.global[key].message
		end,
	}

	-- What the target receives: the stored message, unbranded, exactly as ns:Whisper sends it; none while it is empty.
	local function exampleHidden()
		return sectionHidden() or (config().message or "") == ""
	end
	args["whisperExampleSpace" .. index] = ns.OptionsSpacer(base + 7.5, exampleHidden)
	args["whisperExample" .. index] = ns.OptionsWhisperExample(base + 7.6, function()
		return config().message or ""
	end, exampleHidden)
	args["space_c" .. index] = ns.OptionsSpacer(base + 8, sectionHidden)

	-- The icon row closes the section, under the emote row or grid.
	args["space_d" .. index] = ns.OptionsSpacer(base + 11, sectionHidden)
	args["iconLabel" .. index] = ns.OptionsRowLabel(L["BUTTON_ICON"], base + 12, WHISPER_LABEL_WIDTH, sectionHidden)
	local choices, choiceOrder = IconChoices()
	args["iconSelect" .. index] = {
		type = "select",
		name = "",
		desc = L["BUTTON_ICON_DESCRIPTION"],
		width = EMOTE_SELECT_WIDTH,
		order = base + 13,
		hidden = sectionHidden,
		values = choices,
		sorting = choiceOrder,
		get = function()
			-- What the macro actually wears: an icon this client's list lacks shows as Default rather than blank.
			return ns.GetThankYouIcon(config())
		end,
		set = function(_, value)
			config().macroIcon = value
			ns.ReconcileMacros()
		end,
	}

	--[[
	    A single-emote button gets one dropdown instead of the checklist: there is
	    nothing to randomise between, so a grid of checkboxes would be the wrong
	    control for the choice being made.
	]]
	if button.singleEmote then
		local values, sorting = EmoteChoices()
		args["emoteLabel" .. index] =
			ns.OptionsRowLabel(L["BUTTON_EMOTE"], base + 9, WHISPER_LABEL_WIDTH, sectionHidden)
		args["emoteSelect" .. index] = {
			type = "select",
			name = "",
			desc = L["BUTTON_EMOTE_DESCRIPTION"],
			width = EMOTE_SELECT_WIDTH,
			order = base + 10,
			hidden = sectionHidden,
			values = values,
			sorting = sorting,
			get = function()
				--[[
				    A token this client does not have shows as "none" rather than
				    blank: profiles travel between flavours, and an emote that only
				    exists on a later one would otherwise leave the box empty and
				    unexplained.
				]]
				local current = config().emote
				return (current and ns.IsClientEmote(current)) and current or ""
			end,
			set = function(_, value)
				config().emote = value
			end,
		}
		return
	end

	-- The shared grid hides on emotesEnabled, which a button doesn't carry, so it follows the macro toggle instead.
	local emoteGroup = ns.DefineEmoteGroup(config, base + 9)
	emoteGroup.hidden = sectionHidden
	args["emoteGroup" .. index] = emoteGroup
end

function ns.BuildThankYouButtonOptions()
	local options = {
		name = L["TAB_THANK_YOU_BUTTON"],
		type = "group",
		args = {
			descIntro = ns.OptionsDesc(L["BUTTON_DESCRIPTION"], 1),
		},
	}

	for index, button in ipairs(Data.THANK_YOU_BUTTONS) do
		AddButtonSection(options.args, button, index)
	end

	return options
end
