local _, ns = ...

--------------------------------------------------------------------------------
-- Spell Ranks
--------------------------------------------------------------------------------

-- Spells came in ranks until Cataclysm, so only these flavors offer Show All Spell Ranks.
ns.HAS_SPELL_RANKS = ns.EXPANSION ~= nil and ns.EXPANSION <= 3

--------------------------------------------------------------------------------
-- Frames
--------------------------------------------------------------------------------

function ns.HideTooltip(owner)
	if GameTooltip:IsOwned(owner) then
		GameTooltip:Hide()
	end
end

-- The heading of the tooltip on the game spellbook's tab: "BBB // Spellbook", gold like a tooltip title.
function ns.SpellbookTabTitle()
	return ns.GetColor("TITLE") .. ns.L["ADDON_SHORT_NAME"] .. " // " .. ns.L["TAB_SPELLBOOK"] .. "|r"
end

--[[
	Pins region inside parent, offset UI units in from every edge, snapped to whole screen pixels and never
	less than offset pixels, so a 1-unit edge drawn around it stays one pixel at any UI scale.
]]
function ns.PixelInset(region, parent, offset)
	region:ClearAllPoints()
	if PixelUtil then
		PixelUtil.SetPoint(region, "TOPLEFT", parent, "TOPLEFT", offset, -offset, offset, offset)
		PixelUtil.SetPoint(region, "BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset, offset, offset)
	else
		region:SetPoint("TOPLEFT", offset, -offset)
		region:SetPoint("BOTTOMRIGHT", -offset, offset)
	end
end

--[[
	A font string in a FontObject's face at a size of its own, so a UI skin that changes the game's fonts
	(ElvUI) still sets its face.
]]
function ns.SizedFontString(parent, fontObject, size, layer)
	local fontString = parent:CreateFontString(nil, layer or "ARTWORK", fontObject)
	local face, _, flags = fontString:GetFont()
	if face then
		fontString:SetFont(face, size, flags)
	end
	return fontString
end

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
	A WoW macro name cut to at most maxBytes (default ns.MACRO_NAME_MAX_LENGTH), backing up to the start of
	any UTF-8 character the cut would split, so a Russian, Korean or Chinese name never ends in a broken byte.
]]
function ns.TrimMacroName(name, maxBytes)
	maxBytes = maxBytes or ns.MACRO_NAME_MAX_LENGTH
	local cut = maxBytes + 1
	while cut > 1 and (name:byte(cut) or 0) >= 0x80 and name:byte(cut) < 0xC0 do
		cut = cut - 1
	end
	return name:sub(1, cut - 1)
end

--------------------------------------------------------------------------------
-- Class Spells
--------------------------------------------------------------------------------

--[[
	Calls fn(name, icon, spellId, skillLineName, skillLineIndex, subName) for every learned, castable spell
	in skill line order, General (Attack, Shoot, Throw, racials) included; subName is the book's text under the name, such as
	"Rank 3", or nil. The Retail engine (Forever, Retail) reads the book through
	C_SpellBook; the Classic engine (Classic Era, TBC, MoP Classic) through the spell tab globals. Resolved once
	at load.

	The name is the spell's own, read by ID: the book shows some spells under a name /cast can't use, such as
	Call Pet as "Call" plus the current pet's name.
]]
local function CastName(id, bookName)
	return id and C_Spell.GetSpellName(id) or bookName
end

--[[
	MoP Classic's book holds Call Pet as a flyout, and also holds the flyout's five spells as entries of their
	own, Call Pet 5 among them in the spec tabs whether or not a pet is in that slot. /cast Call Pet works, so
	the flyout is one macro under its book name and its five spells are left out. Era and TBC list Call Pet as
	one spell, with no flyout, so they're unchanged.
]]

-- the Call Pet flyout's spell IDs, and the first one known (for the macro's icon and tooltip), or nil when the book has no such flyout
local function CallPetFlyout()
	local found
	for line = 1, GetNumSpellTabs() do
		local _, _, offset, numSlots = GetSpellTabInfo(line)
		for slot = offset + 1, offset + numSlots do
			local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
			if itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID then
				found = true
			end
		end
	end
	if not found then
		return nil
	end
	local members, firstKnown = {}, nil
	local _, _, numSlots = GetFlyoutInfo(ns.CALL_PET_FLYOUT_ID)
	for flyoutSlot = 1, numSlots or 0 do
		local spellId, _, isKnown = GetFlyoutSlotInfo(ns.CALL_PET_FLYOUT_ID, flyoutSlot)
		if spellId then
			members[spellId] = true
			if isKnown and not firstKnown then
				firstKnown = spellId
			end
		end
	end
	return members, firstKnown
end

--[[
	Classic Era shares its client with Season of Discovery, and its book can list SoD's rune abilities
	(Metamorphosis : Demon Charge) though Era can't cast them. Their IDs are SoD's range, 300000 and up, the
	same cut the Vanilla data tables make.
]]
local HIDES_SOD_SPELLS = ns.FLAVOR == "Vanilla" and not ns.IS_DISCOVERY

local function IsOtherSeasonSpell(id)
	return HIDES_SOD_SPELLS and id ~= nil and id >= ns.SOD_FIRST_SPELL_ID
end

if C_SpellBook.GetNumSpellBookSkillLines then
	function ns.ForEachClassSpell(fn)
		local bank = Enum.SpellBookSpellBank.Player
		for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
			local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
			if info and not info.shouldHide and not info.offSpecID then
				for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
					local item = C_SpellBook.GetSpellBookItemInfo(slot, bank)
					if
						item
						and item.itemType == Enum.SpellBookItemType.Spell
						and not item.isPassive
						and not item.isOffSpec
					then
						local id = item.spellID or item.actionID
						if not IsOtherSeasonSpell(id) then
							fn(CastName(id, item.name), item.iconID, id, info.name, line, item.subName)
						end
					end
				end
			end
		end
	end
else
	function ns.ForEachClassSpell(fn)
		local callPetSpells, callPetId = CallPetFlyout()
		for line = 1, GetNumSpellTabs() do
			local lineName, _, offset, numSlots = GetSpellTabInfo(line)
			for slot = offset + 1, offset + numSlots do
				local itemType, id = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL)
				if
					itemType == "SPELL"
					and not IsPassiveSpell(slot, BOOKTYPE_SPELL)
					and not IsOtherSeasonSpell(id)
					and not (callPetSpells and callPetSpells[id])
				then
					local name, subName = GetSpellBookItemName(slot, BOOKTYPE_SPELL)
					fn(CastName(id, name), GetSpellBookItemTexture(slot, BOOKTYPE_SPELL), id, lineName, line, subName)
				elseif itemType == "FLYOUT" and id == ns.CALL_PET_FLYOUT_ID and callPetId then
					fn(
						GetSpellBookItemName(slot, BOOKTYPE_SPELL),
						GetSpellBookItemTexture(slot, BOOKTYPE_SPELL),
						callPetId,
						lineName,
						line
					)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Trainer Services
--------------------------------------------------------------------------------

--[[
	The spell ID of a trainer window's service. Forever and Retail hand it over through
	C_TooltipInfo.GetTrainerService; the Classic engine shows the service on the hidden scan tooltip and reads
	the spell back with GetSpell. Resolved once at load.
]]
if C_TooltipInfo and C_TooltipInfo.GetTrainerService then
	function ns.GetTrainerServiceSpellId(index)
		local data = C_TooltipInfo.GetTrainerService(index)
		return data and data.id
	end
else
	function ns.GetTrainerServiceSpellId(index)
		local scanTooltip = ns.GetScanTooltip()
		scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		scanTooltip:SetTrainerService(index)
		local _, spellId = scanTooltip:GetSpell()
		scanTooltip:Hide()
		return spellId
	end
end
