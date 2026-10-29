local _, ns = ...
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local L = ns.L
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local PixelInset = ns.PixelInset

-- A solid line texture on parent, one screen pixel thick along the given axis ("HORIZONTAL" or "VERTICAL").
local function PixelLine(parent, layer, color, axis)
	local line = parent:CreateTexture(nil, layer)
	line:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	local setter = axis == "VERTICAL" and "SetWidth" or "SetHeight"
	if PixelUtil then
		PixelUtil[setter](line, 1, 1)
	else
		line[setter](line, 1)
	end
	return line
end

--[[
	Lays ns.macros (built by Features/Spellbook/Macro-Builder.lua) out in the page's window (Features/Spellbook/Spellbook-Window.lua):
	the parchment with two columns and the page strip, between the controls along its top and the legend and macro
	slot counts along its bottom, which Features/Spellbook/Spellbook-Controls.lua builds. Each category is a block under its header; its spells flow two to a row into the
	very next free slot, a form's run labelled above its own tiles. Features/Spellbook/Macro-Button.lua owns each tile,
	Features/Spellbook/Macro-Menu.lua the right-click menu, Features/Spellbook/Category-Menu.lua the category menu, and Features/Spellbook/Spellbook-Paging.lua the page strip.
	Features/Spellbook/Spellbook-Events.lua redraws the page as the game changes.
]]

-- The window's bands, in UI units from its edges, inside the portrait frame's border.
local TITLE_HEIGHT, CONTROLS_HEIGHT = 24, 36
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

-- Past every section a spellbook tab can make (#ns.PAGE_CATEGORIES + its tab's rank), short of Unlearned's.
local CONSUMABLES_RANK = 1000000

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
		-- a page category's spells alphabetically by the name the page shows, each copy after its spell
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
		GameTooltip:SetText(
			L["PAGE_CATEGORY_SETTINGS"]:format(#header.macros, header.name),
			TITLE.r,
			TITLE.g,
			TITLE.b,
			1,
			true
		)
		GameTooltip:AddLine(L["PAGE_CATEGORY_SETTINGS_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
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

-- Rebuilds the list from the spellbook and the class lists, updates changed macros, then redraws.
local function Refresh(page)
	ns.CollectMacros()
	ns.SyncAllMacros()
	ns.UpdateSpellbookMacroCount(page)
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
ns.spellbookPages = pages -- read by Features/Spellbook/Spellbook-Events.lua

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

	-- the controls row along the top and the footer along the bottom (Features/Spellbook/Spellbook-Controls.lua)
	ns.BuildSpellbookControls(page)

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
ns.LayoutSpellbookPage = Layout
ns.CreateSpellbookGearButton = CreateGearButton

-- The window's bands, which Features/Spellbook/Spellbook-Controls.lua builds the controls row and the footer in.
ns.SPELLBOOK_TITLE_HEIGHT, ns.SPELLBOOK_CONTROLS_HEIGHT = TITLE_HEIGHT, CONTROLS_HEIGHT
ns.SPELLBOOK_FOOTER_HEIGHT, ns.SPELLBOOK_FRAME_BORDER = FOOTER_HEIGHT, FRAME_BORDER
