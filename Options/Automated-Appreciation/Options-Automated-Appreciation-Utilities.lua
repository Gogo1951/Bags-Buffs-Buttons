local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetSpellName = C_Spell.GetSpellName
local GetSpellDescription = C_Spell.GetSpellDescription
local GetSpellTexture = C_Spell.GetSpellTexture

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    The title drawn at the top of a sub-panel: "Teammate Buffs > Tracked
    Abilities", so it is always clear where you are. Only the title carries the
    parent; the settings tree already shows it by nesting, and the tree label is
    the plain name passed to AddToBlizOptions.
]]
function ns.SubPanelTitle(parentName, name)
	return parentName .. " > " .. name
end

--[[
    Always seconds. FormatDuration switches to minutes above 60 and rounds, which
    is right for a buff ticking down and wrong for a fixed list: it would print 89
    as "1 Minute" and 144 as "2 Minutes", two units in one dropdown.
]]
local function FormatChoice(seconds)
	return ns.FormatDuration(seconds, true)
end

-- The listed value closest to what is stored.
local function NearestChoice(value)
	local best, bestGap
	for _, choice in ipairs(Data.SECONDS_CHOICES) do
		local gap = math.abs(choice - (value or 0))
		if not bestGap or gap < bestGap then
			best, bestGap = choice, gap
		end
	end
	return best
end

--[[
    A seconds dropdown over Data.SECONDS_CHOICES.

    `get` snaps to the NEAREST listed value rather than returning what is stored.
    A saved value can sit off the scale -- 25, 47 -- and AceConfig renders a
    select whose value is missing from `values` as an empty box, which a player
    cannot fix without guessing that re-picking is what it wants. Snapping shows
    the closest real option; the stored number is left alone until they choose,
    so nobody's setting is silently rewritten by opening the panel.
]]
function ns.DefineSecondsSelect(settings, key, order, desc)
	return {
		type = "select",
		desc = desc,
		--[[
		    The right half of a label-beside-control row: the caller pairs this with
		    ns.OptionsRowLabel, the same way every other dropdown in the add-on is
		    built. A select carrying its own `name` stacks the label above itself in
		    header gold, which is not how this UI reads a setting.
		]]
		name = "",
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		sorting = Data.SECONDS_CHOICES,
		values = function()
			local values = {}
			for _, seconds in ipairs(Data.SECONDS_CHOICES) do
				values[seconds] = FormatChoice(seconds)
			end
			return values
		end,
		get = function()
			return NearestChoice(settings()[key])
		end,
		set = function(_, value)
			settings()[key] = value
		end,
	}
end

-- The player every buff panel's Example lines credit: a mage, for the Arcane Intellect and portals they name.
local SAMPLE_CLASS = "MAGE"

--[[
    The Example line under a buff panel's print toggle, hidden with it. build
    gets the sample player's class and name and returns the message body, made
    by the same builder the real print uses.
]]
function ns.DefinePrintExample(settings, order, build)
	return ns.OptionsExample(order, function()
		return { build(SAMPLE_CLASS, ns.SAMPLE_NAMES[SAMPLE_CLASS]) }
	end, function()
		return not settings().printEnabled
	end)
end

-- The Example line under a buff panel's whisper toggle, hidden with it.
function ns.DefineWhisperExample(settings, order, spellId)
	return ns.OptionsWhisperExample(order, function()
		local link = ns.GetSpellLink(spellId) or ""
		return ns:BuildAnnounceMessage("MESSAGE_WHISPER_THANKS", link)
	end, function()
		return not settings().whisperEnabled
	end)
end

-- The blank line above an Example, hidden whenever the Example is.
function ns.DefineExampleSpacer(settings, key, order)
	return ns.OptionsSpacer(order, function()
		return not settings()[key]
	end)
end

--[[
    Cut to a byte budget without splitting a multi-byte character. The cap is
    counted in bytes, not characters, because what it really protects is the
    chat line: WoW measures that in bytes too, and one ability link already
    spends a good part of it. For English the two are the same number.

    A cut landing mid-character would leave a broken tail byte that renders as a
    replacement glyph, so step back off any UTF-8 continuation byte (0x80-0xBF)
    sitting at the cut.
]]
function ns.TrimToBytes(text, maxBytes)
	if #text <= maxBytes then
		return text
	end
	local cut = maxBytes
	while cut > 0 do
		local b = text:byte(cut + 1)
		if not b or b < 128 or b >= 192 then
			break
		end
		cut = cut - 1
	end
	return text:sub(1, cut)
end

--[[
    Every class this client's data names, sorted by token: the classes this
    game version has. Count as Tanks and Buff Duty's Classes list draw from it.
]]
function ns.OptionsClassList()
	local classes = {}
	for _, list in ipairs({
		ns.TRACKED_ABILITIES,
		ns.BUFF_WINDOW_SPELLS,
		ns.BUFF_WINDOW_SELF_SPELLS,
		ns.BUFF_WINDOW_WEAPON_ENCHANTS,
	}) do
		for _, row in ipairs(list) do
			if row.class then
				classes[row.class] = true
			end
		end
	end
	local classNames = {}
	for class in pairs(classes) do
		classNames[#classNames + 1] = class
	end
	table.sort(classNames)
	return classNames
end

-- A class's name in the client's language, in its class color.
ns.OptionsClassName = ns.ClassName

--[[
    A row label naming an ability, which shows the game's own tooltip for it
    on hover, the same one an action bar shows. `hyperlink` returns
    "spell:<id>" or "item:<id>". A plain Label takes no mouse, so this one is
    an InteractiveLabel, which AceConfigDialog gives the same hover handler as
    any control, and that handler shows `tooltipHyperlink` when there is one.
]]
function ns.OptionsAbilityLabel(text, order, width, hyperlink)
	local label = ns.OptionsRowLabel(text, order, width)
	label.dialogControl = "InteractiveLabel"
	label.tooltipHyperlink = hyperlink
	return label
end

--[[
    The spell an ability's tooltip quotes: the HIGHEST id in its rank group
    that the client describes, so it reads the rank you actually cast, not rank
    1. Ids are sorted rather than trusted in data order -- rows are not
    reliably rank-ordered (Combustion is { 29977, 11129 }, Vanish
    { 1856, 1857, 27617, 26889, 44290 }). Classic holds tooltip data only for
    spells the character has known, and these panels list every class, so each
    id is requested once here and the pick is made again at every hover, when
    the text has had time to land.
]]
function ns.SpellTooltipLink(ids)
	local ranked = {}
	for i = 1, #ids do
		ranked[i] = ids[i]
		C_Spell.RequestLoadSpellData(ids[i])
	end
	table.sort(ranked)
	return function()
		for i = #ranked, 1, -1 do
			local text = GetSpellDescription(ranked[i])
			if text and text ~= "" then
				return "spell:" .. ranked[i]
			end
		end
		return "spell:" .. ranked[#ranked]
	end
end

--[[
    Hide every control on a panel behind its master switch.

    Applied to the finished args table rather than threaded through every shared
    Define* builder. The rule is positional -- everything except the intro text
    and the switch itself -- so a control added later is covered automatically
    instead of depending on someone remembering to pass a flag down.

    Existing `hidden` values are COMPOSED, not replaced. Several controls already
    hide for their own reasons (the emote grid follows its own toggle), and
    overwriting that would leave the grid showing whenever the master was on.
]]
function ns.HideAllExcept(args, isHidden, keep)
	for key, option in pairs(args) do
		if not keep[key] then
			local own = option.hidden
			if own == nil then
				option.hidden = isHidden
			else
				option.hidden = function(info)
					if isHidden(info) then
						return true
					end
					if type(own) == "function" then
						return own(info)
					end
					return own
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

function ns.OptionsFeatureToggle(feature, order, width)
	return {
		type = "toggle",
		name = L[feature.name],
		desc = L[feature.desc],
		width = width or "full",
		order = order,
		get = function()
			return ns.db.global[feature.key][feature.setting]
		end,
		set = function(_, value)
			ns.SetFeatureSwitch(feature.key, value)
		end,
	}
end

--------------------------------------------------------------------------------
-- Shared Buff-Panel Builders
--------------------------------------------------------------------------------

--[[
    Widget factories shared by the three buff panels (Stranger Buffs, Teammate
    Buffs, Service Alerts). Each panel file owns its own layout and order
    numbers, and draws its controls from here. Every factory takes a `settings` accessor returning the profile
    subtable the control binds to (ns.db.global.strangers / .teammates /
    .services), so one definition serves every panel. The watched-buff list is
    shared between Teammates and Services (ns.db.global.watchedBuffs); a given id
    only ever appears on one of the two panels.
]]

--[[
    One toggle per tracked entry. Spell entries carry a resolved name (ranks were
    already collapsed at build time); item entries carry an itemId whose name and
    icon resolve lazily, so a cold item cache fills the label in by the time the
    panel is viewed. Grouped items carry a name for the whole group, since their
    per-rank item names differ: either our own `label` (Repair Bots) or a
    `labelItem` whose client name is the group's (Soulstone, Scroll of Agility). Either way the toggle flips every watched id in the entry
    and reads its state from the first.

    `watched` is an optional accessor returning the id->bool table the toggle
    binds to; it defaults to the shared thank-you list (watchedBuffs). The
    Good News panel passes its own list, since it reuses the same ids with
    independent choices.
]]
function ns.DefineEntryToggle(entry, order, watched)
	local ids = entry.ids
	local primary = ids[1]
	local function list()
		return watched and watched() or ns.db.global.watchedBuffs
	end

	local nameField, descField, hyperlink

	if entry.itemId then
		local itemId = entry.itemId
		local groupLabel = entry.label
		local labelItem = entry.labelItem or itemId
		nameField = function()
			local shown = groupLabel or C_Item.GetItemInfo(labelItem) or L["TRACKED_ITEM_PENDING"]:format(labelItem)
			local texture = C_Item.GetItemIconByID(itemId)
			if texture then
				return "|T" .. texture .. ":16|t " .. shown
			end
			return shown
		end
		if entry.itemIds and #entry.itemIds > 1 then
			--[[
			    For a grouped toggle, list every member item (links) so the tooltip
			    spells out exactly what the single checkbox covers.
			]]
			descField = function()
				local lines = {}
				for _, id in ipairs(entry.itemIds) do
					lines[#lines + 1] = (select(2, C_Item.GetItemInfo(id))) or L["TRACKED_ITEM_PENDING"]:format(id)
				end
				return table.concat(lines, "\n")
			end
		else
			-- A lone item shows the game's own item tooltip.
			hyperlink = "item:" .. itemId
		end
	else
		local name = entry.spellName
		local displayName = name
		if primary then
			local texture = GetSpellTexture(primary)
			if texture then
				displayName = "|T" .. texture .. ":16|t " .. name
			end
		end
		nameField = displayName

		if entry.spellIds and #entry.spellIds > 1 then
			--[[
			    Grouped spells (e.g. Portals): list the members alphabetically so the
			    tooltip spells out exactly what the one checkbox covers.
			]]
			descField = function()
				local names = {}
				for _, id in ipairs(entry.spellIds) do
					names[#names + 1] = GetSpellName(id) or L["TRACKED_SPELL_PENDING"]:format(id)
				end
				table.sort(names)
				return table.concat(names, "\n")
			end
		else
			-- A lone ability, or a rank group, shows the game's own spell tooltip.
			hyperlink = ns.SpellTooltipLink(ids)
		end
	end

	return {
		type = "toggle",
		name = nameField,
		desc = descField,
		tooltipHyperlink = hyperlink,
		order = order,
		width = "full",
		get = function()
			return list()[primary]
		end,
		set = function(_, value)
			for _, id in ipairs(ids) do
				list()[id] = value
			end
		end,
	}
end

--[[
    The displayed name embeds an icon escape (|T...|t), so sorting by it would sort
    by texture path. This returns the clean, lowercased name for comparison only.
]]
local function EntrySortKey(entry)
	local name = entry.label or entry.spellName
	if not name and entry.itemId then
		name = C_Item.GetItemInfo(entry.labelItem or entry.itemId)
	end
	return (name or ""):lower()
end

--[[
    A copy of `entries` ordered alphabetically by display name, with the watched id
    breaking ties for a stable result. Item names resolve lazily, which is why the
    panels register their builders as functions (run on open, when the item cache
    is warm) rather than as prebuilt tables.
]]
function ns.SortedEntries(entries)
	local sorted = {}
	for i = 1, #entries do
		sorted[i] = entries[i]
	end
	table.sort(sorted, function(a, b)
		local keyA, keyB = EntrySortKey(a), EntrySortKey(b)
		if keyA == keyB then
			return (a.ids[1] or 0) < (b.ids[1] or 0)
		end
		return keyA < keyB
	end)
	return sorted
end

--[[
    The "Enable Sound Effects" toggle, offered by every buff panel. NOT
    full-width: its DefineSoundPreview speaker shares the row, and full-width
    would push the speaker onto its own line.
]]
function ns.DefineSoundToggle(settings, order)
	return {
		type = "toggle",
		name = L["NOTIFICATIONS_SOUND_ENABLE"],
		desc = L["NOTIFICATIONS_SOUND_DESCRIPTION"],
		order = order,
		get = function()
			return settings().soundEnabled
		end,
		set = function(_, value)
			settings().soundEnabled = value
		end,
	}
end

--------------------------------------------------------------------------------
-- Shared Praise & Notification Controls
--------------------------------------------------------------------------------

--[[
    The reaction toggles every buff panel offers, one factory each. They are
    separate rather than one block because the panels file them under different
    headers: the whisper and the emote are praise the other player sees, the
    print and the sound are notifications only you get.
]]
function ns.DefinePrintToggle(settings, order)
	return {
		type = "toggle",
		name = L["NOTIFICATIONS_PRINT_ENABLE"],
		desc = L["NOTIFICATIONS_PRINT_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return settings().printEnabled
		end,
		set = function(_, value)
			settings().printEnabled = value
		end,
	}
end

function ns.DefineWhisperToggle(settings, order)
	return {
		type = "toggle",
		name = L["PRAISE_WHISPER_ENABLE"],
		desc = L["PRAISE_WHISPER_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return settings().whisperEnabled
		end,
		set = function(_, value)
			settings().whisperEnabled = value
		end,
	}
end

function ns.DefineEmotesToggle(settings, order)
	return {
		type = "toggle",
		name = L["PRAISE_EMOTES_ENABLE"],
		desc = L["PRAISE_EMOTES_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return settings().emotesEnabled
		end,
		set = function(_, value)
			settings().emotesEnabled = value
		end,
	}
end

--[[
    Shared by the emote picker and the blank line above it, so both disappear
    together when the panel's emotes are switched off.
]]
function ns.EmotesHidden(settings)
	return function()
		return not settings().emotesEnabled
	end
end

--[[
    The emote picker: one half-width toggle per entry in Data.EMOTES, inline under
    the panel's Enable Emotes toggle and hidden along with it.
]]
function ns.DefineEmoteGroup(settings, order)
	local group = {
		type = "group",
		name = L["EMOTES_SELECT"],
		order = order,
		inline = true,
		hidden = ns.EmotesHidden(settings),
		args = {},
	}

	for i, emoteData in ipairs(Data.EMOTES) do
		local emote = emoteData.token
		group.args[emote] = {
			type = "toggle",
			name = ns.GetEmoteCommand(emote),
			desc = emoteData.desc,
			order = i,
			width = "half",
			get = function()
				return settings().emotes[emote]
			end,
			set = function(_, value)
				settings().emotes[emote] = value
			end,
		}
	end

	return group
end

--[[
    "Enable Praise Delay" and the dropdown that sets its length, offered by every
    buff panel. The delay holds back the whisper and the emote only: the print and
    the sound are your own heads-up and stay instant. The toggle takes the label
    half of the row and the dropdown the other half, so the two total one row and
    the dropdown sits clear of the caption.
]]
function ns.DefinePraiseDelayToggle(settings, order)
	return {
		type = "toggle",
		name = L["PRAISE_DELAY_ENABLE"],
		desc = L["PRAISE_DELAY_DESCRIPTION"],
		width = ns.OPTIONS_LABEL_WIDTH,
		order = order,
		get = function()
			return settings().praiseDelayEnabled
		end,
		set = function(_, value)
			settings().praiseDelayEnabled = value
		end,
	}
end

--[[
    Nothing to set while the delay is off, so the dropdown only appears with it.
    Its labels come from the client's own duration strings (ns.FormatDuration), so
    "2 seconds" reads correctly in every language without the add-on shipping a string
    per length. Data.PRAISE_DELAY_CHOICES doubles as the display order.
]]
function ns.DefinePraiseDelaySelect(settings, order)
	return {
		type = "select",
		name = "",
		desc = L["PRAISE_DELAY_LENGTH_DESCRIPTION"],
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		hidden = function()
			return not settings().praiseDelayEnabled
		end,
		sorting = Data.PRAISE_DELAY_CHOICES,
		values = function()
			local values = {}
			for _, seconds in ipairs(Data.PRAISE_DELAY_CHOICES) do
				values[seconds] = ns.FormatDuration(seconds)
			end
			return values
		end,
		get = function()
			return settings().praiseDelay
		end,
		set = function(_, value)
			settings().praiseDelay = value
		end,
	}
end

--------------------------------------------------------------------------------
-- Spell Dropdown Rows
--------------------------------------------------------------------------------

--[[
    The Off / When Missing / Under labels for a list of choices the Self-Buffs
    and Weapon Buffs panels share, "Under 5 Minutes" built from the client's
    own duration string.
]]
function ns.BuffWindowRefreshValues(choices)
	local values = {}
	for _, choice in ipairs(choices) do
		if choice == Data.SELF_REFRESH_OFF then
			values[choice] = L["BUFF_WINDOW_SELF_REFRESH_OFF"]
		elseif choice == Data.SELF_REFRESH_MISSING then
			values[choice] = L["BUFF_WINDOW_SELF_REFRESH_MISSING"]
		else
			values[choice] = L["BUFF_WINDOW_SELF_REFRESH_UNDER"]:format(D_MINUTES:format(choice))
		end
	end
	return values
end

--[[
    One spell's row inside a class's inline group: its icon and name as the
    caption, and a dropdown beside it. The Buff Duty panels build their lists
    from these, so every dropdown on them shares one x and one width -- the
    caption takes ns.OPTIONS_INLINE_LABEL_WIDTH, and a row outside a box that
    should line up with these takes ns.OPTIONS_ALIGNED_LABEL_WIDTH.

    Hovering the caption shows the spell's own game tooltip (ns.SpellTooltipLink),
    and hovering the dropdown says what it sets (`desc`).

    `select` carries the dropdown's values, sorting, get and set.
]]
function ns.DefineSpellSelectRow(args, entry, order, desc, select)
	local primary = entry.ids[1]
	local texture = GetSpellTexture(primary)
	local caption = texture and ("|T" .. texture .. ":16|t " .. entry.spellName) or entry.spellName

	args["label_" .. primary] =
		ns.OptionsAbilityLabel(caption, order, ns.OPTIONS_INLINE_LABEL_WIDTH, ns.SpellTooltipLink(entry.ids))
	args["select_" .. primary] = {
		type = "select",
		name = "",
		desc = desc,
		values = select.values,
		sorting = select.sorting,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order + 0.5,
		get = select.get,
		set = select.set,
	}
end
