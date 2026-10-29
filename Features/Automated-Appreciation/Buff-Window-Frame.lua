local _, ns = ...
local Data = ns.Data
local L = ns.L

local GetColor = ns.GetColor

--[[
    The Buff Window's frames: draws the sections Features/Automated-Appreciation/Buff-Window.lua builds
    as a click-to-cast list. Every icon is a SecureActionButtonTemplate button,
    because casting a spell from a click is protected -- and that one fact shapes
    this file. A secure button's attributes, position and visibility can only
    change out of combat, so everything that lays the window out refuses to run
    in combat, and the caller redraws once combat ends. Mid-fight only alpha
    (the range fade), which the client allows on a protected frame, and the
    cooldown swipes, plain children of the buttons, still change.

    Two frames stack so combat visibility and our own never fight: the anchor
    belongs to a secure state driver (Hide in Combat), and the content inside it
    is shown and hidden by this file, out of combat only. The content carries a
    title bar whose close button turns Buff Duty off for the class you're
    playing (ns.CloseBuffWindow).
]]

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

local ICON_SIZE = Data.BUFF_WINDOW_ICON_SIZE
local ICON_GAP = 4
-- An icon plus the same 4-pixel gap between rows as between icons.
local ROW_HEIGHT = ICON_SIZE + ICON_GAP
--[[
    Extra room under each section (a party, Return the Favor, Target), so one
    party's last member doesn't crowd the next party's header.
]]
local SECTION_GAP = 4
--[[
    The name column fits the longest name on the list, between these bounds:
    never narrower than a short name needs to look tidy, and never so wide that a
    long title-and-realm string pushes the icons off across the screen.
]]
local MIN_NAME_WIDTH = 80
local MAX_NAME_WIDTH = 260
-- Room between the end of the longest name and the first icon.
local NAME_GAP = 8
-- A member's role icon lines up with the header above it.
local MEMBER_INDENT = 0
--[[
    Parties sit two to a row, reading across -- 1 2, then 3 4 -- and the
    columns stand this far apart.
]]
local PARTIES_PER_ROW = 2
local COLUMN_GAP = 16
-- A pet sits one step further in, under its owner.
local PET_INDENT = 10
local PADDING = 7
--[[
    The title bar: one icon-high row for the title and close button, then one
    blank row before the first section so the title doesn't read as one of them.
]]
local TITLE_HEIGHT = ICON_SIZE
local TITLE_GAP = ROW_HEIGHT + ICON_GAP
local CLOSE_SIZE = 22
-- Room between the end of the title and the close button.
local TITLE_CLOSE_GAP = 8
local OUT_OF_RANGE_ALPHA = 0.35
local RANGE_INTERVAL = 0.5

--[[
    Where the window's top-left corner sits until it is first dragged: a little
    left of and above the middle of the screen.
]]
local DEFAULT_X, DEFAULT_Y = -110, 160

local BACKDROP = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	edgeSize = 12,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local anchor, content, title
local labels, icons = {}, {}
local usedLabels, usedIcons = 0, 0
local lastSignature
local rangeTicker

--------------------------------------------------------------------------------
-- Position
--------------------------------------------------------------------------------

local function RestorePosition()
	local point = ns.db.global.buffWindow.point
	anchor:ClearAllPoints()
	if point then
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", point[1], point[2])
	else
		anchor:SetPoint("TOPLEFT", UIParent, "CENTER", DEFAULT_X, DEFAULT_Y)
	end
end

--[[
    Saved as the top-left corner, so a window that grows or shrinks with the
    list keeps its top edge where the player put it.
]]
local function SavePosition()
	ns.db.global.buffWindow.point = { anchor:GetLeft(), anchor:GetTop() }
end

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

local function OnIconEnter(self)
	local spec = self.spec
	if not spec then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if spec.itemId then
		GameTooltip:SetItemByID(spec.itemId)
	else
		GameTooltip:SetSpellByID(spec.spellId)
	end
	GameTooltip:AddLine(" ")
	-- A Self Buffs weapon or Soulstone icon brings its own hint, already worded.
	local hint = spec.hint
	if not hint then
		local text = (spec.favorGUID and L["BUFF_WINDOW_TOOLTIP_FAVOR"])
			or (spec.isGroup and L["BUFF_WINDOW_TOOLTIP_GROUP"])
			or L["BUFF_WINDOW_TOOLTIP_CAST"]
		hint = text:format(spec.targetName)
	end
	GameTooltip:AddLine(GetColor("INFO") .. hint .. "|r", 1, 1, 1, true)
	if spec.favorGUID then
		GameTooltip:AddLine(
			GetColor("INFO") .. L["BUFF_WINDOW_TOOLTIP_DISMISS"]:format(spec.targetName) .. "|r",
			1,
			1,
			1,
			true
		)
	end
	GameTooltip:Show()
end

local function OnIconLeave()
	GameTooltip:Hide()
end

--[[
    PreClick, because the secure click fires the game's "replace your
    enchant?" question before PostClick runs (Buff-Window-Weapons.lua answers it).
    Every cast is noted too, so a "more powerful spell" refusal can be pinned
    on who it was aimed at (ns.NoteBuffCastAttempt).
]]
local function OnIconPreClick(self, button)
	if button ~= "LeftButton" or not self.spec then
		return
	end
	if self.spec.confirmReplace then
		ns.ExpectReplaceEnchant()
	end
	ns.NoteBuffCastAttempt(self.spec)
end

--[[
    Right-click on a favor drops that stranger from the list. Buttons register
    both up and down (below), so this answers the up half only.
]]
local function OnIconPostClick(self, button, down)
	if button == "RightButton" and not down and self.spec and self.spec.favorGUID then
		ns.DismissFavor(self.spec.favorGUID)
	end
end

local function AcquireIcon()
	usedIcons = usedIcons + 1
	local button = icons[usedIcons]
	if not button then
		button = CreateFrame("Button", nil, content, "SecureActionButtonTemplate")
		button:SetSize(ICON_SIZE, ICON_SIZE)
		--[[
		    Both halves: the secure template acts on the one ActionButtonUseKeyDown
		    names and ignores the other, so registering only "AnyUp" leaves the
		    button dead for anyone casting on key down.
		]]
		button:RegisterForClicks("AnyUp", "AnyDown")
		button.icon = button:CreateTexture(nil, "ARTWORK")
		button.icon:SetAllPoints()
		-- Trims the baked-in border every spell icon carries.
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		--[[
		    The action bar's own swipe and countdown, so a buff still on cooldown
		    reads exactly as it would on a bar (OmniCC and friends pick it up too).
		    A plain child of the secure button, so it updates freely in combat.
		]]
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cooldown:SetAllPoints()
		button.cooldown:SetHideCountdownNumbers(false)
		-- The template's numbers are sized for a 36-pixel bar button; ours is 20.
		if button.cooldown.SetCountdownFont then
			button.cooldown:SetCountdownFont("GameFontHighlightSmallOutline")
		end
		button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
		button:SetScript("OnEnter", OnIconEnter)
		button:SetScript("OnLeave", OnIconLeave)
		button:SetScript("PreClick", OnIconPreClick)
		button:SetScript("PostClick", OnIconPostClick)
		icons[usedIcons] = button
	end
	return button
end

--[[
    Left button only ("type1"): a right-click finds no "type2" and no bare
    "type" to fall back on, so it casts nothing and is free for dismissing a
    favor. Every attribute is written on every use, nil included, because a
    pooled button still carries whatever its last spec set; a nil spec clears
    them all. Shared with the Buff Key, which writes the same attributes.
]]
function ns.SetBuffButtonAttributes(button, spec)
	if not spec then
		for _, key in ipairs({ "type1", "spell", "item", "unit", "macrotext", "target-slot" }) do
			button:SetAttribute(key, nil)
		end
		return
	end
	--[[
	    The weapon a poison goes on: the template uses this slot once the item
	    leaves the cursor waiting on one.
	]]
	button:SetAttribute("target-slot", spec.targetSlot)
	if spec.macrotext then
		button:SetAttribute("type1", "macro")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", nil)
		button:SetAttribute("macrotext", spec.macrotext)
	elseif spec.item then
		-- "item:12345", resolved by the template the way /use resolves it.
		button:SetAttribute("type1", "item")
		button:SetAttribute("spell", nil)
		button:SetAttribute("item", spec.item)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	else
		button:SetAttribute("type1", "spell")
		--[[
		    Rank text ("Name(Rank 2)") casts that exact rank through the secure
		    template's CastSpellByName; a bare name casts your highest. Not a spell
		    ID: the template hands a number to CastSpellByID, and on Classic Era a
		    lower rank's ID cast nothing. Group buffs pass their highest rank's
		    text too: Prayer of Fortitude's bare name cast Rank 1.
		]]
		button:SetAttribute("spell", spec.castSpell or spec.spellName)
		button:SetAttribute("item", nil)
		button:SetAttribute("unit", spec.unit)
		button:SetAttribute("macrotext", nil)
	end
end

local function SetIcon(button, spec)
	button.spec = spec
	if spec.itemId then
		button.icon:SetTexture(C_Item.GetItemIconByID(spec.itemId))
	else
		button.icon:SetTexture(C_Spell.GetSpellTexture(spec.spellId))
	end
	ns.SetBuffButtonAttributes(button, spec)
	button:Show()
end

--------------------------------------------------------------------------------
-- Labels
--------------------------------------------------------------------------------

local function AcquireLabel()
	usedLabels = usedLabels + 1
	local label = labels[usedLabels]
	if not label then
		label = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		label:SetJustifyH("LEFT")
		label:SetWordWrap(false)
		labels[usedLabels] = label
	end
	return label
end

--------------------------------------------------------------------------------
-- Cooldowns
--------------------------------------------------------------------------------

local GetItemCooldown = C_Container.GetItemCooldown

-- An item icon (a poison, a Soulstone) shows the item's own cooldown.
-- Each spell's cooldown, read once per pass of UpdateCooldowns: false where the client had none.
local cooldownsThisPass = {}

local function GetCooldown(spec)
	if spec.itemId then
		local start, duration = GetItemCooldown(spec.itemId)
		return start, duration, 1
	end
	local info = cooldownsThisPass[spec.spellId]
	if info == nil then
		info = C_Spell.GetSpellCooldown(spec.spellId) or false
		cooldownsThisPass[spec.spellId] = info
	end
	if info then
		return info.startTime, info.duration, info.modRate
	end
	return nil
end

--[[
    Draws each icon's cooldown the way an action button does, global cooldown
    included. Every rank shares one cooldown, so the spec's own id is enough. A
    value the client keeps secret leaves the swipe as it was rather than
    erroring; the next update after combat corrects it.

    With no cooldown running, an icon for a buff that is running low (not gone)
    shows how much of it is left as a sliver: reversed, so the bright part is
    the time remaining and the dark part the time spent. No countdown, ours or
    a cooldown-count add-on's (noCooldownCount): the sliver alone reads at a
    glance. It ends whole once the buff runs out.
]]
local function UpdateCooldowns()
	if not content or not content:IsVisible() then
		return
	end
	local now = GetTime()
	wipe(cooldownsThisPass)
	for i = 1, usedIcons do
		local button = icons[i]
		local spec = button.spec
		local start, duration, modRate
		if spec then
			start, duration, modRate = GetCooldown(spec)
		end
		if ns.IsPlain(start) and ns.IsPlain(duration) then
			local cooldown = button.cooldown
			if start and duration and duration > 0 then
				cooldown:SetReverse(false)
				cooldown:SetHideCountdownNumbers(false)
				cooldown.noCooldownCount = nil
				cooldown:SetCooldown(start, duration, modRate or 1)
			elseif spec.buffExpires and spec.buffExpires > now then
				cooldown:SetReverse(true)
				cooldown:SetHideCountdownNumbers(true)
				cooldown.noCooldownCount = true
				cooldown:SetCooldown(spec.buffExpires - spec.buffDuration, spec.buffDuration)
			else
				cooldown:Clear()
			end
		end
	end
end

local function OnSpellUpdateCooldown()
	UpdateCooldowns()
end

ns.SetEventHandler("SPELL_UPDATE_COOLDOWN", OnSpellUpdateCooldown)

--------------------------------------------------------------------------------
-- Range
--------------------------------------------------------------------------------

local IsItemInRange = C_Item.IsItemInRange

--[[
    An item used on someone (a Soulstone) asks the item's own range out of
    combat only, and falls back on the buffs' check in combat or when the
    client has no answer. The Buff Key asks it too.
]]
local function InRange(spec)
	if spec.itemId and spec.unit and not InCombatLockdown() then
		local isPlayer = UnitIsUnit(spec.unit, "player")
		if ns.IsPlain(isPlayer) and not isPlayer then
			local inRange = IsItemInRange(spec.itemId, spec.unit)
			if ns.IsPlain(inRange) and inRange ~= nil then
				return inRange and true or false
			end
		end
	end
	return ns.IsBuffInRange(spec.unit, spec.spellName)
end
ns.IsBuffSpecInRange = InRange

local function UpdateRange()
	if not content:IsVisible() then
		return
	end
	for i = 1, usedIcons do
		local button = icons[i]
		local spec = button.spec
		local inRange = not spec or InRange(spec)
		button:SetAlpha(inRange and 1 or OUT_OF_RANGE_ALPHA)
	end
end

local function StartRangeTicker()
	if not rangeTicker then
		rangeTicker = C_Timer.NewTicker(RANGE_INTERVAL, UpdateRange)
	end
end

local function StopRangeTicker()
	if rangeTicker then
		rangeTicker:Cancel()
		rangeTicker = nil
	end
end

--------------------------------------------------------------------------------
-- Render
--------------------------------------------------------------------------------

--[[
    Everything a redraw would write, as one string, so an unchanged list (the
    usual result of a raid's constant aura traffic) skips the redraw entirely.
]]
local function Signature(sections)
	local parts = {}
	local function AddIcons(list)
		for _, spec in ipairs(list) do
			parts[#parts + 1] = spec.column
				.. ":"
				.. (spec.castSpell or spec.spellName or spec.item or ("item:" .. tostring(spec.itemId)))
				.. "@"
				.. (spec.unit or "")
				.. (spec.targetSlot or "")
				.. (spec.macrotext or "")
				.. "~"
				.. (spec.buffExpires or "")
		end
	end
	for _, section in ipairs(sections) do
		parts[#parts + 1] = "#" .. (section.grid or "") .. section.label
		AddIcons(section.icons)
		for _, row in ipairs(section.rows) do
			parts[#parts + 1] = (row.pet and ">>" or ">") .. (row.grid or "") .. row.label
			AddIcons(row.icons)
		end
	end
	return table.concat(parts, "|")
end

--[[
    A width of 0 lets the text run unconstrained, so the measure is the whole
    name rather than whatever fit the last layout's column.
]]
local function MeasureLabel(text, indent)
	local label = AcquireLabel()
	label:SetWidth(0)
	label:SetText(text)
	return label, indent + label:GetStringWidth()
end

--[[
    How tall a line's content stands: an icon's height for every line, a bare
    header included. The window's top and bottom edges are measured from this,
    so a line keeps its room whether or not a buff icon is showing on it, and
    the window holds still as icons come and go.
]]
local function ContentHeight()
	return ICON_SIZE
end

--[[
    `offsets` maps a buff's column to how far its icon sits from the grid's
    first, in pixels. `x` is the left edge of the window column the row sits
    in, `y` the row's middle.
]]
local function PlaceRow(line, x, y, nameWidth, offsets)
	local label, indent = line.label, line.indent
	label:ClearAllPoints()
	label:SetPoint("LEFT", content, "TOPLEFT", x + indent, y)
	label:SetWidth(nameWidth - indent)
	label:Show()

	local left = x + nameWidth + NAME_GAP
	for _, spec in ipairs(line.specs) do
		local button = AcquireIcon()
		button:ClearAllPoints()
		button:SetPoint("LEFT", content, "TOPLEFT", left + offsets[spec.column], y)
		SetIcon(button, spec)
	end
end

--[[
    The icons sit in a grid: one column per buff, so a buff lines up down the
    whole window and a party's group buff sits over the single one it
    replaces. A member who doesn't need a buff leaves its cell empty. Only the
    columns some icon uses are kept, in buff order, so a buff nobody needs
    leaves no gap.

    A section can name its own grid (Self Buffs does): its columns are other
    buffs than the parties', so lining them up with the parties' would only
    push them right. A row can name one too (each weapon hand does), so its
    icons start at the left whatever the header's hold. Returns grid ->
    (column -> pixels from the first icon), and grid -> the icons' whole
    width. The party columns share one grid, so a buff sits at the same place
    in each.
]]
local MAIN_GRID = "main"

local function GridSlots(sections)
	local used = {}
	local function Mark(grid, list)
		used[grid] = used[grid] or {}
		for _, spec in ipairs(list) do
			used[grid][spec.column] = true
		end
	end
	for _, section in ipairs(sections) do
		local grid = section.grid or MAIN_GRID
		Mark(grid, section.icons)
		for _, row in ipairs(section.rows) do
			Mark(row.grid or grid, row.icons)
		end
	end

	local offsetsByGrid, widths = {}, {}
	for grid, columnSet in pairs(used) do
		local columns = {}
		for column in pairs(columnSet) do
			columns[#columns + 1] = column
		end
		table.sort(columns)
		local offsets, x = {}, 0
		for slot, column in ipairs(columns) do
			if slot > 1 then
				x = x + ICON_SIZE + ICON_GAP
			end
			offsets[column] = x
		end
		offsetsByGrid[grid] = offsets
		widths[grid] = #columns > 0 and x + ICON_SIZE or 0
	end
	return offsetsByGrid, widths
end

--[[
    Places a run of lines down from `y`, the first one's middle. Returns where
    the next run's first middle goes, and the lowest edge this run drew.
]]
local function PlaceLines(lines, x, y, nameWidth, offsetsByGrid)
	local bottom = y
	for _, line in ipairs(lines) do
		PlaceRow(line, x, y, nameWidth, offsetsByGrid[line.grid])
		bottom = y - ContentHeight(line) / 2
		y = y - ROW_HEIGHT
		if line.sectionEnd then
			y = y - SECTION_GAP
		end
	end
	return y, bottom
end

local function ReleaseAll()
	for i = 1, usedLabels do
		labels[i]:Hide()
	end
	for i = 1, usedIcons do
		icons[i]:Hide()
		icons[i].spec = nil
	end
	usedLabels, usedIcons = 0, 0
end

function ns.RenderBuffWindow(sections)
	if InCombatLockdown() or not content then
		return
	end

	local signature = Signature(sections)
	if signature ~= lastSignature then
		lastSignature = signature
		ReleaseAll()

		--[[
		    Two passes: every label is measured before any is placed, because the
		    icon column starts where the longest name ends. The sections before
		    the parties (Self-Buffs, Target, Return the Favor) run across the top;
		    the parties go under them PARTIES_PER_ROW to a row, so a full raid's
		    eight groups stand four rows high instead of running off the screen.
		]]
		local top, partyRows = {}, {}
		local parties = 0
		local nameWidth = MIN_NAME_WIDTH
		for _, section in ipairs(sections) do
			local lines = top
			if section.party then
				parties = parties + 1
				local index = math.ceil(parties / PARTIES_PER_ROW)
				partyRows[index] = partyRows[index] or {}
				lines = {}
				table.insert(partyRows[index], lines)
			end
			local grid = section.grid or MAIN_GRID
			local function Measure(text, indent, specs, lineGrid, header)
				local label, width = MeasureLabel(text, indent)
				lines[#lines + 1] = { label = label, indent = indent, specs = specs, grid = lineGrid, header = header }
				nameWidth = math.max(nameWidth, width)
			end
			Measure(GetColor("TITLE") .. section.label .. "|r", 0, section.icons, grid, true)
			for _, row in ipairs(section.rows) do
				-- A row can set its own indent: the weapon hands sit flush with their header.
				Measure(row.label, row.indent or (row.pet and PET_INDENT or MEMBER_INDENT), row.icons, row.grid or grid)
			end
			lines[#lines].sectionEnd = true
		end
		nameWidth = math.min(math.ceil(nameWidth), MAX_NAME_WIDTH)

		-- A window column: the names, then as many icons as its grid keeps.
		local offsetsByGrid, iconWidths = GridSlots(sections)
		local function ColumnWidth(grid)
			return nameWidth + NAME_GAP + math.max(iconWidths[grid] or 0, ICON_SIZE)
		end
		local function ContentWidth()
			local width = 0
			for _, line in ipairs(top) do
				width = math.max(width, ColumnWidth(line.grid))
			end
			local partyWidth = ColumnWidth(MAIN_GRID)
			local partyColumns = math.min(parties, PARTIES_PER_ROW)
			if partyColumns > 0 then
				width = math.max(width, (partyColumns - 1) * (partyWidth + COLUMN_GAP) + partyWidth)
			end
			return width
		end

		--[[
		    The close button sits over the far-right icon column (see
		    CreateBuffWindowFrame), so the window is never narrower than the
		    title plus that column. A short list widens its name column to make
		    up the difference, which pushes the icons right until the last one
		    sits under the close button.
		]]
		local minWidth = math.ceil(title:GetStringWidth()) + TITLE_CLOSE_GAP + (CLOSE_SIZE + ICON_SIZE) / 2
		local width = ContentWidth()
		if width < minWidth then
			nameWidth = nameWidth + (minWidth - width)
			width = ContentWidth()
		end

		--[[
		    Rows sit ROW_HEIGHT apart, middle to middle, but the first and last
		    are measured by what they show: TITLE_GAP under the title bar to the
		    top of the first line's content, and PADDING from the bottom of the
		    lowest's to the window's edge, the same as the sides. The parties in a
		    row start level, and the next row starts under the taller of them.
		]]
		local first = top[1] or partyRows[1][1][1]
		local firstMiddle = -(PADDING + TITLE_HEIGHT + TITLE_GAP + ContentHeight(first) / 2)
		local y, bottom = PlaceLines(top, PADDING, firstMiddle, nameWidth, offsetsByGrid)
		local partyWidth = ColumnWidth(MAIN_GRID)
		for _, partyRow in ipairs(partyRows) do
			local nextY = y
			for index, lines in ipairs(partyRow) do
				local x = PADDING + (index - 1) * (partyWidth + COLUMN_GAP)
				local partyY, partyBottom = PlaceLines(lines, x, y, nameWidth, offsetsByGrid)
				nextY = math.min(nextY, partyY)
				bottom = math.min(bottom, partyBottom)
			end
			y = nextY
		end

		anchor:SetSize(PADDING * 2 + width, -bottom + PADDING)
	end

	content:Show()
	UpdateCooldowns()
	UpdateRange()
	StartRangeTicker()
end

function ns.HideBuffWindow()
	if InCombatLockdown() or not content then
		return
	end
	content:Hide()
	StopRangeTicker()
end

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

--[[
    Applies Hide in Combat and the saved position. Returns false when combat
    blocks it -- the state driver and the anchor are both protected then -- so
    the caller can apply it again once combat ends.
]]
function ns.ApplyBuffWindowSettings()
	if InCombatLockdown() or not anchor then
		return false
	end
	if ns.db.global.buffWindow.hideInCombat then
		RegisterStateDriver(anchor, "visibility", "[combat] hide; show")
	else
		UnregisterStateDriver(anchor, "visibility")
		anchor:Show()
	end
	RestorePosition()
	-- A profile switch can change the list's settings without changing its rows.
	lastSignature = nil
	return true
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function ns.CreateBuffWindowFrame()
	anchor = CreateFrame("Frame", nil, UIParent)
	anchor:SetSize(1, 1)
	anchor:SetMovable(true)
	anchor:SetClampedToScreen(true)
	anchor:SetFrameStrata("MEDIUM")

	content = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
	content:SetAllPoints(anchor)
	content:SetBackdrop(BACKDROP)
	content:SetBackdropColor(0, 0, 0, 0.75)
	content:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
	content:EnableMouse(true)
	content:RegisterForDrag("LeftButton")
	content:SetScript("OnDragStart", function()
		if not ns.db.global.buffWindow.locked and not InCombatLockdown() then
			anchor:StartMoving()
		end
	end)
	--[[
	    StopMovingOrSizing re-anchors the frame to whichever screen point is
	    nearest (often CENTER), so a resize after a drag would grow from the
	    middle. Re-applying the saved top-left keeps the title bar fixed. The
	    anchor holds the secure icons, so a drag let go once combat has begun
	    waits for it to end before re-anchoring.
	]]
	content:SetScript("OnDragStop", function()
		anchor:StopMovingOrSizing()
		SavePosition()
		if InCombatLockdown() then
			ns.QueueBuffWindowSettings()
			return
		end
		RestorePosition()
	end)

	-- Titled like the other windows, the add-on's name last: "Buff Duty // BBB".
	title = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("LEFT", content, "TOPLEFT", PADDING, -(PADDING + TITLE_HEIGHT / 2))
	title:SetText(
		GetColor("TEXT")
			.. L["TAB_BUFF_WINDOW"]
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//|r "
			.. GetColor("INFO")
			.. L["ADDON_SHORT_NAME"]
			.. "|r"
	)

	--[[
	    Closing turns Buff Duty off rather than hiding the window for the
	    session, since the window reopens itself on the next roster or aura
	    change. The template's own click hides its parent, which is protected
	    (it holds the secure icons), so the script is replaced outright.
	]]
	local close = CreateFrame("Button", nil, content, "UIPanelCloseButton")
	close:SetSize(CLOSE_SIZE, CLOSE_SIZE)
	-- Centered over the far-right icon column, which ends PADDING from the edge.
	close:SetPoint("CENTER", content, "TOPRIGHT", -(PADDING + ICON_SIZE / 2), -(PADDING + TITLE_HEIGHT / 2))
	close:SetScript("OnClick", ns.CloseBuffWindow)

	content:Hide()
end
