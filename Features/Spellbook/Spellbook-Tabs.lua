local _, ns = ...
local BODY = ns.COLORS_RGB.BODY
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip

--[[
	The page's launcher tab on the Retail-engine spellbook (Blizzard_PlayerSpells), for
	Features/Spellbook/Spellbook-Host-Modern.lua: a tab that runs its onClick and lights while isSelected says so.

	Placement: tabs line up right of the native tabs and skip over tab-sized frames from other add-ons that sit
	in that row. Tabs that don't fit before the search box stack down the book's right edge. Only frames that
	overlap the next free slot push it along, so an add-on that places itself after these tabs can't make them
	leapfrog each other.

	Every frame here is parented to UIParent and only anchored over the book: a frame parented to a Blizzard
	panel stays protected, and in combat could no longer be shown, moved or scaled. Nothing Blizzard owns is
	written to.
]]

local TAB_WIDTH, TAB_HEIGHT, GAP = 44, 32, 8

local SKIN = {
	tab = "spellbook-Tab-Frame-C60",
	tabActive = "spellbook-Tab-Frame-Glow-C60",
	tabGlow = "spellbook-Tab-Frame-glow-gradient-C60",
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
	close, minimize and settings buttons), so they're never taken for another add-on's launcher.
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

function SpellbookTabs:Sync()
	local book = self.book
	if not book then
		return
	end
	local gamepad = InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()
	-- with the Spellbook switched off, its tab goes too: it is the only one registered
	if gamepad or not book:IsVisible() or #self.tabs == 0 or not ns.IsSpellbookEnabled() then
		for _, tab in ipairs(self.tabs) do
			tab.button:Hide()
		end
		return
	end

	-- the buttons hang off UIParent, so they take the book's scale and sit in its strata, under its border
	local scale = book:GetEffectiveScale() / UIParent:GetEffectiveScale()
	local strata, level = PlayerSpellsFrame:GetFrameStrata(), PlayerSpellsFrame.NineSlice:GetFrameLevel() - 5
	for _, tab in ipairs(self.tabs) do
		local button = tab.button
		button:SetScale(scale)
		button:SetFrameStrata(strata)
		button:SetFrameLevel(level)
		SelectTab(button, tab.isSelected ~= nil and tab.isSelected())
		button:Show()
	end
	self:Layout()
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

-- another add-on's launcher can appear after ours were placed, so lay out again when it shows
function SpellbookTabs:HookLauncher(launcher)
	if self.hookedForeign[launcher] or not launcher:HasScript("OnShow") then
		return
	end
	self.hookedForeign[launcher] = true
	launcher:HookScript("OnShow", Relayout)
end

function SpellbookTabs:CreateButton(tab)
	local button = MakeTab(UIParent, tab.icon)
	tab.button = button
	button:Hide()
	button:SetScript("OnClick", function()
		tab.onClick()
	end)
	button:SetScript("OnEnter", function(tabButton)
		GameTooltip:SetOwner(tabButton, "ANCHOR_RIGHT")
		GameTooltip:SetText(tab.name)
		if tab.description then
			GameTooltip:AddLine(tab.description, BODY.r, BODY.g, BODY.b, true)
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

	for _, tab in ipairs(self.tabs) do
		self:CreateButton(tab)
	end

	local function Request()
		SpellbookTabs:RequestSync()
	end
	for _, event in ipairs({ "SpellBookFrame.Show", "SpellBookFrame.Hide", "SpellBookFrame.DisplayedSpellsChanged" }) do
		EventRegistry:RegisterCallback("PlayerSpellsFrame." .. event, Request, SpellbookTabs)
	end
	book:HookScript("OnSizeChanged", Relayout)
	book:HookScript("OnShow", Relayout)
	book:HookScript("OnHide", function()
		SpellbookTabs:Sync()
	end)
	self:RequestSync()
end

--[[
	info is { name (the tab's tooltip title), description (a white line under it), hint ({ key, action }, a
	blue pair under that), icon (texture path or fileID), onClick() (what a click runs), isSelected() (when to
	light it) }; description, hint and isSelected are optional.
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

--[[
	The game's book (Blizzard_PlayerSpells) loads on demand, often only when it first opens, so the tab attaches
	when it loads, through the Spellbook's dispatcher (Spellbook-Core.lua), or at once if it already has.
]]
function ns:OnAddonLoaded(addonName)
	if addonName == "Blizzard_PlayerSpells" then
		SpellbookTabs:Attach()
	end
end

ns.SetModuleEvent("Spellbook", "ADDON_LOADED", true)
if C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
	SpellbookTabs:Attach()
end
