local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
-- Shared with the macro's own menu (Features/Spellbook/Menu-Utilities.lua, loaded before both).
local SetTip, OptionTip = ns.MenuSetTip, ns.MenuOptionTip
local LabelAndValue, AutoShotLabel = ns.MenuLabelAndValue, ns.MenuAutoShotLabel
local DESCRIPTIONS, NOTES = ns.MENU_DESCRIPTIONS, ns.MENU_NOTES
local COMBAT, REPEAT, FIRST, ERRORS = ns.MENU_COMBAT, ns.MENU_REPEAT, ns.MENU_FIRST, ns.MENU_ERRORS

--[[
	A category's options menu, from the gear on its header, and the confirm its reset asks first. The tooltips,
	the submenu layout and the option tables it shares with a macro's own right-click menu live in
	Features/Spellbook/Menu-Utilities.lua.
]]

-- The category menu's reset, asked first; data is the reset itself, run on Yes.
StaticPopupDialogs.BAGSBUFFSBUTTONS_RESET_CATEGORY = {
	text = L["MENU_RESET_CATEGORY_CONFIRM"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(_, data)
		data()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

--[[
	A category's menu, from the gear on its header (Features/Spellbook/Spellbook-Page.lua): the right-click menu's
	options, each applied to every macro in the category that offers it, so Hide Errors can go on all of them at
	once. A checkbox is ticked, or a choice picked, only when every one of those macros has it. The spells'
	own choices (a fixed rank, the grouped spells, the pet ability, the stance, the focus copy) and the actions
	stay on each macro's own menu. A macro not on the bars yet only has its settings stored; its WoW macro is
	made with them when it is first placed. onChange runs after each change, to redraw the page.
]]
function ns.ShowCategoryMenu(owner, name, macros, onChange)
	local list = {}
	for _, macro in ipairs(macros) do
		if not macro.focus and ns.HasOptions(macro) then
			list[#list + 1] = macro
		end
	end
	if #list == 0 then
		return
	end
	-- the category's macros that pass test
	local function offering(test)
		local found = {}
		for _, macro in ipairs(list) do
			if test(macro) then
				found[#found + 1] = macro
			end
		end
		return found
	end
	local function offeringOption(key)
		return offering(function(macro)
			return ns.OffersOption(macro, key)
		end)
	end
	local function all(targets, test)
		for _, macro in ipairs(targets) do
			if not test(macro) then
				return false
			end
		end
		return true
	end
	--[[
		runs set on each macro, then redraws the page once; the redraw rebuilds every macro and rewrites the ones
		already made, so no macro is rewritten on its own first
	]]
	local function apply(targets, set)
		for _, macro in ipairs(targets) do
			set(macro)
		end
		onChange()
	end

	MenuUtil.CreateContextMenu(owner, function(_, root)
		root:CreateTitle(GetColor("TITLE") .. L["MENU_CATEGORY_TITLE"]:format(name) .. "|r")
		root:CreateDivider()

		-- a submenu button, as wide as its label and the room the single-spell menu leaves before the arrow
		local function submenu(parent, label)
			local button = parent:CreateButton(label)
			button:AddInitializer(function(frame)
				return LabelAndValue(frame, label, nil)
			end)
			return button
		end

		-- an option on every macro offering it, or nothing when none does; returns whether it was added
		local function checkbox(menu, key, label)
			local targets = offeringOption(key)
			if #targets == 0 then
				return false
			end
			local function isOn()
				return all(targets, function(macro)
					return ns.IsOptionOn(macro, key)
				end)
			end
			local element = menu:CreateCheckbox(label, isOn, function()
				local on = not isOn()
				apply(targets, function(macro)
					ns.SetOption(macro, key, on)
				end)
			end)
			OptionTip(element, key, label)
			return true
		end
		-- a choice of one for targets: picked when each of them has it, and set on all of them
		local function radio(menu, label, targets, isOn, set, tip, note)
			local element = menu:CreateRadio(label, function()
				return all(targets, isOn)
			end, function()
				apply(targets, set)
				return MenuResponse.Refresh
			end)
			SetTip(element, label, tip, note)
		end
		-- whether any of these options is offered here, before a submenu for them is drawn
		local function anyOffered(options)
			for _, option in ipairs(options) do
				if option[2] and #offeringOption(option[1]) > 0 then
					return true
				end
			end
			return false
		end

		local above = false
		for _, option in ipairs({ { "cursor", L["MENU_CAST_AT_CURSOR"] }, { "noToggle", L["MENU_NEVER_TURN_OFF"] } }) do
			above = checkbox(root, option[1], option[2]) or above
		end
		local function section()
			if above then
				root:CreateDivider()
			end
			above = true
		end

		-- Target: the unit at each place in the target priority, on every macro whose kind can pick it
		local prioritized = offering(ns.OffersTargetPriority)
		if #prioritized > 0 then
			section()
			local targetMenu = submenu(root, L["MENU_GROUP_TARGET"])
			for place = 1, ns.TARGET_PRIORITY_SLOTS do
				local placeKey = "MENU_PRIORITY_" .. place
				local slotMenu = submenu(targetMenu, L[placeKey])
				SetTip(slotMenu, L[placeKey], L["MENU_PRIORITY_DESCRIPTION"])
				if place > 1 then
					radio(slotMenu, L["MENU_UNIT_NONE"], prioritized, function(macro)
						return ns.TargetPriority(macro)[place] == nil
					end, function(macro)
						ns.SetTargetPriorityUnit(macro, place, nil)
					end, L["MENU_UNIT_NONE_DESCRIPTION"])
				end
				for _, row in ipairs(ns.TARGET_UNITS) do
					local unit = row[1]
					local targets = offering(function(macro)
						return ns.OffersTargetPriority(macro) and ns.KindOffersUnit(macro.kind, unit)
					end)
					if #targets > 0 then
						radio(slotMenu, L[row[2]], targets, function(macro)
							return ns.TargetPriority(macro)[place] == unit
						end, function(macro)
							ns.SetTargetPriorityUnit(macro, place, unit)
						end, L[row[2] .. "_DESCRIPTION"])
					end
				end
			end
		end

		-- Grouped: the right-click for each spell's group or single version
		local rightClick = offeringOption("groupVersion")
		if #rightClick > 0 then
			section()
			local groupedMenu = submenu(root, L["MENU_GROUP_GROUPED"])
			checkbox(groupedMenu, "groupVersion", L["MENU_RIGHT_CLICK_GROUP"])
		end

		-- Rank: the highest each spell knows, or Dynamic where the spell takes it
		local ranked = offering(function(macro)
			return ns.OffersFixedRank(macro) or ns.OffersTargetRank(macro)
		end)
		if #ranked > 0 then
			section()
			local rankMenu = submenu(root, L["MENU_GROUP_RANK"])
			radio(rankMenu, L["MENU_HIGHEST"], ranked, function(macro)
				return ns.AbilityRank(macro) == nil
			end, function(macro)
				ns.SetAbilityRank(macro, nil)
			end, L["MENU_HIGHEST_DESCRIPTION"])
			local dynamic = offering(ns.OffersTargetRank)
			if #dynamic > 0 then
				radio(rankMenu, L["MENU_RANK_DYNAMIC"], dynamic, function(macro)
					return ns.AbilityRank(macro) == "targetRank"
				end, function(macro)
					ns.SetAbilityRank(macro, "targetRank")
				end, L[DESCRIPTIONS.targetRank], L[NOTES.targetRank])
			end
		end
		if above then
			root:CreateDivider()
		end

		-- When: the combat check, how often it casts, and when it does nothing
		local whenMenu = submenu(root, L["MENU_GROUP_WHEN"])
		local checked = offeringOption("combatOnly")
		for _, choice in ipairs(COMBAT) do
			local check = choice[1]
			radio(whenMenu, L[choice[2]], checked, function(macro)
				return ns.CombatCheck(macro) == check
			end, function(macro)
				ns.SetCombatCheck(macro, check)
			end, L[choice[3]])
		end
		local repeating = offeringOption("oncePerTarget")
		if #repeating > 0 then
			whenMenu:CreateDivider()
			for _, choice in ipairs(REPEAT) do
				local rule = choice[1]
				radio(whenMenu, L[choice[2]], repeating, function(macro)
					return ns.RepeatRule(macro) == rule
				end, function(macro)
					ns.SetRepeatRule(macro, rule)
				end, L[choice[3]])
			end
		end
		whenMenu:CreateDivider()
		checkbox(whenMenu, "stopIfChanneling", L["MENU_STOP_IF_CHANNELING"])
		checkbox(whenMenu, "stopIfStealthed", L["MENU_STOP_IF_STEALTHED"])

		-- First: what runs before the cast, then the equipped on-use items
		local itemUsers = offering(ns.OffersUseItems)
		local slots = #itemUsers > 0 and ns.UsableSlots() or {}
		if anyOffered(FIRST) or #slots > 0 then
			local firstMenu = submenu(root, L["MENU_GROUP_FIRST"])
			local offered = false
			for _, option in ipairs(FIRST) do
				offered = checkbox(firstMenu, option[1], L[option[2]]) or offered
			end
			if offered and #slots > 0 then
				firstMenu:CreateDivider()
			end
			for _, usable in ipairs(slots) do
				local slot = usable.slot
				local function isOn()
					return all(itemUsers, function(macro)
						return ns.IsUsingSlot(macro, slot) ~= nil
					end)
				end
				local icon = GetInventoryItemTexture("player", slot)
				local label = (icon and "|T" .. icon .. ":16|t " or "") .. ns.SlotLabel(slot)
				local element = firstMenu:CreateCheckbox(label, isOn, function()
					local on = not isOn()
					apply(itemUsers, function(macro)
						if (ns.IsUsingSlot(macro, slot) ~= nil) ~= on then
							ns.ToggleUseSlot(macro, slot)
						end
					end)
				end)
				SetTip(element, ns.SlotLabel(slot), L["MENU_USE_ITEM_DESCRIPTION"])
			end
		end

		-- Then: what runs after the cast
		local THEN = {
			{ "startAttack", L["MENU_START_AUTO_ATTACK"] },
			{ "autoShot", ns.AutoShotLabelKey() and AutoShotLabel() },
			{ "petAttack", L["MENU_START_PET_ATTACK"] },
		}
		if anyOffered(THEN) then
			local thenMenu = submenu(root, L["MENU_GROUP_THEN"])
			for _, option in ipairs(THEN) do
				if option[2] then
					checkbox(thenMenu, option[1], option[2])
				end
			end
		end

		local errorsMenu = submenu(root, L["MENU_GROUP_ERRORS"])
		for _, option in ipairs(ERRORS) do
			checkbox(errorsMenu, option[1], L[option[2]])
		end

		-- last, apart from the options: every macro here back to its kind's defaults, as a tile's middle-click
		root:CreateDivider()
		-- a whole category's hand-set options take real effort to set again, so it asks first
		local reset = root:CreateButton(L["TOOLTIP_ACTION_RESET_CATEGORY"]:format(name), function()
			StaticPopup_Show("BAGSBUFFSBUTTONS_RESET_CATEGORY", name, nil, function()
				for _, macro in ipairs(list) do
					ns.ResetMacroSettings(macro)
				end
				onChange()
				ns:PrintMessage(L["CHAT_CATEGORY_OPTIONS_RESET"]:format(name))
			end)
		end)
		SetTip(reset, L["TOOLTIP_ACTION_RESET_CATEGORY"]:format(name), L["MENU_RESET_CATEGORY_DESCRIPTION"])
	end)
end
