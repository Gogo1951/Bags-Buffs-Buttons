local ADDON_NAME, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- Display Context
--------------------------------------------------------------------------------

--[[
    Answers "it's gone / off-screen" reports for everything the add-on draws:
    screen size and UI scale, then the mini-map button's saved placement, the
    Buff Window's, and where the spellbook,
    the Spellbook's tab and its page sit. Read-only.
]]

-- The main mini-map button, and where a dragged position lives, link by link.
local function AppendMinimapLines(lines)
	lines[#lines + 1] = ""
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	-- Without the data object, login never registers a button and every repaint returns early.
	lines[#lines + 1] = string.format("Data broker object: %s", ns.dataBrokerObject and "present" or "MISSING")
	lines[#lines + 1] = string.format("Minimap button created: %s", button and "yes" or "no")

	local minimap = ns.db and ns.db.global.minimap
	if type(minimap) == "table" then
		lines[#lines + 1] = string.format("Minimap button hidden: %s", tostring(minimap.hide or false))
		lines[#lines + 1] = string.format("Minimap saved angle: %s", tostring(minimap.minimapPos))
	else
		lines[#lines + 1] = "Minimap saved position: (none yet)"
	end

	--[[
	    Where a dragged position lives, link by link: LibDBIcon's drag handler
	    computes the angle with math.atan2 every frame and writes it into the
	    button's db, which has to be the very table AceDB saves, and the raw
	    SavedVariables value is what the client writes at logout.
	]]
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("math.atan2 present: %s", tostring(type(math.atan2) == "function"))
	lines[#lines + 1] = string.format("LibDBIcon-1.0 minor: %s", tostring(LibStub.minors["LibDBIcon-1.0"]))
	if button then
		lines[#lines + 1] = string.format("Button db present: %s", tostring(button.db ~= nil))
		lines[#lines + 1] = string.format(
			"Button db is ns.db.global.minimap: %s",
			tostring(button.db ~= nil and minimap ~= nil and button.db == minimap)
		)
		lines[#lines + 1] = string.format("Button db.minimapPos: %s", tostring(button.db and button.db.minimapPos))
	end
	local saved = _G[ns.SAVED_VARIABLES_NAME]
	local savedGlobal = type(saved) == "table" and saved.global
	local savedMinimap = type(savedGlobal) == "table" and savedGlobal.minimap
	lines[#lines + 1] = string.format(
		"%s.global.minimap.minimapPos: %s",
		ns.SAVED_VARIABLES_NAME,
		tostring(type(savedMinimap) == "table" and savedMinimap.minimapPos or nil)
	)
end

--[[
    The Buff Window saves its top-left corner in UIParent's coordinates,
    measured from the bottom-left, so a corner outside UIParent's size was
    saved on a bigger screen or a smaller UI scale.
]]
local function AppendBuffWindowLines(lines)
	local uiWidth, uiHeight = UIParent:GetWidth(), UIParent:GetHeight()
	lines[#lines + 1] = string.format("UIParent size: %.1f x %.1f", uiWidth, uiHeight)

	lines[#lines + 1] = ""
	local db = ns.db and ns.db.global.buffWindow
	if not db then
		lines[#lines + 1] = "Buff Window: (database not loaded)"
		return
	end
	local point = db.point
	if type(point) == "table" then
		local left, top = tonumber(point[1]), tonumber(point[2])
		local onScreen = left and top and left >= 0 and left <= uiWidth and top >= 0 and top <= uiHeight
		lines[#lines + 1] = string.format(
			"Buff Window saved top-left: %s, %s (%s)",
			tostring(point[1]),
			tostring(point[2]),
			onScreen and "on screen" or "OFF SCREEN"
		)
	else
		lines[#lines + 1] =
			"Buff Window saved top-left: (never dragged; default, a little left of and above the middle)"
	end
	lines[#lines + 1] = string.format(
		"Buff Window: enabled=%s locked=%s hideInCombat=%s",
		tostring(db.enabled),
		tostring(db.locked),
		tostring(db.hideInCombat)
	)
end

--[[
	The page and the Classic-engine host's tab are kept to themselves, so they are found by shape: the page
	among its window's children (BagsBuffsButtonsSpellbookFrame, built on the first click of a tab), carrying the geometry
	and frame pools the page builder gives it; the tab among UIParent's, carrying the checked overlay the host
	draws.
]]
local function FrameLine(label, frame)
	if not frame then
		return string.format("%s: (none)", label)
	end
	local left, bottom, width, height = frame:GetRect()
	return string.format(
		"%s: shown %s, visible %s, rect %s, scale %s, strata %s, level %s",
		label,
		tostring(frame:IsShown()),
		tostring(frame:IsVisible()),
		left and string.format("%.0f,%.0f %.0fx%.0f", left, bottom, width, height) or "unplaced",
		tostring(frame:GetScale()),
		tostring(frame:GetFrameStrata()),
		tostring(frame:GetFrameLevel())
	)
end

local function FindClassicFrames()
	local page, tab
	local window = _G.BagsBuffsButtonsSpellbookFrame
	for _, child in ipairs(window and { window:GetChildren() } or {}) do
		if child.geometry and child.buttons and child.headers then
			page = child
		end
	end
	for _, child in ipairs({ UIParent:GetChildren() }) do
		if not child:IsForbidden() then
			if child.checked and child:IsObjectType("Button") and child:GetNumPoints() > 0 then
				local _, relativeTo = child:GetPoint(1)
				if
					relativeTo
					and relativeTo.GetName
					and tostring(relativeTo:GetName()):find("^SpellBookSkillLineTab")
				then
					tab = child
				end
			end
		end
	end
	return page, tab
end

local function PageLines(lines, page)
	if not page then
		return
	end
	local geometry = page.geometry
	lines[#lines + 1] = string.format(
		"  page geometry: view %s wide, %s columns; %s macro cells and %s headers in use",
		tostring(geometry and geometry.viewWidth),
		tostring(geometry and geometry.columns),
		tostring(page.buttons and page.buttons.used),
		tostring(page.headers and page.headers.used)
	)
	local controls = page.pagingControls
	if controls and controls.GetCurrentPage then
		lines[#lines + 1] = string.format(
			"  paging: page %s of %s, arrows shown %s",
			tostring(controls:GetCurrentPage()),
			tostring(controls.GetMaxPages and controls:GetMaxPages()),
			tostring(controls:IsShown())
		)
	end
end

-- The spellbook, the Spellbook's tab, its window and the page.
local function AppendSpellbookLines(lines)
	local spellbookTabs = ns.SpellbookTabs
	if spellbookTabs then
		local tab = spellbookTabs.byId[ADDON_NAME]
		lines[#lines + 1] = FrameLine("PlayerSpellsFrame", PlayerSpellsFrame)
		lines[#lines + 1] = FrameLine("Spellbook", spellbookTabs.book)
		lines[#lines + 1] = FrameLine("Page root", spellbookTabs.root)
		lines[#lines + 1] = FrameLine("Tab", tab and tab.button)
		local page = FindClassicFrames()
		lines[#lines + 1] = FrameLine("Window", _G.BagsBuffsButtonsSpellbookFrame)
		lines[#lines + 1] = FrameLine("Page", page)
		PageLines(lines, page)
		lines[#lines + 1] = string.format(
			"Gamepad UI (hides the tab): %s",
			tostring(InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled() or false)
		)
	else
		local page, tab = FindClassicFrames()
		lines[#lines + 1] = FrameLine("SpellBookFrame", SpellBookFrame)
		local shownTabs, index = 0, 1
		while _G["SpellBookSkillLineTab" .. index] do
			if _G["SpellBookSkillLineTab" .. index]:IsShown() then
				shownTabs = shownTabs + 1
			end
			index = index + 1
		end
		lines[#lines + 1] = string.format("Skill line tabs shown: %d of %d", shownTabs, index - 1)
		lines[#lines + 1] = FrameLine("Tab", tab)
		lines[#lines + 1] = FrameLine("Window", _G.BagsBuffsButtonsSpellbookFrame)
		lines[#lines + 1] = FrameLine("Page", page)
		PageLines(lines, page)
	end
end

function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }

	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("Physical screen size: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent and UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))
	lines[#lines + 1] = string.format("useUiScale CVar: %s", tostring(GetCVar("useUiScale")))

	AppendMinimapLines(lines)
	lines[#lines + 1] = ""
	AppendBuffWindowLines(lines)
	lines[#lines + 1] = ""
	AppendSpellbookLines(lines)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local count = C_AddOns.GetNumAddOns()
	for index = 1, count do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

--[[
    What the add-on fills in itself, counted rather than printed, matched by
    key at any depth since AceDB moves it with the active profile: itemCache,
    the derived consumable cache.
]]
local SUMMARIZED_BY_KEY = {
	itemCache = "cached items",
}

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		local noun = type(entry) == "table" and SUMMARIZED_BY_KEY[key]
		if noun then
			lines[#lines + 1] = indent .. tostring(key) .. string.format(" = <%d %s>", CountKeys(entry), noun)
		elseif type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

--[[
    Dumps the single AceDB-managed table (profiles, profileKeys, char, global)
    so a player can paste their exact configuration: every setting in each
    profile and every Restock List row, with only the add-on's own caches
    counted.
]]
function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", ns.SAVED_VARIABLES_NAME .. " = {" }
	DumpTable(_G[ns.SAVED_VARIABLES_NAME] or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end
