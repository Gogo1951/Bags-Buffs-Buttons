local _, ns = ...
local L = ns.L

--[[
	Builds the page's macro list (ns.macros) from the spellbook and the class's spell lists
	(ns.CLASS_SPELL_LISTS, from the flavor's data folder). The lists hold spell IDs; every name comes from the
	client, so the page sorts and builds the same in every locale. No frames here: Features/Spellbook/Spellbook-Page.lua
	draws the page. The options live in Features/Spellbook/Macro-Options.lua, the macro text in Features/Spellbook/Macro-Body.lua,
	the Duplicate copies in Features/Spellbook/Macro-Copies.lua, and the Dynamic Rank rewrites in Features/Spellbook/Dynamic-Rank.lua.
	The class lists resolve in Class-Config.lua, the known ranks and learn levels in Spell-Ranks.lua, a group
	spell's macro handover in Group-Handover.lua, and the folded Shoot macro in Ranged-Attacks.lua, beside this.
]]

local MacroBody = ns.MacroBody
local StancesOf = ns.StancesOf
local SpellName = ns.SpellName
local ClassConfig = ns.ClassConfig
local ResolveClassConfig = ns.ResolveClassConfig
local TargetOf = ns.TargetOf
local ReadSpellbook = ns.ReadSpellbook
local ReplacedSpells = ns.ReplacedSpells
local FoldRangedAttacks = ns.FoldRangedAttacks

local FOCUS_SUFFIX = " @F" -- ends a focus copy's WoW macro name, keeping it apart from the spell's own
ns.FOCUS_SUFFIX = FOCUS_SUFFIX

local UNLISTED = math.huge -- the Unlearned section sorts after everything else
local NO_IDS = {}

--[[
	One macro per learned class spell (and unlearned one, when shown) with its focus copy when that's on, in
	page order. Rebuilt each time the page opens.
]]
ns.macros = {}

--[[
	section is { rank, name, priority }: the spell's spellbook tab, or the Unlearned section. ranks is the
	spell's ReadSpellbook ranks entry, or nil. grouped holds the spells it is grouped with: groupSpell, its
	learned group version's name, or soloSpell, a group spell's learned single version's (the spell a
	right-click casts), rightClickRanks, that spell's known ranks as ReadSpellbook lists them, and
	groupMembers, its SPELL_GROUPS group as { name, learned } in the order they are learned; each is nil where
	there is none. The caller sets replaces after: the spells it replaced in that
	group (see ReplacedSpells), whose WoW macro it may have taken over.
]]
local function MakeMacro(name, icon, unlearned, id, section, ranks, grouped)
	local c = ClassConfig()
	local pet = c.petAbilities[name]
	local macro = {
		name = name,
		spellID = id,
		unlearned = unlearned,
		categoryRank = section[1],
		priority = section[3],
		category = section[2],
		noGlow = c.formSpells[name] == true,
		target = TargetOf(name, id),
		buff = c.buffSpells[name] ~= nil,
		resurrect = c.resurrectSpells[name] ~= nil,
		pageTag = c.pageTags[name], -- what the spell is for, which sorts the page (see ns.PageCategory)
		cursor = c.cursorSpells[name] ~= nil,
		petAbility = pet and pet.ability,
		petFamily = pet and pet.family,
		stealth = c.stealthSpells[name] ~= nil,
		stances = StancesOf(name),
		toggles = c.toggleSpells[name] ~= nil,
		ranks = ranks and ranks.known,
		unknownRanks = ranks and ranks.unknown,
		groupSpell = grouped.groupSpell,
		soloSpell = grouped.soloSpell,
		rightClickRanks = grouped.rightClickRanks,
		groupMembers = grouped.groupMembers,
		macroName = ns.TrimMacroName(name),
		-- the question mark icon lets #showtooltip show the spell's own icon on the action bar
		macroIcon = ns.QUESTION_MARK_ICON,
		icon = icon or ns.QUESTION_MARK_ICON,
	}
	macro.kind = ns.MacroKind(macro)
	macro.body = MacroBody(macro)
	return macro
end

--[[
	A copy of a spell macro that casts on the focus target, falling back to the current target. Its menu
	offers only the focus option, which removes it.
]]
local function MakeFocusMacro(macro)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	copy.focus = true
	copy.cursor = false
	copy.petAbility = nil
	copy.petFamily = nil
	copy.macroName = ns.TrimMacroName(macro.name, ns.MACRO_NAME_MAX_LENGTH - #FOCUS_SUFFIX) .. FOCUS_SUFFIX
	copy.body = MacroBody(copy)
	return copy
end

--[[
	A copy of a spell macro made with Duplicate (see ns.DuplicateMacro): the same spell, named with its
	number, with settings of its own (ns.SettingsKey) and no focus copy.
]]
local function MakeCopyMacro(macro, number)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	local suffix = " " .. number
	copy.copy = number
	copy.label = macro.name .. suffix
	copy.macroName = ns.TrimMacroName(macro.name, ns.MACRO_NAME_MAX_LENGTH - #suffix) .. suffix
	copy.body = MacroBody(copy)
	return copy
end

--[[
	A spell macro's copy for one of its lower known ranks, listed after it when Show All Spell Ranks is on: it
	always casts that rank (ns.FixedRank), with settings of its own (ns.SettingsKey), named with the rank's
	number ("Fireball R3"), and casts only its own spell, with no group and no right-click.
]]
local function MakeRankMacro(macro, rank, rankIndex)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	local suffix = " R" .. (rank:match("%d+") or rank)
	copy.rank = rank
	copy.rankIndex = rankIndex
	copy.groupMembers, copy.groupSpell, copy.soloSpell, copy.rightClickRanks = nil, nil, nil, nil
	copy.macroName = ns.TrimMacroName(macro.name, ns.MACRO_NAME_MAX_LENGTH - #suffix) .. suffix
	copy.body = MacroBody(copy)
	return copy
end

--[[
	Whether a later spell of the macro's SPELL_GROUPS group is learned (Cleanse, for Purify), which leaves the
	macro off the page unless Show Grouped Spells is on. members is the group as { name, learned }.
]]
local function LaterGroupSpellLearned(name, members)
	local after = false
	for _, member in ipairs(members or NO_IDS) do
		if after and member.learned then
			return true
		end
		after = after or member.name == name
	end
	return false
end

--[[
	Folds each learned profession specialization (ns.PROFESSION_SPECIALIZATIONS) into its profession: the
	profession's own macro takes the specialization's name and icon on the page (label, icon, and sortName for
	the page's alphabetical order) and still casts the profession, and the specialization's macros, a passive
	that does nothing when cast, go off the page (hidden). Its Duplicate and focus copies keep their own names.
]]
local function FoldSpecializations()
	local own = {}
	for _, macro in ipairs(ns.macros) do
		if not macro.copy and not macro.focus and not macro.rank then
			own[macro.name] = macro
		end
	end
	local folded = {}
	for _, ids in ipairs(ns.PROFESSION_SPECIALIZATIONS or NO_IDS) do
		local profession, shown = own[SpellName(ids[1])], nil
		for i = 2, #ids do
			local specialization = own[SpellName(ids[i])]
			if specialization and profession then
				folded[specialization.name] = true
				shown = specialization
			end
		end
		if shown then
			profession.label, profession.sortName, profession.icon = shown.name, shown.name, shown.icon
		end
	end
	for _, macro in ipairs(ns.macros) do
		if folded[macro.name] then
			macro.hidden = true
		end
	end
end

--[[
	Rebuilds ns.macros: the learned spells (from the spellbook), plus the spells not learned yet when
	ns.ShowsUnlearned().
]]
function ns.CollectMacros()
	wipe(ns.macros)
	ns.MarkRankBodiesStale()
	ResolveClassConfig()
	local taken, seen = {}, {}
	local ranks, learned = ReadSpellbook()
	-- learnLevel and learnTalent say when an unlearned spell can be learned, for its note and tooltip
	local function add(name, icon, unlearned, id, section, learnLevel, learnTalent)
		local c = ClassConfig()
		local groupSpell, soloSpell, members = c.groupSpells[name], c.soloSpells[name], nil
		for _, member in ipairs(c.spellGroups[name] or NO_IDS) do
			members = members or {}
			members[#members + 1] = { name = member, learned = learned[member] == true }
		end
		-- before the macro is made, so its text carries the macro and settings it takes over
		local replaced = not unlearned and members and ReplacedSpells(name, members) or NO_IDS
		ns.HandOverMacro(name, replaced)
		groupSpell = groupSpell and learned[groupSpell] and groupSpell or nil
		soloSpell = soloSpell and learned[soloSpell] and soloSpell or nil
		local rightClick = groupSpell or soloSpell
		local macro = MakeMacro(name, icon, unlearned, id, section, not unlearned and ranks[name] or nil, {
			groupSpell = groupSpell,
			soloSpell = soloSpell,
			rightClickRanks = rightClick and ranks[rightClick] and ranks[rightClick].known,
			groupMembers = members,
		})
		macro.replaces = replaced[1] and replaced or nil
		macro.learnLevel, macro.learnTalent = learnLevel, learnTalent
		-- off the page, but still rewritten, with its copies; before they are made, so they carry it
		macro.hidden = not unlearned and not ns.ShowsGroupedSpells() and LaterGroupSpellLearned(name, members)
		-- another macro already uses the name
		if unlearned and taken[macro.macroName] then
			return
		end
		taken[macro.macroName] = true
		ns.macros[#ns.macros + 1] = macro
		if ns.IsOptionOn(macro, "focus") then
			local copy = MakeFocusMacro(macro)
			taken[copy.macroName] = true
			ns.macros[#ns.macros + 1] = copy
		end
		if not unlearned then
			for _, number in ipairs(ns.MacroCopies(name)) do
				local copy = MakeCopyMacro(macro, number)
				taken[copy.macroName] = true
				ns.macros[#ns.macros + 1] = copy
			end
		end
		-- the lower ranks known, highest first; the spell's own macro casts the highest
		if not unlearned and ns.ShowsAllRanks() then
			for i = 2, #(macro.ranks or NO_IDS) do
				local copy = MakeRankMacro(macro, macro.ranks[i].text, i)
				if not taken[copy.macroName] then
					taken[copy.macroName] = true
					ns.macros[#ns.macros + 1] = copy
				end
			end
		end
	end
	local position = 0
	local tabRanks = ClassConfig().categoryRankByName
	ns.ForEachClassSpell(function(name, icon, id, lineName, line)
		tabRanks[lineName] = tabRanks[lineName] or line
		if name and not seen[name] then -- older books list each rank separately
			seen[name] = true
			position = position + 1
			add(name, icon, nil, id, { line, lineName, position })
		end
	end)
	FoldSpecializations()
	FoldRangedAttacks()
	if ns.ShowsUnlearned() and ns.ForEachUnlearnedSpell then
		ns.ForEachUnlearnedSpell(function(name, icon, id, level, talent)
			position = position + 1
			add(name, icon, true, id, { UNLISTED, L["SECTION_UNLEARNED"], position }, level, talent)
		end, seen)
	end
	-- 0 for the spell's own macro, 1 for its focus copy, then one step per lower rank.
	local function CopyOrder(macro)
		return macro.rankIndex and (1 + macro.rankIndex) or (macro.focus and 1 or 0)
	end
	--[[
		by section; within one, spellbook (or learn level) order, then by name: the spell's own macro, its focus
		copy, then its lower-rank copies highest rank first, and each Duplicate copy after those, by number
	]]
	table.sort(ns.macros, function(a, b)
		if a.categoryRank ~= b.categoryRank then
			return a.categoryRank < b.categoryRank
		end
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		if a.name ~= b.name then
			return a.name < b.name
		end
		if (a.copy or 1) ~= (b.copy or 1) then
			return (a.copy or 1) < (b.copy or 1)
		end
		return CopyOrder(a) < CopyOrder(b)
	end)
end
