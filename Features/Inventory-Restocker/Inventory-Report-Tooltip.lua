local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

-- The Inventory Report's lines in item tooltips; what it shows and why is in Inventory-Report-Recording.lua.

--[[
    How long after login the tooltips are hooked, in seconds. A tooltip's add-on
    lines appear in the order their hooks were installed, and this block belongs
    under the others', so it goes in after the add-ons that hook at load, at
    login, or a few staged seconds into it have all had their turn. The cost is
    that an item hovered in the first moments of a session shows no report.
    Best effort: an add-on that loads on demand later still lands below.
]]
local TOOLTIP_HOOK_DELAY = 5

-- Leading pad on each row under the header, matching the other add-ons' tooltip blocks (Water Dispenser's).
local ROW_INDENT = " "

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

--[[
    The other characters on this realm, unpacked once per login. They are
    logged out, so nothing can change them during this session; a new login
    binds a new record, which rebuilds the list.
]]
local others, othersRecord

local function OtherCharacters()
	local record = ns.GetInventoryRecord()
	if others and othersRecord == record then
		return others
	end

	others, othersRecord = {}, record
	local realm = GetRealmName()
	for key, entry in pairs(ns.db.global.inventory) do
		if entry ~= record and entry.realm == realm and entry.name then
			others[#others + 1] = {
				key = key,
				name = entry.name,
				class = entry.class,
				bags = ns.UnpackInventoryCounts(entry.bags),
				bank = entry.bank and ns.UnpackInventoryCounts(entry.bank) or nil,
			}
		end
	end

	-- Alphabetical by name; the key only settles two characters that share one.
	table.sort(others, function(a, b)
		local left, right = a.name:lower(), b.name:lower()
		if left ~= right then
			return left < right
		end
		return a.key < b.key
	end)
	return others
end

-- The Keep amount of this item on the current Restock List, or nil when it is not on it or keeps none.
local function KeepAmount(itemID)
	local settings = ns.restockSettings
	local list = settings and settings.lists and settings.lists[settings.currentList]
	local row = list and list[itemID]
	if type(row) == "table" and (row.amount or 0) > 0 then
		return row.amount
	end
end

local TEXT_COLOR = GetColor("TEXT")

--[[
    The header line, built once: it says the same thing on every tooltip. It is
    the chat prints' branded shape (ns.PrintMessage): tooltips carry the
    add-on's short name.
]]
local REPORT_HEADER = GetColor("INFO")
	.. L["ADDON_SHORT_NAME"]
	.. "|r "
	.. GetColor("SEPARATOR")
	.. "//"
	.. "|r "
	.. TEXT_COLOR
	.. L["INVENTORY_REPORT_TITLE"]
	.. "|r"

--[[
    The right-hand values put their words (Total, Bag, Bank) in the header's
    separator gray and every count in white, so the numbers stand out. The gray
    picks up again after each count, for a locale that puts more words behind
    it.
]]
local LABEL_COLOR = GetColor("SEPARATOR")

local function Count(value)
	return TEXT_COLOR .. value .. "|r" .. LABEL_COLOR
end

-- Only the places holding some: "Bag 7, Bank 18", "Bag 7" or "Bank 18", and nil when both are 0.
local function Counts(bags, bank)
	if bags > 0 and bank > 0 then
		return format(L["INVENTORY_REPORT_COUNTS"], Count(bags), Count(bank))
	elseif bags > 0 then
		return format(L["INVENTORY_REPORT_BAG"], Count(bags))
	elseif bank > 0 then
		return format(L["INVENTORY_REPORT_BANK"], Count(bank))
	end
end

--[[
    A character's row: its name one space in and in its class color, its
    counts at the right edge. A character holding none (this one can lead the
    block that way) is the name alone.
]]
local function CharacterRow(name, class, bags, bank)
	local counts = Counts(bags, bank)
	return {
		ROW_INDENT .. (ns.GetClassColor(class) or TEXT_COLOR) .. name .. "|r",
		counts and (LABEL_COLOR .. counts .. "|r"),
	}
end

--[[
    The report's lines, ready to add, or nil when there is nothing to say: the
    report is off, or nobody on the realm holds the item and it is not on the
    Restock List either. An item on the list always reports, so a list item
    nobody holds says so rather than saying nothing.

    Each line is { left, right }. A line with both goes in as a double line, a
    label with its count at the tooltip's right edge; one with only a left is a
    plain line (a spacer).

    This character always leads, holding any or not, so the list reads top to
    bottom against the total; the others follow under a spacer, and only those
    holding some.

    Published for the tooltip hooks below.
]]
function ns.GetInventoryReportLines(itemID)
	local record = ns.GetInventoryRecord()
	if not (record and ns.db and ns.db.global.inventoryReport) then
		return nil
	end

	local bankCounts = ns.GetInventoryBankCounts()
	local bags = C_Item.GetItemCount(itemID, false) or 0
	local bank = bankCounts and bankCounts[itemID] or 0
	local total = bags + bank

	local holders = {}
	for _, other in ipairs(OtherCharacters()) do
		local otherBags = other.bags[itemID] or 0
		local otherBank = other.bank and other.bank[itemID] or 0
		if otherBags + otherBank > 0 then
			holders[#holders + 1] = { character = other, bags = otherBags, bank = otherBank }
			total = total + otherBags + otherBank
		end
	end

	local keep = KeepAmount(itemID)
	if total == 0 and not keep then
		return nil
	end

	local lines = { { REPORT_HEADER, LABEL_COLOR .. format(L["INVENTORY_REPORT_TOTAL"], Count(total)) .. "|r" } }

	lines[#lines + 1] = CharacterRow(record.name, record.class, bags, bank)

	if #holders > 0 then
		lines[#lines + 1] = { " " }
		for _, holder in ipairs(holders) do
			lines[#lines + 1] = CharacterRow(holder.character.name, holder.character.class, holder.bags, holder.bank)
		end
	end

	return lines
end

--------------------------------------------------------------------------------
-- Tooltip Hooks
--------------------------------------------------------------------------------

--[[
    Which tooltips already carry a report for what they are showing. Era can
    fire OnTooltipSetItem more than once for one item (a recipe and the item it
    makes), and a second block under the first is the bug this prevents.
    Cleared with the tooltip's lines. Weak-keyed, though only the two tooltips
    below ever land in it.
]]
local reported = setmetatable({}, { __mode = "k" })

local function AddReport(tooltip, itemID)
	if not itemID or reported[tooltip] or ns.IsSecretValue(itemID) then
		return
	end
	if tooltip.IsForbidden and tooltip:IsForbidden() then
		return
	end

	local lines = ns.GetInventoryReportLines(itemID)
	if not lines then
		return
	end

	reported[tooltip] = true
	tooltip:AddLine(" ")
	for _, line in ipairs(lines) do
		if line[2] then
			tooltip:AddDoubleLine(line[1], line[2], 1, 1, 1, 1, 1, 1)
		else
			tooltip:AddLine(line[1], 1, 1, 1)
		end
	end
end

local function OnTooltipCleared(tooltip)
	reported[tooltip] = nil
end

local function ItemIDFromLink(link)
	return link and tonumber(link:match("item:(%d+)"))
end

-- A hook cannot be removed, so it is installed once however often login runs.
local tooltipsHooked = false

--[[
    Forever runs Retail's tooltip pipeline, where OnTooltipSetItem is gone and
    TooltipDataProcessor hands every item tooltip to a post-call; Era and TBC
    have no TooltipDataProcessor and still fire OnTooltipSetItem. Only the main
    tooltip and the clicked-link one are reported on: the comparison tooltips
    beside them would only repeat the same block.
]]
local function HookTooltips()
	if tooltipsHooked then
		return
	end
	tooltipsHooked = true

	local tooltips = { GameTooltip, ItemRefTooltip }
	for _, tooltip in ipairs(tooltips) do
		tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
	end

	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if tooltip == GameTooltip or tooltip == ItemRefTooltip then
				AddReport(tooltip, data and data.id)
			end
		end)
		return
	end

	local function OnTooltipSetItem(tooltip)
		local _, link = tooltip:GetItem()
		AddReport(tooltip, ItemIDFromLink(link))
	end
	for _, tooltip in ipairs(tooltips) do
		tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
	end
end

-- Called at login (ns.InitializeInventoryReport) to hook the tooltips once TOOLTIP_HOOK_DELAY has passed.
function ns.HookInventoryReportTooltipsLater()
	C_Timer.After(TOOLTIP_HOOK_DELAY, HookTooltips)
end
