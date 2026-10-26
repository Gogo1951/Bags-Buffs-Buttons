local _, ns = ...
local L = ns.L
local HideTooltip = ns.HideTooltip
local HasTemplate = ns.HasTemplate
local SizedFontString = ns.SizedFontString
local PixelLine = ns.PixelLine
local PixelInset = ns.PixelInset

--[[
	Lays ns.macros (built by Features/Macro-Builder.lua) out in the page's window (Features/Spellbook-Window.lua):
	the controls along its top, the parchment with two columns and the page strip, and the legend and macro slot
	counts along its bottom. Each category is a block under its header; its spells flow two to a row into the
	very next free slot, a form's run labelled above its own tiles. Features/Macro-Button.lua owns each tile,
	Features/Macro-Menu.lua the right-click and category menus, and Features/Spellbook-Paging.lua the page strip.
]]

-- The window's bands, in UI units from its edges, inside the portrait frame's border.
local TITLE_HEIGHT, CONTROLS_HEIGHT = 24, 36
local CONTROLS_LEFT = 64 -- clear of the portrait
local FOOTER_HEIGHT, FRAME_BORDER = 28, 4
local PARCHMENT_SIDE = 8
local PAGER_HEIGHT = 30
local COLUMN_TOP, COLUMN_SIDE = 14, 20 -- each column's padding inside the parchment

-- The flow inside a column (see PackRows and Paginate).
local SLOTS, GAP_X = 2, 12
local TILE_WIDTH, TILE_HEIGHT = ns.TILE_WIDTH, ns.TILE_HEIGHT
--[[
	The strip above each row of tiles: clear space, then a form's label, then a short gap to the tiles it names.
	The strip is sized so the space between one row's icons and the next is one icon tall (a 32 tile holds a 30
	icon, a pixel of air above and below it), and the label keeps its place against the tiles under it, so the
	space falls above the label.
]]
local ROW_STRIP_HEIGHT = 28
local LABEL_HEIGHT, LABEL_GAP = 13, 3
local LABEL_TOP_GAP = ROW_STRIP_HEIGHT - LABEL_HEIGHT - LABEL_GAP
--[[
	CATEGORY_GAP is the clear space over a category's header, from the tiles of the one before. A header's name
	sits about 30 above its first tiles (the header's lower half and a row strip), so the gap is wider than that:
	more air above a header than below it, so each name reads with the spells under it.
]]
local HEADER_HEIGHT, CATEGORY_GAP = 20, 34
local COLUMN_WIDTH = SLOTS * TILE_WIDTH + (SLOTS - 1) * GAP_X

local HEADER_SIZE, CONTINUED_SIZE, LABEL_SIZE = 16, 12, 10

-- The parchment and its ink. Every category shares the same ink, as the game's own book does.
local PARCHMENT_COLOR = { 0.847, 0.765, 0.6 }
local VIGNETTE_COLOR = { 0.36, 0.235, 0.086 } -- the aged edges, darker toward the border
local EDGE_COLOR = { 0.043, 0.043, 0.043 }
local INNER_EDGE_COLOR = { 0.42, 0.353, 0.243 }
local HEADER_INK = ns.INK_COLOR
local LABEL_INK = { 0.42, 0.29, 0.137 }
local CONTINUED_INK = { 0.42, 0.353, 0.243 }
local RULE_COLOR = { 0.612, 0.498, 0.333 }
local DIVIDER_COLOR = { 0.651, 0.545, 0.376 }
-- the small dark buttons that hold the gold gear
local GEAR_FILL = { 0.165, 0.145, 0.125 }
local GEAR_EDGE = { 0.549, 0.478, 0.322 }
-- the footer, on the dark frame
local LEGEND_COLOR = { 0.75, 0.75, 0.75 }
local GLOW_SWATCH = { 1, 0.886, 0.478 }
local GLOW_SWATCH_FILL = { 0.18, 0.165, 0.141 }

-- Forever's parchment, where this build has it; otherwise the parchment colour with darkened edges
local ATLAS_PAGE_LEFT, ATLAS_PAGE_RIGHT = "spellbook-Page-Left-C60", "spellbook-Page-Right-C60"
local VIGNETTE_WIDTH, VIGNETTE_ALPHA = 46, 0.24

-- Acquire hands out pooled frames in order; ReleaseAll hides the ones from the last layout.
local function FramePool(create)
	local pool = { used = 0 }
	function pool:Acquire()
		self.used = self.used + 1
		local frame = self[self.used] or create()
		self[self.used] = frame
		frame:ClearAllPoints()
		frame:Show()
		return frame
	end
	function pool:ReleaseAll()
		for i = 1, #self do
			self[i]:Hide()
		end
		self.used = 0
	end
	return pool
end

-- Whether one spell name sorts before another, ignoring case and accents where the client can compare UTF-8.
local function NameBefore(a, b)
	if strcmputf8i then
		return strcmputf8i(a, b) < 0
	end
	return a < b
end

--[[
	Whether a macro passes the page's filters: its name holds the filter box's text, and it is in the school
	the filter dropdown picked under Sort By Category, or in the category it picked under Sort By School.
]]
local function PassesFilters(page, macro)
	local text = page.filterText
	if text and text ~= "" and not (macro.label or macro.name):lower():find(text:lower(), 1, true) then
		return false
	end
	local picked = page.groupFilter
	if not picked then
		return true
	elseif ns.PageSort() == "category" then
		return macro.category == picked
	end
	return not macro.unlearned and ns.PageCategory(macro) == picked
end

--[[
	The macros in page order as { macro, header, sub } entries. Sorted by school, that is ns.macros under its
	spellbook tabs. Sorted by category, the spell macros go under their page category (ns.PageCategory), in
	ns.PAGE_CATEGORIES' order and alphabetically within each, any macro without a page category after them
	under its own section, then BBB Consumables (Connoisseur's macros, see ns.ConsumablePageMacros), and the
	Unlearned section last, those keeping ns.macros' order; a focus, Duplicate or
	rank copy still follows its spell. Within a page category, the spells needing a form (sub, from
	ns.PageSubCategory) follow its own, a run for each form, the forms alphabetically, then the basic attacks. A macro the page hides (a
	grouped spell a later one replaced, see ns.ShowsGroupedSpells) or that the page's filters leave out
	(PassesFilters) is left out.
]]
-- Past every section a spellbook tab can make (#ns.PAGE_CATEGORIES + its tab's rank), short of Unlearned's.
local CONSUMABLES_RANK = 1000000

local function PageOrder(page)
	local entries = {}
	local consumables = ns.ConsumablePageMacros()
	if ns.PageSort() ~= "category" then
		-- BBB Consumables goes in ahead of the Unlearned section, which ns.macros ends with
		local function addConsumables()
			for _, macro in ipairs(consumables) do
				if PassesFilters(page, macro) then
					entries[#entries + 1] = { macro = macro, header = macro.category }
				end
			end
			consumables = {}
		end
		for _, macro in ipairs(ns.macros) do
			if macro.unlearned then
				addConsumables()
			end
			if not macro.hidden and PassesFilters(page, macro) then
				entries[#entries + 1] = { macro = macro, header = macro.category }
			end
		end
		addConsumables()
		return entries
	end
	local labels, ranks = {}, {}
	for i, row in ipairs(ns.PAGE_CATEGORIES) do
		labels[row.key], ranks[row.key] = L[row.labelKey], i
	end
	local knownForms = ns.KnownForms()
	for i, macro in ipairs(ns.macros) do
		local entry = { macro = macro, index = i }
		local category = not macro.unlearned and ns.PageCategory(macro)
		if macro.unlearned then
			entry.rank, entry.header = math.huge, macro.category
		elseif category then
			entry.rank, entry.header = ranks[category], labels[category]
			entry.sub, entry.subRank = ns.PageSubCategory(macro, knownForms)
		else
			entry.rank, entry.header = #ns.PAGE_CATEGORIES + macro.categoryRank, macro.category
		end
		if not macro.hidden and PassesFilters(page, macro) then
			entries[#entries + 1] = entry
		end
	end
	-- after every section but Unlearned, in the Macros panel's order
	for position, macro in ipairs(consumables) do
		if PassesFilters(page, macro) then
			entries[#entries + 1] = {
				macro = macro,
				index = #ns.macros + position,
				rank = CONSUMABLES_RANK,
				header = macro.category,
			}
		end
	end
	table.sort(entries, function(a, b)
		if a.rank ~= b.rank then
			return a.rank < b.rank
		end
		-- the category's own spells, then each form's, then the basic attacks
		if a.subRank ~= b.subRank then
			return (a.subRank or 0) < (b.subRank or 0)
		end
		if a.sub ~= b.sub then
			return NameBefore(a.sub, b.sub)
		end
		-- a page category's spells alphabetically, each copy after its spell
		-- by the name the page shows, so a profession under its specialization's name sorts by that
		local aName, bName = a.macro.sortName or a.macro.name, b.macro.sortName or b.macro.name
		if a.rank <= #ns.PAGE_CATEGORIES and aName ~= bName then
			return NameBefore(aName, bName)
		end
		return a.index < b.index
	end)
	return entries
end

--[[
	The page order as categories, each { name, macros, groups }: its macros in order, and its runs as groups of
	{ sub, macros }, sub the form's name, or nil for the category's own spells.
]]
local function Categories(entries)
	local categories, category, group = {}, nil, nil
	for _, entry in ipairs(entries) do
		if not category or entry.header ~= category.name then
			category = { name = entry.header, macros = {}, groups = {} }
			categories[#categories + 1] = category
			group = nil
		end
		if not group or group.sub ~= entry.sub then
			group = { sub = entry.sub, macros = {} }
			category.groups[#category.groups + 1] = group
		end
		group.macros[#group.macros + 1] = entry.macro
		category.macros[#category.macros + 1] = entry.macro
	end
	return categories
end

--[[
	A category's runs packed into rows of SLOTS tiles, each { segments }. A run starts in the very next free
	slot, so two runs can share a row; a run that wraps carries on as a segment marked continued at the start of
	the next row.
]]
local function PackRows(groups)
	local rows, row, used = {}, nil, 0
	for _, group in ipairs(groups) do
		local i, continued = 1, false
		while i <= #group.macros do
			if not row or used == SLOTS then
				row = { segments = {} }
				rows[#rows + 1] = row
				used = 0
			end
			local take = math.min(SLOTS - used, #group.macros - i + 1)
			local segment = { group = group, sub = group.sub, continued = continued, macros = {} }
			for k = i, i + take - 1 do
				segment.macros[#segment.macros + 1] = group.macros[k]
			end
			row.segments[#row.segments + 1] = segment
			used, i, continued = used + take, i + take, true
		end
	end
	return rows
end

--[[
	Every row is the same height: a label strip over its tiles, holding a form's label where the row has one and
	left empty otherwise, so rows step down evenly whether or not they're labelled. The strip is also the space
	between rows and under the header.
]]
local ROW_HEIGHT = LABEL_TOP_GAP + LABEL_HEIGHT + LABEL_GAP + TILE_HEIGHT

-- The height of a category's header and its rows first to last.
local function BlockHeight(first, last)
	return HEADER_HEIGHT + (last - first + 1) * ROW_HEIGHT
end

--[[
	Fills columns in order (page 1 left, page 1 right, page 2 left, ...) with category blocks, each
	{ category, first, last, continued, y }. A category starts right under the one before and takes as many
	of its rows as the column has room for; the rest carry on at the top of the next column, under its header
	again, marked continued. It moves whole to the next column only when not even its header and first row fit,
	so a category never leaves a header alone at a column's foot, and one more row above only pushes the last
	row on.
]]
local function Paginate(categories, height)
	local columns = { {} }
	local column, y = columns[1], 0
	local function nextColumn()
		column, y = {}, 0
		columns[#columns + 1] = column
	end
	for _, category in ipairs(categories) do
		local rows = category.rows
		local first, continued = 1, false
		while first <= #rows do
			local gap = #column > 0 and CATEGORY_GAP or 0
			local room = height - y - gap
			local last = first - 1
			while last < #rows and BlockHeight(first, last + 1) <= room do
				last = last + 1
			end
			-- an empty column always takes at least one row, so a category can never stall
			if last < first and #column == 0 then
				last = first
			end
			if last < first then
				nextColumn()
			else
				column[#column + 1] =
					{ category = category, first = first, last = last, continued = continued, y = y + gap }
				y = y + gap + BlockHeight(first, last)
				first = last + 1
				if first <= #rows then
					continued = true
					nextColumn()
				end
			end
		end
	end
	if #column == 0 and #columns > 1 then
		columns[#columns] = nil
	end
	return columns
end

--[[
	The parchment: a black edge and a thin brown line inside it, then Forever's page art where the build has
	it, else the parchment colour with its edges darkened.
]]
local function DrawParchment(parchment)
	local edge = parchment:CreateTexture(nil, "BACKGROUND", nil, -8)
	edge:SetAllPoints()
	edge:SetColorTexture(unpack(EDGE_COLOR))
	local inner = parchment:CreateTexture(nil, "BACKGROUND", nil, -7)
	inner:SetColorTexture(unpack(INNER_EDGE_COLOR))
	PixelInset(inner, parchment, 2)
	local paper = CreateFrame("Frame", nil, parchment)
	PixelInset(paper, parchment, 3)
	parchment.paper = paper
	if C_Texture.GetAtlasInfo(ATLAS_PAGE_LEFT) and C_Texture.GetAtlasInfo(ATLAS_PAGE_RIGHT) then
		local left = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
		left:SetAtlas(ATLAS_PAGE_LEFT)
		left:SetPoint("TOPLEFT", paper)
		left:SetPoint("BOTTOMRIGHT", paper, "BOTTOM")
		local right = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
		right:SetAtlas(ATLAS_PAGE_RIGHT)
		right:SetPoint("TOPLEFT", paper, "TOP")
		right:SetPoint("BOTTOMRIGHT", paper)
		return
	end
	local base = parchment:CreateTexture(nil, "BACKGROUND", nil, -6)
	base:SetAllPoints(paper)
	base:SetColorTexture(unpack(PARCHMENT_COLOR))
	-- a strip down each edge, the aged colour fading to clear toward the middle
	if not CreateColor then
		return
	end
	local dark = CreateColor(VIGNETTE_COLOR[1], VIGNETTE_COLOR[2], VIGNETTE_COLOR[3], VIGNETTE_ALPHA)
	local clear = CreateColor(VIGNETTE_COLOR[1], VIGNETTE_COLOR[2], VIGNETTE_COLOR[3], 0)
	local function strip(point, relative, horizontal, from, to)
		local texture = parchment:CreateTexture(nil, "BACKGROUND", nil, -5)
		texture:SetColorTexture(1, 1, 1)
		texture:SetPoint(point, paper, point)
		texture:SetPoint(relative, paper, relative)
		if horizontal then
			texture:SetWidth(VIGNETTE_WIDTH)
		else
			texture:SetHeight(VIGNETTE_WIDTH)
		end
		pcall(texture.SetGradient, texture, horizontal and "HORIZONTAL" or "VERTICAL", from, to)
	end
	strip("TOPLEFT", "BOTTOMLEFT", true, dark, clear)
	strip("TOPRIGHT", "BOTTOMRIGHT", true, clear, dark)
	strip("BOTTOMLEFT", "BOTTOMRIGHT", false, dark, clear)
	strip("TOPLEFT", "TOPRIGHT", false, clear, dark)
end

-- A small dark square button with the gold gear: a category's settings, or the page's.
local function CreateGearButton(parent, size)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(size, size)
	local edge = button:CreateTexture(nil, "BACKGROUND")
	edge:SetAllPoints()
	edge:SetColorTexture(unpack(GEAR_EDGE))
	local fill = button:CreateTexture(nil, "BORDER")
	fill:SetColorTexture(unpack(GEAR_FILL))
	PixelInset(fill, button, 1)
	local gear = button:CreateTexture(nil, "ARTWORK")
	gear:SetTexture(ns.TEXTURE_GEAR)
	gear:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
	local glyphSize = math.floor(size * 0.62 + 0.5)
	gear:SetSize(glyphSize, glyphSize)
	gear:SetPoint("CENTER")
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(fill)
	highlight:SetColorTexture(1, 1, 1, 0.12)
	-- nudged while held down, like the game's buttons
	button:SetScript("OnMouseDown", function()
		gear:SetPoint("CENTER", 1, -1)
	end)
	button:SetScript("OnMouseUp", function()
		gear:SetPoint("CENTER")
	end)
	button:SetScript("OnLeave", HideTooltip)
	return button
end

--[[
	A category's header: its name in dark ink, "(Continued)" in lighter ink where it carries on from the
	column before, a rule filling the width, and the gear that opens the category's menu. Layout sets the text
	and what the gear acts on.
]]
local function CreateHeader(page)
	local header = CreateFrame("Frame", nil, page.parchment.paper)
	header:SetSize(COLUMN_WIDTH, HEADER_HEIGHT)
	header.Text = SizedFontString(header, "GameFontNormalLarge", HEADER_SIZE)
	header.Text:SetTextColor(unpack(HEADER_INK))
	header.Text:SetShadowOffset(0, 0)
	header.Text:SetPoint("LEFT")
	header.Continued = SizedFontString(header, "GameFontNormal", CONTINUED_SIZE)
	header.Continued:SetTextColor(unpack(CONTINUED_INK))
	header.Continued:SetShadowOffset(0, 0)
	local gear = CreateGearButton(header, 18)
	header.gear = gear
	gear:SetPoint("RIGHT")
	local rule = PixelLine(header, "ARTWORK", RULE_COLOR)
	rule:SetPoint("LEFT", header.Continued, "RIGHT", 8, 0)
	rule:SetPoint("RIGHT", gear, "LEFT", -8, 0)
	gear:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["PAGE_CATEGORY_SETTINGS"]:format(#header.macros, header.name), 1, 0.82, 0, 1, true)
		GameTooltip:AddLine(L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"], 1, 1, 1, true)
		GameTooltip:Show()
	end)
	gear:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.ShowCategoryMenu(self, header.name, header.macros, function()
			page.Refresh()
		end)
	end)
	return header
end

-- A form's label over its own tiles: its name in capitals, then a rule to the run's right edge, ending in a tick.
local function CreateSubLabel(page)
	local label = CreateFrame("Frame", nil, page.parchment.paper)
	label:SetHeight(LABEL_HEIGHT)
	label.Text = SizedFontString(label, "GameFontNormalSmall", LABEL_SIZE)
	label.Text:SetTextColor(unpack(LABEL_INK))
	label.Text:SetShadowOffset(0, 0)
	label.Text:SetPoint("LEFT")
	local rule = PixelLine(label, "ARTWORK", RULE_COLOR)
	rule:SetPoint("LEFT", label.Text, "RIGHT", 6, 0)
	rule:SetPoint("RIGHT")
	local tick = PixelLine(label, "ARTWORK", RULE_COLOR, "VERTICAL")
	tick:SetHeight(4)
	tick:SetPoint("TOPRIGHT", rule, "TOPRIGHT")
	return label
end

-- The width of a run of n tiles.
local function RunWidth(n)
	return n * TILE_WIDTH + (n - 1) * GAP_X
end

-- The segment of a row that holds a slot (0 for the first), or nil past its last tile.
local function SegmentAt(row, slot)
	local start = 0
	for _, segment in ipairs(row.segments) do
		if slot < start + #segment.macros then
			return segment
		end
		start = start + #segment.macros
	end
	return nil
end

--[[
	Whether a form's run shows its label at this row, starting at slot: always where the run starts, and where
	it carries on only when that isn't plain from the tile above its first slot, which belongs to another run
	or isn't there (the first row of a column, under the header again). So "BASIC ATTACKS" shows again over a
	row whose first tile sits under a Defensive Stance spell, but not over the next row, under its own.
]]
local function NeedsLabel(segment, above, slot)
	if not segment.continued or not above then
		return true
	end
	local over = SegmentAt(above, slot)
	return over == nil or over.group ~= segment.group
end

-- Draws one column's blocks, x and y its top left inside the paper.
local function DrawColumn(page, column, x, y, bars)
	for _, block in ipairs(column) do
		local category = block.category
		local top = y + block.y
		local header = page.headers:Acquire()
		header:SetPoint("TOPLEFT", page.parchment.paper, "TOPLEFT", x, -top)
		header.name, header.macros = category.name, category.macros
		header.Text:SetText(category.name)
		-- the gear only where a macro has options to set
		local settable = false
		for _, macro in ipairs(category.macros) do
			settable = settable or ns.HasOptions(macro)
		end
		header.gear:SetShown(settable)
		-- an empty "(Continued)" sits flush against the name, so the rule starts where it always does
		header.Continued:SetText(block.continued and L["PAGE_CONTINUED"] or "")
		header.Continued:SetPoint("LEFT", header.Text, "RIGHT", block.continued and 6 or 0, 0)
		top = top + HEADER_HEIGHT
		for r = block.first, block.last do
			local row = category.rows[r]
			local above = r > block.first and category.rows[r - 1] or nil
			local slot = 0
			for _, segment in ipairs(row.segments) do
				local left = x + slot * (TILE_WIDTH + GAP_X)
				if segment.sub and NeedsLabel(segment, above, slot) then
					local label = page.subheaders:Acquire()
					label:SetPoint("TOPLEFT", page.parchment.paper, "TOPLEFT", left, -(top + LABEL_TOP_GAP))
					label:SetWidth(RunWidth(#segment.macros))
					label.Text:SetText(segment.sub:upper())
				end
				local tileTop = top + LABEL_TOP_GAP + LABEL_HEIGHT + LABEL_GAP
				for k, macro in ipairs(segment.macros) do
					local button = page.buttons:Acquire()
					button:SetPoint(
						"TOPLEFT",
						page.parchment.paper,
						"TOPLEFT",
						left + (k - 1) * (TILE_WIDTH + GAP_X),
						-tileTop
					)
					ns.SetMacroButton(button, macro, bars)
				end
				slot = slot + #segment.macros
			end
			top = top + ROW_HEIGHT
		end
	end
end

-- Draws the current page: two columns of blocks, or the empty note when nothing is listed.
local function Layout(page)
	page.headers:ReleaseAll()
	page.subheaders:ReleaseAll()
	page.buttons:ReleaseAll()
	local controls = page.pagingControls
	page.markPlaced:SetShown(#ns.macros > 0)
	local categories = Categories(PageOrder(page))
	if #categories == 0 then
		local text = page.filterText or ""
		page.empty:SetText(
			#ns.macros == 0 and L["PAGE_EMPTY"]
				or text ~= "" and L["PAGE_NO_MATCHES_FOR"]:format(text)
				or L["PAGE_NO_MATCHES"]
		)
		page.empty:Show()
		controls:SetMaxPages(1)
		controls:Hide()
		return
	end
	page.empty:Hide()

	for _, category in ipairs(categories) do
		category.rows = PackRows(category.groups)
	end
	local paper = page.parchment.paper
	local columns = Paginate(categories, paper:GetHeight() - COLUMN_TOP - PAGER_HEIGHT)
	local maxPages = math.ceil(#columns / 2)
	controls:SetMaxPages(maxPages)
	controls:Show()

	local current = math.min(controls:GetCurrentPage(), maxPages)
	local bars = ns.ScanActionBars()
	local half = paper:GetWidth() / 2
	for side = 1, 2 do
		local column = columns[(current - 1) * 2 + side]
		if column then
			DrawColumn(page, column, (side - 1) * half + COLUMN_SIDE, COLUMN_TOP, bars)
		end
	end
end

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

-- Rebuilds the list from the spellbook and the class lists, updates changed macros, then redraws.
local function Refresh(page)
	ns.CollectMacros()
	ns.SyncAllMacros()
	UpdateMacroCount(page)
	-- the sort can change outside the dropdown (the options panel, a profile change)
	if page.sortButton.GenerateMenu then
		page.sortButton:GenerateMenu()
	else
		page.sortButton:SetText(page.sortButton.SortLabel())
	end
	page.UpdateFilterButton() -- the schools or categories on offer follow the new list
	Layout(page)
end

local pages = {} -- every page built, so a settings change can redraw the open one

--[[
	Gives a settings menu entry the explanation its Options Interface control shows, as AceConfig shows it: the
	label as a gold title, then a white line. Builds whose menus can't take a tooltip show the entry bare.
]]
local function AddMenuTooltip(element, labelKey, descKey)
	if not element.SetTooltip then
		return
	end
	element:SetTooltip(function(tooltip)
		tooltip:SetText(L[labelKey], 1, 0.82, 0, 1, true)
		tooltip:AddLine(L[descKey], 1, 1, 1, true)
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

local function BuildPage(page)
	pages[#pages + 1] = page
	-- for the Display Context report
	page.geometry = { viewWidth = COLUMN_WIDTH, columns = SLOTS }
	function page.Refresh()
		Refresh(page)
	end

	local parchment = CreateFrame("Frame", nil, page)
	page.parchment = parchment
	parchment:SetPoint("TOPLEFT", PARCHMENT_SIDE, -(TITLE_HEIGHT + CONTROLS_HEIGHT))
	parchment:SetPoint("BOTTOMRIGHT", -PARCHMENT_SIDE, FRAME_BORDER + FOOTER_HEIGHT)
	parchment:SetClipsChildren(true)
	DrawParchment(parchment)
	local divider = PixelLine(parchment.paper, "BORDER", DIVIDER_COLOR, "VERTICAL")
	divider:SetPoint("TOP", 0, -COLUMN_TOP / 2)
	divider:SetPoint("BOTTOM", 0, PAGER_HEIGHT)

	page.headers = FramePool(function()
		return CreateHeader(page)
	end)
	page.subheaders = FramePool(function()
		return CreateSubLabel(page)
	end)
	page.buttons = FramePool(function()
		local button = ns.CreateMacroButton(parchment.paper)
		button.page = page -- the tile's menu redraws the page
		return button
	end)

	page.empty = parchment.paper:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	page.empty:SetTextColor(unpack(HEADER_INK))
	page.empty:SetShadowOffset(0, 0)
	page.empty:SetPoint("CENTER", 0, PAGER_HEIGHT / 2)
	page.empty:SetWidth(COLUMN_WIDTH)
	page.empty:SetWordWrap(true)

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
		GameTooltip:SetText(SETTINGS, 1, 0.82, 0, 1, true)
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
		GameTooltip:SetText(L["SETTINGS_MARK_ALL_PLACED"], 1, 0.82, 0, 1, true)
		GameTooltip:AddLine(L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"], 1, 1, 1, true)
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
		GameTooltip:SetText(L["PAGE_MACRO_SLOTS"], 1, 0.82, 0, 1, true)
		GameTooltip:AddLine(L["TOOLTIP_MACRO_SLOTS"], 1, 1, 1, true)
		GameTooltip:Show()
	end)
	slotsHover:SetScript("OnLeave", HideTooltip)
	slotsHover:SetScript("OnHide", HideTooltip)

	-- the page strip along the parchment's bottom; the wheel turns the page anywhere on the parchment
	local controls = ns.CreatePagingControls(page, parchment.paper)
	page.pagingControls = controls
	controls:SetPoint("BOTTOMLEFT", parchment.paper, "BOTTOMLEFT", 14, 0)
	controls:SetPoint("BOTTOMRIGHT", parchment.paper, "BOTTOMRIGHT", -14, 0)
	function page:OnPageChanged()
		Layout(self)
	end
	parchment:EnableMouseWheel(true)
	parchment:SetScript("OnMouseWheel", function(_, delta)
		if controls:IsShown() then
			controls:OnMouseWheel(delta)
		end
	end)
end

ns.BuildSpellbookPage = BuildPage
ns.RefreshSpellbookPage = Refresh

--[[
	Redraws whichever page is open, after a change made outside it (the options panel, a profile change).
	Returns whether a page was open.
]]
function ns:RefreshOpenPages()
	local refreshed = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			Refresh(page)
			refreshed = true
		end
	end
	return refreshed
end

--[[
	Brings the macros the add-on made in step with a change made outside the page, whether or not a page is
	open. In combat the rewrite waits for combat to end (ns.SyncAllMacros).
]]
function ns:RefreshMacros()
	if ns:RefreshOpenPages() then
		return
	end
	ns.CollectMacros()
	ns.SyncAllMacros()
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

--[[
	A learned spell or the gear worn changes the page's list; redraw the open page, once per burst, since
	SPELLS_CHANGED fires several times in a row. With no page open, the list is dropped, so the targetRank
	macros rebuild it, new ranks and all, before their next rewrite; but a spell learned that takes over a
	replaced spell's macro (ns.HandOverDue) or that a grouped macro moves up to (ns.GroupSpellLearned)
	rebuilds and rewrites now, so that macro works straight away.
]]
local spellsPending = false

local function RefreshForSpells()
	spellsPending = false
	local groupChanged = ns.GroupSpellLearned()
	if not ns:RefreshOpenPages() then
		wipe(ns.macros)
		if ns.db and (groupChanged or ns.HandOverDue()) then
			ns:RefreshMacros()
		end
	end
end

function ns:OnSpellsChanged()
	if not spellsPending then
		spellsPending = true
		C_Timer.After(0, RefreshForSpells)
	end
end

--[[
	The gear worn changes the Use Items choices, and which ranged attack the Shoot macro casts, so rebuild and
	rewrite the macros, page open or not, once per burst: a gear set swap fires once per slot.
]]
local gearPending = false

function ns:OnPlayerEquipmentChanged()
	ns:InvalidateUsableSlots()
	if gearPending or not ns.db then
		return
	end
	gearPending = true
	C_Timer.After(0, function()
		gearPending = false
		-- In combat nothing can be written, so only an open page redraws; the rest waits for combat to end.
		if InCombatLockdown() then
			if not ns:RefreshOpenPages() then
				ns.QueueMacroSync()
			end
			return
		end
		ns:RefreshMacros()
	end)
end

--[[
	Unlearned spells and unlearned ranks whose names weren't loaded were skipped; redraw once a burst of them
	arrives. It can fire before PLAYER_LOGIN creates the database.
]]
local refreshPending = false

function ns:OnSpellDataLoadResult(spellID)
	local pendingRank = ns.TakePendingRank(spellID)
	if not ns.db or not (pendingRank or ns.ShowsUnlearned()) or refreshPending then
		return
	end
	refreshPending = true
	C_Timer.After(0, function()
		refreshPending = false
		ns:RefreshOpenPages()
	end)
end

-- Placing or removing an action only changes the glows; redraw them once per burst.
local glowsPending = false

local function RedrawGlows()
	glowsPending = false
	local bars
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			bars = bars or ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.UpdateMacroGlow(page.buttons[i], bars)
			end
		end
	end
end

function ns:OnActionbarSlotChanged()
	if not glowsPending then
		glowsPending = true
		C_Timer.After(0, RedrawGlows)
	end
end

--[[
	A macro made, renamed or deleted, here or in the macro window, changes the slot counts and the glows;
	redraw the open page's tiles once per burst, since syncing fires one per macro.
]]
local macrosPending = false

local function RedrawButtons()
	macrosPending = false
	for _, page in ipairs(pages) do
		if page:IsVisible() then
			local bars = ns.ScanActionBars()
			for i = 1, page.buttons.used do
				ns.SetMacroButton(page.buttons[i], page.buttons[i].macro, bars)
			end
			UpdateMacroCount(page)
		end
	end
end

function ns:OnUpdateMacros()
	if not macrosPending then
		macrosPending = true
		C_Timer.After(0, RedrawButtons)
	end
end
