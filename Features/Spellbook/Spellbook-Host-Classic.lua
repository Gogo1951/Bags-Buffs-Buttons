local _, ns = ...
local BODY = ns.COLORS_RGB.BODY
local L = ns.L
local GetColor = ns.GetColor
local HideTooltip = ns.HideTooltip

--[[
	Hosts the page on the Classic engine (Classic Era, TBC, MoP Classic): a tab under the class's skill line
	tabs down the book's right edge toggles the page's window (Features/Spellbook/Spellbook-Window.lua). The tab is
	parented to UIParent and only anchored to the book, so nothing Blizzard owns is written to and the book's
	own buttons stay untainted; native tab clicks are watched with hooksecurefunc.
]]

local ICON_ADDON = ns.ICON_ADDON

local TAB_GAP = 17 -- the space the book leaves between its skill line tabs

local book = SpellBookFrame
local tab

-- The tab shows only over the book's own spell pages, never the pet book or another tab of it.
local function ShowsSpells()
	return book:IsShown() and (book.bookType == nil or book.bookType == BOOKTYPE_SPELL)
end

local function SyncTab()
	tab.checked:SetShown(ns.IsSpellbookWindowShown())
end

--[[
	The skill line tab the page's tab lines up under: the class's last spell tab, so it sits right under the
	class's own tabs. Other add-ons show tabs of their own in the book's spare slots (WhatsTraining takes the
	second to last), and lining up under the last shown tab put ours below theirs, off the bottom of the book.
	Falls back to the last shown tab when the spell tab count doesn't name a shown tab.
]]
local function AnchorSkillLineTab()
	local classLast = GetNumSpellTabs and _G["SpellBookSkillLineTab" .. GetNumSpellTabs()]
	if classLast and classLast:IsShown() then
		return classLast
	end
	local last
	local i = 1
	while _G["SpellBookSkillLineTab" .. i] do
		local skillLineTab = _G["SpellBookSkillLineTab" .. i]
		if skillLineTab:IsShown() then
			last = skillLineTab
		end
		i = i + 1
	end
	return last
end

local function Sync()
	local shown = ShowsSpells() and ns.IsSpellbookEnabled()
	tab:SetShown(shown)
	if shown then
		tab:ClearAllPoints()
		local last = AnchorSkillLineTab()
		if last then
			tab:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -TAB_GAP)
		else
			tab:SetPoint(SpellBookSkillLineTab1:GetPoint(1))
		end
		tab:SetFrameStrata(book:GetFrameStrata())
		tab:SetFrameLevel(book:GetFrameLevel() + 30)
	end
	SyncTab()
end

local function CreateTab()
	tab = CreateFrame("Button", nil, UIParent)
	tab:SetSize(32, 32)
	tab:Hide()
	local background = tab:CreateTexture(nil, "BACKGROUND")
	background:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
	background:SetSize(64, 64)
	background:SetPoint("TOPLEFT", -3, 11)
	tab:SetNormalTexture(ICON_ADDON)
	tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	tab.checked = tab:CreateTexture(nil, "OVERLAY")
	tab.checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	tab.checked:SetBlendMode("ADD")
	tab.checked:SetAllPoints()
	tab.checked:Hide()
	tab:SetScript("OnClick", ns.ToggleSpellbookWindow)
	tab:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(ns.SpellbookTabTitle())
		GameTooltip:AddLine(L["SPELLBOOK_TAB_DESCRIPTION"], BODY.r, BODY.g, BODY.b, true)
		GameTooltip:AddDoubleLine(
			GetColor("INFO") .. L["TOOLTIP_KEY_CLICK"] .. "|r",
			GetColor("INFO") .. L["TOOLTIP_ACTION_OPEN_PAGE"] .. "|r"
		)
		GameTooltip:Show()
	end)
	tab:SetScript("OnLeave", HideTooltip)
	tab:SetScript("OnHide", HideTooltip)
end

--[[
	Closes the game's book when the window opens (Features/Spellbook/Spellbook-Window.lua), the way the game closes one of
	its panels for another. Not in combat, where the book's spell buttons are protected and hiding it is blocked;
	there the book just stays open behind the window.
]]
function ns.CloseGameSpellbook()
	if book:IsShown() and not InCombatLockdown() then
		HideUIPanel(book)
	end
end

CreateTab()
ns.SyncSpellbookHost = Sync -- the master switch shows or hides the tab at once
ns.OnSpellbookWindowToggled(SyncTab)
book:HookScript("OnShow", Sync)
book:HookScript("OnHide", Sync)
-- The book's own update runs on every page or book-type change and whenever the skill line tabs change.
if book.Update then
	hooksecurefunc(book, "Update", Sync)
end
