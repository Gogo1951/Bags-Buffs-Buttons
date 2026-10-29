local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local HasTemplate = ns.HasTemplate

--[[
	The page's window, BagsBuffsButtonsSpellbookFrame, which every host opens from its tab on the game's spellbook: the
	Blizzard portrait frame (the gold book in its portrait, the title, the close button) holding the page
	Features/Spellbook/Spellbook-Page.lua builds. It stays clear of the book, so UI skins that restyle the book leave it
	alone, and it is parented to UIParent, so nothing Blizzard owns is written to.
]]

local ICON_ADDON = ns.ICON_ADDON

--[[
	A 100% UI is 768 points tall, so this size shows unscaled there with the screen margin to spare; smaller UIs
	shrink it to fit.
]]
local WINDOW_WIDTH, WINDOW_HEIGHT = 1000, 640
local SCREEN_MARGIN = 40 -- kept clear around the window when it is scaled down to fit

local window
local listeners = {} -- the hosts' tabs, told when the window shows or hides
local dockWidth = 0 -- the panel docked at the window's right edge (ns.DockSpellbookPanel), or 0 for none

--[[
	Shrinks the window, never grows it, so the whole spread fits on screen at any resolution or UI scale, a docked
	panel included.
]]
local function FitToScreen()
	local scale = math.min(
		1,
		(UIParent:GetWidth() - 2 * SCREEN_MARGIN) / (WINDOW_WIDTH + dockWidth),
		(UIParent:GetHeight() - 2 * SCREEN_MARGIN) / WINDOW_HEIGHT
	)
	window:SetScale(scale)
end

local function Notify()
	for _, listener in ipairs(listeners) do
		listener()
	end
end

local function CreateWindow()
	local template = HasTemplate("PortraitFrameTemplate") and "PortraitFrameTemplate" or "BasicFrameTemplate"
	window = CreateFrame("Frame", "BagsBuffsButtonsSpellbookFrame", UIParent, template)
	window:Hide()
	window:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
	window:SetPoint("CENTER")
	window:SetFrameStrata("HIGH")
	window:SetToplevel(true)
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	-- "Spell Book // Bags Buffs & Buttons" in the add-ons' shared colours: the page white, the slashes grey, the name blue
	local title = GetColor("TEXT")
		.. L["WINDOW_TITLE"]
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//|r "
		.. GetColor("INFO")
		.. L["ADDON_TITLE"]
		.. "|r"
	if window.SetTitle then
		window:SetTitle(title)
	else
		window.TitleText:SetText(title)
	end
	if window.SetPortraitToAsset then
		window:SetPortraitToAsset(ICON_ADDON)
	end
	-- Escape closes it, like the book
	table.insert(UISpecialFrames, window:GetName())
	window:HookScript("OnShow", function()
		FitToScreen()
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN)
		Notify()
		-- the window takes the book's place, so the host closes the game's own book behind it
		if ns.CloseGameSpellbook then
			ns.CloseGameSpellbook()
		end
	end)
	window:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE)
		Notify()
	end)

	-- the page covers the whole window; it draws the controls, parchment and footer inside the frame's border
	local page = CreateFrame("Frame", nil, window)
	page:SetAllPoints()
	ns.BuildSpellbookPage(page)
	page:SetScript("OnShow", ns.RefreshSpellbookPage)
end

function ns.ToggleSpellbookWindow()
	if not ns.IsSpellbookEnabled() then
		ns:PrintMessage(L["SPELLBOOK_DISABLED"])
		return
	end
	if not window then
		CreateWindow()
	end
	window:SetShown(not window:IsShown())
end

function ns.IsSpellbookWindowShown()
	return window ~= nil and window:IsShown()
end

-- Calls fn whenever the window shows or hides, so a host's tab can show it as selected.
function ns.OnSpellbookWindowToggled(fn)
	listeners[#listeners + 1] = fn
end

--[[
	Closes the window, for the Spellbook's switch turning off (ns.SetSpellbookEnabled).
]]
function ns.HideSpellbookWindow()
	if window then
		window:Hide()
	end
end

--[[
	Docks a panel width wide against the window's right edge, the Conditionals panel
	(Features/Spellbook/Conditionals-Panel.lua), or none with 0: the window shrinks to fit both, and keeps the
	panel on screen as it is dragged, pulled back in at once if it hangs off the edge now.
]]
function ns.DockSpellbookPanel(width)
	dockWidth = width
	if not window then
		return
	end
	window:SetClampRectInsets(0, width, 0, 0)
	FitToScreen()
	local point, relativeTo, relativePoint, x, y = window:GetPoint()
	if point then
		window:ClearAllPoints()
		window:SetPoint(point, relativeTo, relativePoint, x, y)
	end
end

-- The window, or nil before it is first opened, for the panel docked beside it.
function ns.SpellbookWindow()
	return window
end

-- The key binding's toggle (Features/Spellbook/Key-Bindings.lua), the same as a click on a host's tab.
ns.ToggleSpellbookPage = ns.ToggleSpellbookWindow
