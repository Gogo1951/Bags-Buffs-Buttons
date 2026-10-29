local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local LabelAndValue, AutoShotLabel = ns.MenuLabelAndValue, ns.MenuAutoShotLabel
local DESCRIPTIONS, NOTES = ns.MENU_DESCRIPTIONS, ns.MENU_NOTES
local COMBAT, REPEAT, FIRST, ERRORS = ns.MENU_COMBAT, ns.MENU_REPEAT, ns.MENU_FIRST, ns.MENU_ERRORS

--[[
	A page macro's right-click options menu, opened from its button on the page (Features/Spellbook/Macro-Button.lua).
	What the macro's kind is for comes first, as checkboxes: Cast At Cursor on Blizzard, the pet's ability on a
	summon, the stance a spell needs, Never Turn Off on a form, the wand and the pet on a nuke. Then Target,
	Grouped Spells, Rank, Conditionals (a button opening its panel) and the four groups (When, First, Then, Error Messages), each a submenu button with what is on in it on the right, by
	its arrow; then the actions, and the macro text in a submenu of its own. Every option explains itself in its tooltip. The options themselves live in
	Features/Spellbook/Macro-Options.lua. Its tooltips, submenu layout and option tables are shared with a category's
	menu, in Features/Spellbook/Menu-Utilities.lua.
]]

-- "<label> // <macro name>", the heading of the macro's tooltip block
function ns.MacroHeading(label, macro)
	return GetColor("INFO")
		.. label
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//|r "
		.. GetColor("TEXT")
		.. (macro.label or macro.name)
		.. "|r"
end

-- the classes whose enemy spells offer Start Pet Attack at the top, since their pet is always out
local PET_CLASSES = { HUNTER = true, WARLOCK = true }

--[[
	Lays text out in a menu title's font string as a left-aligned block width wide, wrapping as it needs, and
	returns the block's size for the menu to take. The menu gives a title's text a fixed 20 high, which
	would cut it to one line, so the height is freed before the text is measured.
]]
local function TextBlock(fontString, text, width)
	width = math.ceil(width)
	fontString:SetJustifyH("LEFT")
	fontString:SetWordWrap(true)
	if fontString.SetMaxLines then
		fontString:SetMaxLines(0)
	end
	fontString:SetWidth(width)
	fontString:SetHeight(0)
	fontString:SetText(text)
	local height = math.ceil(fontString:GetStringHeight())
	fontString:SetHeight(height)
	return width, height
end

--[[
	What is on in a group, its value: "In Combat" for one, "2 Options" for more, nil for none, so a group left
	alone says nothing.
]]
local function GroupValue(on)
	if #on == 0 then
		return nil
	end
	return #on == 1 and on[1] or L["MENU_OPTIONS_COUNT"]:format(#on)
end

--[[
	The macro text's lines, for the Macro Text submenu, with pipes escaped so the text shows as written. The
	tag line is left out, though the length counts it.
]]
local function BodyLines(macro)
	local lines = {}
	for line in (ns.UntaggedBody(macro.body) .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = line:gsub("|", "||")
	end
	return lines
end

--[[
	The options a macro's kind is for, shown at the top as checkboxes, as { key, label }: Cast At Cursor
	(who it casts on is the Target submenu's), the spell's own extras (pet ability, stance, Never Turn Off) and, on an enemy spell,
	the wand or Auto Shot and, for a class with a pet, Start Pet Attack.
]]
local function FeaturedOptions(macro)
	local featured = {}
	local function add(key, label)
		if ns.OffersOption(macro, key) then
			featured[#featured + 1] = { key, label }
		end
	end
	add("cursor", L["MENU_CAST_AT_CURSOR"])
	if macro.petAbility then
		add("pet", L["MENU_CAST_IF_SUMMONED"]:format(macro.petAbility))
	end
	if macro.stances then
		add("stance", L["MENU_SWITCH_TO"]:format(macro.stances[1]))
	end
	add("noToggle", L["MENU_NEVER_TURN_OFF"])
	if macro.kind == "enemy" then
		if ns.AutoShotLabelKey() then
			add("autoShot", AutoShotLabel())
		end
		if PET_CLASSES[select(2, UnitClass("player"))] then
			add("petAttack", L["MENU_START_PET_ATTACK"])
		end
	end
	return featured
end

-- The tooltip of a featured option that has no explanation of its own in DESCRIPTIONS.
local function FeaturedTip(element, macro, key, label)
	if key == "pet" then
		SetTip(element, label, L["MENU_PET_DESCRIPTION"]:format(macro.petFamily, macro.petAbility))
	elseif key == "stance" then
		SetTip(element, label, L["MENU_STANCE_DESCRIPTION"]:format(macro.stances[1]))
	else
		OptionTip(element, key, label)
	end
end

--[[
	Makes this macro's options its kind's defaults, its target priority among them; read every value first,
	since a default moves what follows it.
]]
local function MakeDefault(macro)
	if ns.OffersTargetPriority(macro) then
		ns.MakeTargetPriorityDefault(macro)
	end
	local values = {}
	for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
		if ns.OffersOption(macro, key) then
			values[key] = ns.IsOptionOn(macro, key)
		end
	end
	for key, on in pairs(values) do
		ns.SetKindDefault(macro.kind, key, on)
		ns.ClearOwnSetting(macro, key)
	end
	ns:RefreshMacros()
	ns:PrintMessage(L["MENU_DEFAULT_SET"]:format(L[ns.KindRow(macro.kind).labelKey]))
end

--[[
	Every spell macro has a menu. A focus copy's menu only removes it. The
	menu stays open while options change: the game's checkboxes refresh it by default, and the radio choices
	ask it to, so every label and the macro text redraw in place.
]]
function ns.ShowMacroMenu(button)
	local macro = button.macro
	if not ns.HasOptions(macro) then
		return
	end
	local page = button.page
	-- runs a setter on the macro and rebuilds the page, which rewrites the macro and its focus copy
	local function change(set)
		set()
		ns.RefreshSpellbookPage(page)
	end

	MenuUtil.CreateContextMenu(button, function(_, root)
		root:CreateTitle(
			"|T"
				.. (macro.icon or ns.QUESTION_MARK_ICON)
				.. ":16|t "
				.. GetColor("TITLE")
				.. (macro.label or macro.name)
				.. "|r"
		)
		root:CreateDivider()

		-- a checkbox turning an option on or off, with its tooltip
		local function checkbox(menu, key, label)
			local element = menu:CreateCheckbox(label, function()
				return ns.IsOptionOn(macro, key)
			end, function()
				change(function()
					ns.ToggleOption(macro, key)
				end)
			end)
			OptionTip(element, key, label)
			return element
		end
		-- a choice of one: radio buttons that keep the menu open
		local function radio(menu, label, isOn, set, tip, note)
			local element = menu:CreateRadio(label, isOn, function()
				change(set)
				return MenuResponse.Refresh
			end)
			SetTip(element, label, tip, note)
			return element
		end
		--[[
			a submenu whose label shows what is on in it, set again each time the menu redraws; onLabels lists
			the labels of what is on
		]]
		local function group(labelKey, onLabels)
			local menu = root:CreateButton(L[labelKey])
			menu:AddInitializer(function(frame)
				local value = GroupValue(onLabels())
				return LabelAndValue(frame, L[labelKey], value and GetColor("INFO") .. value .. "|r")
			end)
			return menu
		end
		-- the macro text, its length (red over what a macro holds) as the value, the lines in the submenu
		local function addMacroText()
			local menu = root:CreateButton(L["MACRO_TEXT"])
			menu:AddInitializer(function(frame)
				local length = #macro.body
				return LabelAndValue(
					frame,
					L["MACRO_TEXT"],
					GetColor(length > ns.MACRO_BODY_MAX_LENGTH and "OFF" or "HELP")
						.. L["MENU_MACRO_LENGTH"]:format(length, ns.MACRO_BODY_MAX_LENGTH)
						.. "|r"
				)
			end)
			-- the lines as one block, sized to the widest line and the line count
			menu:CreateTitle(""):AddInitializer(function(frame)
				local fontString, lines, width = frame.fontString, BodyLines(macro), 1
				for _, line in ipairs(lines) do
					fontString:SetText(line)
					width = math.max(width, fontString:GetUnboundedStringWidth())
				end
				return TextBlock(fontString, GetColor("TEXT") .. table.concat(lines, "\n") .. "|r", width)
			end)
		end

		--[[
			Delete, with how many action bar slots hold the macro; one in use asks first. It deletes the WoW
			macro and resets every option, so the macro starts over (a Duplicate copy leaves the page).
		]]
		local function addDelete()
			local index = ns.FindMacroIndex(macro)
			local used = index ~= 0 and ns.MacroBarCount(index) or 0
			local label = used == 0 and L["MENU_DELETE"]
				or used == 1 and L["MENU_DELETE_USED_ONE"]
				or L["MENU_DELETE_USED"]:format(used)
			local element = root:CreateButton(label, function()
				local function delete()
					ns.DeletePageMacro(macro)
					ns.RefreshSpellbookPage(page)
				end
				if used > 0 then
					ns.ConfirmDelete(macro.label or macro.name, delete)
				else
					delete()
				end
			end)
			SetTip(
				element,
				L["MENU_DELETE"],
				L[macro.copy and "MENU_DELETE_COPY_DESCRIPTION" or "MENU_DELETE_DESCRIPTION"]
			)
		end

		if macro.focus then
			root:CreateButton(L["MENU_REMOVE_FOCUS"], function()
				change(function()
					ns.SetOption(macro, "focus", false)
				end)
			end)
			root:CreateDivider()
			addMacroText()
			return
		end

		-- what this kind of spell is for, one click away
		local featured = FeaturedOptions(macro)
		local isFeatured = {}
		for _, option in ipairs(featured) do
			local key, label = option[1], option[2]
			isFeatured[key] = true
			local element = root:CreateCheckbox(label, function()
				return ns.IsOptionOn(macro, key)
			end, function()
				change(function()
					ns.ToggleOption(macro, key)
				end)
			end)
			FeaturedTip(element, macro, key, label)
		end

		-- each section below the checkboxes starts with a divider, once something is above it
		local above = #featured > 0
		local function section()
			if above then
				root:CreateDivider()
			end
			above = true
		end

		--[[
			Target: who the macro tries, in turn, as up to three priorities, each a submenu of the units it can
			pick. A lower priority leaves out the units a higher one took, and Third waits for Second. The menu
			can't drop an entry once drawn, so a pick reopens it, drawn afresh.
		]]
		if ns.OffersTargetPriority(macro) then
			section()
			local function unitLabel(unit)
				for _, row in ipairs(ns.TARGET_UNITS) do
					if row[1] == unit then
						return L[row[2]]
					end
				end
			end
			local targetMenu = group("MENU_GROUP_TARGET", function()
				local on = {}
				if ns.HasTargetPriority(macro) then
					local labels = {}
					for i, unit in ipairs(ns.TargetPriority(macro)) do
						labels[i] = unitLabel(unit)
					end
					on[1] = table.concat(labels, ", ")
				end
				return on
			end)
			local list = ns.TargetPriority(macro)
			local function pick(place, unit)
				return function()
					change(function()
						ns.SetTargetPriorityUnit(macro, place, unit)
					end)
					C_Timer.After(0, function()
						ns.ShowMacroMenu(button)
					end)
					return MenuResponse.CloseAll
				end
			end
			-- an empty priority after the last to fill, but none after Self, since nothing after the player is ever tried
			local places = #list + (list[#list] == "player" and 0 or 1)
			for place = 1, math.min(places, ns.TARGET_PRIORITY_SLOTS) do
				local placeKey = "MENU_PRIORITY_" .. place
				local slotMenu = targetMenu:CreateButton(L[placeKey])
				slotMenu:AddInitializer(function(frame)
					local unit = ns.TargetPriority(macro)[place]
					return LabelAndValue(
						frame,
						L[placeKey],
						GetColor("INFO") .. (unitLabel(unit) or L["MENU_UNIT_NONE"]) .. "|r"
					)
				end)
				SetTip(slotMenu, L[placeKey], L["MENU_PRIORITY_DESCRIPTION"])
				local taken = {}
				for i = 1, place - 1 do
					taken[list[i]] = true
				end
				if place > 1 then
					local element = slotMenu:CreateRadio(L["MENU_UNIT_NONE"], function()
						return ns.TargetPriority(macro)[place] == nil
					end, pick(place, nil))
					SetTip(element, L["MENU_UNIT_NONE"], L["MENU_UNIT_NONE_DESCRIPTION"])
				end
				for _, row in ipairs(ns.TARGET_UNITS) do
					local unit = row[1]
					if not taken[unit] and ns.KindOffersUnit(macro.kind, unit) then
						local element = slotMenu:CreateRadio(L[row[2]], function()
							return ns.TargetPriority(macro)[place] == unit
						end, pick(place, unit))
						SetTip(element, L[row[2]], L[row[2] .. "_DESCRIPTION"])
					end
				end
			end
		end

		--[[
			Grouped Spells: Right-Click For the group (or single) version, and the spells of its SPELL_GROUPS
			group, each a checkbox, the ones not learned yet in gray, so they can be ticked ahead of training
		]]
		local rightClick = ns.RightClickSpell(macro)
		local offersRightClick = ns.OffersOption(macro, "groupVersion")
		if offersRightClick or ns.OffersGroupedSpells(macro) then
			section()
			local groupedMenu = group("MENU_GROUP_GROUPED", function()
				local on = ns.IsOptionOn(macro, "groupVersion") or ns.IsGrouped(macro)
				return on and { L["MENU_ENABLED"] } or {}
			end)
			if offersRightClick then
				local label = L["MENU_RIGHT_CLICK_FOR"]:format(rightClick)
				local element = groupedMenu:CreateCheckbox(label, function()
					return ns.IsOptionOn(macro, "groupVersion")
				end, function()
					change(function()
						ns.ToggleOption(macro, "groupVersion")
					end)
				end)
				-- off while a Conditionals row checks Right-Click, which has the right-click already (see ns.ConditionBlockReason)
				local taken = not ns.IsOptionOn(macro, "groupVersion") and ns.ConditionalsUseRightClick(macro)
				SetTip(
					element,
					label,
					L["MENU_GROUP_VERSION_DESCRIPTION"]:format(rightClick, macro.name),
					taken and L["MENU_RIGHT_CLICK_TAKEN"] or nil
				)
				if taken then
					element:SetEnabled(false)
				end
			end
			if ns.OffersGroupedSpells(macro) then
				if offersRightClick then
					groupedMenu:CreateDivider()
				end
				for _, member in ipairs(macro.groupMembers) do
					local name = member.name
					local icon = C_Spell.GetSpellTexture(name)
					local label = (icon and "|T" .. icon .. ":16|t " or "")
						.. (member.learned and name or GetColor("MUTED") .. name .. "|r")
					local element = groupedMenu:CreateCheckbox(label, function()
						return ns.IsGroupedSpellOn(macro, name)
					end, function()
						change(function()
							ns.ToggleGroupedSpell(macro, name)
						end)
					end)
					SetTip(
						element,
						name,
						L["MENU_GROUPED_SPELL_DESCRIPTION"]:format(name),
						not member.learned and L["MENU_GROUPED_SPELL_NOT_LEARNED"] or nil
					)
				end
			end
		end

		-- Rank: Highest, Dynamic (a friendly spell's Dynamic Rank), or a known rank; the rest in red, unclickable
		if ns.OffersFixedRank(macro) or ns.OffersTargetRank(macro) then
			section()
			local rankMenu = group("MENU_GROUP_RANK", function()
				local rank = ns.AbilityRank(macro)
				return rank and { rank == "targetRank" and L["MENU_RANK_DYNAMIC"] or rank } or {}
			end)
			local function isRank(choice)
				return function()
					return ns.AbilityRank(macro) == choice
				end
			end
			local function setRank(choice)
				return function()
					ns.SetAbilityRank(macro, choice)
				end
			end
			radio(rankMenu, L["MENU_HIGHEST"], isRank(nil), setRank(nil), L["MENU_HIGHEST_DESCRIPTION"])
			if ns.OffersTargetRank(macro) then
				radio(
					rankMenu,
					L["MENU_RANK_DYNAMIC"],
					isRank("targetRank"),
					setRank("targetRank"),
					L[DESCRIPTIONS.targetRank],
					L[NOTES.targetRank]
				)
			end
			if macro.ranks then
				rankMenu:CreateDivider()
			end
			local all = {}
			for _, list in ipairs({ macro.ranks or {}, macro.unknownRanks or {} }) do
				for _, rank in ipairs(list) do
					all[#all + 1] = rank
				end
			end
			table.sort(all, function(a, b) -- up from Rank 1
				return a.level < b.level
			end)
			for _, rank in ipairs(all) do
				if rank.unknown then
					local label = GetColor("OFF") .. L["MENU_RANK_LEARN_LEVEL"]:format(rank.text, rank.level) .. "|r"
					rankMenu:CreateRadio(label, isRank(rank.text), function() end):SetEnabled(false)
				else
					radio(
						rankMenu,
						rank.text,
						isRank(rank.text),
						setRank(rank.text),
						L["MENU_FIXED_RANK_DESCRIPTION"]:format(rank.text)
					)
				end
			end
		end

		--[[
			Conditionals: opens the panel docked beside the window (Features/Spellbook/Conditionals-Panel.lua), where
			the rows are set; the value names the one set ("Shift: Frost Nova") or counts them
		]]
		if ns.OffersConditionals(macro) then
			section()
			local element = root:CreateButton(L["MENU_GROUP_CONDITIONALS"], function()
				ns.ShowConditionalsPanel(macro, page)
			end)
			element:AddInitializer(function(frame)
				local value = GroupValue(ns.ConditionalSummaries(macro))
				return LabelAndValue(frame, L["MENU_GROUP_CONDITIONALS"], value and GetColor("INFO") .. value .. "|r")
			end)
			SetTip(element, L["MENU_GROUP_CONDITIONALS"], L["MENU_CONDITIONALS_DESCRIPTION"])
		end
		if above then
			root:CreateDivider()
		end

		-- When: the combat check, how often it casts, and when it does nothing
		local whenMenu = group("MENU_GROUP_WHEN", function()
			local on = {}
			for _, choice in ipairs(COMBAT) do
				if choice[1] and ns.CombatCheck(macro) == choice[1] then
					on[#on + 1] = L[choice[2]]
				end
			end
			for _, choice in ipairs(REPEAT) do
				if choice[1] and ns.OffersOption(macro, "oncePerTarget") and ns.RepeatRule(macro) == choice[1] then
					on[#on + 1] = L[choice[2]]
				end
			end
			for _, key in ipairs({ "stopIfChanneling", "stopIfStealthed" }) do
				if ns.IsOptionOn(macro, key) then
					on[#on + 1] = L[key == "stopIfChanneling" and "MENU_STOP_IF_CHANNELING" or "MENU_STOP_IF_STEALTHED"]
				end
			end
			return on
		end)
		for _, choice in ipairs(COMBAT) do
			local check = choice[1]
			radio(whenMenu, L[choice[2]], function()
				return ns.CombatCheck(macro) == check
			end, function()
				ns.SetCombatCheck(macro, check)
			end, L[choice[3]])
		end
		if ns.OffersOption(macro, "oncePerTarget") then
			whenMenu:CreateDivider()
			for _, choice in ipairs(REPEAT) do
				local rule = choice[1]
				radio(whenMenu, L[choice[2]], function()
					return ns.RepeatRule(macro) == rule
				end, function()
					ns.SetRepeatRule(macro, rule)
				end, L[choice[3]])
			end
		end
		whenMenu:CreateDivider()
		checkbox(whenMenu, "stopIfChanneling", L["MENU_STOP_IF_CHANNELING"])
		checkbox(whenMenu, "stopIfStealthed", L["MENU_STOP_IF_STEALTHED"])

		--[[
			First: what runs before the cast, the items last, each labelled with its place in the order. The
			slots are the equipped on-use items, plus any slot already ticked so it can be unticked after a gear
			swap.
		]]
		local slots = {}
		if ns.OffersUseItems(macro) then
			local listed = {}
			for _, usable in ipairs(ns.UsableSlots()) do
				slots[#slots + 1], listed[usable.slot] = usable.slot, true
			end
			for _, slot in ipairs(ns.UseItemSlots(macro)) do
				if not listed[slot] then
					slots[#slots + 1] = slot
				end
			end
		end
		local firstOffered = #slots > 0
		for _, option in ipairs(FIRST) do
			firstOffered = firstOffered or ns.OffersOption(macro, option[1])
		end
		if firstOffered then
			local firstMenu = group("MENU_GROUP_FIRST", function()
				local on = {}
				for _, option in ipairs(FIRST) do
					if ns.IsOptionOn(macro, option[1]) then
						on[#on + 1] = L[option[2]]
					end
				end
				for _, slot in ipairs(ns.UseItemSlots(macro)) do
					on[#on + 1] = ns.SlotName(slot)
				end
				return on
			end)
			local offered = false
			for _, option in ipairs(FIRST) do
				if ns.OffersOption(macro, option[1]) then
					checkbox(firstMenu, option[1], L[option[2]])
					offered = true
				end
			end
			if offered and #slots > 0 then
				firstMenu:CreateDivider()
			end
			for _, slot in ipairs(slots) do
				local element = firstMenu:CreateCheckbox(ns.SlotLabel(slot), function()
					return ns.IsUsingSlot(macro, slot) ~= nil
				end, function()
					change(function()
						ns.ToggleUseSlot(macro, slot)
					end)
				end)
				-- the icon, and the slot's place in the order, set each time the menu redraws
				element:AddInitializer(function(frame)
					local at = ns.IsUsingSlot(macro, slot)
					local icon = GetInventoryItemTexture("player", slot)
					frame.fontString:SetTextToFit(
						(icon and "|T" .. icon .. ":16|t " or "")
							.. ns.SlotLabel(slot)
							.. (at and " (" .. at .. ")" or "")
					)
				end)
				SetTip(element, ns.SlotLabel(slot), L["MENU_USE_ITEM_DESCRIPTION"])
			end
		end

		-- Then: what runs after the cast, less what sits at the top already
		local THEN = {
			{ "startAttack", L["MENU_START_AUTO_ATTACK"] },
			{ "autoShot", ns.AutoShotLabelKey() and AutoShotLabel() },
			{ "petAttack", L["MENU_START_PET_ATTACK"] },
		}
		local thenOptions = {}
		for _, option in ipairs(THEN) do
			if option[2] and not isFeatured[option[1]] and ns.OffersOption(macro, option[1]) then
				thenOptions[#thenOptions + 1] = option
			end
		end
		if #thenOptions > 0 then
			local thenMenu = group("MENU_GROUP_THEN", function()
				local on = {}
				for _, option in ipairs(thenOptions) do
					if ns.IsOptionOn(macro, option[1]) then
						on[#on + 1] = option[2]
					end
				end
				return on
			end)
			for _, option in ipairs(thenOptions) do
				checkbox(thenMenu, option[1], option[2])
			end
		end

		local errorsMenu = group("MENU_GROUP_ERRORS", function()
			local on = {}
			for _, option in ipairs(ERRORS) do
				if ns.IsOptionOn(macro, option[1]) then
					on[#on + 1] = L[option[2]]
				end
			end
			return on
		end)
		for _, option in ipairs(ERRORS) do
			checkbox(errorsMenu, option[1], L[option[2]])
		end

		root:CreateDivider()
		addMacroText()

		--[[
			the actions: Make Default changes a kind's defaults, Duplicate and the focus copy add a macro to the
			page, and Delete takes this one's WoW macro off the bars (and a Duplicate copy off the page)
		]]
		root:CreateDivider()
		local kindRow = macro.kind and ns.KindRow(macro.kind)
		if kindRow then
			local label = L["MENU_MAKE_DEFAULT"]:format(L[kindRow.labelKey])
			local element = root:CreateButton(label, function()
				MakeDefault(macro)
			end)
			SetTip(element, label, L["MENU_MAKE_DEFAULT_DESCRIPTION"]:format(L[kindRow.labelKey]))
		end
		if ns.OffersDuplicate(macro) then
			local element = root:CreateButton(L["MENU_DUPLICATE"], function()
				ns.DuplicateMacro(macro)
				ns.RefreshSpellbookPage(page)
			end)
			SetTip(element, L["MENU_DUPLICATE"], L["MENU_DUPLICATE_DESCRIPTION"])
		end
		if ns.OffersOption(macro, "focus") then
			local on = ns.IsOptionOn(macro, "focus")
			local element = root:CreateButton(L[on and "MENU_REMOVE_FOCUS" or "MENU_ADD_FOCUS"], function()
				change(function()
					ns.ToggleOption(macro, "focus")
				end)
			end)
			SetTip(element, L[on and "MENU_REMOVE_FOCUS" or "MENU_ADD_FOCUS"], L["MENU_FOCUS_DESCRIPTION"])
		end
		addDelete()
	end)
end
