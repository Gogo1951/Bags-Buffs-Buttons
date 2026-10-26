local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip
local SizedFontString = ns.SizedFontString

--[[
	One macro's tile on the spellbook page: its icon, its name with its note under it (the rank and the options
	that are on), the glow while it isn't on the bars, its tooltip, and the click, drag and right-click that
	place it or open its menu (Features/Macro-Menu.lua). Features/Spellbook-Page.lua lays the tiles out.
]]

local TILE_WIDTH, TILE_HEIGHT, ICON_SIZE = 218, 32, 30
ns.TILE_WIDTH, ns.TILE_HEIGHT = TILE_WIDTH, TILE_HEIGHT
local NAME_SIZE, NOTE_SIZE = 14, 12

local INK_COLOR = ns.INK_COLOR
local FADED_INK_COLOR = ns.FADED_INK_COLOR

--[[
	The native spell item's atlases (Camelot's SpellBookItemTemplate, read in game), whose anchors are offsets
	from its icon. Each falls back to an old file texture, sized from the icon, if this build lacks the atlas.
]]
local ATLAS_FRAME = "spellbook-item-iconframe"
local ATLAS_FRAME_INACTIVE = "spellbook-item-iconframe-inactive"
local ATLAS_FRAME_HOVER = "spellbook-item-iconframe-hover"
local ATLAS_GLOW = "spellbook-item-unassigned-glow"
local ATLAS_MASK = "spellbook-item-spellicon-mask"

local function HasAtlas(atlas)
	return C_Texture.GetAtlasInfo(atlas) ~= nil
end

-- Stretches texture over the icon, grown by the given insets (left, top, right, bottom).
local function SetAroundIcon(texture, icon, left, top, right, bottom)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", icon, "TOPLEFT", -left, top)
	texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", right, -bottom)
end

-- Returns true when the atlas was used.
local function SetAtlasOr(texture, atlas, file, scale, icon)
	if HasAtlas(atlas) then
		texture:SetAtlas(atlas, false)
		return true
	end
	if file then
		texture:SetTexture(file)
		texture:SetSize(ICON_SIZE * scale, ICON_SIZE * scale)
		texture:SetPoint("CENTER", icon)
	end
	return false
end

--[[
	The spell whose own tooltip heads the macro's: a learned spell by name, so its highest known rank, an
	unlearned one by its ID. Nil when there's none, as for a consumable, which leads with its item's.
]]
local function TooltipSpellID(macro)
	if macro.consumable then
		return nil
	elseif macro.unlearned then
		return macro.spellID
	end
	local name = macro.name
	if macro.rangedAttacks then
		name = ns.CastSpellName(macro) -- the Shoot macro shows the attack for the weapon equipped
	elseif macro.rank then
		name = name .. "(" .. macro.rank .. ")" -- a rank's macro shows that rank's tooltip
	end
	local info = name and C_Spell.GetSpellInfo(name)
	return info and info.spellID or macro.spellID
end

-- Whether any of the game's menus is open, a macro's options menu included.
local function MenuOpen()
	return Menu ~= nil and Menu.GetManager ~= nil and Menu.GetManager():IsAnyMenuOpen()
end

-- A keybind and what it does, both in the interaction blue, as a pair across the tooltip.
local function AddHint(keybind, action)
	GameTooltip:AddDoubleLine(GetColor("INFO") .. keybind .. "|r", GetColor("INFO") .. action .. "|r")
end

-- Middle-click: the macro's own options dropped, the page redrawn and its WoW macro rewritten to match.
local function ResetOptions(macro)
	ns.ResetMacroSettings(macro)
	ns:RefreshMacros()
	ns:PrintMessage(L["CHAT_MACRO_OPTIONS_RESET"]:format(macro.label or macro.name))
end

--[[
	The options a macro's note and tooltip can name, most telling first, as { key, note key, full label key }:
	the note names up to two that are on, or counts them when more are; the tooltip lists them all by their
	full labels. A row without keys builds its text from the macro.
]]
local OPTION_SUBTEXTS = {
	{ "pet", "SUBTEXT_PET", "MENU_CAST_IF_SUMMONED" },
	{ "cursor", "SUBTEXT_CURSOR", "MENU_CAST_AT_CURSOR" },
	{ "targetPriority", "SUBTEXT_TARGET_PRIORITY", "MENU_GROUP_TARGET" },
	{ "stance", "SUBTEXT_STANCE", "MENU_SWITCH_TO" },
	{ "useItems", "SUBTEXT_USE_ITEMS" },
	{ "petAttack", "SUBTEXT_PET_ATTACK", "MENU_START_PET_ATTACK" },
	{ "targetRank", "SUBTEXT_DYNAMIC_RANK", "MENU_DYNAMIC_RANK" },
	{ "fixedRank" },
	{ "targetEnemy", "SUBTEXT_TARGET_ENEMY", "MENU_TARGET_NEAREST_ENEMY" },
	{ "targetFriend", "SUBTEXT_TARGET_FRIEND", "MENU_TARGET_NEAREST_FRIEND" },
	{ "groupVersion", "SUBTEXT_GROUPED_SPELLS", "MENU_RIGHT_CLICK_FOR" },
	{ "groupedSpells", "SUBTEXT_GROUPED_SPELLS" },
	{ "oncePerCombat", "SUBTEXT_ONCE_PER_COMBAT", "MENU_ONCE_PER_COMBAT" },
	{ "oncePerTarget", "SUBTEXT_ONCE_PER_TARGET", "MENU_ONCE_PER_TARGET" },
	{ "combatOnly", "SUBTEXT_COMBAT_ONLY", "MENU_IN_COMBAT" },
	{ "noCombat", "SUBTEXT_NO_COMBAT", "SUBTEXT_NO_COMBAT" },
	{ "cancelForm", "SUBTEXT_LEAVE_FORM", "MENU_LEAVE_FORM_BEFORE" },
	{ "noToggle", "SUBTEXT_NO_TOGGLE", "MENU_NEVER_TURN_OFF" },
	{ "autoShot" },
	{ "startAttack", "SUBTEXT_START_ATTACK", "MENU_START_AUTO_ATTACK" },
	{ "stopAttack", "SUBTEXT_STOP_ATTACK", "MENU_STOP_ATTACK" },
	{ "stopCast", "SUBTEXT_STOP_CASTING", "MENU_STOP_CASTING" },
	{ "stopIfChanneling", "SUBTEXT_STOP_IF_CHANNELING", "MENU_STOP_IF_CHANNELING" },
	{ "stopIfStealthed", "SUBTEXT_STOP_IF_STEALTHED", "MENU_STOP_IF_STEALTHED" },
	{ "hideErrors", "SUBTEXT_HIDE_ERRORS", "MENU_HIDE_ERRORS" },
	{ "muteErrors", "SUBTEXT_MUTE_ERRORS", "MENU_MUTE_ERRORS" },
}

-- Calls fn(entry) for each OPTION_SUBTEXTS row whose option is on for the macro, in order.
local function ForEachOnOption(macro, fn)
	for _, entry in ipairs(OPTION_SUBTEXTS) do
		local key = entry[1]
		local on
		if key == "useItems" then
			on = ns.UseItemSlots(macro)[1] ~= nil
		elseif key == "fixedRank" then
			on = ns.FixedRank(macro) ~= nil
		elseif key == "groupedSpells" then
			on = ns.IsGrouped(macro)
		elseif key == "targetPriority" then
			on = ns.HasTargetPriority(macro)
		else
			on = ns.IsOptionOn(macro, key)
		end
		if on then
			fn(entry)
		end
	end
end

-- The autoShot note: Auto Shot's own name from the client, or "Wand" rather than the wand's "Shoot".
local function AutoShotSubText()
	if ns.AutoShotLabelKey() == "MENU_START_WAND" then
		return L["SUBTEXT_WAND"]
	end
	return ns.AutoShotName()
end

-- The target priority's note: the first unit it tries other than the target ("Mouse Over", "Self").
local function TargetPrioritySubText(macro)
	for _, unit in ipairs(ns.TargetPriority(macro)) do
		for _, row in ipairs(ns.TARGET_UNITS) do
			if row[1] == unit and unit ~= "target" then
				return L[row[2]]
			end
		end
	end
	return L["SUBTEXT_TARGET_PRIORITY"]
end

-- MAX_NOTES names fit on a tile's note line ("Max Rank, Grouped, Hide Errors"); more are counted instead.
local MAX_NOTES = 3

--[[
	A spell macro's note: lead (a spell's "Max Rank"), if given, and the options that are on by
	name ("Dynamic Rank, Grouped"), or "N Options" counting them when there are more than MAX_NOTES names, or
	nil when there are none. Options with the same note (Right-Click For and the Grouped Spells ticked, both
	"Grouped") count as one.
]]
local function OptionSubText(macro, lead)
	local notes, count, seen = { lead }, 0, {}
	ForEachOnOption(macro, function(entry)
		local note
		-- a fixed rank's note is the rank's own text ("Rank 3")
		if entry[1] == "fixedRank" then
			note = ns.FixedRank(macro)
		elseif entry[1] == "autoShot" then
			note = AutoShotSubText()
		elseif entry[1] == "targetPriority" then
			note = TargetPrioritySubText(macro)
		else
			note = L[entry[2]]
		end
		if not seen[note] then
			seen[note] = true
			count = count + 1
			notes[#notes + 1] = note
		end
	end)
	if #notes > MAX_NOTES then
		return L["SUBTEXT_OPTIONS_COUNT"]:format(count)
	end
	return notes[1] and table.concat(notes, ", ") or nil
end

-- An option's full label, as the tooltip's Options On line shows it.
local function OptionLabel(macro, entry)
	local key = entry[1]
	if key == "useItems" then
		local slots = {}
		for i, slot in ipairs(ns.UseItemSlots(macro)) do
			slots[i] = ns.SlotLabel(slot)
		end
		return table.concat(slots, ", ")
	elseif key == "fixedRank" then
		return ns.FixedRank(macro)
	elseif key == "autoShot" then
		return L[ns.AutoShotLabelKey() or "MENU_START_AUTO_SHOT"]
	elseif key == "pet" then
		return L[entry[3]]:format(macro.petAbility)
	elseif key == "stance" then
		return L[entry[3]]:format(macro.stances[1])
	elseif key == "groupVersion" then
		return L[entry[3]]:format(ns.RightClickSpell(macro))
	elseif key == "groupedSpells" then
		return table.concat(ns.GroupedSpells(macro), ", ")
	elseif key == "targetPriority" then
		local labels = {}
		for i, unit in ipairs(ns.TargetPriority(macro)) do
			for _, row in ipairs(ns.TARGET_UNITS) do
				if row[1] == unit then
					labels[i] = L[row[2]]
				end
			end
		end
		return L[entry[3]] .. " (" .. table.concat(labels, ", ") .. ")"
	end
	return L[entry[3]]
end

-- "Options On: Cast On Mouseover, Stop Casting", every option that is on by its menu label, or nil for none.
local function OptionsOnLine(macro)
	local labels = {}
	ForEachOnOption(macro, function(entry)
		labels[#labels + 1] = OptionLabel(macro, entry)
	end)
	if #labels == 0 then
		return nil
	end
	return GetColor("TITLE")
		.. L["TOOLTIP_OPTIONS_ON"]:format(GetColor("TEXT") .. table.concat(labels, ", ") .. "|r")
		.. "|r"
end

-- Tiles are reused across refreshes; SetMacro points one at a macro.
local function CreateMacroButton(parent)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(TILE_WIDTH, TILE_HEIGHT)
	button.icon = button:CreateTexture(nil, "ARTWORK", nil, -1)
	button.icon:SetSize(ICON_SIZE, ICON_SIZE)
	button.icon:SetPoint("LEFT", 1, 0)
	if HasAtlas(ATLAS_MASK) then
		local mask = button:CreateMaskTexture()
		mask:SetAtlas(ATLAS_MASK, false)
		mask:SetAllPoints(button.icon)
		button.icon:AddMaskTexture(mask)
	end
	-- the frame's curl hangs off the icon's bottom left
	button.border = button:CreateTexture(nil, "OVERLAY", nil, 1)
	if SetAtlasOr(button.border, ATLAS_FRAME, "Interface\\Buttons\\UI-Quickslot2", 1.6, button.icon) then
		SetAroundIcon(button.border, button.icon, 11, 3, 3, 8)
	end
	-- glow on a macro that isn't on the action bars yet, like the native page's unassigned spells
	button.glow = button:CreateTexture(nil, "OVERLAY", nil, 5)
	if SetAtlasOr(button.glow, ATLAS_GLOW, "Interface\\Buttons\\UI-ActionButton-Border", 1.8, button.icon) then
		SetAroundIcon(button.glow, button.icon, 5, 4, 4, 4)
	else
		button.glow:SetBlendMode("ADD")
		button.glow:SetVertexColor(1, 0.82, 0) -- the texture is white; Blizzard tints it per use
	end
	button.glow:Hide()
	-- fades in and out like the spellbook's glow on new spells; UpdateGlow starts it
	button.pulse = button.glow:CreateAnimationGroup()
	button.pulse:SetLooping("BOUNCE")
	local fade = button.pulse:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0.2)
	fade:SetDuration(0.5)
	fade:SetSmoothing("IN_OUT")
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	if HasAtlas(ATLAS_FRAME_HOVER) then
		highlight:SetAtlas(ATLAS_FRAME_HOVER, false)
	else
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetBlendMode("ADD")
	end
	SetAroundIcon(highlight, button.icon, 2, 2, 2, 2)

	--[[
		the name in dark ink, without the font's shadow, which reads as a smudge on parchment; always high by the
		icon, so it sits in the same place with a note under it or none
	]]
	button.name = SizedFontString(button, "GameFontNormal", NAME_SIZE)
	button.name:SetShadowOffset(0, 0)
	button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 8, -2)
	button.name:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, -3)
	button.name:SetJustifyH("LEFT")
	button.name:SetWordWrap(false)
	--[[
		the note under it, in faded ink on the parchment, its letters' foot level with the icon's bottom: the
		line's box drops a unit below the icon, the room it keeps under the letters for descenders
	]]
	button.subText = SizedFontString(button, "GameFontNormalSmall", NOTE_SIZE)
	button.subText:SetShadowOffset(0, 0)
	button.subText:SetPoint("BOTTOMLEFT", button.icon, "BOTTOMRIGHT", 8, -1)
	button.subText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.subText:SetJustifyH("LEFT")
	button.subText:SetWordWrap(false)

	button:RegisterForDrag("LeftButton")
	button:SetScript("OnDragStart", function(self)
		ns.PickupMacro(self.macro)
	end)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	button:SetScript("OnClick", function(self, mouseButton)
		if mouseButton == "RightButton" then
			HideTooltip(self)
			ns.ShowMacroMenu(self)
		elseif mouseButton == "MiddleButton" then
			if ns.HasOptions(self.macro) then
				HideTooltip(self)
				ResetOptions(self.macro)
			end
		else
			ns.PickupMacro(self.macro)
		end
	end)
	button:SetScript("OnEnter", function(self)
		-- an open menu stands alone: no macro's tooltip shows over or beside it
		if MenuOpen() then
			return
		end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		-- the spell's own tooltip (a consumable's item's) comes first, then the macro as a block of our own
		local spellID = TooltipSpellID(self.macro)
		if self.macro.itemLink then
			GameTooltip:SetHyperlink(self.macro.itemLink)
		elseif spellID then
			GameTooltip:SetSpellByID(spellID)
			if GameTooltip:NumLines() == 0 then
				GameTooltip:SetHyperlink("spell:" .. spellID)
			end
		end
		local title = ns.MacroHeading(L["ADDON_SHORT_NAME"], self.macro)
		if GameTooltip:NumLines() > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(title)
		else
			GameTooltip:SetText(title)
		end
		-- what the macro does beyond its text, set off by a blank line above
		local notes = {}
		if not self.macro.consumable then
			notes[#notes + 1] = OptionsOnLine(self.macro)
		end
		if #notes > 0 then
			GameTooltip:AddLine(" ")
			for _, note in ipairs(notes) do
				GameTooltip:AddLine(note, nil, nil, nil, true)
			end
		end
		-- the macro text always has a blank line above it, notes or none
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(ns.UntaggedBody(self.macro.body), 1, 1, 1, true)
		GameTooltip:AddLine(" ")
		if self.blockReason == "long" then
			local line = L["TOOLTIP_TOO_LONG"]:format(self.blockLength, ns.MACRO_BODY_MAX_LENGTH)
			GameTooltip:AddLine(GetColor("OFF") .. line .. "|r", nil, nil, nil, true)
			GameTooltip:AddLine(" ")
		elseif self.macro.unlearned then
			GameTooltip:AddLine(GetColor("OFF") .. L["TOOLTIP_NOT_LEARNED"] .. "|r", nil, nil, nil, true)
			local when = self.macro.learnTalent and L["TOOLTIP_LEARN_TALENT"]
				or self.macro.learnLevel and L["TOOLTIP_LEARN_LEVEL"]:format(self.macro.learnLevel)
			if when then
				GameTooltip:AddLine(GetColor("HELP") .. when .. "|r", nil, nil, nil, true)
			end
			GameTooltip:AddLine(" ")
		elseif self.glow:IsShown() then
			GameTooltip:AddLine(GetColor("HELP") .. L["TOOLTIP_NOT_ON_BARS"] .. "|r", nil, nil, nil, true)
			GameTooltip:AddLine(" ")
		end
		-- each click on a line of its own, a blank line between
		AddHint(L["TOOLTIP_KEY_CLICK_DRAG"], L["TOOLTIP_ACTION_PLACE_ON_BAR"])
		if ns.HasOptions(self.macro) then
			GameTooltip:AddLine(" ")
			AddHint(L["TOOLTIP_KEY_RIGHT_CLICK"], L["TOOLTIP_ACTION_MACRO_OPTIONS"])
			GameTooltip:AddLine(" ")
			AddHint(L["TOOLTIP_KEY_MIDDLE_CLICK"], L["TOOLTIP_ACTION_RESET_OPTIONS"])
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", HideTooltip)
	button:SetScript("OnHide", HideTooltip)
	return button
end

--[[
	Shows the glow when the button's macro is learned but not on the bars (from ns.ScanActionBars).
	The stance bar's forms (noGlow) and macros marked placed never glow.
]]
local function UpdateGlow(button, bars)
	local macro = button.macro
	local shown = not macro.noGlow
		and not macro.unlearned
		and not ns.IsMarkedPlaced(macro)
		and not ns.IsOnActionBars(macro, bars)
	button.glow:SetShown(shown)
	if not shown then
		button.pulse:Stop()
	elseif not button.pulse:IsPlaying() then
		button.pulse:Play()
	end
end

--[[
	The note under the name, or nil for none: why the page can't place the macro, in red; else a consumable's
	item, Focus,
	the rank and the options that are on (OptionSubText), when an unlearned spell can be learned, or the spell's own subtext as the game's spellbook shows it ("Racial").
]]
local function NoteText(button, macro)
	if button.blockReason then
		return GetColor("OFF") .. L["SUBTEXT_TOO_LONG"] .. "|r"
	elseif macro.consumable then
		return macro.itemName -- the item it uses now, or nothing while the bags hold none
	elseif macro.focus then
		return L["SUBTEXT_FOCUS"]
	end
	--[[
		a learned spell with ranks ("Rank 4") leads with "Max Rank", since the macro casts the highest rank known,
		unless it is set to a fixed or dynamic rank, which names its own
	]]
	local spellID = TooltipSpellID(macro)
	local spellSubText = spellID and C_Spell.GetSpellSubtext(spellID) or ""
	local maxRank = not macro.unlearned
		and spellSubText:match("%d")
		and not ns.FixedRank(macro)
		and not ns.IsOptionOn(macro, "targetRank")
	local subText = OptionSubText(macro, maxRank and L["SUBTEXT_MAX_RANK"] or nil)
	if subText then
		return subText
	elseif macro.unlearned and (macro.learnTalent or macro.learnLevel) then
		-- when it can be learned, in place of its "Rank 1"
		return macro.learnTalent and L["SUBTEXT_TALENT"] or L["SUBTEXT_LEARN_LEVEL"]:format(macro.learnLevel)
	elseif spellSubText ~= "" then
		return spellSubText
	end
	return nil
end

--[[
	bars is a ns.ScanActionBars() result, read here when nil. A spell's rank macros share its name, told
	apart by their notes ("Rank 3").
]]
local function SetMacro(button, macro, bars)
	-- Connoisseur rewrites a consumable's macro as the bags change, so its item is read again at each draw
	if macro.consumable then
		ns.ReadConsumableMacro(macro)
	end
	button.macro = macro
	button.blockReason, button.blockLength = ns.MacroBlockReason(macro)
	UpdateGlow(button, bars or ns.ScanActionBars())
	button.icon:SetTexture(macro.icon)
	button.icon:SetDesaturated(macro.unlearned == true)
	local frameAtlas = macro.unlearned and ATLAS_FRAME_INACTIVE or ATLAS_FRAME
	if HasAtlas(frameAtlas) then
		button.border:SetAtlas(frameAtlas, false)
	end
	-- a Duplicate copy shows its number, a profession its specialization; rank versions keep the spell's name
	button.name:SetText(macro.label or macro.name)
	button.name:SetTextColor(unpack(macro.unlearned and FADED_INK_COLOR or INK_COLOR))
	button.subText:SetText(NoteText(button, macro))
	button.subText:SetTextColor(unpack(FADED_INK_COLOR))
end

ns.CreateMacroButton = CreateMacroButton
ns.UpdateMacroGlow = UpdateGlow
ns.SetMacroButton = SetMacro
