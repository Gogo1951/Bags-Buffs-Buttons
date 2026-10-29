local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Item-Info -- the session's C_Item.GetItemInfo answers, the links built from
    them, and the GET_ITEM_INFO_RECEIVED subscription every feature waiting on a
    cold item shares. Owned here rather than by any one feature, so each one's
    item names fill in whichever features this client loads.
]]

--------------------------------------------------------------------------------
-- Item Info Waiters
--------------------------------------------------------------------------------

--[[
    GET_ITEM_INFO_RECEIVED has more than one waiter -- the consumable macros' bag
    scan (ns.RegisterDataRetry); the Restock List, which defers an add, an
    upgrade or a Starter List tick on the same cold-cache miss; and each options
    panel showing items that have not loaded yet (ns.WarmItemCache). The client
    answers this event once per item it resolves, which during a login is a
    flood, so it is registered only while somebody is actually waiting.

    Keyed rather than counted: a waiter that asks twice must not need to release
    twice, and the last one out is what unregisters.
]]
local itemInfoWaiters = {}

--[[
    The misses ns.GetItemData is remembering, [itemID] = true. Kept beside the
    waiters because the waiters decide how long a miss can be trusted, and the
    last one out drops them all: see Session Item Data below.
]]
local rememberedMisses = {}

local MODULE = "ItemInfo"

--[[
    Every answer goes to each waiter in this order: the Restocker forgets the
    item's remembered miss and retries its rows first, then the options item
    lists waiting on it repaint, asking only once the miss is gone, then the
    consumable macros rebuild if the item is one of theirs.
]]
ns.RegisterEventModule(MODULE, function(_, itemID, success)
	if ns.OnRestockerItemInfoReceived then
		ns.OnRestockerItemInfoReceived(itemID, success)
	end
	if ns.OnOptionsItemInfoReceived then
		ns.OnOptionsItemInfoReceived(itemID, success)
	end
	if ns.OnConsumableItemInfoReceived then
		ns.OnConsumableItemInfoReceived(itemID, success)
	end
end)

function ns.RequestItemInfoEvents(key)
	itemInfoWaiters[key] = true
	ns.SetModuleEvent(MODULE, "GET_ITEM_INFO_RECEIVED", true)
end

-- A release by a key that isn't waiting changes nothing, so it leaves the event and the remembered misses be.
function ns.ReleaseItemInfoEvents(key)
	if itemInfoWaiters[key] == nil then
		return
	end
	itemInfoWaiters[key] = nil
	if next(itemInfoWaiters) == nil then
		ns.SetModuleEvent(MODULE, "GET_ITEM_INFO_RECEIVED", false)
		rememberedMisses = {}
	end
end

--------------------------------------------------------------------------------
-- Session Item Data
--------------------------------------------------------------------------------

--[[
    A plain memo over C_Item.GetItemInfo, and the link builder that rides on it. Distinct
    from the consumable cache (Features/Macros-for-Consumables/Item-Cache.lua): that one is
    persisted, enriched from the consumable tables, and only ever holds consumables, while
    this one is thrown away at logout and answers for any item at all. Reach for
    the consumable cache when a consumable's own facts are wanted, and for this
    when a name, an icon or a link is.
]]

-- Every C_Item.GetItemInfo answer this session, keyed by whatever was asked for.
local getItemInfoCache = {}

--[[
    A miss is remembered too, but only while somebody is waiting on
    GET_ITEM_INFO_RECEIVED, which is when the same cold item gets asked about
    over and over. Every answer that arrives re-runs the parked upgrades,
    recipes and Starter List ticks, and each of those asks again about whatever
    is still cold. During a login that is a flood, and without the remembered
    miss every one of those asks would be a fresh C_Item.GetItemInfo call.

    A miss taken while nobody is listening is never remembered. The client
    announces its answer once, and with the event unregistered that answer
    lands unheard, so a remembered miss would outlive it for the rest of the
    session: a Restock List row stuck on a question-mark icon, and a later add,
    upgrade or recipe for that item parked for an answer that already came.
    The last waiter out drops every remembered miss for the same reason
    (ns.ReleaseItemInfoEvents above). While somebody listens a miss is safe to
    keep, because every answer heard reaches ns.OnRestockerItemInfoReceived
    (Restocker-List.lua), which forgets that item's miss before it retries
    anything. The one answer it skips is for an item that does not exist,
    whose miss stays true. The price is a fresh call for every ask while
    nothing waits, which a Restock List redraw pays once or twice per cold row.

    Not scoped to a frame by GetTime() instead. That clock can read the same
    across consecutive frames, so a frame's miss can still be trusted after
    its answer has landed unheard, and a deferral that reads it then is
    stranded just the same.

    Only ID-keyed misses are remembered. This cache is keyed by whatever the
    caller asked with -- an id on the hot paths, an item link at a merchant --
    and GET_ITEM_INFO_RECEIVED reports an id, so an id is the only key
    ns.ForgetItemDataMiss can clear when the answer arrives.
]]
function ns.ForgetItemDataMiss(itemID)
	rememberedMisses[itemID] = nil
end

-- Calls C_Item.GetItemInfo and saves the results; an ID-keyed miss is remembered only while a waiter listens.
function ns.GetItemData(request)
	local cached = getItemInfoCache[request]
	if cached ~= nil then
		return cached
	end
	if rememberedMisses[request] then
		return nil
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
		C_Item.GetItemInfo(request)
	if itemName == nil then
		if type(request) == "number" and next(itemInfoWaiters) ~= nil then
			rememberedMisses[request] = true
		end
		return nil
	end

	local cacheItem = {
		itemID = tonumber(string.match(itemLink, "item:(%d+)")),
		itemName = itemName,
		itemLink = itemLink,
		itemRarity = itemRarity,
		itemLevel = itemLevel,
		itemMinLevel = itemMinLevel,
		itemType = itemType,
		itemSubType = itemSubType,
		itemStackCount = itemStackCount,
		itemEquipLoc = itemEquipLoc,
		itemTexture = itemTexture,
		itemSellPrice = itemSellPrice,
	}
	getItemInfoCache[request] = cacheItem
	return cacheItem
end

--[[
    A printable, hoverable, shift-clickable link for an item, always.

    C_Item.GetItemInfo returns nothing until the client has resolved an item, and on a
    fresh login that is exactly when the Restocker wants to name things -- so a
    bare-name fallback would print plain text most of the time. A link built by
    hand from the id works the moment it is printed: the
    client resolves |Hitem:| on hover, so the tooltip is correct even while the
    cache behind it is still cold.

    The colour on the hand-built form is white rather than the item's quality
    colour, which is the one thing that cannot be known without the cache. The
    cached link is preferred whenever it exists, and it carries the real colour.
]]
function ns.GetItemHyperlink(itemID, fallbackName)
	local info = itemID and ns.GetItemData(itemID) or nil
	if info and info.itemLink then
		return info.itemLink
	end

	if itemID then
		local label = (fallbackName and fallbackName ~= "") and fallbackName or L["LOADING_ITEM"]:format(itemID)
		return GetColor("TEXT") .. "|Hitem:" .. itemID .. "|h[" .. label .. "]|h|r"
	end

	return fallbackName or "?"
end

--[[
    An item's name for the add-on's own windows, panels and tooltips: the
    link's text in its quality color, with the square brackets taken off.
    Brackets are how chat marks a link, so everything printed to chat keeps
    them (ns.GetItemHyperlink above). Beside the item's icon they are clutter,
    and the Restock List's own rows have never worn them.

    ns.UnbracketItemLink takes a link the caller already holds. ns.GetItemLabel
    names an item from its ID the way ns.GetItemHyperlink does, cold cache
    included.
]]
function ns.UnbracketItemLink(link)
	return (link:gsub("|h%[(.-)%]|h", "|h%1|h"))
end

function ns.GetItemLabel(itemID, fallbackName)
	return ns.UnbracketItemLink(ns.GetItemHyperlink(itemID, fallbackName))
end
