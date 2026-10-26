local _, ns = ...

--[[
	The page strip along the parchment's bottom: the previous arrow at its left, "Page 1/2" in the faded ink of
	a tile's rank line in its middle, the next arrow at its right; the caller sizes and places it. Built here rather than from Blizzard's
	paging template, which reads a format string the Classic engine's clients don't define. A click or wheel
	step that turns the page calls page:OnPageChanged(); SetMaxPages and SetCurrentPage never do.
]]
local PAGE_BUTTON_SIZE = 32
local PAGE_PREV_TEXTURE = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage"
local PAGE_NEXT_TEXTURE = "Interface\\Buttons\\UI-SpellbookIcon-NextPage"

local function CreatePageButton(parent, texture)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(PAGE_BUTTON_SIZE, PAGE_BUTTON_SIZE)
	button:SetNormalTexture(texture .. "-Up")
	button:SetPushedTexture(texture .. "-Down")
	button:SetDisabledTexture(texture .. "-Disabled")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	return button
end

-- parent holds the strip; page is told when it turns.
function ns.CreatePagingControls(page, parent)
	local controls = CreateFrame("Frame", nil, parent or page)
	controls:SetHeight(PAGE_BUTTON_SIZE)
	local current, maxPages = 1, 1
	local prevButton = CreatePageButton(controls, PAGE_PREV_TEXTURE)
	prevButton:SetPoint("LEFT")
	local nextButton = CreatePageButton(controls, PAGE_NEXT_TEXTURE)
	nextButton:SetPoint("RIGHT")
	controls.PageText = controls:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	controls.PageText:SetPoint("CENTER")
	controls.PageText:SetTextColor(unpack(ns.FADED_INK_COLOR))
	controls.PageText:SetShadowOffset(0, 0)

	local function Update()
		controls.PageText:SetText(PAGE_NUMBER:format(current) .. "/" .. maxPages)
		prevButton:SetEnabled(current > 1)
		nextButton:SetEnabled(current < maxPages)
	end

	local function Turn(step)
		local target = math.max(1, math.min(maxPages, current + step))
		if target ~= current then
			current = target
			Update()
			PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN)
			page:OnPageChanged()
		end
	end

	prevButton:SetScript("OnClick", function()
		Turn(-1)
	end)
	nextButton:SetScript("OnClick", function()
		Turn(1)
	end)

	function controls:SetMaxPages(pages)
		maxPages = math.max(1, pages)
		current = math.min(current, maxPages)
		Update()
	end
	function controls:GetMaxPages()
		return maxPages
	end
	function controls:GetCurrentPage()
		return current
	end
	function controls:SetCurrentPage(pageNumber)
		current = math.max(1, math.min(maxPages, pageNumber))
		Update()
	end
	function controls:OnMouseWheel(delta)
		Turn(delta > 0 and -1 or 1)
	end

	Update()
	return controls
end
