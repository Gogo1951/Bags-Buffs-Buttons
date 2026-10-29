local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local TITLE, BODY = ns.COLORS_RGB.TITLE, ns.COLORS_RGB.BODY
local INFO, OFF, WARNING = ns.COLORS_RGB.INFO, ns.COLORS_RGB.OFF, ns.COLORS_RGB.TITLE
local SetTip = ns.MenuSetTip
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString
local PixelInset = ns.PixelInset
local SettingsKey = ns.SettingsKey

--[[
	The Conditionals panel, docked against the Spell Book window's right edge (ns.DockSpellbookPanel, in
	Features/Spellbook/Spellbook-Window.lua) and opened from a macro's menu (Features/Spellbook/Macro-Menu.lua). It
	lists the macro's rows (Features/Spellbook/Conditionals.lua) top to bottom: a grip to drag a row up or down, one
	or two condition dropdowns joined by "and", the spell the row casts and its remove button. Under them the
	macro's own spell as the fixed Otherwise row, the Add Condition button, and the macro text with its length
	against what a macro holds, which follow every change.

	A row's spell slot takes a spell two ways: a click puts the page in pick mode, where the next spell clicked
	on the page fills the slot and Escape or a right-click cancels; or a spell dragged from the page (or the
	game's own spellbook, or an action bar) is dropped on it. A drag from the page still picks up the macro, so
	it can go on an action bar as before. Add Condition starts pick mode for the new row straight away. The page
	outlines the tile the panel is open for, and in pick mode dims the ones that can't be picked
	(Features/Spellbook/Macro-Button.lua asks ns.IsConditionalsPanelFor and ns.IsPickingConditionalSpell).

	Every change rebuilds the page, as the menu's do (ns.RefreshSpellbookPage), which rewrites the macro; the
	rebuild makes the page's macros afresh, so the panel holds its macro's settings key and finds it again after
	each refresh (ns.OnSpellbookPageRefreshed).
]]

local PANEL_WIDTH = 470
local DOCK_INSET = 2 -- tucked under the window's border, top and bottom
local PADDING = 16
local HEADER_ICON = 24
local HINT_TOP, ROWS_TOP = 46, 72
local ROW_HEIGHT, ROW_GAP = 34, 6
local DROPDOWN_HEIGHT = 24
local DROPDOWN_MIN_WIDTH = 56
local DROPDOWN_TEXT_LEFT, CARET_SIZE, CARET_RIGHT = 8, 12, 5
local OTHERWISE_LABEL_WIDTH = 96
local SLOT_HEIGHT, SLOT_ICON = 28, 22
local REMOVE_SIZE = 20
local METER_WIDTH, METER_HEIGHT = 120, 6
local METER_WARNING = 0.9 -- the share of what a macro holds past which the meter turns gold
local INNER_WIDTH = PANEL_WIDTH - 2 * PADDING

-- The panel's own dark leather, so it reads as part of the window rather than the parchment.
local PANEL_FILL = { 0.165, 0.141, 0.11 }
local PANEL_EDGE = { 0.302, 0.259, 0.196 }
local ROW_FILL = { 0.122, 0.106, 0.082 }
local ROW_EDGE = { 0.239, 0.204, 0.157 }
local FIELD_FILL = { 0.047, 0.047, 0.055 }
local FIELD_EDGE = { 0.353, 0.302, 0.22 }
local FOOTER_EDGE = { 0.29, 0.29, 0.31 }
local MUTED_INK = { 0.722, 0.671, 0.557 }
local ARROW_INK = { 0.541, 0.49, 0.392 }
local METER_TRACK = { 0.165, 0.165, 0.18 }
local HIGHLIGHT_ALPHA = 0.08
local DROP_ALPHA = 0.18 -- the wash on the row a dragged row will land on
local SKIPPED_ALPHA = 0.5 -- a row the macro text leaves out (ns.ConditionalSkipReason)

local TEXTURE_CARET = "Interface\\Buttons\\Arrow-Down-Up"
local TEXTURE_ARROW = "Interface\\ChatFrame\\ChatFrameExpandArrow"
local TEXTURE_REMOVE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local TEXTURE_REMOVE_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
local TEXTURE_REMOVE_HIGHLIGHT = "Interface\\Buttons\\UI-GroupLoot-Pass-Highlight"

local panel
local picking -- the index of the row whose slot waits for a spell, while the page is in pick mode

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

-- A box on frame: a one-pixel edge in one colour around a fill in another.
local function Box(frame, fill, edge)
	local edgeTexture = frame:CreateTexture(nil, "BACKGROUND")
	edgeTexture:SetAllPoints()
	edgeTexture:SetColorTexture(unpack(edge))
	local fillTexture = frame:CreateTexture(nil, "BORDER")
	fillTexture:SetColorTexture(unpack(fill))
	PixelInset(fillTexture, frame, 1)
	return edgeTexture, fillTexture
end

-- The faint wash a box's button shows under the cursor.
local function AddHighlight(button)
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetColorTexture(1, 1, 1, HIGHLIGHT_ALPHA)
	PixelInset(highlight, button, 1)
end

-- A tooltip on owner, its title gold and its lines white, then, if given, why it does nothing, in red.
local function ShowTip(owner, title, body, reason)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:SetText(title, TITLE.r, TITLE.g, TITLE.b, 1, true)
	if body then
		GameTooltip:AddLine(body, BODY.r, BODY.g, BODY.b, true)
	end
	if reason then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(GetColor("OFF") .. reason .. "|r", nil, nil, nil, true)
	end
	GameTooltip:Show()
end

-- A keybind and what it does, both in the interaction blue, as a pair across the tooltip, as a tile's are.
local function AddHint(keybind, action)
	GameTooltip:AddDoubleLine(GetColor("INFO") .. keybind .. "|r", GetColor("INFO") .. action .. "|r")
end

-- A condition's label, or a question mark for a key this client doesn't know.
local function ConditionLabel(key)
	local condition = ns.ConditionRow(key)
	return condition and L[condition.labelKey] or "?"
end

--------------------------------------------------------------------------------
-- Changes
--------------------------------------------------------------------------------

-- The page macro the panel is open for, found again by its settings key, or nil once it has left the page.
local function CurrentMacro()
	if not panel or not panel.key then
		return nil
	end
	for _, macro in ipairs(ns.macros) do
		if not macro.focus and SettingsKey(macro) == panel.key and ns.OffersConditionals(macro) then
			return macro
		end
	end
	return nil
end

--[[
	Runs a setter on the macro, set(macro), and rebuilds the page, which rewrites the macro and redraws the
	panel (see ns.OnSpellbookPageRefreshed below).
]]
local function Change(set)
	local macro = CurrentMacro()
	if not macro then
		return
	end
	set(macro)
	ns.RefreshSpellbookPage(panel.page)
end

-- The macro and the row at index, or nil for either once they are gone.
local function RowAt(index)
	local macro = CurrentMacro()
	return macro, macro and ns.Conditionals(macro)[index]
end

--[[
	Whether the panel is open for a page macro, so its tile is outlined on the page. A focus copy shares its
	spell's settings key but has no Conditionals, so it is never the one.
]]
function ns.IsConditionalsPanelFor(macro)
	return panel ~= nil and panel:IsShown() and ns.OffersConditionals(macro) and SettingsKey(macro) == panel.key
end

-- Redraws the page's tiles, for their outline and pick-mode dimming, without rebuilding its macros.
local function RedrawPage()
	if panel.page:IsVisible() then
		ns.LayoutSpellbookPage(panel.page)
	end
end

local Update -- set below; the pick mode redraws the panel

--------------------------------------------------------------------------------
-- Pick Mode
--------------------------------------------------------------------------------

--[[
	The page's look in pick mode: a blue edge around the parchment and a banner across its top saying what a
	click does. It takes no clicks, so they reach the tiles under it.
]]
local function PickOverlay()
	if panel.overlay then
		return panel.overlay
	end
	local parchment = panel.page.parchment
	local overlay = CreateFrame("Frame", nil, parchment)
	overlay:SetAllPoints()
	overlay:SetFrameLevel(parchment:GetFrameLevel() + 50)
	overlay:EnableMouse(false)
	-- each edge as { one corner, the other, the setter for its thickness }
	for _, edge in ipairs({
		{ "TOPLEFT", "TOPRIGHT", "SetHeight" },
		{ "BOTTOMLEFT", "BOTTOMRIGHT", "SetHeight" },
		{ "TOPLEFT", "BOTTOMLEFT", "SetWidth" },
		{ "TOPRIGHT", "BOTTOMRIGHT", "SetWidth" },
	}) do
		local line = overlay:CreateTexture(nil, "OVERLAY")
		line:SetColorTexture(INFO.r, INFO.g, INFO.b)
		line:SetPoint(edge[1])
		line:SetPoint(edge[2])
		line[edge[3]](line, 2)
	end
	local banner = CreateFrame("Frame", nil, overlay)
	banner:SetPoint("TOP", 0, -8)
	banner:SetHeight(26)
	Box(banner, FIELD_FILL, { INFO.r, INFO.g, INFO.b })
	local text = SizedFontString(banner, "GameFontHighlight", 13, "OVERLAY")
	text:SetPoint("CENTER")
	text:SetText(L["CONDITIONALS_PICK_BANNER"])
	banner:SetWidth(math.ceil(text:GetStringWidth()) + 28)
	panel.overlay = overlay
	return overlay
end

--[[
	Starts or ends pick mode for a row's slot (index, or nil to end it). While it is on, the panel takes the
	keyboard so Escape ends it rather than closing the window; it never starts in combat, where a frame can't
	take the keyboard, and combat ends it.
]]
local function SetPicking(index)
	picking = index
	if panel then
		PickOverlay():SetShown(index ~= nil)
		panel:EnableKeyboard(index ~= nil)
		RedrawPage()
		Update()
	end
end

function ns.IsPickingConditionalSpell()
	return picking ~= nil
end

function ns.CancelConditionalPick()
	if picking then
		SetPicking(nil)
	end
end

local function StartPick(index)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
		return
	end
	SetPicking(index)
end

--[[
	A page tile clicked in pick mode (Features/Spellbook/Macro-Button.lua): its spell fills the slot waiting for
	one. A tile that can't be picked leaves pick mode on, with the game's error line saying why.
]]
function ns.PickConditionalSpell(macro)
	local index = picking
	local name, rank = ns.ConditionalSpellOf(macro)
	if not name then
		UIErrorsFrame:AddMessage(L["CONDITIONALS_CANNOT_PICK"], 1, 0.1, 0.1)
		return
	end
	SetPicking(nil)
	Change(function(own)
		ns.SetConditionalSpell(own, index, name, rank)
	end)
end

--[[
	The spell on the cursor, its name and rank text, or nil: a page macro dragged from its tile gives its spell
	(ns.ConditionalSpellOf), another macro the spell it would cast now, a spell from a spellbook or an action
	bar its own name.
]]
local function SpellFromCursor()
	local kind, id, _, spellID = GetCursorInfo()
	if kind == "macro" then
		local indexes = ns.ReadMacroIndexes()
		for _, macro in ipairs(ns.macros) do
			if ns.FindMacroIndex(macro, indexes) == id then
				return ns.ConditionalSpellOf(macro)
			end
		end
		local spell = GetMacroSpell(id)
		if type(spell) == "number" then
			return C_Spell.GetSpellName(spell)
		end
		return type(spell) == "string" and spell or nil
	elseif kind == "spell" and spellID then
		return C_Spell.GetSpellName(spellID)
	end
	return nil
end

-- Fills a row's slot from the cursor and clears it; returns whether the cursor held a spell.
local function DropOnSlot(index)
	local name, rank = SpellFromCursor()
	if not name then
		return false
	end
	ClearCursor()
	ns.CancelConditionalPick()
	Change(function(macro)
		ns.SetConditionalSpell(macro, index, name, rank)
	end)
	return true
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

--[[
	A condition dropdown's menu, for the condition at place in the row: every condition offered, less the one
	the row's other place holds and the one that can never match beside it, each explaining itself, a condition
	the macro can't use (ns.ConditionBlockReason) greyed with why. The first dropdown also offers And, a second
	condition, while the row has one; the second offers dropping itself.
]]
local function OpenConditionMenu(owner, index, place)
	local macro = CurrentMacro()
	local row = macro and ns.Conditionals(macro)[index]
	if not row then
		return
	end
	MenuUtil.CreateContextMenu(owner, function(_, root)
		local function addChoices(menu, at)
			local other = row.when[at == 1 and 2 or 1]
			local opposite = other and ns.ConditionRow(other) and ns.ConditionRow(other).opposite
			for _, condition in ipairs(ns.CONDITIONS) do
				local key = condition.key
				local current = row.when[at] == key
				if (current or ns.OffersCondition(key)) and key ~= other and key ~= opposite then
					local label = L[condition.labelKey]
					local element = menu:CreateRadio(label, function()
						return row.when[at] == key
					end, function()
						Change(function(own)
							ns.SetConditionalCondition(own, index, at, key)
						end)
					end)
					local reason = ns.ConditionBlockReason(macro, key)
					SetTip(element, label, L[condition.descKey], reason)
					if reason and not current then
						element:SetEnabled(false)
					end
				end
			end
		end
		addChoices(root, place)
		if place == 1 and #row.when < ns.CONDITIONALS_MAX_CONDITIONS then
			root:CreateDivider()
			local andMenu = root:CreateButton(L["CONDITIONALS_AND_MENU"])
			SetTip(andMenu, L["CONDITIONALS_AND_MENU"], L["CONDITIONALS_AND_DESCRIPTION"])
			addChoices(andMenu, 2)
		elseif place == 2 then
			root:CreateDivider()
			local element = root:CreateButton(L["CONDITIONALS_DROP_SECOND"], function()
				Change(function(own)
					ns.SetConditionalCondition(own, index, 2, nil)
				end)
			end)
			SetTip(element, L["CONDITIONALS_DROP_SECOND"], L["CONDITIONALS_DROP_SECOND_DESCRIPTION"])
		end
	end)
end

--[[
	A condition dropdown in a row: a dark field with the condition's name and a caret, as wide as its name needs,
	so "Out Of Combat" reads whole and the spell slot keeps the rest of the row.
]]
local function CreateDropdown(row, place)
	local dropdown = CreateFrame("Button", nil, row)
	dropdown:SetHeight(DROPDOWN_HEIGHT)
	Box(dropdown, FIELD_FILL, FIELD_EDGE)
	AddHighlight(dropdown)
	local caret = dropdown:CreateTexture(nil, "ARTWORK")
	caret:SetTexture(TEXTURE_CARET)
	caret:SetSize(CARET_SIZE, CARET_SIZE)
	caret:SetPoint("RIGHT", -CARET_RIGHT, 0)
	dropdown.text = SizedFontString(dropdown, "GameFontHighlightSmall", 12)
	dropdown.text:SetPoint("LEFT", DROPDOWN_TEXT_LEFT, 0)
	dropdown.text:SetJustifyH("LEFT")
	dropdown.text:SetWordWrap(false)
	function dropdown:SetLabel(label)
		self.text:SetText(label)
		local textWidth = math.ceil(self.text:GetUnboundedStringWidth())
		self:SetWidth(math.max(DROPDOWN_MIN_WIDTH, DROPDOWN_TEXT_LEFT + textWidth + 4 + CARET_SIZE + CARET_RIGHT))
	end
	dropdown:SetScript("OnClick", function(self)
		HideTooltip(self)
		OpenConditionMenu(self, row.index, place)
	end)
	dropdown:SetScript("OnEnter", function(self)
		local macro, conditional = RowAt(row.index)
		local key = conditional and conditional.when[place]
		local condition = key and ns.ConditionRow(key)
		if condition then
			local reason = ns.ConditionBlockReason(macro, key) or ns.ConditionalSkipReason(macro, row.index)
			ShowTip(self, L[condition.labelKey], L[condition.descKey], reason)
		end
	end)
	dropdown:SetScript("OnLeave", HideTooltip)
	return dropdown
end

-- The grip at a row's left: six dots, dragged to move the row to the row it is let go over.
local function CreateGrip(row)
	local grip = CreateFrame("Button", nil, row)
	grip:SetSize(12, 18)
	for column = 0, 1 do
		for line = 0, 2 do
			local dot = grip:CreateTexture(nil, "ARTWORK")
			dot:SetColorTexture(unpack(ARROW_INK))
			dot:SetSize(2, 2)
			dot:SetPoint("TOPLEFT", 3 + column * 4, -(3 + line * 5))
		end
	end
	-- the row under the cursor, other than the one dragged, or nil
	local function Target()
		for i, other in ipairs(panel.rows) do
			if i ~= row.index and other:IsShown() and other:IsMouseOver() then
				return i
			end
		end
		return nil
	end
	grip:RegisterForDrag("LeftButton")
	grip:SetScript("OnDragStart", function()
		HideTooltip(grip)
		panel.dragFrom = row.index
		row:SetAlpha(0.6)
		-- the row it would land on shows a wash while the drag goes on
		panel:SetScript("OnUpdate", function()
			local to = Target()
			for i, other in ipairs(panel.rows) do
				other.drop:SetShown(i == to)
			end
		end)
	end)
	grip:SetScript("OnDragStop", function()
		panel:SetScript("OnUpdate", nil)
		for _, other in ipairs(panel.rows) do
			other.drop:Hide()
		end
		local from, to = panel.dragFrom, Target()
		panel.dragFrom = nil
		if from and to then
			ns.CancelConditionalPick()
			Change(function(macro)
				ns.MoveConditional(macro, from, to)
			end)
		else
			Update()
		end
	end)
	grip:SetScript("OnEnter", function(self)
		ShowTip(self, L["CONDITIONALS_REORDER"], L["CONDITIONALS_REORDER_DESCRIPTION"])
	end)
	grip:SetScript("OnLeave", HideTooltip)
	return grip
end

-- A row's spell slot: the spell's icon and name, or what to do to give it one.
local function CreateSlot(row)
	local slot = CreateFrame("Button", nil, row)
	slot:SetHeight(SLOT_HEIGHT)
	slot.edge = Box(slot, FIELD_FILL, FIELD_EDGE)
	AddHighlight(slot)
	slot.icon = slot:CreateTexture(nil, "ARTWORK")
	slot.icon:SetSize(SLOT_ICON, SLOT_ICON)
	slot.icon:SetPoint("LEFT", 3, 0)
	slot.text = SizedFontString(slot, "GameFontNormal", 13)
	slot.text:SetPoint("LEFT", slot.icon, "RIGHT", 6, 0)
	slot.text:SetPoint("RIGHT", -6, 0)
	slot.text:SetJustifyH("LEFT")
	slot.text:SetWordWrap(false)
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	slot:SetScript("OnClick", function(self, mouseButton)
		HideTooltip(self)
		if mouseButton == "RightButton" then
			ns.CancelConditionalPick()
		elseif GetCursorInfo() and DropOnSlot(row.index) then
			return
		elseif picking == row.index then
			ns.CancelConditionalPick()
		else
			StartPick(row.index)
		end
	end)
	slot:SetScript("OnReceiveDrag", function()
		DropOnSlot(row.index)
	end)
	--[[
		the spell's own tooltip, as a tile shows it, or what to do while the slot is empty; then why the row never
		casts, if it doesn't, and the clicks
	]]
	slot:SetScript("OnEnter", function(self)
		local macro, conditional = RowAt(row.index)
		if not conditional then
			return
		end
		local info = conditional.spell and C_Spell.GetSpellInfo(ns.ConditionalSpellText(conditional))
		if info then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetSpellByID(info.spellID)
		else
			ShowTip(self, conditional.spell or L["CONDITIONALS_PICK_SPELL"], L["CONDITIONALS_SLOT_DESCRIPTION"])
		end
		local reason = ns.ConditionalSkipReason(macro, row.index)
		if reason then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GetColor("OFF") .. reason .. "|r", nil, nil, nil, true)
		end
		GameTooltip:AddLine(" ")
		if picking == row.index then
			AddHint(L["TOOLTIP_KEY_RIGHT_CLICK"], L["CONDITIONALS_ACTION_CANCEL"])
		else
			AddHint(L["TOOLTIP_KEY_CLICK"], L["CONDITIONALS_ACTION_PICK"])
		end
		GameTooltip:AddLine(" ")
		AddHint(L["CONDITIONALS_KEY_DRAG"], L["CONDITIONALS_ACTION_DROP"])
		GameTooltip:Show()
	end)
	slot:SetScript("OnLeave", HideTooltip)
	return slot
end

local function CreateRow(parent, index)
	local row = CreateFrame("Frame", nil, parent)
	row.index = index
	row:SetHeight(ROW_HEIGHT)
	row:SetWidth(INNER_WIDTH)
	row:SetPoint("TOPLEFT", PADDING, -(ROWS_TOP + (index - 1) * (ROW_HEIGHT + ROW_GAP)))
	Box(row, ROW_FILL, ROW_EDGE)
	row.drop = row:CreateTexture(nil, "ARTWORK")
	row.drop:SetColorTexture(INFO.r, INFO.g, INFO.b, DROP_ALPHA)
	PixelInset(row.drop, row, 1)
	row.drop:Hide()
	row.grip = CreateGrip(row)
	row.grip:SetPoint("LEFT", 6, 0)
	row.first = CreateDropdown(row, 1)
	row.first:SetPoint("LEFT", row.grip, "RIGHT", 6, 0)
	row.andText = SizedFontString(row, "GameFontHighlightSmall", 12)
	row.andText:SetTextColor(unpack(ARROW_INK))
	row.andText:SetPoint("LEFT", row.first, "RIGHT", 6, 0)
	row.andText:SetText(L["CONDITIONALS_AND"])
	row.second = CreateDropdown(row, 2)
	row.second:SetPoint("LEFT", row.andText, "RIGHT", 6, 0)
	row.arrow = row:CreateTexture(nil, "ARTWORK")
	row.arrow:SetTexture(TEXTURE_ARROW)
	row.arrow:SetVertexColor(unpack(ARROW_INK))
	row.arrow:SetSize(12, 12)
	row.remove = CreateFrame("Button", nil, row)
	row.remove:SetSize(REMOVE_SIZE, REMOVE_SIZE)
	row.remove:SetPoint("RIGHT", -6, 0)
	row.remove:SetNormalTexture(TEXTURE_REMOVE)
	row.remove:SetPushedTexture(TEXTURE_REMOVE_DOWN)
	row.remove:SetHighlightTexture(TEXTURE_REMOVE_HIGHLIGHT, "ADD")
	row.remove:SetScript("OnClick", function(self)
		HideTooltip(self)
		ns.CancelConditionalPick()
		Change(function(macro)
			ns.RemoveConditional(macro, index)
		end)
	end)
	row.remove:SetScript("OnEnter", function(self)
		ShowTip(self, L["CONDITIONALS_REMOVE"], L["CONDITIONALS_REMOVE_DESCRIPTION"])
	end)
	row.remove:SetScript("OnLeave", HideTooltip)
	row.slot = CreateSlot(row)
	row.slot:SetPoint("LEFT", row.arrow, "RIGHT", 6, 0)
	row.slot:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
	return row
end

--[[
	Draws a row: its conditions, the "and" and second dropdown only when it has two, and its spell, or the slot
	waiting in pick mode, or the slot asking for one. A row the macro text leaves out (ns.ConditionalSkipReason)
	is drawn faded; its tooltips say why.
]]
local function UpdateRow(row, macro, conditional)
	row:SetAlpha(ns.ConditionalSkipReason(macro, row.index) and SKIPPED_ALPHA or 1)
	local when = conditional.when or {}
	row.first:SetLabel(ConditionLabel(when[1]))
	local two = when[2] ~= nil
	row.andText:SetShown(two)
	row.second:SetShown(two)
	row.second:SetLabel(two and ConditionLabel(when[2]) or "")
	row.arrow:ClearAllPoints()
	row.arrow:SetPoint("LEFT", two and row.second or row.first, "RIGHT", 6, 0)
	local slot = row.slot
	if picking == row.index then
		slot.edge:SetColorTexture(INFO.r, INFO.g, INFO.b)
		slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
		slot.icon:SetDesaturated(true)
		slot.text:SetText(GetColor("INFO") .. L["CONDITIONALS_PICKING"] .. "|r")
	elseif conditional.spell then
		slot.edge:SetColorTexture(unpack(FIELD_EDGE))
		slot.icon:SetTexture(C_Spell.GetSpellTexture(conditional.spell) or ns.QUESTION_MARK_ICON)
		slot.icon:SetDesaturated(false)
		slot.text:SetText(
			GetColor("TITLE")
				.. conditional.spell
				.. (conditional.rank and " " .. GetColor("HELP") .. conditional.rank .. "|r" or "")
				.. "|r"
		)
	else
		slot.edge:SetColorTexture(unpack(FIELD_EDGE))
		slot.icon:SetTexture(ns.QUESTION_MARK_ICON)
		slot.icon:SetDesaturated(true)
		slot.text:SetText(GetColor("MUTED") .. L["CONDITIONALS_PICK_SPELL"] .. "|r")
	end
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

-- The fixed last row, the macro's own spell, cast when no row above matches; drawn muted, with no controls.
local function CreateOtherwise(parent)
	local row = CreateFrame("Frame", nil, parent)
	row:SetSize(INNER_WIDTH, ROW_HEIGHT)
	row:SetAlpha(0.8)
	Box(row, PANEL_FILL, ROW_EDGE)
	local label = SizedFontString(row, "GameFontHighlightSmall", 13)
	label:SetTextColor(unpack(MUTED_INK))
	label:SetPoint("LEFT", 24, 0)
	label:SetWidth(OTHERWISE_LABEL_WIDTH)
	label:SetJustifyH("LEFT")
	label:SetText(L["CONDITIONALS_OTHERWISE"])
	local arrow = row:CreateTexture(nil, "ARTWORK")
	arrow:SetTexture(TEXTURE_ARROW)
	arrow:SetVertexColor(unpack(ARROW_INK))
	arrow:SetSize(12, 12)
	arrow:SetPoint("LEFT", label, "RIGHT", 6, 0)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(SLOT_ICON, SLOT_ICON)
	row.icon:SetPoint("LEFT", arrow, "RIGHT", 9, 0)
	row.text = SizedFontString(row, "GameFontNormal", 13)
	row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.text:SetPoint("RIGHT", -6, 0)
	row.text:SetJustifyH("LEFT")
	row.text:SetWordWrap(false)
	return row
end

-- The footer: "Macro Text", a meter of its length against what a macro holds, the count, and the text itself.
local function CreateFooter(parent)
	local footer = CreateFrame("Frame", nil, parent)
	footer:SetPoint("BOTTOMLEFT", PADDING, PADDING)
	footer:SetPoint("BOTTOMRIGHT", -PADDING, PADDING)
	Box(footer, FIELD_FILL, FOOTER_EDGE)
	local title = SizedFontString(footer, "GameFontNormal", 13)
	title:SetPoint("TOPLEFT", 10, -9)
	title:SetText(GetColor("TITLE") .. L["MACRO_TEXT"] .. "|r")
	footer.count = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.count:SetPoint("TOPRIGHT", -10, -10)
	local track = footer:CreateTexture(nil, "ARTWORK")
	track:SetColorTexture(unpack(METER_TRACK))
	track:SetSize(METER_WIDTH, METER_HEIGHT)
	track:SetPoint("RIGHT", footer.count, "LEFT", -10, 0)
	footer.meter = footer:CreateTexture(nil, "OVERLAY")
	footer.meter:SetPoint("TOPLEFT", track)
	footer.meter:SetHeight(METER_HEIGHT)
	footer.body = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.body:SetPoint("TOPLEFT", 10, -30)
	footer.body:SetWidth(INNER_WIDTH - 20)
	footer.body:SetJustifyH("LEFT")
	footer.body:SetWordWrap(true)
	footer.tooLong = SizedFontString(footer, "GameFontHighlightSmall", 12)
	footer.tooLong:SetPoint("TOPLEFT", footer.body, "BOTTOMLEFT", 0, -6)
	footer.tooLong:SetWidth(INNER_WIDTH - 20)
	footer.tooLong:SetJustifyH("LEFT")
	return footer
end

--[[
	Shows the macro text, its tag line left out though the length counts it, as the menu's Macro Text does. The
	meter is blue, gold once it nears what a macro holds, and red past it, where a line under the text says the
	macro isn't written until it fits, as the tile's tooltip does.
]]
local function UpdateFooter(footer, macro)
	local length, max = #macro.body, ns.MACRO_BODY_MAX_LENGTH
	local over = length > max
	local near = not over and length >= max * METER_WARNING
	footer.count:SetText(GetColor(over and "OFF" or "HELP") .. L["MENU_MACRO_LENGTH"]:format(length, max) .. "|r")
	local color = over and OFF or near and WARNING or INFO
	footer.meter:SetColorTexture(color.r, color.g, color.b)
	footer.meter:SetWidth(math.max(1, METER_WIDTH * math.min(1, length / max)))
	footer.body:SetText((ns.UntaggedBody(macro.body):gsub("|", "||")))
	footer.tooLong:SetShown(over)
	footer.tooLong:SetText(GetColor("OFF") .. L["TOOLTIP_TOO_LONG"]:format(length, max) .. "|r")
	local height = 30 + math.ceil(footer.body:GetStringHeight()) + 10
	if over then
		height = height + 6 + math.ceil(footer.tooLong:GetStringHeight())
	end
	footer:SetHeight(height)
end

--[[
	Redraws the panel for its macro: the heading, the rows, the Otherwise row and the Add Condition button under
	the last row, and the footer. Closes it once its macro has left the page.
]]
Update = function()
	if not panel or not panel:IsShown() then
		return
	end
	local macro = CurrentMacro()
	if not macro then
		panel:Hide()
		return
	end
	panel.icon:SetTexture(macro.icon or ns.QUESTION_MARK_ICON)
	-- a rank's own macro shares its spell's name, so its heading names the rank too
	panel.title:SetText(
		GetColor("TITLE")
			.. (macro.label or macro.name)
			.. (macro.rank and " " .. GetColor("HELP") .. macro.rank .. "|r" or "")
			.. "|r "
			.. GetColor("SEPARATOR")
			.. "//|r "
			.. GetColor("TEXT")
			.. L["CONDITIONALS_TITLE"]
			.. "|r"
	)
	local conditionals = ns.Conditionals(macro)
	for i, row in ipairs(panel.rows) do
		local conditional = conditionals[i]
		row:SetShown(conditional ~= nil)
		if conditional then
			UpdateRow(row, macro, conditional)
		end
	end
	-- with no rows yet, a line saying what one does stands where they go
	panel.empty:SetShown(#conditionals == 0)
	local y = ROWS_TOP + math.max(#conditionals, panel.empty:IsShown() and 1 or 0) * (ROW_HEIGHT + ROW_GAP)
	panel.otherwise:SetPoint("TOPLEFT", PADDING, -y)
	local own = ns.CastSpellName(macro)
	panel.otherwise.icon:SetTexture(C_Spell.GetSpellTexture(own) or macro.icon or ns.QUESTION_MARK_ICON)
	panel.otherwise.text:SetText(GetColor("TITLE") .. own .. "|r")
	panel.add:SetPoint("TOPLEFT", PADDING, -(y + ROW_HEIGHT + ROW_GAP + 4))
	panel.add:SetEnabled(#conditionals < ns.CONDITIONALS_MAX_ROWS)
	UpdateFooter(panel.footer, macro)
end

local function CreatePanel(page)
	local window = page:GetParent()
	panel = CreateFrame("Frame", "BagsBuffsButtonsConditionalsPanel", window)
	panel:Hide()
	panel.page = page
	panel:SetWidth(PANEL_WIDTH)
	panel:SetPoint("TOPLEFT", window, "TOPRIGHT", -DOCK_INSET, -DOCK_INSET)
	panel:SetPoint("BOTTOMLEFT", window, "BOTTOMRIGHT", -DOCK_INSET, DOCK_INSET)
	panel:EnableMouse(true)
	-- dragging the panel moves the window it is docked to
	panel:RegisterForDrag("LeftButton")
	panel:SetScript("OnDragStart", function()
		window:StartMoving()
	end)
	panel:SetScript("OnDragStop", function()
		window:StopMovingOrSizing()
	end)
	Box(panel, PANEL_FILL, PANEL_EDGE)

	panel.icon = panel:CreateTexture(nil, "ARTWORK")
	panel.icon:SetSize(HEADER_ICON, HEADER_ICON)
	panel.icon:SetPoint("TOPLEFT", PADDING, -14)
	panel.title = SizedFontString(panel, "GameFontNormalLarge", 16)
	panel.title:SetPoint("LEFT", panel.icon, "RIGHT", 10, 0)
	panel.title:SetWidth(INNER_WIDTH - HEADER_ICON - 10 - 24) -- clear of the close button
	panel.title:SetJustifyH("LEFT")
	panel.title:SetWordWrap(false)
	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -6)
	close:SetScript("OnClick", function()
		panel:Hide()
	end)
	local hint = SizedFontString(panel, "GameFontHighlightSmall", 13)
	hint:SetPoint("TOPLEFT", PADDING, -HINT_TOP)
	hint:SetWidth(INNER_WIDTH)
	hint:SetJustifyH("LEFT")
	hint:SetTextColor(unpack(MUTED_INK))
	hint:SetText(L["CONDITIONALS_HINT"])

	panel.empty = SizedFontString(panel, "GameFontHighlightSmall", 13)
	panel.empty:SetPoint("TOPLEFT", PADDING, -ROWS_TOP)
	panel.empty:SetSize(INNER_WIDTH, ROW_HEIGHT)
	panel.empty:SetJustifyH("LEFT")
	panel.empty:SetJustifyV("MIDDLE")
	panel.empty:SetText(GetColor("MUTED") .. L["CONDITIONALS_EMPTY"] .. "|r")

	panel.rows = {}
	for i = 1, ns.CONDITIONALS_MAX_ROWS do
		panel.rows[i] = CreateRow(panel, i)
	end
	panel.otherwise = CreateOtherwise(panel)
	panel.add = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.add:SetSize(150, 22)
	panel.add:SetText(L["CONDITIONALS_ADD"])
	panel.add:SetMotionScriptsWhileDisabled(true)
	-- the new row has no spell yet, so pick mode starts for it at once
	panel.add:SetScript("OnClick", function()
		ns.CancelConditionalPick()
		Change(ns.AddConditional)
		local macro = CurrentMacro()
		local count = macro and #ns.Conditionals(macro) or 0
		if count > 0 and not ns.Conditionals(macro)[count].spell and not InCombatLockdown() then
			SetPicking(count)
		end
	end)
	panel.add:SetScript("OnEnter", function(self)
		ShowTip(
			self,
			L["CONDITIONALS_ADD"],
			L["CONDITIONALS_ADD_DESCRIPTION"],
			L["CONDITIONALS_ADD_LIMIT"]:format(ns.CONDITIONALS_MAX_ROWS)
		)
	end)
	panel.add:SetScript("OnLeave", HideTooltip)
	panel.footer = CreateFooter(panel)

	--[[
		the panel takes the keyboard only in pick mode, where Escape ends it and every other key goes on to the
		game; each key sets its own passing on, since that can't be set in combat, which ends pick mode anyway
	]]
	panel:SetScript("OnKeyDown", function(self, key)
		if InCombatLockdown() then
			return
		end
		local cancel = key == "ESCAPE" and picking ~= nil
		self:SetPropagateKeyboardInput(not cancel)
		if cancel then
			ns.CancelConditionalPick()
		end
	end)
	panel:RegisterEvent("PLAYER_REGEN_DISABLED")
	panel:SetScript("OnEvent", function()
		ns.CancelConditionalPick()
	end)
	panel:SetScript("OnShow", function()
		ns.DockSpellbookPanel(PANEL_WIDTH)
	end)
	-- the tile's outline goes with the panel
	panel:SetScript("OnHide", function()
		ns.CancelConditionalPick()
		ns.DockSpellbookPanel(0)
		RedrawPage()
	end)
	-- closing the window closes the panel, so it opens again only from a macro's menu
	window:HookScript("OnHide", function()
		panel:Hide()
	end)
end

-- Opens the panel for a page macro (from its menu), or moves it to that macro when it is open for another.
function ns.ShowConditionalsPanel(macro, page)
	if not ns.OffersConditionals(macro) then
		return
	end
	if not panel then
		CreatePanel(page)
	end
	ns.CancelConditionalPick()
	panel.key = SettingsKey(macro)
	panel:Show()
	RedrawPage()
	Update()
end

-- The page rebuilt its macros: draw the panel again from the new ones.
ns.OnSpellbookPageRefreshed(function(page)
	if panel and panel.page == page then
		Update()
	end
end)
