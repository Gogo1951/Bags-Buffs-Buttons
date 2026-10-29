local ADDON_NAME, ns = ...

local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

local function Global(name)
	return {
		name,
		function()
			return _G[name] ~= nil
		end,
	}
end

local function Method(namespace, name, label)
	return {
		label or (namespace .. "." .. name),
		function()
			local owner = _G[namespace]
			return type(owner) == "table" and type(owner[name]) == "function"
		end,
	}
end

local function Template(name)
	return {
		"Template " .. name,
		function()
			return type(C_XMLUtil) == "table" and C_XMLUtil.GetTemplateInfo(name) ~= nil
		end,
	}
end

--[[
	Existence and shape checks only: read-only, no side effects. One row per API the Spellbook calls or
	guards. Every pair the add-on picks between at load is listed as both halves, and a FAIL on one half is
	the report working: it says which branch this client took. The spellbook read (C_SpellBook's skill lines,
	or the spell tab globals) picks ns.ForEachClassSpell; the tooltip reads (C_TooltipInfo's getters, or the
	hidden scan tooltip's Set methods) pick ns.ReadTooltipLines and ns.GetTrainerServiceSpellId; the macro
	slot limits come from Constants.MacroConsts or the MAX_*_MACROS globals; the spellbook itself is
	Blizzard_PlayerSpells with Features/Spellbook/Spellbook-Tabs.lua on the Retail engine, SpellBookFrame on the Classic engine;
	the page's header, settings cog and paging arrows each fall back without their template.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_API_CHECKS, {
	-- { label, testFunction }
	Method("C_AddOns", "GetAddOnMetadata"),
	Method("C_AddOns", "GetAddOnInfo"),
	Method("C_AddOns", "GetNumAddOns"),
	Method("C_AddOns", "IsAddOnLoaded"),
	Method("C_Seasons", "GetActiveSeason"),
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},

	-- The spellbook read, Retail-engine half.
	Method("C_SpellBook", "GetNumSpellBookSkillLines"),
	Method("C_SpellBook", "GetSpellBookSkillLineInfo"),
	Method("C_SpellBook", "GetSpellBookItemInfo"),
	{
		"Enum.SpellBookSpellBank.Player and Enum.SpellBookItemType.Spell",
		function()
			return type(Enum) == "table"
				and type(Enum.SpellBookSpellBank) == "table"
				and Enum.SpellBookSpellBank.Player ~= nil
				and type(Enum.SpellBookItemType) == "table"
				and Enum.SpellBookItemType.Spell ~= nil
		end,
	},
	-- The spellbook read, Classic-engine half.
	Global("GetNumSpellTabs"),
	Global("GetSpellTabInfo"),
	Global("GetSpellBookItemInfo"),
	Global("GetSpellBookItemName"),
	Global("GetSpellBookItemTexture"),
	Global("IsPassiveSpell"),
	Global("BOOKTYPE_SPELL"),
	-- MoP Classic's Call Pet flyout, which the Classic-engine read lists as one macro.
	Global("GetFlyoutInfo"),
	Global("GetFlyoutSlotInfo"),

	-- Every spell the page names, sorts or builds a macro for.
	Method("C_Spell", "GetSpellName"),
	Method("C_Spell", "GetSpellInfo"),
	Method("C_Spell", "GetSpellTexture"),
	Method("C_Spell", "GetSpellSubtext"),
	Method("C_Spell", "IsSpellHarmful"),
	Method("C_Spell", "SpellHasRange"),
	Method("C_Spell", "IsSpellPassive"),
	Method("C_Spell", "RequestLoadSpellData"),
	Method("C_Spell", "GetSpellLevelLearned", "C_Spell.GetSpellLevelLearned (guarded)"),
	Method("C_Spell", "GetSpellDescription"),
	Method("C_Spell", "IsSpellDataCached"),
	Global("IsPlayerSpell"),
	Method("C_CreatureInfo", "GetCreatureFamilyInfo"),
	Method("C_Item", "GetItemSpell"),
	Global("GetShapeshiftFormInfo"),
	Global("GetNumShapeshiftForms"),
	Global("GetInventoryItemLink"),
	Global("GetInventoryItemTexture"),

	-- The tooltip reads, Retail-engine half.
	Method("C_TooltipInfo", "GetSpellByID"),
	Method("C_TooltipInfo", "GetItemByID"),
	Method("C_TooltipInfo", "GetInventoryItem"),
	Method("C_TooltipInfo", "GetTrainerService"),
	-- The macro buttons' own tooltip.
	Method("GameTooltip", "SetSpellByID"),
	-- The tooltip reads, Classic-engine half: the scan tooltip's methods, probed on GameTooltip, which has them too.
	Method("GameTooltip", "SetInventoryItem", "Hidden scan tooltip SetInventoryItem (legacy)"),
	Method("GameTooltip", "SetTrainerService", "Hidden scan tooltip SetTrainerService (legacy)"),
	Method("GameTooltip", "GetSpell", "Hidden scan tooltip GetSpell (legacy)"),
	Method("GameTooltip", "SetHyperlink", "Hidden scan tooltip SetHyperlink (legacy)"),

	-- Writing and placing the macros.
	Global("CreateMacro"),
	Global("EditMacro"),
	Global("DeleteMacro"),
	Global("GetMacroInfo"),
	Global("GetNumMacros"),
	-- The macro slot limits, Retail-engine half then Classic-engine half.
	{
		"Constants.MacroConsts",
		function()
			return type(Constants) == "table" and type(Constants.MacroConsts) == "table"
		end,
	},
	Global("MAX_ACCOUNT_MACROS"),
	Global("MAX_CHARACTER_MACROS"),
	Global("PickupMacro"),
	Global("GetActionInfo"),
	Global("GetActionText"),
	Global("InCombatLockdown"),
	-- The in-combat and slots-full errors, and the Hide Errors option's /run line.
	Method("UIErrorsFrame", "AddMessage"),
	Method("UIErrorsFrame", "Clear"),
	-- The Mute Errors option's sound settings.
	Method("C_CVar", "GetCVar"),
	Method("C_CVar", "SetCVar"),

	-- Recording trainer spells.
	Global("GetNumTrainerServices"),
	Global("GetTrainerServiceLevelReq"),
	Global("IsTradeskillTrainer"),
	Method("C_Trainer", "GetTrainerType"),
	{
		"Enum.TrainerType",
		function()
			return type(Enum) == "table" and type(Enum.TrainerType) == "table"
		end,
	},

	-- The Retail-engine spellbook and Features/Spellbook/Spellbook-Tabs.lua, whose tab hides under the gamepad UI.
	Global("PlayerSpellsFrame"),
	Method("EventUtil", "ContinueOnAddOnLoaded"),
	Method("EventRegistry", "RegisterCallback"),
	Global("RunNextFrame"),
	Method("InputUtil", "IsGamepadUIEnabled", "InputUtil.IsGamepadUIEnabled (guarded)"),
	Global("HideUIPanel"),
	Template("SpellBookHeaderTemplate"),
	Template("SpellBookSettingsDropdownTemplate"),
	-- The Classic-engine spellbook.
	Global("SpellBookFrame"),
	Global("SpellBookSkillLineTab1"),
	Global("UISpecialFrames"),
	Template("PortraitFrameTemplate"),
	Template("BasicFrameTemplate"),
	{
		"SpellBookFrame.Update",
		function()
			return type(SpellBookFrame) == "table" and type(SpellBookFrame.Update) == "function"
		end,
	},
	Global("hooksecurefunc"),
	-- The page itself, on either book.
	Method("C_XMLUtil", "GetTemplateInfo"),
	Method("C_Texture", "GetAtlasInfo"),
	Method("MenuUtil", "CreateContextMenu"),
	-- An open menu holds the button's tooltip back, and a radio keeps the menu open by answering Refresh.
	Method("Menu", "GetManager", "Menu.GetManager (guarded)"),
	{
		"MenuResponse.Refresh",
		function()
			return type(MenuResponse) == "table" and MenuResponse.Refresh ~= nil
		end,
	},
	--[[
		The Conditionals (Features/Spellbook/Conditionals.lua and Features/Spellbook/Conditionals-Panel.lua): the
		Spec conditions are offered only where a talent group count says the character has two specs, the
		Retail-engine count first, then the Classic-engine one; a spell dropped on a slot is read off the cursor;
		the panel docks with its own close and Add Condition buttons.
	]]
	Method("C_SpecializationInfo", "GetNumSpecGroups", "C_SpecializationInfo.GetNumSpecGroups (guarded)"),
	Global("GetNumTalentGroups"),
	Global("GetCursorInfo"),
	Global("ClearCursor"),
	Global("GetMacroSpell"),
	Template("UIPanelCloseButton"),
	Template("UIPanelButtonTemplate"),

	Method("Settings", "OpenToCategory"),
	--[[
		The key binding: its toggle opens the Retail-engine book through PlayerSpellsUtil where the client has
		it, and the Spellbook panel shows the bound key. Then the three routes ns:OpenKeyBindings tries for the
		Set Key button, in its order; one route passing whole is enough, and the report says which one this
		client has.
	]]
	Method("PlayerSpellsUtil", "OpenToSpellBookTab", "PlayerSpellsUtil.OpenToSpellBookTab (guarded)"),
	Global("GetBindingKey"),
	{
		"GetBindingText (guarded)",
		function()
			return type(GetBindingText) == "function"
		end,
	},
	{
		"Settings.KEYBINDINGS_CATEGORY_ID",
		function()
			return type(Settings) == "table" and Settings.KEYBINDINGS_CATEGORY_ID ~= nil
		end,
	},
	Method("SettingsPanel", "GetCategoryList"),
	{
		"SettingsPanel category list GetAllCategories",
		function()
			if not (type(SettingsPanel) == "table" and type(SettingsPanel.GetCategoryList) == "function") then
				return false
			end
			local ok, list = pcall(SettingsPanel.GetCategoryList, SettingsPanel)
			return ok and type(list) == "table" and type(list.GetAllCategories) == "function"
		end,
	},
	{
		"KeyBindingFrame_LoadUI (legacy)",
		function()
			return type(KeyBindingFrame_LoadUI) == "function" or type(KeyBindingFrame) == "table"
		end,
	},
	Global("ShowUIPanel"),
	Method("C_Timer", "After"),
	Method("C_EventUtils", "IsEventValid"),
	Global("GetCVar"),
	Global("SetCVar"),
})

--------------------------------------------------------------------------------
-- Shared Reads
--------------------------------------------------------------------------------

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

local function Shown(text)
	return (tostring(text):gsub("\r?\n", "\\n"):gsub("|", "||"))
end

local function PlayerClass()
	return select(2, UnitClass("player"))
end

local function ClassLists()
	return ns.CLASS_SPELL_LISTS and ns.CLASS_SPELL_LISTS[PlayerClass()]
end

-- An entry of a class list is a spell ID, or a table of every rank's ID.
local function EntryIds(entry)
	return type(entry) == "table" and entry or { entry }
end

-- How many of a list's entries this client names, and the IDs of the ones it doesn't.
local function ResolvedCount(entries)
	local resolved, missing = 0, {}
	for _, entry in ipairs(entries or {}) do
		local named = false
		for _, id in ipairs(EntryIds(entry)) do
			if C_Spell.GetSpellName(id) then
				named = true
			end
		end
		if named then
			resolved = resolved + 1
		else
			missing[#missing + 1] = tostring(EntryIds(entry)[1])
		end
	end
	return resolved, missing
end

local function ListLine(label, entries)
	local resolved, missing = ResolvedCount(entries)
	local line = string.format("  %s: %d of %d named", label, resolved, #(entries or {}))
	if #missing > 0 then
		line = line .. " (no name for " .. table.concat(missing, ", ") .. ")"
	end
	return line
end

-- The class lists of spell IDs Features/Spellbook/Class-Config.lua resolves to names.
local LIST_KEYS = {
	"mouseoverEnemy",
	"mouseoverFriend",
	"resurrect",
	"utility",
	"attacks",
	"crowdControl",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"heals",
	"noCooldown",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"threat",
	"buffs",
	"cursor",
	"stealth",
	"noToggle",
	"extraSpells",
}
-- Every list of spell IDs the data files hold: the channeled lists no feature reads still ship, so Validate Data checks them.
local DATA_LIST_KEYS = {
	"mouseoverEnemy",
	"mouseoverFriend",
	"resurrect",
	"utility",
	"attacks",
	"crowdControl",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"heals",
	"noCooldown",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"threat",
	"buffs",
	"cursor",
	"channeled",
	"stealth",
	"noToggle",
	"extraSpells",
}
local PER_SPELL_OPTIONS = {
	"cursor",
	"focus",
	"pet",
	"stance",
	"petAttack",
	"stopCast",
	"startAttack",
	"noToggle",
	"targetRank",
	"fixedRank",
	"targetEnemy",
	"targetFriend",
	"combatOnly",
	"noCombat",
	"oncePerCombat",
	"oncePerTarget",
	"stopAttack",
	"stopIfChanneling",
	"stopIfStealthed",
	"hideErrors",
	"muteErrors",
	"cancelForm",
	"autoShot",
	"groupVersion",
	"useItems",
	"groupedSpells",
	"targetPriority",
	"conditionals",
}

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------

--[[
	The spells the page gates options on for the player's class: the ranged attack the after-cast option
	starts, the Warrior stances a stance option switches to, and each summon spell with the pet ability it
	casts while that pet is out. Built from the flavor's class lists, so it follows the data folder this
	client loaded.
]]
ns.AppendDiagnosticRows(ns.DIAGNOSTIC_SPELLS, {})
do
	local lists = ClassLists()
	if lists and lists.autoShot then
		ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] = { label = "ranged attack", id = lists.autoShot }
	end
	for _, id in ipairs(lists and lists.stanceSlots or {}) do
		ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] = { label = "stance", id = id }
	end
	for summonId, pet in pairs(lists and lists.petAbilities or {}) do
		ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] = { label = "summon", id = summonId }
		ns.DIAGNOSTIC_SPELLS[#ns.DIAGNOSTIC_SPELLS + 1] = { label = "pet ability", id = pet.abilityId }
	end
end

local function SpellLine(spell)
	return string.format(
		"  %s %d: %s, IsPlayerSpell %s, IsSpellKnown %s",
		spell.label,
		spell.id,
		tostring(C_Spell.GetSpellName(spell.id) or "NIL"),
		tostring(IsPlayerSpell(spell.id)),
		tostring(IsSpellKnown(spell.id))
	)
end

--------------------------------------------------------------------------------
-- Page Context
--------------------------------------------------------------------------------

--[[
	The Retail-engine page shuts itself whenever the book hides, the gamepad UI is on, the spell search takes
	focus or shows its preview, or the book's selected native tab is no longer the one the page opened over;
	another add-on's tab or page opening shuts it too, through the ones Features/Spellbook/Spellbook-Tabs.lua watches.
]]
local function RetailBookLine(lines, spellbookTabs)
	local book = spellbookTabs.book
	if not book then
		return
	end
	local nativeTabs = book.CategoryTabSystem
	lines[#lines + 1] = string.format(
		"  book shown %s; native tab %s, the page opened over %s; search focused %s, search preview shown %s; gamepad UI %s; other add-ons' tabs and pages watched %d",
		YesNo(book:IsVisible()),
		tostring(nativeTabs and nativeTabs.selectedTabID),
		tostring(spellbookTabs.shownTab),
		YesNo(book.SearchBox and book.SearchBox:HasFocus()),
		YesNo(book.SearchPreviewContainer and book.SearchPreviewContainer:IsShown()),
		YesNo(InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()),
		CountKeys(spellbookTabs.hookedForeign)
	)
end

local function HostLines(lines)
	local spellbookTabs = ns.SpellbookTabs
	if spellbookTabs then
		local tab = spellbookTabs.byId[ADDON_NAME]
		lines[#lines + 1] = string.format(
			"Spellbook: Retail-engine; Blizzard_PlayerSpells loaded %s, attached %s, tab registered %s; page window built %s, shown %s",
			YesNo(C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells")),
			YesNo(spellbookTabs.book ~= nil),
			YesNo(tab ~= nil),
			YesNo(_G.BagsBuffsButtonsSpellbookFrame ~= nil),
			YesNo(_G.BagsBuffsButtonsSpellbookFrame and _G.BagsBuffsButtonsSpellbookFrame:IsShown())
		)
		RetailBookLine(lines, spellbookTabs)
	else
		lines[#lines + 1] = string.format(
			"Spellbook: Classic-engine; SpellBookFrame present %s, shown %s, book type %s; page window built %s, shown %s",
			YesNo(SpellBookFrame ~= nil),
			YesNo(SpellBookFrame and SpellBookFrame:IsShown()),
			tostring(SpellBookFrame and SpellBookFrame.bookType),
			YesNo(_G.BagsBuffsButtonsSpellbookFrame ~= nil),
			YesNo(_G.BagsBuffsButtonsSpellbookFrame and _G.BagsBuffsButtonsSpellbookFrame:IsShown())
		)
	end
end

local function ClassListLines(lines)
	local lists = ClassLists()
	if not lists then
		lines[#lines + 1] = "Class lists: none for this class on this flavor"
		return
	end
	lines[#lines + 1] = "Class lists:"
	for _, key in ipairs(LIST_KEYS) do
		lines[#lines + 1] = ListLine(key, lists[key])
	end
	local stances, stancesNamed = 0, 0
	for spellId, stanceIds in pairs(lists.stances or {}) do
		stances = stances + 1
		local named = C_Spell.GetSpellName(spellId) ~= nil
		for _, stanceId in ipairs(stanceIds) do
			named = named and C_Spell.GetSpellName(stanceId) ~= nil
		end
		stancesNamed = stancesNamed + (named and 1 or 0)
	end
	lines[#lines + 1] = string.format("  stances: %d of %d named with all their stances", stancesNamed, stances)
	for summonId, pet in pairs(lists.petAbilities or {}) do
		local family = C_CreatureInfo.GetCreatureFamilyInfo(pet.familyId)
		lines[#lines + 1] = string.format(
			"  pet: %s casts %s while [pet:%s] (family %d)",
			tostring(C_Spell.GetSpellName(summonId) or ("NIL " .. summonId)),
			tostring(C_Spell.GetSpellName(pet.abilityId) or ("NIL " .. pet.abilityId)),
			tostring(family and family.name or "NIL"),
			pet.familyId
		)
	end
end

--[[
	The one option the class lists still decide, read off ns.ClassConfig, which resolves them on first use: a
	ranged attack named on this client offers its Start option. The focus copy is the one option a flavor
	decides, asked of ns.OffersOption with an enemy spell. Every other option is offered to every class.
]]
local function ClassGateLines(lines)
	local config = ns.ClassConfig()
	lines[#lines + 1] =
		string.format("Ranged attack for the Add Attack option: %s", tostring(config.autoShot or "none"))
	lines[#lines + 1] =
		string.format("Focus copies offered on this flavor: %s", YesNo(ns.OffersOption({ target = "harm" }, "focus")))
end

-- The stance bar's forms, each by slot as a stance option's [stance:n] counts it.
local function StanceFormLines(lines)
	local forms = {}
	for index = 1, GetNumShapeshiftForms() or 0 do
		local spellID = select(4, GetShapeshiftFormInfo(index))
		forms[#forms + 1] = string.format("%d %s", index, tostring(spellID and C_Spell.GetSpellName(spellID) or "NIL"))
	end
	lines[#lines + 1] =
		string.format("Stance bar forms: %d%s", #forms, #forms > 0 and (" (" .. table.concat(forms, ", ") .. ")") or "")
end

-- How many of the bundled trainer rows apply to this character, as Features/Spellbook/Unlearned-Spells.lua filters them.
local function TrainerRowsForPlayer()
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	local count = 0
	for _, row in ipairs((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}) do
		if (not row.faction or row.faction == faction) and (not row.race or row.race == race) then
			count = count + 1
		end
	end
	return count
end

--[[
	Right-Click For Group Version is offered on a spell only when this client names both halves of its
	GROUP_VERSIONS pair and the spellbook holds the group version, both read by name as the page reads them.
]]
local function GroupVersionLines(lines)
	local learned = {}
	pcall(ns.ForEachClassSpell, function(name)
		if name then
			learned[name] = true
		end
	end)
	local pairsTotal, named, offered = 0, 0, {}
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or {}) do
		pairsTotal = pairsTotal + 1
		local single, group = C_Spell.GetSpellName(singleId), C_Spell.GetSpellName(groupId)
		if single and group then
			named = named + 1
			if learned[single] then
				offered[#offered + 1] =
					string.format("%s -> %s (group version learned %s)", single, group, YesNo(learned[group]))
			end
		end
	end
	table.sort(offered)
	lines[#lines + 1] = string.format("Group versions: %d of %d pairs named on this client", named, pairsTotal)
	for _, line in ipairs(offered) do
		lines[#lines + 1] = "  " .. line
	end
end

local function SpellbookLines(lines)
	local total, byLine, order = 0, {}, {}
	local ok, problem = pcall(ns.ForEachClassSpell, function(_, _, _, lineName, line)
		total = total + 1
		local key = string.format("%s %s", tostring(line), tostring(lineName))
		if not byLine[key] then
			byLine[key] = 0
			order[#order + 1] = key
		end
		byLine[key] = byLine[key] + 1
	end)
	if not ok then
		lines[#lines + 1] = "Spellbook spells: (read failed: " .. Shown(problem) .. ")"
		return
	end
	lines[#lines + 1] = string.format("Spellbook spells (castable, every rank): %d", total)
	for _, key in ipairs(order) do
		lines[#lines + 1] = string.format("  skill line %s: %d", key, byLine[key])
	end
end

--[[
	The Call Pet flyout (flyout 9, as Features/Utilities.lua names it), which the Classic-engine read lists as
	one macro under its book name, cast as the first of its spells the player knows, and leaves its spells
	out; with none known, the flyout is left out too. MoP Classic's book holds it; Era and TBC have none.
]]

local function CallPetFlyoutLines(lines)
	if ns.SpellbookTabs or type(GetFlyoutInfo) ~= "function" then
		return
	end
	local found = false
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
		lines[#lines + 1] = "Call Pet flyout: not in the book"
		return
	end
	local _, _, numSlots, isKnown = GetFlyoutInfo(ns.CALL_PET_FLYOUT_ID)
	local members, memberIds = {}, {}
	for flyoutSlot = 1, numSlots or 0 do
		local spellId, _, slotKnown = GetFlyoutSlotInfo(ns.CALL_PET_FLYOUT_ID, flyoutSlot)
		if spellId then
			memberIds[spellId] = true
		end
		members[#members + 1] = string.format(
			"%s %s known %s",
			tostring(spellId),
			tostring(spellId and C_Spell.GetSpellName(spellId) or "NIL"),
			YesNo(slotKnown)
		)
	end
	lines[#lines + 1] = string.format(
		"Call Pet flyout: in the book, flyout known %s, %s slots%s",
		YesNo(isKnown),
		tostring(numSlots),
		#members > 0 and (" (" .. table.concat(members, "; ") .. ")") or ""
	)
	-- the macro the page last built for it, as the page writes it
	for _, macro in ipairs(ns.macros or {}) do
		if memberIds[macro.spellID] and not macro.focus and not macro.copy then
			lines[#lines + 1] = string.format("  page macro %s: %s", Shown(macro.macroName), Shown(macro.body))
		end
	end
end

local function PageListLines(lines)
	local byCategory, order = {}, {}
	local kinds = { unlearned = 0, focus = 0, copy = 0 }
	for _, macro in ipairs(ns.macros or {}) do
		local category = tostring(macro.category)
		if not byCategory[category] then
			byCategory[category] = 0
			order[#order + 1] = category
		end
		byCategory[category] = byCategory[category] + 1
		for kind in pairs(kinds) do
			if macro[kind] then
				kinds[kind] = kinds[kind] + 1
			end
		end
	end
	lines[#lines + 1] = string.format(
		"Page list (as of the page's last redraw): %d macros; unlearned %d, focus copies %d, Duplicate copies %d",
		#(ns.macros or {}),
		kinds.unlearned,
		kinds.focus,
		kinds.copy
	)
	for _, category in ipairs(order) do
		lines[#lines + 1] = string.format("  %s: %d", category, byCategory[category])
	end
	local byKind = {}
	for _, kind in ipairs(ns.MACRO_KINDS) do
		local count = 0
		for _, macro in ipairs(ns.macros or {}) do
			if macro.kind == kind.key and not macro.focus then
				count = count + 1
			end
		end
		byKind[#byKind + 1] = kind.key .. "=" .. count
	end
	lines[#lines + 1] = "  by kind: " .. table.concat(byKind, ", ")
	--[[
		A rank choice is offered only on a spell with more than one rank whose learn level is known (the trainer
		data, this character's trainers, then the client's own lookup where it has one)
	]]
	local fixed, dynamic = 0, 0
	for _, macro in ipairs(ns.macros or {}) do
		if not macro.focus then
			fixed = fixed + (ns.OffersFixedRank(macro) and 1 or 0)
			dynamic = dynamic + (ns.OffersTargetRank(macro) and 1 or 0)
		end
	end
	lines[#lines + 1] = string.format(
		"  ranks: a fixed rank offered on %d, Dynamic Rank on %d; client learn-level lookup %s",
		fixed,
		dynamic,
		YesNo(C_Spell.GetSpellLevelLearned ~= nil)
	)
end

--[[
	The state most likely to explain a "the tab isn't there", "a spell is missing" or "an option isn't offered"
	report: who the player is and which data folder and spellbook this client gave them, whether the page's tab
	and page exist and what shuts the Retail-engine page, how much of the class lists this client could name
	(an ID it can't name never matches, so that spell loses its options), the spells, stance bar forms and
	class and flavor gates the options depend on, the group versions on offer, what the spellbook holds by
	skill line and in its Call Pet flyout, every page setting and which class options apply, the
	unlearned-spells sources, the options panel and key binding routes, and what the page last listed, with
	the rank choices it offers. Existence/value reads only.
]]
function ns:BuildPageContextReport()
	local lines = { ns.GetDiagnosticClientHeader(), "" }
	local _, race = UnitRace("player")
	lines[#lines + 1] = string.format(
		"Player: %s %s %s level %d, in combat %s; expansion %s",
		tostring(UnitFactionGroup("player")),
		tostring(race),
		tostring(PlayerClass()),
		UnitLevel("player") or 0,
		YesNo(InCombatLockdown()),
		tostring(ns.EXPANSION)
	)
	HostLines(lines)
	lines[#lines + 1] = ""
	ClassListLines(lines)
	lines[#lines + 1] = "Spells the options gate on:"
	if #ns.DIAGNOSTIC_SPELLS == 0 then
		lines[#lines + 1] = "  (none for this class)"
	end
	for _, spell in ipairs(ns.DIAGNOSTIC_SPELLS) do
		lines[#lines + 1] = SpellLine(spell)
	end
	StanceFormLines(lines)
	ClassGateLines(lines)
	GroupVersionLines(lines)
	SpellbookLines(lines)
	CallPetFlyoutLines(lines)

	lines[#lines + 1] = ""
	local profile = ns.db and ns.db.profile
	if profile then
		lines[#lines + 1] = string.format(
			"Profile: %s; login message %s",
			tostring(ns.db:GetCurrentProfile()),
			OnOff(ns.db.global.showWelcome)
		)
		lines[#lines + 1] = string.format(
			"Page settings: show unlearned %s (unlearned file loaded %s), count spells on bars %s, marked placed %d, sort by %s",
			OnOff(profile.showUnlearned),
			YesNo(ns.ForEachUnlearnedSpell ~= nil),
			OnOff(profile.countSpellsOnBars),
			CountKeys(profile.markedPlaced),
			tostring(profile.pageSort)
		)
		lines[#lines + 1] = string.format(
			"Dynamic Rank: on for any macro %s; a new target or mouseover rewrites those macros only out of combat (in combat now %s)",
			YesNo(ns.AnyTargetRank()),
			YesNo(InCombatLockdown())
		)
		local kindDefaults = {}
		for _, kind in ipairs(ns.MACRO_KINDS) do
			local on = {}
			for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
				if ns.KindDefault(kind.key, key) then
					on[#on + 1] = key
				end
			end
			if ns.KindOffersTargetPriority(kind.key) then
				on[#on + 1] = "targets:" .. table.concat(ns.KindTargetPriority(kind.key), ">")
			end
			kindDefaults[#kindDefaults + 1] = kind.key .. "=" .. (#on > 0 and table.concat(on, "+") or "none")
		end
		lines[#lines + 1] = "Kind defaults: " .. table.concat(kindDefaults, ", ")
		local counts = {}
		for _, key in ipairs(PER_SPELL_OPTIONS) do
			counts[#counts + 1] = key .. "=" .. CountKeys(profile[key])
		end
		local copies = 0
		for _, numbers in pairs(profile.macroCopies) do
			copies = copies + #numbers
		end
		lines[#lines + 1] = "Per-spell settings saved: "
			.. table.concat(counts, ", ")
			.. string.format("; Duplicate copies %d, of %d spells", copies, CountKeys(profile.macroCopies))
		lines[#lines + 1] = "Conditionals: Spec conditions offered (dual spec) " .. tostring(ns.HasDualSpec())
		lines[#lines + 1] = string.format(
			"Unlearned sources: bundled trainer rows %d (%d for your faction and race), recorded by this character %d, class list extra spells %d",
			#((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}),
			TrainerRowsForPlayer(),
			CountKeys(profile.trainerSpells),
			#ns.ClassExtraSpells()
		)
	else
		lines[#lines + 1] = "Profile: (database not loaded)"
	end
	local settingsRoute = type(Settings) == "table"
		and Settings.OpenToCategory
		and ns.optionsFrames
		and ns.optionsFrames.categoryID
	lines[#lines + 1] = string.format(
		"Options panel: category id %s, /msb opens it through %s",
		tostring(ns.optionsFrames and ns.optionsFrames.categoryID),
		settingsRoute and "Settings.OpenToCategory" or "AceConfigDialog:Open"
	)
	lines[#lines + 1] = string.format(
		"Key binding: MACROSPELLBOOK_TOGGLE %s; it opens %s",
		tostring(GetBindingKey("MACROSPELLBOOK_TOGGLE") or "not bound"),
		not ns.ToggleSpellbookPage and "nothing, no spellbook host loaded" or "the page's window"
	)

	lines[#lines + 1] = ""
	PageListLines(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Macro Context
--------------------------------------------------------------------------------

-- The sound settings the Mute Errors option turns off around its cast and puts back within a second.
local MUTE_ERRORS_CVARS = { "Sound_EnableSFX", "Sound_EnableErrorSpeech" }

local function MuteErrorsLine(lines)
	local values = {}
	for _, cvar in ipairs(MUTE_ERRORS_CVARS) do
		values[#values + 1] = string.format("%s %s", cvar, tostring(C_CVar.GetCVar(cvar)))
	end
	lines[#lines + 1] = string.format(
		"Mute Errors: %d macros use it; %s; BBBMute global present %s",
		CountKeys(ns.db.profile.muteErrors),
		table.concat(values, ", "),
		YesNo(type(BBBMute) == "function")
	)
end

--[[
	The state behind "clicking a macro does nothing", "my own macro was left alone" or "the macro didn't
	update": combat, free macro slots (character macros spill into general ones once full), which macros the
	add-on recorded as its own and for whom, each page macro as ns.FindMacroIndex finds it (by its tag line,
	or by name for a macro from before the tags, which the next sync tags), page macros too long to write or
	out of step with their WoW macro, untagged macros sharing a page macro's name that the page leaves alone,
	what is on the action bars, the equipped items with a Use: effect, the Mute Errors sound
	settings, and the trainer recording. Existence/value reads only.
]]
function ns:BuildMacroContextReport()
	local lines = { ns.GetDiagnosticClientHeader(), "" }
	lines[#lines + 1] = "In combat: "
		.. YesNo(InCombatLockdown())
		.. " (a macro change made in combat is written when combat ends)"
	local numAccount, maxAccount, numCharacter, maxCharacter = ns.MacroCounts()
	lines[#lines + 1] = string.format(
		"Macros: %d of %d general, %d of %d character (limits from %s)",
		numAccount or 0,
		maxAccount,
		numCharacter or 0,
		maxCharacter,
		(type(Constants) == "table" and type(Constants.MacroConsts) == "table") and "Constants.MacroConsts"
			or (MAX_ACCOUNT_MACROS and MAX_CHARACTER_MACROS) and "the MAX_*_MACROS globals"
			or "the fallback, Blizzard_MacroUI not loaded yet"
	)
	if not ns.db then
		lines[#lines + 1] = "(database not loaded)"
		return table.concat(lines, "\n")
	end
	local thisCharacter, otherCharacters, shared = 0, 0, 0
	for _, record in pairs(ns.db.global.ownedMacros) do
		if record == ns.MacroOwnerKey() then
			thisCharacter = thisCharacter + 1
		elseif type(record) == "string" then
			otherCharacters = otherCharacters + 1
		else
			shared = shared + 1
		end
	end
	lines[#lines + 1] = string.format(
		"Recorded as the add-on's: general %d this character's, %d other characters', %d shared (from before owners were recorded, or a retired equipment macro); character %d; tag line IDs handed out %d (register holds %d)",
		thisCharacter,
		otherCharacters,
		shared,
		CountKeys(ns.db.char.ownedMacros),
		ns.db.global.macroTagCount,
		CountKeys(ns.db.global.macroTags)
	)

	local counts = { tag = 0, owned = 0, claim = 0, adopt = 0, missing = 0, tooLong = 0, outOfStep = 0 }
	local leftAlone = {}
	local indexes = ns.ReadMacroIndexes()
	for _, macro in ipairs(ns.macros or {}) do
		if #macro.body > ns.MACRO_BODY_MAX_LENGTH then
			counts.tooLong = counts.tooLong + 1
		end
		local index, found = ns.FindMacroIndex(macro, indexes)
		if index == 0 then
			counts.missing = counts.missing + 1
		else
			counts[found] = counts[found] + 1
			if select(3, GetMacroInfo(index)) ~= macro.body then
				counts.outOfStep = counts.outOfStep + 1
			end
		end
		local wowName = ns.WowMacroName(macro)
		if found ~= "owned" and found ~= "claim" and found ~= "adopt" and indexes.names[wowName] then
			leftAlone[#leftAlone + 1] = wowName
		end
	end
	lines[#lines + 1] = string.format(
		"Page macros (as of the page's last redraw): %d found by tag; by name, from before the tags, %d this character's, %d to claim, %d to adopt; %d not created yet; %d of those found out of step with the page; %d over %d bytes, never written",
		counts.tag,
		counts.owned,
		counts.claim,
		counts.adopt,
		counts.missing,
		counts.outOfStep,
		counts.tooLong,
		ns.MACRO_BODY_MAX_LENGTH
	)
	lines[#lines + 1] = "Names shared with an untagged macro the page leaves alone (the player's own, or another character's): "
		.. (leftAlone[1] and table.concat(leftAlone, ", ") or "none")

	local scanOk, bars = pcall(ns.ScanActionBars)
	if scanOk then
		local placed = 0
		for _, macro in ipairs(ns.macros or {}) do
			if ns.IsOnActionBars(macro, bars) then
				placed = placed + 1
			end
		end
		lines[#lines + 1] = string.format(
			"Action bars: %d macros, %d spells; %d page macros count as placed",
			CountKeys(bars.macros),
			CountKeys(bars.spells),
			placed
		)
	else
		lines[#lines + 1] = "Action bars: (read failed: " .. Shown(bars) .. ")"
	end

	local usableOk, usable = pcall(ns.UsableSlots)
	if usableOk then
		local slots = {}
		for _, entry in ipairs(usable) do
			slots[#slots + 1] = string.format("%d %s", entry.slot, Shown(ns.SlotLabel(entry.slot)))
		end
		lines[#lines + 1] = "Equipped items with a Use: effect: " .. (slots[1] and table.concat(slots, "; ") or "none")
	else
		lines[#lines + 1] = "Equipped items with a Use: effect: (read failed: " .. Shown(usable) .. ")"
	end

	MuteErrorsLine(lines)
	lines[#lines + 1] = string.format(
		"Trainer recording: file loaded %s, %d spells recorded on this character",
		YesNo(ns.OnTrainerShow ~= nil),
		CountKeys(ns.db.profile.trainerSpells)
	)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
	Every game record the Spellbook names by ID, for the Localization tab's Game Names report: the client
	strings it reads or matches, the slot names its Use Items options show, every spell and creature family
	in the player's class lists, every GROUP_VERSIONS spell and the
	class's SPELL_GROUPS spells, the
	ranged attack the after-cast option starts, and every trainer spell the Unlearned section can list, each
	read as the features read it. The rank text a fixed or Dynamic Rank macro writes ("Rank 3") is the
	spell's subtext, so every trainer rank above the first (a row that requires an earlier one) has a rank
	row too. The class-list and trainer spells are the player's class only, the class whose page this
	character sees. A spell loads late, so its rows ask for it.
]]

local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

local function SpellRow(constant, kind, id, read)
	return {
		constant = constant,
		kind = kind,
		id = id,
		lookup = function()
			return read(id)
		end,
		request = function()
			C_Spell.RequestLoadSpellData(id)
		end,
	}
end

local function FamilyRow(constant, id)
	return {
		constant = constant,
		kind = "creatureFamily",
		id = id,
		lookup = function()
			local info = C_CreatureInfo.GetCreatureFamilyInfo(id)
			return info and info.name
		end,
	}
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_NAME_LOOKUPS, {
	-- { constant, kind, id, lookup, request }
	UiLabel("SETTINGS"),
	UiLabel("PAGE_NUMBER"),
	UiLabel("NOT_BOUND"),
	UiLabel("KEY_BINDINGS"),
	UiLabel("SETTINGS_KEYBINDINGS_LABEL"),
	UiLabel("GAMEMENU_OPTIONS"),
	UiLabel("ITEM_SPELL_TRIGGER_ONUSE"),
	UiLabel("ERR_NOT_IN_COMBAT"),
	UiLabel("HEADSLOT"),
	UiLabel("NECKSLOT"),
	UiLabel("SHOULDERSLOT"),
	UiLabel("SHIRTSLOT"),
	UiLabel("CHESTSLOT"),
	UiLabel("WAISTSLOT"),
	UiLabel("LEGSSLOT"),
	UiLabel("FEETSLOT"),
	UiLabel("WRISTSLOT"),
	UiLabel("HANDSSLOT"),
	UiLabel("FINGER0SLOT_UNIQUE"),
	UiLabel("FINGER1SLOT_UNIQUE"),
	UiLabel("TRINKET0SLOT_UNIQUE"),
	UiLabel("TRINKET1SLOT_UNIQUE"),
	UiLabel("BACKSLOT"),
	UiLabel("MAINHANDSLOT"),
	UiLabel("SECONDARYHANDSLOT"),
	UiLabel("RANGEDSLOT"),
	UiLabel("TABARDSLOT"),
})

do
	local lists = ClassLists()
	local rows, seen = ns.DIAGNOSTIC_NAME_LOOKUPS, { spell = {}, spellRank = {}, creatureFamily = {} }
	local function Add(kind, id, row)
		if not seen[kind][id] then
			seen[kind][id] = true
			rows[#rows + 1] = row
		end
	end
	local function AddSpell(constant, id)
		Add("spell", id, SpellRow(constant, "spell", id, C_Spell.GetSpellName))
	end
	local function AddRank(constant, id)
		Add("spellRank", id, SpellRow(constant, "spellRank", id, C_Spell.GetSpellSubtext))
	end
	local function AddFamily(constant, id)
		Add("creatureFamily", id, FamilyRow(constant, id))
	end
	local function AddEntries(constant, entries)
		for position, entry in ipairs(entries or {}) do
			for _, id in ipairs(EntryIds(entry)) do
				AddSpell(string.format("%s[%d]", constant, position), id)
			end
		end
	end
	if lists then
		for _, key in ipairs(LIST_KEYS) do
			AddEntries(key, lists[key])
		end
		for _, id in ipairs(lists.stanceSlots or {}) do
			AddSpell("stanceSlots", id)
		end
		for spellId, stanceIds in pairs(lists.stances or {}) do
			AddSpell("stances", spellId)
			for _, stanceId in ipairs(stanceIds) do
				AddSpell("stances", stanceId)
			end
		end
		for summonId, pet in pairs(lists.petAbilities or {}) do
			AddSpell("petAbilities", summonId)
			AddSpell("petAbilities", pet.abilityId)
			AddFamily("petAbilities", pet.familyId)
		end
	end
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or {}) do
		AddSpell("GROUP_VERSIONS", singleId)
		AddSpell("GROUP_VERSIONS", groupId)
	end
	for _, ids in ipairs((ns.SPELL_GROUPS or {})[PlayerClass()] or {}) do
		for _, id in ipairs(ids) do
			AddSpell("SPELL_GROUPS", id)
		end
	end
	if lists and lists.autoShot then
		AddSpell("autoShot", lists.autoShot)
	end
	for _, row in ipairs((ns.TRAINER_SPELLS or {})[PlayerClass()] or {}) do
		AddSpell("TRAINER_SPELLS", row.id)
		if row.requires then
			AddRank("TRAINER_SPELLS", row.id)
		end
	end
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
	One entry per data file, and one report row per entry on the Data tab. The class lists and trainer spells
	are keyed by class token, so their collectors walk every class and answer once per spell ID, keeping the
	class and where the ID sits as its DATA_* values; a class list entry with several rank IDs answers once
	per rank. The group versions answer once per half of each pair, naming the other half.
]]
local function KeyValue(key)
	return key
end

local function RowField(field)
	return function(_, row)
		local value = type(row) == "table" and row[field] or nil
		if type(value) == "table" then
			return table.concat(value, ",")
		end
		return value
	end
end

local function CollectClassListSpells(listsByClass)
	local entries = {}
	local function Add(classToken, list, entry)
		for _, id in ipairs(EntryIds(entry)) do
			entries[#entries + 1] = { id = id, key = classToken, row = { list = list } }
		end
	end
	for classToken, lists in pairs(listsByClass) do
		for _, key in ipairs(DATA_LIST_KEYS) do
			for _, entry in ipairs(lists[key] or {}) do
				Add(classToken, key, entry)
			end
		end
		if lists.autoShot then
			Add(classToken, "autoShot", lists.autoShot)
		end
		for _, id in ipairs(lists.stanceSlots or {}) do
			Add(classToken, "stanceSlots", id)
		end
		for spellId, stanceIds in pairs(lists.stances or {}) do
			Add(classToken, "stances", spellId)
			for _, stanceId in ipairs(stanceIds) do
				Add(classToken, "stances", stanceId)
			end
		end
		for summonId, pet in pairs(lists.petAbilities or {}) do
			Add(classToken, "petAbilities", summonId)
			Add(classToken, "petAbilities", pet.abilityId)
		end
	end
	return entries
end

-- GROUP_VERSIONS is keyed by the single-target spell; each pair answers once per half.
local function CollectGroupVersionSpells(groupBySingle)
	local entries = {}
	for singleId, groupId in pairs(groupBySingle) do
		entries[#entries + 1] = { id = singleId, row = { half = "single", pair = groupId } }
		entries[#entries + 1] = { id = groupId, row = { half = "group", pair = singleId } }
	end
	return entries
end

local function CollectTrainerSpells(spellsByClass)
	local entries = {}
	for classToken, rows in pairs(spellsByClass) do
		for _, row in ipairs(rows) do
			entries[#entries + 1] = { id = row.id, key = classToken, row = row }
		end
	end
	return entries
end

-- A plain list of spell IDs (BASIC_ATTACK_SPELL_IDS).
local function CollectSpellIds(ids)
	local entries = {}
	for _, id in ipairs(ids) do
		entries[#entries + 1] = { id = id }
	end
	return entries
end

-- RANGED_ATTACKS rows carry their spell as id.
local function CollectRangedAttacks(rows)
	local entries = {}
	for _, row in ipairs(rows) do
		entries[#entries + 1] = { id = row.id, row = row }
	end
	return entries
end

ns.AppendDiagnosticRows(ns.DIAGNOSTIC_DATA_SOURCES, {
	-- { label, sources = { { table, kind, rowId or collect, dataColumns } } }
	{
		label = "Game-IDs",
		sources = {
			{ table = "BASIC_ATTACK_SPELL_IDS", kind = "spell", collect = CollectSpellIds },
			{ table = "RANGED_ATTACKS", kind = "spell", collect = CollectRangedAttacks },
		},
	},
	{
		label = "Class-Spell-Lists",
		sources = {
			{
				table = "CLASS_SPELL_LISTS",
				kind = "spell",
				collect = CollectClassListSpells,
				dataColumns = { { "DATA_CLASS", KeyValue }, { "DATA_LIST", RowField("list") } },
			},
		},
	},
	{
		label = "Trainer-Spells",
		sources = {
			{
				table = "TRAINER_SPELLS",
				kind = "spell",
				collect = CollectTrainerSpells,
				dataColumns = {
					{ "DATA_CLASS", KeyValue },
					{ "DATA_LEVEL", RowField("level") },
					{ "DATA_REQUIRES", RowField("requires") },
					{ "DATA_FACTION", RowField("faction") },
					{ "DATA_RACE", RowField("race") },
					{ "DATA_TALENT", RowField("talent") },
				},
			},
		},
	},
	{
		label = "Group-Versions",
		sources = {
			{
				table = "GROUP_VERSIONS",
				kind = "spell",
				collect = CollectGroupVersionSpells,
				dataColumns = { { "DATA_HALF", RowField("half") }, { "DATA_PAIR", RowField("pair") } },
			},
		},
	},
})
