local _, ns = ...
local L = ns.L

--[[
	Connoisseur's macros on the page, in a BBB Consumables section after every other: the Bandage, Food and
	Water macros it keeps pointed at the best item in the bags. Connoisseur writes and owns those WoW macros
	(Features/Connoisseur/Macros); the page only shows the ones that exist and picks them up, so nothing here
	creates, rewrites or tags one. A tile's icon is the item the macro uses now, its note that item's name, and
	both are read again whenever the tile is drawn, as Connoisseur rewrites the macro when the bags change.
]]

-- In the order the Macros panel's Which Macros to Create toggles list them, keyed by ns.MACRO_CONFIG's type.
local TYPES = {
	"Bandage",
	"Explosive",
	"Feed Pet",
	"Food",
	"Health Potion",
	"Healthstone",
	"Mana Gem",
	"Mana Potion",
	"Poisons",
	"Soulstone",
	"Water",
}

--[[
	Reads a consumable page macro's WoW macro again: its text, and the item it uses now and that item's icon,
	or the type's default item's icon (ns.MACRO_DEFAULT_ITEM_IDS) while the bags hold nothing it can use.
]]
function ns.ReadConsumableMacro(macro)
	local index = GetMacroIndexByName(macro.wowName)
	local body = index > 0 and GetMacroBody(index) or nil
	local itemName, itemLink
	if index > 0 then
		itemName, itemLink = GetMacroItem(index)
	end
	local defaultItem = ns.MACRO_DEFAULT_ITEM_IDS[macro.type]
	macro.body = body or ""
	macro.itemName, macro.itemLink = itemName, itemLink
	macro.icon = (itemLink and C_Item.GetItemIconByID(itemLink))
		or (defaultItem and C_Item.GetItemIconByID(defaultItem))
		or ns.QUESTION_MARK_ICON
end

--[[
	The page macros for the Connoisseur macros that exist, in TYPES' order. Each carries consumable = true, its
	WoW macro's name as wowName (Connoisseur's own, "- Food", in place of the page's prefix), and its name as
	the Macros panel shows it, without the dash.
]]
function ns.ConsumablePageMacros()
	local macros = {}
	for position, type in ipairs(TYPES) do
		local config = ns.MACRO_CONFIG[type]
		if config and GetMacroIndexByName(config.macro) > 0 then
			local macro = {
				consumable = true,
				type = type,
				name = (config.macro:gsub("^%- ", "")),
				wowName = config.macro,
				macroName = config.macro,
				category = L["SECTION_CONSUMABLES"],
				priority = position,
			}
			ns.ReadConsumableMacro(macro)
			macros[#macros + 1] = macro
		end
	end
	return macros
end
