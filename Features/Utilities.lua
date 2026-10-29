local _, ns = ...

--[[
    Utilities -- stateless, cross-cutting helpers used by multiple files: the
    color accessor, cross-client API shims, and the secret-value checks. No
    SavedVariables, and no module state beyond the hidden tooltip Era and TBC
    read tooltip text through. Each feature's own helpers live beside it, in
    Features/<Feature>/<Feature>-Utilities.lua.
]]

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Derived color table and accessor. The raw hex palette lives in
    Data/Data.lua (ns.PALETTE); this file prefixes each entry with the
    |cff escape and exposes ns.GetColor. Append |r at the point of use.
]]
local COLOR_PREFIX = "|cff"

local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = COLOR_PREFIX .. hex
end

ns.COLORS = COLORS

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

--[[
    "RRGGBB" to the {r, g, b} 0-1 triple the frame APIs take. Exposed rather than
    kept private to the palette loop below because the Restock window converts
    its own colors (ns.RESTOCKER_WINDOW_COLORS in Data/Data.lua) with it too, so
    every color is kept as the hex it was chosen as, never as hand-divided decimals.
]]
function ns.HexToRGB(hex)
	return {
		r = tonumber(hex:sub(1, 2), 16) / 255,
		g = tonumber(hex:sub(3, 4), 16) / 255,
		b = tonumber(hex:sub(5, 6), 16) / 255,
	}
end

--[[
    The same palette as numbers, for the APIs that take components rather than
    an escape string -- SetTextColor, SetColorTexture, SetVertexColor. Derived
    from ns.PALETTE at load rather than written out again, so a palette edit
    reaches the drawn frames and the coloured text together instead of moving
    one and leaving the other behind.
]]
ns.COLORS_RGB = {}
for key, hex in pairs(ns.PALETTE) do
	ns.COLORS_RGB[key] = ns.HexToRGB(hex)
end

--[[
    A class's color as an escape, for a character's name: the hex from
    ns.CLASS_COLORS (Data/Data.lua) behind the same prefix. nil for no class
    and for one the table does not hold, so each caller says what a name of
    unknown class falls back to. Append |r at the point of use.
]]
function ns.GetClassColor(classToken)
	local hex = classToken and ns.CLASS_COLORS[classToken]
	return hex and (COLOR_PREFIX .. hex) or nil
end

-- A class's name in the client's language, in its class color, white for a class the table does not hold.
function ns.ClassName(classToken)
	return (ns.GetClassColor(classToken) or ns.GetColor("TEXT"))
		.. (LOCALIZED_CLASS_NAMES_MALE[classToken] or classToken)
		.. "|r"
end

--------------------------------------------------------------------------------
-- Spell Knowledge
--------------------------------------------------------------------------------

--[[
    On Forever the IsSpellKnown and IsPlayerSpell globals exist only in
    Blizzard's deprecation layer, which the loadDeprecationFallbacks CVar
    switches off. C_SpellBook ships on all three clients, so these read it
    directly: ns.IsSpellKnown is exactly the deprecated IsSpellKnown (in the
    spellbook, overrides excluded) and ns.IsPlayerSpell is IsPlayerSpell.
    Callers wanting "does the player know it" test both.
]]
function ns.IsSpellKnown(spellID)
	return C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, false)
end

function ns.IsPlayerSpell(spellID)
	return C_SpellBook.IsSpellKnown(spellID)
end

--------------------------------------------------------------------------------
-- Client Differences
--------------------------------------------------------------------------------

--[[
    One accessor per API the engines differ on, resolved once here so every
    caller agrees and Diagnostics' API Endpoints show which side a client took.
    Each answers on every client, neutrally where the client lacks the API:

      ns.FetchPurchasedBankTabIDs()  Forever's character bank is the C_Bank
                                     tabs the player bought; nil on Era and
                                     TBC, which have BANK_CONTAINER and bags.
      ns.GetNumTalentTabs()          The classic talent trees; nil on Forever,
                                     whose talents are Retail's.
      ns.UnitCharacterPoints(unit)   Unspent talent points; nil on Forever.
      ns.IsSecretValue(value)        Forever's secret values; false elsewhere.
      ns.GetPlayerFullName()         This character's name: the first name and
                                     surname on Forever, the one name on Era
                                     and TBC.
      ns.GetNumQuestLogEntries(),    The quest log: a quest ID, nil for a
      ns.GetQuestLogQuestID(index)   header line.
      ns.GetNumSkillLines(),         The skill list, in the legacy return order.
      ns.GetSkillLineInfo(index)
      ns.GetPetFoodTypes()           The pet's diets, as a list.
      ns.GetMerchantItemInfo(index)  A merchant slot, in the legacy return
                                     order as far as the eighth value, whether
                                     the slot costs something besides gold.

    Forever runs on the Retail client, which has dropped the legacy quest,
    skill, pet and merchant readers for namespaced ones that return a table;
    Era and TBC have only the legacy globals. Spell names need no shim: every
    call site reads C_Spell.GetSpellName, which all three clients ship.
]]
if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
	function ns.FetchPurchasedBankTabIDs()
		return C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Character)
	end
else
	function ns.FetchPurchasedBankTabIDs()
		return nil
	end
end

if GetNumTalentTabs then
	ns.GetNumTalentTabs = GetNumTalentTabs
else
	function ns.GetNumTalentTabs()
		return nil
	end
end

if UnitCharacterPoints then
	ns.UnitCharacterPoints = UnitCharacterPoints
else
	function ns.UnitCharacterPoints()
		return nil
	end
end

if issecretvalue then
	ns.IsSecretValue = issecretvalue
else
	function ns.IsSecretValue()
		return false
	end
end

--[[
    A Forever character has a first name and a surname, unique together across
    the region, and the client hands them back as two values. Only a client
    with that system has RegionalUniqueNamesEnabled, and what it writes between
    the two is a constant of its own. On Era and TBC a name's second value is a
    realm, which for the player is nil.

    UnitNameUnmodified rather than UnitName, as AceDB keys its own records:
    this is the name a character is saved under, so it must not follow
    anything that restyles names for display.

    The surname is added only to a first value that does not already end with
    it. An earlier beta build's UnitName gave the whole name first, and saved
    files from it hold keys in that shape.

    Wherever the add-on saves or names a character -- a Restock List's
    characters, the Inventory Report, the character's own profile -- a Forever
    character is this whole name, never its first name alone.
]]
if RegionalUniqueNamesEnabled then
	local separatorConstants = Constants.CharacterNameSeparatorConsts
	local SURNAME_SEPARATOR = separatorConstants and separatorConstants.CHARACTERNAME_SURNAME_SEPARATOR or " "

	function ns.GetPlayerFullName()
		local name, surname = UnitNameUnmodified("player")
		if name and surname and surname ~= "" and RegionalUniqueNamesEnabled() then
			local ending = SURNAME_SEPARATOR .. surname
			if name:sub(-#ending) ~= ending then
				name = name .. ending
			end
		end
		return name
	end
else
	function ns.GetPlayerFullName()
		return (UnitName("player"))
	end
end

-- Whether this client ships a frame template, asked before CreateFrame names one it may lack.
function ns.HasTemplate(template)
	return C_XMLUtil.GetTemplateInfo(template) ~= nil
end

if C_QuestLog and C_QuestLog.GetInfo then
	ns.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local info = C_QuestLog.GetInfo(questIndex)
		if info and not info.isHeader then
			return info.questID
		end
	end
else
	ns.GetNumQuestLogEntries = GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questIndex)
		if not isHeader then
			return questID
		end
	end
end

if C_SkillInfo and C_SkillInfo.GetSkillLineInfo then
	ns.GetNumSkillLines = C_SkillInfo.GetNumSkillLines

	function ns.GetSkillLineInfo(skillIndex)
		local info = C_SkillInfo.GetSkillLineInfo(skillIndex)
		if info then
			return info.name, info.isHeader, not info.isCollapsed, info.rank
		end
	end
else
	ns.GetNumSkillLines = GetNumSkillLines
	ns.GetSkillLineInfo = GetSkillLineInfo
end

if C_PetInfo and C_PetInfo.GetPetFoodTypes then
	ns.GetPetFoodTypes = C_PetInfo.GetPetFoodTypes
else
	function ns.GetPetFoodTypes()
		return { GetPetFoodTypes() }
	end
end

if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
	function ns.GetMerchantItemInfo(index)
		local info = C_MerchantFrame.GetItemInfo(index)
		if info then
			return info.name,
				info.texture,
				info.price,
				info.stackCount,
				info.numAvailable,
				info.isPurchasable,
				info.isUsable,
				info.hasExtendedCost
		end
	end
else
	ns.GetMerchantItemInfo = GetMerchantItemInfo
end

--------------------------------------------------------------------------------
-- Secret Values
--------------------------------------------------------------------------------

-- True when a value is safe to compare, concatenate, or send; secret values error on all three.
function ns.IsPlain(value)
	return not (issecretvalue and issecretvalue(value))
end

--[[
    On WoW Forever, unit identity and aura data go secret in combat. Ask these
    before reading either; both are always false on the other flavors.
]]
function ns.IsUnitIdentitySecret(unit)
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldUnitIdentityBeSecret(unit)
end

function ns.AreAurasSecret()
	return ns.FLAVOR == "Camelot" and C_Secrets.ShouldAurasBeSecret()
end

--------------------------------------------------------------------------------
-- Item Stats
--------------------------------------------------------------------------------

--[[
    An item's stat table from its link. WoW Forever ships C_Item.GetItemStats;
    Classic Era and TBC Anniversary have only the legacy global GetItemStats,
    which returns the same table. Resolved once at load, modern first; both are
    rows in the Diagnostic Tools API report.
]]
ns.GetItemStats = C_Item.GetItemStats or GetItemStats

--------------------------------------------------------------------------------
-- Tooltip Text
--------------------------------------------------------------------------------

--[[
    An item's or spell's tooltip as plain lines, a right-hand column kept after
    " >> ". kind is "item" or "spell". C_TooltipInfo hands the lines over as
    data where the client ships its GetItemByID and GetSpellByID getters (WoW
    Forever); elsewhere they are read off a hidden tooltip that is never shown
    (Classic Era and TBC Anniversary). Color escapes are stripped so each line
    reads as its words. Resolved once at load. A read can throw on an odd id, so
    callers protect it.
]]
local SCAN_TOOLTIP_NAME = "BagsBuffsButtonsScanTooltip"
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }
local scanTooltip

local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

local function ReadTooltipData(kind, id)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](id)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

--[[
    The add-on's one hidden tooltip, made on first use, and its global name, which its line font strings are
    named from. Every read through it is synchronous, so readers share it.
]]
function ns.GetScanTooltip()
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	return scanTooltip, SCAN_TOOLTIP_NAME
end

-- The hidden tooltip's lines once setter (a GameTooltip method) has filled it with the rest.
local function ReadScanTooltipWith(setter, ...)
	ns.GetScanTooltip()
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	scanTooltip[setter](scanTooltip, ...)
	local lines = {}
	for index = 1, scanTooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. index]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	scanTooltip:Hide()
	return lines
end

local function ReadScanTooltip(kind, id)
	return ReadScanTooltipWith("SetHyperlink", kind .. ":" .. id)
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

--[[
	The same lines for any tooltip: getter is the C_TooltipInfo function and setter the GameTooltip method that
	fill it (e.g. "GetInventoryItem" and "SetInventoryItem"), both called with the rest. The getter is used
	where the client ships it, the hidden tooltip elsewhere.
]]
function ns.ReadTooltipLines(getter, setter, ...)
	if not (C_TooltipInfo and C_TooltipInfo[getter]) then
		return ReadScanTooltipWith(setter, ...)
	end
	local lines = {}
	local data = C_TooltipInfo[getter](...)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

--------------------------------------------------------------------------------
-- Character Profile Names
--------------------------------------------------------------------------------

--[[
    AceDB keeps each character's profile choice in the saved file's
    profileKeys, under a name it builds for the character, and a new character
    gets a profile of that same name. On Era and TBC it is "Name - Realm". On
    WoW Forever, where a whole name is unique across the region, it is the
    first name and surname with a space between and no realm (AceDB-3.0 from
    minor 39, which is the copy in Includes/Libraries). These three are the
    only places that spell the format out:

      ns.GetCharacterProfileName()
          This character's. nil while the client has not named the character,
          when it answers with its "Unknown" placeholder.
      ns.ProfileNameForCharacter(name, realm)
          Any character's, from its whole name and its realm as the client
          writes them.
      ns.SplitCharacterProfileName(profileKey)
          The name and realm back out of one; no realm on Forever. nil for a
          key that names no character: one written while the client had not
          named the character, or on Forever the first name and rule set an
          AceDB older than minor 39 wrote ("Name - PvE").

    This is not the add-on's own character key (ns.GetCharacterKey,
    "Name-Realm" with the realm's spaces closed up), which everything the
    add-on saves by character is keyed by.
]]
local function HasRegionalNames()
	return RegionalUniqueNamesEnabled ~= nil and RegionalUniqueNamesEnabled()
end

function ns.ProfileNameForCharacter(name, realm)
	if HasRegionalNames() then
		return name
	end
	return name .. " - " .. realm
end

--[[
    Every recorded character's class token, by the name AceDB keys the
    character under (ns.ProfileNameForCharacter). Read off the records the
    Inventory Report keeps (ns.db.global.inventory, refreshed at every login
    by Features/Inventory-Restocker/Inventory-Report-Recording.lua), so a character's class is known from its
    first login on a build that keeps that record. The Restock List and the
    Ignore List color their character names by it.
]]
function ns.GetClassesByProfileName()
	local classes = {}
	for _, record in pairs(ns.db.global.inventory) do
		if type(record) == "table" and record.name and record.realm then
			classes[ns.ProfileNameForCharacter(record.name, record.realm)] = record.class
		end
	end
	return classes
end

function ns.GetCharacterProfileName()
	local name, surname = (UnitNameUnmodified or UnitName)("player")
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	if HasRegionalNames() then
		return surname and (name .. " " .. surname) or name
	end
	return name .. " - " .. GetRealmName()
end

function ns.SplitCharacterProfileName(profileKey)
	local name, realm
	if not HasRegionalNames() then
		name, realm = profileKey:match("^(.-) %- (.+)$")
	elseif not profileKey:find(" - ", 1, true) then
		name = profileKey
	end
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	return name, realm
end

--------------------------------------------------------------------------------
-- Character Keys
--------------------------------------------------------------------------------

-- "-Realm" as it ends a character's key, the realm's spaces closed up; empty where the client names no realm.
local function RealmSuffix()
	local realm = ((GetRealmName() or ""):gsub("%s+", ""))
	if realm == "" then
		return ""
	end
	return "-" .. realm
end

--[[
    Stable per-character identity, which the Inventory Report's records, the
    Diagnostics reports and the two Connoisseur key migrations key on. The
    character's whole name, which on Forever is its first name and surname
    (ns.GetPlayerFullName above), then its realm.
]]
function ns.GetCharacterKey()
	return (ns.GetPlayerFullName() or "Unknown") .. RealmSuffix()
end
