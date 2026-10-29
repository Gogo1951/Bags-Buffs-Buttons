local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Window Frame
--------------------------------------------------------------------------------

--[[
    The frame the Restock List and the Staples window share, matching the
    Spellbook's window (Features/Spellbook/Spellbook-Window.lua
    and Spellbook-Page.lua, the look every window here follows): the Blizzard
    portrait frame with the gold bag in its portrait, the title in the add-ons'
    shared colours, then the bands below.

      title     TITLE_HEIGHT across the top, the frame's own title bar
      header    CONTROLS_HEIGHT under it, on the dark frame, from clear of the
                portrait (CONTROLS_LEFT) to the frame's right: the window's
                buttons and its filter, as the Spell Book's controls row
      body      an inset from under the header to the footer
      footer    FOOTER_HEIGHT along the bottom, inside FRAME_BORDER

    Parented to UIParent and anchored by the caller, so nothing Blizzard owns is
    written to.
]]
ns.RESTOCK_WINDOW_BANDS = {
	TITLE_HEIGHT = 24,
	CONTROLS_HEIGHT = 36,
	CONTROLS_LEFT = 64,
	FOOTER_HEIGHT = 28,
	FRAME_BORDER = 4,
	INSET_LEFT = 4, -- the portrait frame's border, as ButtonFrameTemplate places its own inset
	INSET_RIGHT = 6,
}

local BANDS = ns.RESTOCK_WINDOW_BANDS

-- Where a header control centres vertically, from the frame's top edge.
ns.RESTOCK_HEADER_CENTER_Y = -(BANDS.TITLE_HEIGHT + BANDS.CONTROLS_HEIGHT / 2)

--[[
    A portrait frame named name, titled "<title> // Bags Buffs & Buttons": the
    window's own name white, the slashes grey, the add-on's name blue, as the
    Spell Book's title is. A client without the portrait template gets the
    plain frame and no portrait.
]]
function ns.CreateRestockerPortraitFrame(name, title)
	local template = ns.HasTemplate("PortraitFrameTemplate") and "PortraitFrameTemplate" or "BasicFrameTemplate"
	local frame = CreateFrame("Frame", name, UIParent, template)
	local text = GetColor("TEXT")
		.. title
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//|r "
		.. GetColor("INFO")
		.. L["ADDON_TITLE"]
		.. "|r"
	if frame.SetTitle then
		frame:SetTitle(text)
	elseif frame.TitleText then
		frame.TitleText:SetText(text)
	end
	if frame.SetPortraitToAsset then
		frame:SetPortraitToAsset(ns.ICON_RESTOCKER)
	end
	return frame
end

-- The inset holding a window's body, between its header and its footer.
function ns.CreateRestockerBodyInset(frame)
	local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate3")
	inset:SetPoint("TOPLEFT", frame, "TOPLEFT", BANDS.INSET_LEFT, -(BANDS.TITLE_HEIGHT + BANDS.CONTROLS_HEIGHT))
	inset:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BANDS.INSET_RIGHT, BANDS.FRAME_BORDER + BANDS.FOOTER_HEIGHT)
	return inset
end

--[[
    A panel button for a header or footer, sized to its caption the way the
    Spell Book's Mark All Spells As Placed button is: its text plus room for the
    art's ends, at the controls row's height.
]]
local HEADER_BUTTON_HEIGHT = 22
local HEADER_BUTTON_PADDING = 32

function ns.CreateRestockerHeaderButton(parent, text)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetText(text)
	button:SetHeight(HEADER_BUTTON_HEIGHT)
	ns.FitRestockerHeaderButton(button)
	return button
end

--[[
    Sized here and again wherever the caption may have changed: a font not yet
    resolved at login measures as nothing, so a width of zero is left alone
    rather than collapsing the button.
]]
function ns.FitRestockerHeaderButton(button)
	local width = button:GetFontString() and button:GetFontString():GetStringWidth() or 0
	if width > 0 then
		button:SetWidth(width + HEADER_BUTTON_PADDING)
	end
end

--------------------------------------------------------------------------------
-- ElvUI
--------------------------------------------------------------------------------

--[[
    With ElvUI loaded, its Skins module dresses a window's buttons and fields
    as it dresses Blizzard's, so they match the rest of that UI rather than the
    default art, as the Spell Book's controls do. The module is another
    add-on's API, so each call is guarded: a change to it leaves a control in
    the default art instead of breaking the window. Without ElvUI this does
    nothing.
]]
function ns.ApplyRestockerElvUISkin(editBoxes, buttons, checkBoxes)
	local elv = ElvUI and ElvUI[1]
	local skins = elv and elv.GetModule and elv:GetModule("Skins", true)
	if not skins then
		return
	end
	for _, box in ipairs(editBoxes or {}) do
		pcall(skins.HandleEditBox, skins, box)
	end
	for _, button in ipairs(buttons or {}) do
		pcall(skins.HandleButton, skins, button)
	end
	for _, checkBox in ipairs(checkBoxes or {}) do
		pcall(skins.HandleCheckBox, skins, checkBox)
	end
end
