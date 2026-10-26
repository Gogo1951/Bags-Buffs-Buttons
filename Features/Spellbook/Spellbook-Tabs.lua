local _, ns = ...
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip

--[[
	The page's tab on the Retail-engine spellbook (Blizzard_PlayerSpells), for Features/Spellbook-Host-Modern.lua.

	Placement: tabs line up right of the native tabs and skip over tab-sized frames from other add-ons that sit
	in that row. Tabs that don't fit before the search box stack down the book's right edge. Only frames that
	overlap the next free slot push it along, so an add-on that places itself after these tabs can't make them
	leapfrog each other.

	The page covers the book below its top 60px toolbar and clips its children. page.header covers that
	toolbar, shows and hides with the page, and doesn't clip, so the page can put its own controls there.

	Pages from other add-ons: opening a tab here closes any other add-on's page (a shown frame the size of the
	book, closed through its button over the native selected tab, else hidden), and clicking another add-on's
	launcher (a tab-sized button by the native tabs or down the book's right edge) closes ours.

	Every frame here is parented to UIParent and only anchored over the book: a frame parented to a Blizzard
	panel stays protected, and in combat could no longer be shown, moved or scaled. Nothing Blizzard owns is
	written to.
]]

local TAB_WIDTH, TAB_HEIGHT, GAP = 44, 32, 8
local HEADER_HEIGHT = 60 -- the native tab row, search box and settings dropdown sit in the book's top 60px

local SKIN = {
	tab = "spellbook-Tab-Frame-C60",
	tabActive = "spellbook-Tab-Frame-Glow-C60",
	tabGlow = "spellbook-Tab-Frame-glow-gradient-C60",
	pageLeft = "spellbook-Page-Left-C60",
	pageRight = "spellbook-Page-Right-C60",
}

local SpellbookTabs = {
	tabs = {},
	byId = {},
	owned = {}, -- every frame this file creates, so none is taken for another add-on's
	hookedForeign = {},
}

ns.SpellbookTabs = SpellbookTabs

local function Own(frame)
	SpellbookTabs.owned[frame] = true
	return frame
end

local function MakeTab(parent, icon)
	local button = Own(CreateFrame("Button", nil, parent))
	button:SetSize(TAB_WIDTH, TAB_HEIGHT)
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetSize(34, 33)
	button.icon:SetPoint("BOTTOM", -1, 0)
	button.icon:SetTexture(icon)
	local function FrameArt(atlas, y)
		local texture = button:CreateTexture(nil, "ARTWORK", nil, 1)
		texture:SetAtlas(atlas, true)
		texture:SetPoint("BOTTOM", 0, y)
		return texture
	end
	button.normal = FrameArt(SKIN.tab, 1)
	button.active = FrameArt(SKIN.tabActive, 1)
	button.glow = FrameArt(SKIN.tabGlow, 0)
	return button
end

local function SelectTab(button, selected)
	button.normal:SetShown(not selected)
	button.active:SetShown(selected)
	button.glow:SetShown(selected)
end

-- left, bottom, right, top in screen pixels, so frames with different scales compare
local function ScreenRect(frame)
	local left, bottom, width, height = frame:GetRect()
	if not left then
		return
	end
	local scale = frame:GetEffectiveScale()
	return left * scale, bottom * scale, (left + width) * scale, (bottom + height) * scale
end

-- shown, tab-sized frames we don't own: other add-ons' launchers
local function CollectObstacles(tabScreenWidth, tabScreenHeight)
	local rects = {}
	local seen = {}
	local function Scan(parent)
		if not parent then
			return
		end
		for _, child in ipairs({ parent:GetChildren() }) do
			if not seen[child] and not SpellbookTabs.owned[child] and not child:IsForbidden() and child:IsVisible() then
				seen[child] = true
				local left, bottom, right, top = ScreenRect(child)
				if left then
					local width, height = right - left, top - bottom
					if
						width > tabScreenWidth * 0.4
						and width < tabScreenWidth * 2
						and height > tabScreenHeight * 0.4
						and height < tabScreenHeight * 2
					then
						rects[#rects + 1] = { frame = child, left = left, bottom = bottom, right = right, top = top }
					end
				end
			end
		end
	end
	Scan(PlayerSpellsFrame)
	Scan(SpellbookTabs.book)
	Scan(UIParent)
	return rects
end

--[[
	Frames Blizzard keeps under a key on the spells frame or the book (the book itself, the talents page, the
	close, minimize and settings buttons), so they're never taken for another add-on's page or launcher.
]]
local function BlizzardFrames()
	local set = {}
	for _, parent in ipairs({ PlayerSpellsFrame, SpellbookTabs.book }) do
		for _, value in pairs(parent) do
			if type(value) == "table" then
				set[value] = true
			end
		end
	end
	return set
end

local function IsAncestor(frame, child)
	while child do
		if child == frame then
			return true
		end
		child = child:GetParent()
	end
end

local function ScreenCenter(frame)
	local x, y = frame:GetCenter()
	if not x then
		return
	end
	local scale = frame:GetEffectiveScale()
	return x * scale, y * scale
end

-- shown frames we don't own that cover exactly the book: other add-ons' pages
local function FindForeignPages()
	local book = SpellbookTabs.book
	local pages = {}
	if not book:IsVisible() then
		return pages
	end
	local bookLeft, bookBottom, bookRight, bookTop = ScreenRect(book)
	if not bookLeft then
		return pages
	end
	local tolerance = 4 * book:GetEffectiveScale()
	local blizzard = BlizzardFrames()
	for _, parent in ipairs({ PlayerSpellsFrame, UIParent }) do
		for _, child in ipairs({ parent:GetChildren() }) do
			if
				not SpellbookTabs.owned[child]
				and not blizzard[child]
				and not child:IsForbidden()
				and child:IsVisible()
				and not IsAncestor(child, book)
			then
				local left, bottom, right, top = ScreenRect(child)
				if
					left
					and math.abs(left - bookLeft) <= tolerance
					and math.abs(bottom - bookBottom) <= tolerance
					and math.abs(right - bookRight) <= tolerance
					and math.abs(top - bookTop) <= tolerance
				then
					pages[#pages + 1] = child
				end
			end
		end
	end
	return pages
end

--[[
	Clicks the page's own return tab (a button over the native selected tab) so its add-on knows it closed;
	hiding the page would leave the add-on thinking it's open.
]]
local function CloseForeignPage(page)
	local nativeTabs = SpellbookTabs.book.CategoryTabSystem
	local native = nativeTabs.selectedTabID and nativeTabs:GetTabButton(nativeTabs.selectedTabID)
	local nativeX, nativeY
	if native then
		nativeX, nativeY = ScreenCenter(native)
	end
	if nativeX then
		local tolerance = 4 * native:GetEffectiveScale()
		for _, child in ipairs({ page:GetChildren() }) do
			if not child:IsForbidden() and child:IsObjectType("Button") and child:IsVisible() then
				local x, y = ScreenCenter(child)
				if x and math.abs(x - nativeX) <= tolerance and math.abs(y - nativeY) <= tolerance then
					child:Click()
					return
				end
			end
		end
	end
	page:Hide()
end

-- first free spot along one axis, pushed past every obstacle that overlaps the slot
local function NextFreeRowSlot(obstacles, x, width, bottom, top, gap)
	local moved = true
	while moved do
		moved = false
		for _, rect in ipairs(obstacles) do
			if rect.left < x + width and rect.right > x and rect.bottom < top and rect.top > bottom then
				x = rect.right + gap
				moved = true
			end
		end
	end
	return x
end

local function NextFreeColumnSlot(obstacles, y, height, left, right, gap)
	local moved = true
	while moved do
		moved = false
		for _, rect in ipairs(obstacles) do
			if rect.bottom < y and rect.top > y - height and rect.left < right and rect.right > left then
				y = rect.bottom - gap
				moved = true
			end
		end
	end
	return y
end

function SpellbookTabs:Layout()
	local book = self.book
	local nativeTabs = book.CategoryTabSystem
	local scale = book:GetEffectiveScale()
	local tabsLeft, tabsBottom, tabsRight, tabsTop = ScreenRect(nativeTabs)
	local bookLeft, bookBottom, bookRight, bookTop = ScreenRect(book)
	if not tabsLeft or not bookRight then
		return
	end
	local searchLeft = ScreenRect(book.SearchBox)
	local width, height, gap = TAB_WIDTH * scale, TAB_HEIGHT * scale, GAP * scale
	local obstacles = CollectObstacles(width, height)

	local centerY = (tabsBottom + tabsTop) / 2
	local rowBottom, rowTop = centerY - height / 2, centerY + height / 2
	--[[
		other add-ons' launchers sit where these tabs go: by the native tabs (or hanging below them), or down the
		book's right edge
	]]
	local blizzard = BlizzardFrames()
	for _, rect in ipairs(obstacles) do
		local byTabs = rect.bottom < rowTop + height
			and rect.top > rowBottom - height
			and rect.right > bookLeft
			and rect.left < bookRight
		local byEdge = rect.left > bookRight - width / 2
			and rect.left < bookRight + width
			and rect.top < bookTop + height
			and rect.bottom > bookBottom
		if (byTabs or byEdge) and not blizzard[rect.frame] then
			self:HookLauncher(rect.frame)
		end
	end
	local x = tabsRight + gap
	local columnTop = tabsTop
	local inRow = true
	for _, tab in ipairs(self.tabs) do
		local button = tab.button
		button:ClearAllPoints()
		if inRow then
			x = NextFreeRowSlot(obstacles, x, width, rowBottom, rowTop, gap)
			if searchLeft and x + width > searchLeft - gap then
				inRow = false
			end
		end
		if inRow then
			button:SetPoint("LEFT", nativeTabs, "RIGHT", (x - tabsRight) / scale, 0)
			x = x + width + gap
		else
			columnTop = NextFreeColumnSlot(obstacles, columnTop, height, bookRight, bookRight + width, gap)
			button:SetPoint("TOPLEFT", book, "TOPRIGHT", 0, (columnTop - bookTop) / scale)
			columnTop = columnTop - height - gap
		end
	end
end

local function EnsurePage(tab)
	if tab.page then
		return tab.page
	end
	local root = SpellbookTabs.root
	local page = Own(CreateFrame("Frame", nil, root.content))
	page:SetAllPoints()
	page:Hide()
	tab.page = page
	-- the page is clipped below the toolbar, so toolbar controls go on this unclipped frame instead
	local header = Own(CreateFrame("Frame", nil, root))
	page.header = header
	header:SetPoint("TOPLEFT", root, "TOPLEFT")
	header:SetPoint("BOTTOMRIGHT", root.content, "TOPRIGHT")
	header:Hide()
	if tab.onShow then
		page:SetScript("OnShow", tab.onShow)
	end
	if tab.onHide then
		page:SetScript("OnHide", tab.onHide)
	end
	page:HookScript("OnShow", function()
		header:Show()
	end)
	page:HookScript("OnHide", function()
		header:Hide()
	end)
	if tab.onCreate then
		tab.onCreate(page)
	end
	return page
end

function SpellbookTabs:Sync()
	local book = self.book
	if not book then
		return
	end
	local root, nativeTabs = self.root, book.CategoryTabSystem
	local gamepad = InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()
	-- Open() ran before the spellbook loaded
	if self.active and self.shownTab == nil then
		self.shownTab = nativeTabs.selectedTabID
	end
	-- a native tab was picked (or search took over) since we opened
	if
		gamepad
		or nativeTabs.selectedTabID ~= self.shownTab
		or book.SearchBox:HasFocus()
		or book.SearchPreviewContainer:IsShown()
	then
		self.active = nil
	end
	-- with the Spellbook switched off, its tab goes too: it is the only one registered
	if gamepad or not book:IsVisible() or #self.tabs == 0 or not ns.IsSpellbookEnabled() then
		root:Hide()
		for _, tab in ipairs(self.tabs) do
			tab.button:Hide()
		end
		return
	end
	-- another add-on's page only needs watching while a tab here opens a page of its own, not just a launcher
	for _, tab in ipairs(self.tabs) do
		if not tab.onClick then
			self:HookForeign()
			break
		end
	end

	-- the frames hang off UIParent, so they take the book's scale and sit in its strata, under its border
	local scale = book:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local strata, level = PlayerSpellsFrame:GetFrameStrata(), PlayerSpellsFrame.NineSlice:GetFrameLevel() - 10
	root:SetScale(scale)
	root:SetFrameStrata(strata)
	root:SetFrameLevel(level)
	self.returnTab:SetFrameLevel(level + 5)
	for _, tab in ipairs(self.tabs) do
		local button = tab.button
		button:SetScale(scale)
		button:SetFrameStrata(strata)
		button:SetFrameLevel(level + 5)
		SelectTab(button, tab == self.active or (tab.isSelected ~= nil and tab.isSelected()))
		button:Show()
		-- above the native search box and settings dropdown, so a control placed over them takes the clicks
		if tab.page then
			tab.page.header:SetFrameLevel(level + 5)
		end
	end
	self:Layout()

	local active = self.active
	for _, tab in ipairs(self.tabs) do
		if tab.page and tab ~= active then
			tab.page:Hide()
		end
	end
	if not active then
		return root:Hide()
	end

	local content = root.content
	content.whole:SetShown(book.isMinimized)
	content.left:SetShown(not book.isMinimized)
	content.right:SetShown(not book.isMinimized)
	-- the native selected tab still looks selected underneath, so cover it with an unselected copy
	local native = nativeTabs.selectedTabID and nativeTabs:GetTabButton(nativeTabs.selectedTabID)
	local returnTab = self.returnTab
	returnTab:SetShown(native ~= nil)
	if native then
		returnTab:ClearAllPoints()
		returnTab:SetPoint("CENTER", native)
		returnTab.icon:SetTexture(native.Icon:GetTexture())
	end
	EnsurePage(active):Show()
	root:Show()
end

function SpellbookTabs:RequestSync()
	if self.queued then
		return
	end
	self.queued = true
	RunNextFrame(function()
		SpellbookTabs.queued = false
		SpellbookTabs:Sync()
	end)
end

-- other add-ons lay out on the same show/resize events, so look again once they've settled
local function Relayout()
	SpellbookTabs:RequestSync()
	C_Timer.After(0.2, function()
		SpellbookTabs:RequestSync()
	end)
end

-- another add-on's launcher opens its page, so close ours
function SpellbookTabs:HookLauncher(launcher)
	if self.hookedForeign[launcher] or not launcher:HasScript("OnClick") then
		return
	end
	self.hookedForeign[launcher] = true
	launcher:HookScript("OnClick", function()
		SpellbookTabs:Close()
	end)
	launcher:HookScript("OnShow", Relayout)
end

-- another add-on's page can open some other way too (a key binding, a slash command)
function SpellbookTabs:HookForeign()
	for _, page in ipairs(FindForeignPages()) do
		if not self.hookedForeign[page] then
			self.hookedForeign[page] = true
			page:HookScript("OnShow", function()
				SpellbookTabs:Close()
			end)
		end
	end
end

function SpellbookTabs:CreateButton(tab)
	local button = MakeTab(UIParent, tab.icon)
	tab.button = button
	button:Hide()
	button:SetScript("OnClick", function()
		if tab.onClick then
			tab.onClick()
		elseif SpellbookTabs.active == tab then
			SpellbookTabs:Close()
		else
			SpellbookTabs:Open(tab.id)
		end
	end)
	button:SetScript("OnEnter", function(tabButton)
		GameTooltip:SetOwner(tabButton, "ANCHOR_RIGHT")
		GameTooltip:SetText(tab.name)
		if tab.description then
			GameTooltip:AddLine(tab.description, 1, 1, 1, true)
		end
		if tab.hint then
			GameTooltip:AddDoubleLine(GetColor("INFO") .. tab.hint[1] .. "|r", GetColor("INFO") .. tab.hint[2] .. "|r")
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", HideTooltip)
	button:SetScript("OnHide", HideTooltip)
end

function SpellbookTabs:Attach()
	if self.book then
		return
	end
	local book = PlayerSpellsFrame.SpellBookFrame
	self.book = book

	local root = Own(CreateFrame("Frame", nil, UIParent))
	self.root = root
	root:Hide()
	root:SetAllPoints(book)

	-- parchment that eats the mouse over the native spell pages; the pages are its children
	local content = Own(CreateFrame("Frame", nil, root))
	root.content = content
	content:SetPoint("TOPLEFT", root, "TOPLEFT", 0, -HEADER_HEIGHT)
	content:SetPoint("BOTTOMRIGHT", root, "BOTTOMRIGHT")
	content:SetClipsChildren(true)
	content:EnableMouse(true)
	content:EnableMouseWheel(true)
	local art = CreateFrame("Frame", nil, content)
	art:SetAllPoints(root)
	local function PageArt(atlas, from, to)
		local texture = art:CreateTexture(nil, "BACKGROUND")
		texture:SetAtlas(atlas)
		texture:SetPoint("TOPLEFT", root, from)
		texture:SetPoint("BOTTOMRIGHT", root, to)
		return texture
	end
	content.whole = PageArt(SKIN.pageRight, "TOPLEFT", "BOTTOMRIGHT")
	content.left = PageArt(SKIN.pageLeft, "TOPLEFT", "BOTTOM")
	content.right = PageArt(SKIN.pageRight, "TOP", "BOTTOMRIGHT")

	local returnTab = MakeTab(root)
	self.returnTab = returnTab
	SelectTab(returnTab, false)
	returnTab:SetScript("OnClick", function()
		SpellbookTabs:Close()
	end)

	for _, tab in ipairs(self.tabs) do
		self:CreateButton(tab)
	end

	local function Request()
		SpellbookTabs:RequestSync()
	end
	for _, event in ipairs({ "SpellBookFrame.Show", "SpellBookFrame.Hide", "SpellBookFrame.DisplayedSpellsChanged" }) do
		EventRegistry:RegisterCallback("PlayerSpellsFrame." .. event, Request, SpellbookTabs)
	end
	EventRegistry:RegisterCallback("SpellSearchBox.FocusedGained", Request, SpellbookTabs)
	EventRegistry:RegisterCallback("SpellSearchPreview.FocusedGained", Request, SpellbookTabs)
	book:HookScript("OnSizeChanged", Relayout)
	book:HookScript("OnShow", Relayout)
	book:HookScript("OnHide", function()
		SpellbookTabs:Sync()
	end)
	self:RequestSync()
end

--[[
	info is { name (the tab's tooltip title), description (a white line under it), hint ({ key, action }, a
	blue pair under that), icon (texture path or fileID), onCreate(page) (builds the page, once, on first
	open), onShow(page), onHide(page) }; description, hint and the last three are optional. A launcher tab
	gives onClick() instead, which runs in place of opening a page, and isSelected(), which says when to light
	it.
]]
function SpellbookTabs:RegisterTab(id, info)
	if self.byId[id] then
		return self.byId[id]
	end
	local tab = {
		id = id,
		name = info.name,
		description = info.description,
		hint = info.hint,
		icon = info.icon or ns.QUESTION_MARK_ICON,
		onCreate = info.onCreate,
		onShow = info.onShow,
		onHide = info.onHide,
		onClick = info.onClick,
		isSelected = info.isSelected,
	}
	self.tabs[#self.tabs + 1] = tab
	self.byId[id] = tab
	if self.book then
		self:CreateButton(tab)
		self:RequestSync()
	end
	return tab
end

-- Selects the tab; its page shows once the spellbook is open.
function SpellbookTabs:Open(id)
	local tab = self.byId[id]
	if not tab or self.active == tab then
		return
	end
	if self.book then
		for _, page in ipairs(FindForeignPages()) do
			CloseForeignPage(page)
		end
	end
	self.active = tab
	self.shownTab = self.book and self.book.CategoryTabSystem.selectedTabID
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
	self:Sync()
end

function SpellbookTabs:Close()
	if not self.active then
		return
	end
	self.active = nil
	self:Sync()
end

function SpellbookTabs:IsOpen(id)
	return self.active ~= nil and self.active.id == id
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", function()
	SpellbookTabs:Attach()
end)
