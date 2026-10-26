local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Staples Window
--------------------------------------------------------------------------------

--[[
    The window that opens after login when a level-6+ character has nothing on
    their Restock List, and from the Restock List's Pick Staples button,
    offering the staples -- foods, water, class reagents, ammo -- as one-tick
    suggestions, a few of them pre-ticked for the class. The categories are
    rows in Data/Data.lua (ns.STARTER_LIST_CATEGORIES); the trigger, the
    defaults and what every tick does live in Restocker-Starter-List.lua. This
    file draws them, and clears the Restock List's New flags when it closes.

    It wears the Restock List's frame (Restocker-Window-Frame.lua): the bag
    portrait and the title, the header band left clear (the title bar's X
    closes it), the staples in the inset, and the way back to the list in the footer on the
    login route. There is no don't-show-again: the window only adds what is
    ticked, and a player who wants none of it turns the Restocker off.
    Nothing here is protected.
]]

local BANDS = ns.RESTOCK_WINDOW_BANDS

--[[
    The width holds two staples side by side with the scroll bar showing. The
    height is drawn in to what this character is offered, up to the cap: the
    sections are decided by class and level the moment the window opens, and
    how tall the intro comes out depends on the locale's wording. Only a build
    taller than the cap keeps it and scrolls -- a level-60 rogue's, with
    poisons, ammo and reagents under the food.
]]
local WINDOW_WIDTH = 690
local WINDOW_MAX_HEIGHT = 640
local WINDOW_MIN_HEIGHT = 260

local CONTENT_PADDING = 14 -- inside the inset, around everything it holds
local SCROLL_BAR_SPACE = 26
local PARAGRAPH_GAP = 10
local SECTION_GAP = 16
local HEADER_HEIGHT = 18
local HEADER_GAP = 8 -- the rule under a section's name to its first row
local ROW_HEIGHT = 30
local COLUMN_GAP = 24

-- One staple's cell, left to right: the box, the item's icon, its name, and the stacks dropdown at the cell's end.
local CHECKBOX_SIZE = 24
local ICON_SIZE = 18
local ICON_GAP = 4
local NAME_GAP = 6
local DROPDOWN_WIDTH = 110
local DROPDOWN_GAP = 8

local RULE_COLOR = ns.COLORS_RGB.TITLE

-- The key the window's cold items wait under (ns.WarmItemCache).
local WARM_KEY = "StaplesWindow"

local window
local openedFromLogin = false

--------------------------------------------------------------------------------
-- Choices
--------------------------------------------------------------------------------

--[[
    The counts a staple's dropdown offers, in offered order: every number up to
    its cap, or the category's own choices where it lists them (Soul Shards
    step in fours). A stack is whatever its item stacks to, so the label says
    stacks and the tooltip says how many; a category that counts items
    instead (countsItems) shows a bare number, since "1 Stack" of a thing that
    cannot stack reads as a bug.
]]
local function StackChoices(category)
	local offered = category.choices
	if not offered then
		offered = {}
		for stacks = 1, category.maxStacks do
			offered[stacks] = stacks
		end
	end
	return offered
end

local function StackLabel(category, stacks)
	if category.countsItems then
		return tostring(stacks)
	end
	if stacks == 1 then
		return L["STARTER_POPUP_STACK_ONE"]
	end
	return string.format(L["STARTER_POPUP_STACK_MANY"], stacks)
end

-- Stands in for text built from an item the client has not resolved yet, until the window repaints.
local function LoadingText(itemID)
	return GetColor("MUTED") .. string.format(L["LOADING_ITEM"], itemID) .. "|r"
end

--[[
    One section's categories in display order, holding only the ones this
    class is offered right now -- Restocker-Starter-List.lua's class and
    availability rules keep another class's reagents, a not-yet-trained
    spell's reagent, and items this client's folder does not carry out.

    Display order is computed, never authored: the staples with a stacks
    dropdown lead, the fixed-amount singles follow, and each run sorts
    alphabetically by the name it shows, so every locale reads A to Z. A row
    whose name is still loading sorts after the named ones, by item ID, and
    takes its place when the window repaints with the name.
]]
local function SectionCategories(section)
	local categories = {}
	for _, category in ipairs(ns.GetStarterCategories()) do
		if
			category.section == section
			and ns.IsStarterCategoryForClass(category)
			and ns.IsStarterCategoryAvailable(category)
		then
			categories[#categories + 1] = category
		end
	end

	local names = {}
	for _, category in ipairs(categories) do
		names[category] = ns.GetStarterCategoryName(category) or false
	end
	table.sort(categories, function(a, b)
		local aFixed = a.fixedAmount ~= nil
		local bFixed = b.fixedAmount ~= nil
		if aFixed ~= bFixed then
			return bFixed
		end
		local aName, bName = names[a], names[b]
		if aName and bName then
			return aName < bName
		end
		if aName or bName then
			return aName ~= false
		end
		return ns.GetStarterCategoryNameItemID(a) < ns.GetStarterCategoryNameItemID(b)
	end)
	return categories
end

--[[
    The sections this character is offered, top to bottom from what everyone
    stocks to what one class does: food and water (water as the block's last
    cell, under a heading naming both), the rogue's poisons with their note,
    ammo, then the class reagents and tools, where the Hearthstone closes the
    window as the one row that is nobody's consumable. A section with nothing
    to offer is left out rather than drawn empty.
]]
local function OfferedSections()
	local sections = {}

	local provisions = SectionCategories("food")
	local waterCategories = SectionCategories("water")
	for _, category in ipairs(waterCategories) do
		provisions[#provisions + 1] = category
	end
	if #provisions > 0 then
		sections[#sections + 1] = {
			title = (#waterCategories > 0) and L["STARTER_POPUP_FOOD_AND_WATER_HEADER"]
				or L["STARTER_POPUP_FOOD_HEADER"],
			categories = provisions,
		}
	end

	local poisons = SectionCategories("poisons")
	if #poisons > 0 then
		sections[#sections + 1] = {
			title = L["STARTER_POPUP_POISONS_HEADER"],
			--[[
			    The crafting-reagent half of the Restocker already shops for a
			    listed poison's makings, and a fresh rogue has no way to know
			    that, so the section says so, opening with the class-colored
			    class name the mini-map tooltip's notes open with.
			]]
			note = string.format(
				L["STARTER_POPUP_POISONS_NOTE"],
				ns.GetClassColor("ROGUE") .. UnitClass("player") .. "|r" .. GetColor("BODY")
			),
			categories = poisons,
		}
	end

	local ammo = SectionCategories("ammo")
	if #ammo > 0 then
		sections[#sections + 1] = { title = L["STARTER_POPUP_AMMO_HEADER"], categories = ammo }
	end

	local reagents = SectionCategories("reagents")
	if #reagents > 0 then
		sections[#sections + 1] = { title = L["STARTER_POPUP_REAGENTS_HEADER"], categories = reagents }
	end
	return sections
end

--[[
    Every item an offered staple needs that the client has not resolved yet --
    the one a tick adds, for its stack size, and the one the row is named for
    -- handed to ns.WarmItemCache so the window repaints as the answers land.
]]
local function WarmOfferedItems()
	local coldItemIDs, seen = {}, {}
	local function Cold(itemID)
		if itemID and not seen[itemID] then
			seen[itemID] = true
			coldItemIDs[#coldItemIDs + 1] = itemID
		end
	end
	for _, category in ipairs(ns.GetStarterCategories()) do
		if ns.IsStarterCategoryForClass(category) and ns.IsStarterCategoryAvailable(category) then
			if not ns.GetStarterCategoryStackSize(category) then
				Cold(ns.GetStarterCategoryItemID(category))
			end
			if not ns.GetStarterCategoryName(category) then
				Cold(ns.GetStarterCategoryNameItemID(category))
			end
		end
	end
	ns.WarmItemCache(coldItemIDs, WARM_KEY, function()
		if window and window:IsShown() then
			window:Layout()
		end
	end)
end

--------------------------------------------------------------------------------
-- Pools
--------------------------------------------------------------------------------

-- Acquire hands out pooled frames in order; Release hides the ones the last layout used.
local function Pool(create)
	local pool = { used = 0 }
	function pool.Acquire()
		pool.used = pool.used + 1
		local item = pool[pool.used]
		if not item then
			item = create()
			pool[pool.used] = item
		end
		item:Show()
		return item
	end
	function pool.Release()
		for index = 1, #pool do
			pool[index]:Hide()
		end
		pool.used = 0
	end
	return pool
end

--------------------------------------------------------------------------------
-- Stacks Dropdown
--------------------------------------------------------------------------------

--[[
    The game's own dropdown where the build has the template, as the Spell
    Book's sort and filter dropdowns are; otherwise a plain button opening the
    same menu, its label set on each layout. Live either way round: picked
    first, it decides what a later tick adds; changed after, it rewrites the
    listed entry's amount on the spot.
]]
local function SetupStacksMenu(dropdown)
	return function(_, rootDescription)
		local category = dropdown.category
		if not category then
			return
		end
		for _, stacks in ipairs(StackChoices(category)) do
			rootDescription:CreateRadio(StackLabel(category, stacks), function()
				return ns.GetStarterCategoryStacks(category) == stacks
			end, function()
				ns.SetStarterCategoryStacks(category, stacks)
				if not dropdown.SetupMenu then
					dropdown:SetText(StackLabel(category, stacks))
				end
				-- picking a count can tick the box opposite (see ns.SetStarterCategoryStacks)
				if window and window:IsShown() then
					window:Layout()
				end
			end)
		end
	end
end

local function CreateStacksDropdown(parent)
	local dropdown
	if ns.HasTemplate("WowStyle1DropdownTemplate") then
		dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		dropdown:SetWidth(DROPDOWN_WIDTH)
		dropdown:SetupMenu(SetupStacksMenu(dropdown))
	else
		dropdown = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		dropdown:SetSize(DROPDOWN_WIDTH, 22)
		dropdown:SetScript("OnClick", function(self)
			MenuUtil.CreateContextMenu(self, SetupStacksMenu(self))
		end)
	end
	dropdown:SetScript("OnEnter", function(self)
		local category = self.category
		local text
		if category.countsItems then
			text = L["STARTER_POPUP_COUNT_DESCRIPTION"]
		else
			local stackSize = ns.GetStarterCategoryStackSize(category)
			text = stackSize and string.format(L["STARTER_POPUP_STACKS_DESCRIPTION"], stackSize)
				or LoadingText(ns.GetStarterCategoryItemID(category))
		end
		ns.ShowRestockerTooltip(self, text)
	end)
	dropdown:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return dropdown
end

local function RefreshStacksDropdown(dropdown, category)
	dropdown.category = category
	if dropdown.GenerateMenu then
		dropdown:GenerateMenu()
	else
		dropdown:SetText(StackLabel(category, ns.GetStarterCategoryStacks(category)))
	end
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
    One staple: the checkbox, the item's icon, its name, and the stacks
    dropdown at the cell's right end. Ticking adds the item --
    Restocker-Starter-List.lua picks the tier for the character's level -- and
    unticking removes it, whichever tier the list is holding by then. The icon
    shows which item a food row, named for its kind, is today; it comes off the
    client's own item table, so it never waits on the server as a name can.
    Hovering the name or the icon names the exact item and count a tick adds
    right now. A fixed-amount staple (a totem) has no dropdown.
]]
local function CreateStapleCell(content)
	local cell = CreateFrame("Frame", nil, content)
	cell:SetHeight(ROW_HEIGHT)

	local checkbox = CreateFrame("CheckButton", nil, cell, "UICheckButtonTemplate")
	checkbox:SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE)
	checkbox:SetPoint("LEFT", cell, "LEFT", 0, 0)
	checkbox:SetScript("OnClick", function(self)
		local checked = self:GetChecked() and true or false
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		ns.SetStarterCategory(cell.category, checked)
		window:Layout()
	end)
	cell.checkbox = checkbox

	local icon = cell:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", checkbox, "RIGHT", ICON_GAP, 0)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	cell.icon = icon

	local dropdown = CreateStacksDropdown(cell)
	dropdown:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
	cell.dropdown = dropdown

	--[[
	    The name takes the room between the icon and the dropdown, truncating
	    rather than running under it. A button only so it can be hovered and
	    clicked: a click on the name ticks the box, as a checkbox label does.
	]]
	local label = CreateFrame("Button", nil, cell)
	label:SetPoint("LEFT", icon, "LEFT", 0, 0)
	label:SetHeight(ROW_HEIGHT)
	local name = label:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	name:SetPoint("LEFT", icon, "RIGHT", NAME_GAP, 0)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	cell.name = name
	cell.label = label
	label:SetScript("OnClick", function()
		checkbox:Click()
	end)
	label:SetScript("OnEnter", function(self)
		local category = cell.category
		ns.ShowRestockerTooltip(
			self,
			ns.DescribeStarterCategory(category) or LoadingText(ns.GetStarterCategoryItemID(category))
		)
	end)
	label:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	ns.ApplyRestockerElvUISkin(nil, nil, { checkbox })
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if skins and dropdown.SetupMenu then
		pcall(skins.HandleDropDownBox, skins, dropdown, DROPDOWN_WIDTH)
	elseif skins then
		pcall(skins.HandleButton, skins, dropdown)
	end
	return cell
end

local function FillStapleCell(cell, category, width)
	cell.category = category
	cell:SetWidth(width)
	cell.checkbox:SetChecked(ns.IsStarterCategoryChecked(category))

	local itemID = ns.GetStarterCategoryItemID(category)
	cell.icon:SetTexture(itemID and C_Item.GetItemIconByID(itemID) or ns.QUESTION_MARK_ICON)
	cell.name:SetText(ns.GetStarterCategoryName(category) or LoadingText(ns.GetStarterCategoryNameItemID(category)))

	local hasDropdown = not category.fixedAmount
	cell.dropdown:SetShown(hasDropdown)
	if hasDropdown then
		RefreshStacksDropdown(cell.dropdown, category)
		cell.name:SetPoint("RIGHT", cell.dropdown, "LEFT", -DROPDOWN_GAP, 0)
		cell.label:SetPoint("RIGHT", cell.dropdown, "LEFT", -DROPDOWN_GAP, 0)
	else
		cell.name:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
		cell.label:SetPoint("RIGHT", cell, "RIGHT", 0, 0)
	end
end

-- A section's name in gold with a rule running from it to the column's end, as the Restock List's headings are.
local function CreateSectionHeader(content)
	local header = CreateFrame("Frame", nil, content)
	header:SetHeight(HEADER_HEIGHT)
	local text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("LEFT", header, "LEFT", 0, 0)
	header.text = text
	local rule = header:CreateTexture(nil, "ARTWORK")
	rule:SetHeight(1)
	rule:SetPoint("LEFT", text, "RIGHT", 8, 0)
	rule:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	rule:SetColorTexture(RULE_COLOR.r, RULE_COLOR.g, RULE_COLOR.b, 0.25)
	return header
end

local function CreateParagraph(content)
	local text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(true)
	return text
end

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

--[[
    The intro: a paragraph saying why the window opened and what a check does.
    The opening sentence answers to how the window was reached, because both
    routes are real: the login trigger only fires over an empty list, and
    writes the class's pre-ticked staples onto it just before the window
    opens, while Pick Staples opens it over whatever the player already has.
]]
local function IntroText()
	local introKey = "STARTER_POPUP_INTRO_STOCKED"
	if openedFromLogin then
		introKey = "STARTER_POPUP_INTRO_LOGIN"
	elseif ns.IsRestockListEmpty() then
		introKey = "STARTER_POPUP_INTRO_EMPTY"
	end
	return GetColor("BODY") .. L[introKey] .. " " .. L["STARTER_POPUP_INTRO_HOW"] .. "|r"
end

--[[
    Lays the whole body out from the top, then draws the window in to it, up to
    the cap. Run on every open, on every tick (a tick can change which item a
    row names), and as item names arrive.
]]
local function Layout(frame)
	local content = frame.content
	frame.headers.Release()
	frame.cells.Release()
	frame.paragraphs.Release()

	local width = frame.scrollFrame:GetWidth()
	content:SetWidth(width)
	local inner = width - 2 * CONTENT_PADDING
	local columnWidth = (inner - COLUMN_GAP) / 2
	local y = CONTENT_PADDING

	local function Paragraph(text)
		local paragraph = frame.paragraphs.Acquire()
		paragraph:ClearAllPoints()
		paragraph:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING, -y)
		paragraph:SetWidth(inner)
		paragraph:SetText(text)
		y = y + paragraph:GetStringHeight() + PARAGRAPH_GAP
	end

	Paragraph(IntroText())

	for _, section in ipairs(OfferedSections()) do
		y = y + SECTION_GAP - PARAGRAPH_GAP
		local header = frame.headers.Acquire()
		header:ClearAllPoints()
		header:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING, -y)
		header:SetWidth(inner)
		header.text:SetText(section.title)
		y = y + HEADER_HEIGHT + HEADER_GAP

		if section.note then
			Paragraph(GetColor("BODY") .. section.note .. "|r")
		end

		for index, category in ipairs(section.categories) do
			local column = (index - 1) % 2
			local cell = frame.cells.Acquire()
			cell:ClearAllPoints()
			cell:SetPoint("TOPLEFT", content, "TOPLEFT", CONTENT_PADDING + column * (columnWidth + COLUMN_GAP), -y)
			FillStapleCell(cell, category, columnWidth)
			if column == 1 or index == #section.categories then
				y = y + ROW_HEIGHT
			end
		end
	end

	y = y + CONTENT_PADDING
	content:SetHeight(y)

	local chrome = BANDS.TITLE_HEIGHT + BANDS.CONTROLS_HEIGHT + BANDS.FOOTER_HEIGHT + BANDS.FRAME_BORDER + 8
	frame:SetHeight(math.max(WINDOW_MIN_HEIGHT, math.min(WINDOW_MAX_HEIGHT, y + chrome)))
	WarmOfferedItems()
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

--[[
    The footer, on the login route only: the list opened for the player there,
    and the command is how they get it back once both windows are closed. From
    the Pick Staples button they already found their own way to it.
]]
local function CreateFooter(frame)
	local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	hint:SetPoint("LEFT", frame, "BOTTOMLEFT", 12, BANDS.FRAME_BORDER + BANDS.FOOTER_HEIGHT / 2)
	hint:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -12, BANDS.FRAME_BORDER + BANDS.FOOTER_HEIGHT / 2)
	hint:SetJustifyH("LEFT")
	hint:SetWordWrap(false)
	frame.footerHint = hint
end

local function CreateWindow()
	local frame = ns.CreateRestockerPortraitFrame("BagsBuffsButtonsStaplesFrame", L["STARTER_POPUP_TITLE"])
	frame:SetSize(WINDOW_WIDTH, WINDOW_MAX_HEIGHT)
	frame:SetPoint("CENTER")
	-- Over the Restock List, which stays open behind it.
	frame:SetFrameStrata("DIALOG")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	table.insert(UISpecialFrames, frame:GetName())
	frame:Hide()

	local inset = ns.CreateRestockerBodyInset(frame)
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", inset, "TOPLEFT", 4, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -SCROLL_BAR_SPACE, 4)
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(1, 1)
	scrollFrame:SetScrollChild(content)
	frame.scrollFrame = scrollFrame
	frame.content = content

	frame.headers = Pool(function()
		return CreateSectionHeader(content)
	end)
	frame.cells = Pool(function()
		return CreateStapleCell(content)
	end)
	frame.paragraphs = Pool(function()
		return CreateParagraph(content)
	end)
	CreateFooter(frame)
	frame.Layout = Layout

	--[[
	    Closing this window retires its "New" flags: the group is a note about
	    items just added here, and once the window is gone the note is stale --
	    the same rule as the Restock List's own OnHide, and as true with that
	    window still open behind this one, where the repaint below files the new
	    rows under their own types. It also hands Escape back to the list.
	]]
	frame:SetScript("OnHide", function()
		openedFromLogin = false
		ns.SetRestockWindowClosesOnEscape(true)
		ns.ClearRestockNewItems()
		ns.UpdateRestockList()
	end)

	return frame
end

-- fromLogin: true only from the login trigger.
function ns.ShowStarterListPopup(fromLogin)
	window = window or CreateWindow()
	openedFromLogin = fromLogin == true
	window.footerHint:SetText(
		openedFromLogin
				and string.format(
					L["STARTER_POPUP_COMMAND_HINT"],
					GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
				)
			or ""
	)
	-- So Escape closes this window alone; OnHide hands Escape back to the list.
	ns.SetRestockWindowClosesOnEscape(false)
	window:Show()
	window:Raise()
	window:Layout()
	window.scrollFrame:SetVerticalScroll(0)
end

function ns.CloseStarterListPopup()
	if window and window:IsShown() then
		window:Hide()
	end
end
