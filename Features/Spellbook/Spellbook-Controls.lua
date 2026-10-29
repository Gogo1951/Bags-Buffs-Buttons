local _, ns = ...
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local L = ns.L
local HideTooltip = ns.HideTooltip
local HasTemplate = ns.HasTemplate
local PixelInset = ns.PixelInset
local CreateGearButton = ns.CreateSpellbookGearButton
local Layout = ns.LayoutSpellbookPage
local Refresh = ns.RefreshSpellbookPage

--[[
	The Spell Book page's controls row along the top of its window (the filter box, the filter and sort dropdowns
	and the settings gear) and its footer along the bottom (the legend, Mark All Spells As Placed and the macro
	slot counts). Features/Spellbook/Spellbook-Page.lua builds the page between them.
]]

-- The window's bands, in UI units from its edges, as Features/Spellbook/Spellbook-Page.lua sets them.
local TITLE_HEIGHT, CONTROLS_HEIGHT = ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT
local FOOTER_HEIGHT, FRAME_BORDER = ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER
local CONTROLS_LEFT = 64 -- clear of the portrait

-- the footer, on the dark frame
local LEGEND_COLOR = { 0.75, 0.75, 0.75 }
local GLOW_SWATCH = { 1, 0.886, 0.478 }
local GLOW_SWATCH_FILL = { 0.18, 0.165, 0.141 }

--[[
	The general and character macro slots used, at the footer's right: "Macro Slots" in gold, the list names in
	grey, the counts in white, and a full list's count in red.
]]
local function SlotCount(label, used, max)
	local count = used .. "/" .. max
	local color = used >= max and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR
	return GRAY_FONT_COLOR:WrapTextInColorCode(label) .. " " .. color:WrapTextInColorCode(count)
end

local function UpdateMacroCount(page)
	local numAccount, maxAccount, numCharacter, maxCharacter = ns.MacroCounts()
	page.macroCount:SetText(
		NORMAL_FONT_COLOR:WrapTextInColorCode(L["PAGE_MACRO_SLOTS"])
			.. "   "
			.. SlotCount(L["PAGE_MACRO_GENERAL"], numAccount, maxAccount)
			.. "   "
			.. SlotCount(L["PAGE_MACRO_CHARACTER"], numCharacter, maxCharacter)
	)
end

ns.UpdateSpellbookMacroCount = UpdateMacroCount

--[[
	Gives a settings menu entry the explanation its Options Interface control shows, as AceConfig shows it: the
	label as a gold title, then a white line. Builds whose menus can't take a tooltip show the entry bare.
]]
local function AddMenuTooltip(element, labelKey, descKey)
	if not element.SetTooltip then
		return
	end
	element:SetTooltip(function(tooltip)
		tooltip:SetText(L[labelKey], TITLE.r, TITLE.g, TITLE.b, 1, true)
		tooltip:AddLine(L[descKey], BODY.r, BODY.g, BODY.b, true)
	end)
end

--[[
	With ElvUI loaded, its Skins module dresses the page's top controls as it dresses Blizzard's, so the filter
	box, the dropdowns and the button match the rest of that UI rather than the default art. The module is
	another add-on's API, so each call is guarded: a change to it leaves a control in the default art instead
	of breaking the page.
]]
local function ApplyElvUISkin(page)
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if not skins then
		return
	end
	pcall(skins.HandleEditBox, skins, page.filterBox)
	for _, dropdown in ipairs({ page.filterButton, page.sortButton }) do
		if dropdown.SetupMenu then
			pcall(skins.HandleDropDownBox, skins, dropdown, dropdown:GetWidth())
		else
			pcall(skins.HandleButton, skins, dropdown)
		end
	end
	pcall(skins.HandleButton, skins, page.markPlaced)
end

--[[
	A dropdown in the controls row, width wide, whose menu setup builds: the game's dropdown where the build has
	the template, else a plain button that opens the same menu, its label set by the caller.
]]
local function CreateDropdown(parent, width, setup)
	local dropdown
	if HasTemplate("WowStyle1DropdownTemplate") then
		dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		dropdown:SetWidth(width)
		dropdown:SetupMenu(setup)
	else
		dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		dropdown:SetSize(width, 22)
		dropdown:SetScript("OnClick", function(self)
			MenuUtil.CreateContextMenu(self, setup)
		end)
	end
	return dropdown
end

-- The footer's legend at its left: a dark square ringed in the glow's gold, for a spell not on the bars yet.
local function BuildLegend(page)
	local glow = CreateFrame("Frame", nil, page)
	glow:SetSize(11, 11)
	glow:SetPoint("LEFT", page, "BOTTOMLEFT", 12, FRAME_BORDER + FOOTER_HEIGHT / 2)
	local ring = glow:CreateTexture(nil, "BACKGROUND")
	ring:SetAllPoints()
	ring:SetColorTexture(unpack(GLOW_SWATCH))
	local fill = glow:CreateTexture(nil, "BORDER")
	fill:SetColorTexture(unpack(GLOW_SWATCH_FILL))
	PixelInset(fill, glow, 2)
	local label = page:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	label:SetTextColor(unpack(LEGEND_COLOR))
	label:SetPoint("LEFT", glow, "RIGHT", 5, 0)
	label:SetText(L["TOOLTIP_NOT_ON_BARS"])
	page.legendLabel = label
end

--[[
	Builds the page's controls row and footer, after its parchment and before its page strip; the page's
	Layout and Refresh redraw what they show.
]]
function ns.BuildSpellbookControls(page)
	local function SetupSettingsMenu(_, rootDescription)
		rootDescription:CreateTitle(SETTINGS)
		-- the page's list toggles, each changing which macros it lists, so it starts again from its first page
		local function listToggle(labelKey, descKey, getter, setter)
			AddMenuTooltip(
				rootDescription:CreateCheckbox(L[labelKey], getter, function()
					setter(not getter())
					page.pagingControls:SetCurrentPage(1)
					Refresh(page)
				end),
				labelKey,
				descKey
			)
		end
		if ns.HAS_SPELL_RANKS then
			listToggle(
				"SETTINGS_SHOW_ALL_RANKS",
				"OPTIONS_SHOW_ALL_RANKS_DESCRIPTION",
				ns.ShowsAllRanks,
				ns.SetShowAllRanks
			)
		end
		listToggle(
			"SETTINGS_SHOW_GROUPED_SPELLS",
			"OPTIONS_SHOW_GROUPED_SPELLS_DESCRIPTION",
			ns.ShowsGroupedSpells,
			ns.SetShowGroupedSpells
		)
		if ns.ForEachUnlearnedSpell then
			listToggle(
				"SETTINGS_SHOW_UNLEARNED",
				"OPTIONS_SHOW_UNLEARNED_DESCRIPTION",
				ns.ShowsUnlearned,
				ns.SetShowUnlearned
			)
		end
		--[[
			Highlight Unplaced Spells: on while no macro is marked placed, so every one not on the bars glows.
			Turning it off marks them all placed, as the Mark All Spells As Placed button does; turning it on
			clears the marks
		]]
		rootDescription:CreateDivider()
		AddMenuTooltip(
			rootDescription:CreateCheckbox(L["SETTINGS_HIGHLIGHT_UNPLACED"], function()
				return not ns.HasPlacedMarks()
			end, function()
				if ns.HasPlacedMarks() then
					ns.ClearPlacedMarks()
				else
					ns.MarkAllPlaced()
				end
				ns:OnActionbarSlotChanged() -- redraws the glows
			end),
			"SETTINGS_HIGHLIGHT_UNPLACED",
			"SETTINGS_HIGHLIGHT_UNPLACED_DESCRIPTION"
		)
	end

	-- the controls row: on the dark frame under the title, from clear of the portrait to the frame's right
	local rowY = -(TITLE_HEIGHT + CONTROLS_HEIGHT / 2)

	-- the page-wide settings menu, from the gear at the row's right end
	local options = CreateGearButton(page, 22)
	page.options = options
	options:SetPoint("RIGHT", page, "TOPRIGHT", -10, rowY)
	options:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(SETTINGS, TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:Show()
	end)
	options:SetScript("OnClick", function(self)
		HideTooltip(self)
		MenuUtil.CreateContextMenu(self, SetupSettingsMenu)
	end)

	--[[
		The filter box: the page lists only the macros whose names hold its text, as it is typed. Its hint is
		white, readable on the dark box ElvUI or the default art gives it, and clears as soon as the box takes the
		cursor rather than once something is typed.
	]]
	local filterBox
	if HasTemplate("SearchBoxTemplate") then
		filterBox = CreateFrame("EditBox", nil, page, "SearchBoxTemplate")
	else
		filterBox = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
	end
	filterBox:SetAutoFocus(false)
	filterBox:SetSize(170, 20)
	filterBox:SetPoint("LEFT", page, "TOPLEFT", CONTROLS_LEFT + 6, rowY)
	local hint = filterBox.Instructions
	if hint then
		hint:SetText(L["PAGE_FILTER"])
		hint:SetTextColor(1, 1, 1)
		filterBox:HookScript("OnEditFocusGained", function()
			hint:Hide()
		end)
		filterBox:HookScript("OnEditFocusLost", function(self)
			hint:SetShown(self:GetText() == "")
		end)
	end
	filterBox:HookScript("OnTextChanged", function(self)
		-- the template shows the hint again whenever the box empties, even with the cursor in it
		if hint and self:HasFocus() then
			hint:Hide()
		end
		local text = self:GetText():match("^%s*(.-)%s*$")
		if text ~= (page.filterText or "") then
			page.filterText = text
			page.pagingControls:SetCurrentPage(1)
			Layout(page)
		end
	end)
	page.filterBox = filterBox

	--[[
		The filter dropdown: under Sort By Category it shows one school (spellbook tab), under Sort By School one
		category, or all of them (page.groupFilter nil). It offers only those the page's macros fill, in page
		order, and forgets its pick when the sort changes.
	]]
	local function FilterChoices()
		local choices, seen = {}, {}
		if ns.PageSort() == "category" then
			for _, macro in ipairs(ns.macros) do
				if not macro.unlearned and not seen[macro.category] then
					seen[macro.category] = true
					choices[#choices + 1] = { macro.category, macro.category }
				end
			end
			return choices
		end
		for _, macro in ipairs(ns.macros) do
			local key = not macro.unlearned and not macro.hidden and ns.PageCategory(macro)
			if key then
				seen[key] = true
			end
		end
		for _, row in ipairs(ns.PAGE_CATEGORIES) do
			if seen[row.key] then
				choices[#choices + 1] = { row.key, L[row.labelKey] }
			end
		end
		return choices
	end
	local function AllLabel()
		return ns.PageSort() == "category" and L["FILTER_ALL_SCHOOLS"] or L["FILTER_ALL_CATEGORIES"]
	end
	local function FilterLabel()
		for _, choice in ipairs(FilterChoices()) do
			if choice[1] == page.groupFilter then
				return choice[2]
			end
		end
		return AllLabel()
	end
	local filterButton
	local function pickFilter(value)
		page.groupFilter = value
		if not filterButton.SetupMenu then
			filterButton:SetText(FilterLabel())
		end
		page.pagingControls:SetCurrentPage(1)
		Layout(page)
	end
	filterButton = CreateDropdown(page, 150, function(_, rootDescription)
		rootDescription:CreateRadio(AllLabel(), function()
			return page.groupFilter == nil
		end, function()
			pickFilter(nil)
		end)
		for _, choice in ipairs(FilterChoices()) do
			rootDescription:CreateRadio(choice[2], function()
				return page.groupFilter == choice[1]
			end, function()
				pickFilter(choice[1])
			end)
		end
	end)
	filterButton:SetPoint("LEFT", filterBox, "RIGHT", 8, 0)
	page.filterButton = filterButton
	-- redraws the dropdown's choices and label, dropping a pick the page no longer offers
	function page.UpdateFilterButton()
		if FilterLabel() == AllLabel() then
			page.groupFilter = nil
		end
		if filterButton.GenerateMenu then
			filterButton:GenerateMenu()
		else
			filterButton:SetText(FilterLabel())
		end
	end
	page.UpdateFilterButton()

	-- The sort dropdown: Sort By Category or Sort By School (ns.PageSort).
	local SORTS = { { "category", "SORT_BY_CATEGORY" }, { "school", "SORT_BY_SCHOOL" } }
	local function SortLabel()
		for _, sort in ipairs(SORTS) do
			if sort[1] == ns.PageSort() then
				return L[sort[2]]
			end
		end
		return L[SORTS[1][2]]
	end
	local sortButton
	sortButton = CreateDropdown(page, 150, function(_, rootDescription)
		for _, sort in ipairs(SORTS) do
			AddMenuTooltip(
				rootDescription:CreateRadio(L[sort[2]], function()
					return ns.PageSort() == sort[1]
				end, function()
					ns.SetPageSort(sort[1])
					if not sortButton.SetupMenu then
						sortButton:SetText(SortLabel())
					end
					-- the filter dropdown offers the other grouping now, so its pick no longer applies
					page.groupFilter = nil
					page.UpdateFilterButton()
					page.pagingControls:SetCurrentPage(1)
					Layout(page)
				end),
				sort[2],
				"SORT_DESCRIPTION"
			)
		end
	end)
	if not sortButton.SetupMenu then
		sortButton:SetText(SortLabel())
	end
	-- at the row's right, beside the settings gear: how the page is ordered, apart from what it shows
	sortButton:SetPoint("RIGHT", page.options, "LEFT", -8, 0)
	page.sortButton = sortButton
	sortButton.SortLabel = SortLabel

	-- the footer: the legend at its left, the macro slot counts at its right
	BuildLegend(page)

	--[[
		Stops every macro glowing, whether or not it's on the bars, at once and without asking: the settings
		menu undoes it. A spell learned later still glows until it is placed. It sits in the footer beside the
		legend for the glow it clears.
	]]
	local markPlaced = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
	page.markPlaced = markPlaced
	markPlaced:SetText(L["SETTINGS_MARK_ALL_PLACED"])
	markPlaced:SetSize(markPlaced:GetFontString():GetStringWidth() + 32, 22)
	markPlaced:SetPoint("LEFT", page.legendLabel, "RIGHT", 12, 0)
	markPlaced:SetScript("OnClick", function()
		ns.MarkAllPlaced()
		ns:OnActionbarSlotChanged() -- redraws the glows
	end)
	markPlaced:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L["SETTINGS_MARK_ALL_PLACED"], TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:AddLine(L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	markPlaced:SetScript("OnLeave", HideTooltip)
	ApplyElvUISkin(page)

	page.macroCount = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	page.macroCount:SetPoint("RIGHT", page, "BOTTOMRIGHT", -12, FRAME_BORDER + FOOTER_HEIGHT / 2)
	-- a font string takes no hover, so a frame over the counts carries its tooltip
	local slotsHover = CreateFrame("Frame", nil, page)
	slotsHover:SetAllPoints(page.macroCount)
	slotsHover:EnableMouse(true)
	slotsHover:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L["PAGE_MACRO_SLOTS"], TITLE.r, TITLE.g, TITLE.b, 1, true)
		GameTooltip:AddLine(L["TOOLTIP_MACRO_SLOTS"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:Show()
	end)
	slotsHover:SetScript("OnLeave", HideTooltip)
	slotsHover:SetScript("OnHide", HideTooltip)
end
