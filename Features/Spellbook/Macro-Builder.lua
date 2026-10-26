local _, ns = ...
local L = ns.L

--[[
	Builds the page's macro list (ns.macros) from the spellbook and the class's spell lists
	(ns.CLASS_SPELL_LISTS, from the flavor's data folder). The lists hold spell IDs; every name comes from the
	client, so the page sorts and builds the same in every locale. No frames here: Features/Spellbook-Page.lua
	draws the page. The options live in Features/Macro-Options.lua, the macro text in Features/Macro-Body.lua,
	the Duplicate copies in Features/Macro-Copies.lua, and the Dynamic Rank rewrites in Features/Dynamic-Rank.lua.
]]

local MacroBody = ns.MacroBody
local StancesOf = ns.StancesOf

local FOCUS_SUFFIX = " @F" -- ends a focus copy's WoW macro name, keeping it apart from the spell's own
ns.FOCUS_SUFFIX = FOCUS_SUFFIX

local UNLISTED = math.huge -- the Unlearned section sorts after everything else
--[[
	The menu label of the ranged attack the "autoShot" option starts after a cast, by class: Auto Shot, or
	the wand's Shoot. The spell is the class lists' autoShot, which a flavor without one leaves out.
]]
local AUTO_SHOT_LABEL_KEYS = {
	HUNTER = "MENU_START_AUTO_SHOT",
	MAGE = "MENU_START_WAND",
	PRIEST = "MENU_START_WAND",
	WARLOCK = "MENU_START_WAND",
}

local NO_IDS = {}

local requested = {} -- spell ids asked for once, so an id that never loads can't keep the page redrawing

-- A spell's name, or nil while its data isn't loaded (it is then requested).
local function SpellName(id)
	local name = C_Spell.GetSpellName(id)
	if not name and not requested[id] then
		requested[id] = true
		C_Spell.RequestLoadSpellData(id)
	end
	return name
end

ns.SpellName = SpellName

--[[
	The client's names for a list of spells, as name -> position in the list. An entry is a spell ID, or a
	table of every rank's ID where some locales name the ranks differently, so each rank's name matches.
]]
local function NameIndex(entries)
	local index = {}
	for position, entry in ipairs(entries or NO_IDS) do
		for _, id in ipairs(type(entry) == "table" and entry or { entry }) do
			local name = SpellName(id)
			if name and not index[name] then
				index[name] = position
			end
		end
	end
	return index
end

--[[
	The page-only tags (see ns.PageCategory), the class lists' and ns.SHARED_PAGE_SPELLS', in the order a spell
	on two of them takes the first.
]]
local PAGE_TAGS = {
	"racials",
	"professions",
	"tracking",
	"threat",
	"traps",
	"totems",
	"seals",
	"blessings",
	"curses",
	"shocks",
	"finishers",
	"pets",
	"teleports",
	"heals",
	"crowdControl",
	"attacks",
	"offensives",
	"defensives",
	"selfBuffs",
	"pageBuffs",
	"noCooldown",
	"utility",
}

-- Each tagged spell's name -> its page tag, from the class's lists and the shared ones.
local function PageTags(lists)
	local tags = {}
	for _, key in ipairs(PAGE_TAGS) do
		for _, entries in ipairs({ ns.SHARED_PAGE_SPELLS[key] or NO_IDS, lists[key] or NO_IDS }) do
			for name in pairs(NameIndex(entries)) do
				tags[name] = tags[name] or key
			end
		end
	end
	return tags
end

local config -- the player's class lists, resolved to this client's names by ns.CollectMacros

-- Resolves the player's class lists to the names this client gives their spells.
local function ResolveClassConfig()
	local class = select(2, UnitClass("player"))
	local lists = ns.CLASS_SPELL_LISTS[class] or {}
	config = {
		autoShot = lists.autoShot and SpellName(lists.autoShot),
		autoShotLabelKey = lists.autoShot and AUTO_SHOT_LABEL_KEYS[class],
		groupSpells = {},
		soloSpells = {},
		spellGroups = {}, -- each grouped spell's name -> its group's names, in the order they are learned
		categoryRankByName = {}, -- each spellbook tab's name -> its section rank, filled by ns.CollectMacros
		extraSpells = lists.extraSpells or NO_IDS,
		petAbilities = {},
		stances = {},
		stanceIds = {}, -- each stance's name -> its spell ID, so its stance bar slot is found by ID
		stanceSlots = {},
		hasStances = lists.stances ~= nil,
		formSpells = {},
		enemySpells = NameIndex(lists.mouseoverEnemy),
		friendSpells = NameIndex(lists.mouseoverFriend),
		buffSpells = NameIndex(lists.buffs),
		resurrectSpells = NameIndex(lists.resurrect),
		pageTags = PageTags(lists),
		cursorSpells = NameIndex(lists.cursor),
		stealthSpells = NameIndex(lists.stealth),
		toggleSpells = NameIndex(lists.noToggle),
	}
	for summonId, pet in pairs(lists.petAbilities or NO_IDS) do
		local summon, ability = SpellName(summonId), SpellName(pet.abilityId)
		local family = C_CreatureInfo.GetCreatureFamilyInfo(pet.familyId)
		if summon and ability and family and family.name then
			config.petAbilities[summon] = { ability = ability, family = family.name }
		end
	end
	for spellId, stanceIds in pairs(lists.stances or NO_IDS) do
		local name, stances = SpellName(spellId), {}
		for _, stanceId in ipairs(stanceIds) do
			local stance = SpellName(stanceId)
			stances[#stances + 1] = stance
			if stance then
				config.stanceIds[stance] = stanceId
			end
		end
		if name and #stances == #stanceIds then
			config.stances[name] = stances
		end
	end
	for slot, stanceId in ipairs(lists.stanceSlots or NO_IDS) do
		local name = SpellName(stanceId)
		if name then
			config.stanceSlots[name] = slot
			config.stanceIds[name] = config.stanceIds[name] or stanceId
		end
	end
	for singleId, groupId in pairs(ns.GROUP_VERSIONS or NO_IDS) do
		local single, group = C_Spell.GetSpellName(singleId), C_Spell.GetSpellName(groupId)
		if single and group then
			config.groupSpells[single] = group
			config.soloSpells[group] = single
		end
	end
	-- a group whose names aren't all loaded yet waits for the next build, so no spell drops out of it
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		local names = {}
		for _, id in ipairs(ids) do
			names[#names + 1] = SpellName(id)
		end
		if #names == #ids then
			for _, name in ipairs(names) do
				config.spellGroups[name] = names
			end
		end
	end
	--[[
		the stance bar's forms (stances, auras, Stealth) are placed there already, so their macros never glow.
		They also cancel when cast again (Bear Form, Shadowform, Ghost Wolf), except the Warrior stances, which
		never do, and stealth, which Stop Macro If Stealthed keeps on
	]]
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		local name = spellID and C_Spell.GetSpellName(spellID)
		if name then
			config.formSpells[name] = true
		end
		if name and not config.stanceSlots[name] and not config.stealthSpells[name] then
			config.toggleSpells[name] = true
		end
	end
	return config
end

-- The player's class lists, resolved to this client's names on first use and again by ns.CollectMacros.
local function ClassConfig()
	return config or ResolveClassConfig()
end

ns.ClassConfig = ClassConfig

-- The class lists' extraSpells: spells to list until learned that no trainer data covers.
function ns.ClassExtraSpells()
	return ClassConfig().extraSpells
end

--[[
	Whether a spell is cast on an enemy unit: harmful and with a range. Self-centred AoE such as Arcane
	Explosion or Hellfire has no range, so it is left out.
]]
local function TargetsEnemy(id)
	return id ~= nil and C_Spell.IsSpellHarmful(id) == true and C_Spell.SpellHasRange(id) == true
end

--[[
	The macro conditional a spell's mouseover option uses, or nil for spells without one. Enemy spells are
	the mouseoverEnemy list plus every spell TargetsEnemy finds, except cursor spells. A spell that is both
	an enemy and a friend spell casts on any unit.
]]
local function TargetOf(name, id)
	local c = ClassConfig()
	local enemy = c.enemySpells[name] or (not c.cursorSpells[name] and TargetsEnemy(id))
	local friend = c.friendSpells[name]
	if enemy and friend then
		return "exists"
	end
	if enemy then
		return "harm"
	end
	if friend then
		return "help"
	end
end

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
local function MakeRankMacro(macro, rank)
	local copy = {}
	for key, value in pairs(macro) do
		copy[key] = value
	end
	local suffix = " R" .. (rank:match("%d+") or rank)
	copy.rank = rank
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
	Each spell id's learn level: the class's trainer data (the rows for this character's faction and race),
	then the trainers this character recorded. A rank 1 the class starts with (Frost Armor, Fireball) has no
	trainer row, only its Rank 2's requires, so a required spell of the same name without a level of its own
	is learned at level 1. The client's own answer (C_Spell.GetSpellLevelLearned, where it has one) fills the
	rest.
]]
local function LearnLevels()
	local levels, rows = {}, {}
	local faction, race = UnitFactionGroup("player"), select(3, UnitRace("player"))
	for _, row in ipairs(ns.TRAINER_SPELLS and ns.TRAINER_SPELLS[select(2, UnitClass("player"))] or NO_IDS) do
		if (not row.faction or row.faction == faction) and (not row.race or row.race == race) then
			levels[row.id] = row.level
			rows[#rows + 1] = row
		end
	end
	for id, level in pairs(ns.db.profile.trainerSpells) do
		levels[id] = levels[id] or level
	end
	for _, row in ipairs(rows) do
		for _, id in ipairs(row.requires or NO_IDS) do
			if not levels[id] then
				local name = SpellName(id)
				if name and name == SpellName(row.id) then
					levels[id] = 1
				end
			end
		end
	end
	return levels
end

--[[
	Trainer rank ids whose names weren't loaded when the spellbook was last read, so their ranks were left out;
	SPELL_DATA_LOAD_RESULT redraws the open page as each arrives (see ns.TakePendingRank).
]]
local pendingRanks = {}

-- Whether id is a rank ReadSpellbook left out for want of its name; clears it, so it redraws the page once.
function ns.TakePendingRank(id)
	local pending = pendingRanks[id] == true
	pendingRanks[id] = nil
	return pending
end

--[[
	One pass over the spellbook: the ranks of each learned spell with more than one, as
	name -> { known = { { text = "Rank 4", level = 38 }, ... }, unknown = { ... } or nil }, each list highest
	first (a rank whose learn level isn't known is left out), and every learned spell's name, as name -> true.
	Classic's book lists only each spell's highest rank unless Show All Spell Ranks is ticked, so the known
	trainer ranks are added from their ids as well, then the trainer ranks not learned yet.
]]
local function ReadSpellbook()
	local levels, byName, learned, listed = LearnLevels(), {}, {}, {}
	local levelLearned = C_Spell.GetSpellLevelLearned
	local function addRank(name, subName, level, unknown)
		if name and subName and subName ~= "" and level and level > 0 and not listed[name .. subName] then
			listed[name .. subName] = true
			byName[name] = byName[name] or {}
			table.insert(byName[name], { text = subName, level = level, unknown = unknown })
		end
	end
	ns.ForEachClassSpell(function(name, _, id, _, _, subName)
		if name then
			learned[name] = true
		end
		addRank(name, subName, id and (levels[id] or (levelLearned and levelLearned(id))))
	end)
	for id, level in pairs(levels) do
		if ns.IsPlayerSpell(id) then
			local name = SpellName(id)
			if learned[name] then
				addRank(name, C_Spell.GetSpellSubtext(id), level)
			end
		end
	end
	-- after the known ranks, so a known rank's text is never taken by an unknown id of the same name
	wipe(pendingRanks)
	for id, level in pairs(levels) do
		if not ns.IsPlayerSpell(id) then
			local name = SpellName(id)
			if not name then
				pendingRanks[id] = true
			elseif learned[name] then
				addRank(name, C_Spell.GetSpellSubtext(id), level, true)
			end
		end
	end
	local ranks = {}
	for name, list in pairs(byName) do
		if #list > 1 then
			table.sort(list, function(a, b)
				return a.level > b.level
			end)
			local known, unknown = {}, {}
			for _, rank in ipairs(list) do
				table.insert(rank.unknown and unknown or known, rank)
			end
			if #known > 0 then
				ranks[name] = { known = known, unknown = #unknown > 0 and unknown or nil }
			end
		end
	end
	return ranks, learned
end

--[[
	The spells a learned spell replaced in its SPELL_GROUPS group: those just before it no longer in the
	spellbook, nearest first, up to the first that still is. Bear Form goes from the book once Dire Bear
	Form is learned, so its WoW macro, wherever the player placed it, would never be rewritten again; the
	new spell takes it over instead (see ns.HandOverMacro). members is the group as { name, learned }.
]]
local function ReplacedSpells(name, members)
	local replaced, at = {}, nil
	for i, member in ipairs(members) do
		if member.name == name then
			at = i
		end
	end
	for i = (at or 1) - 1, 1, -1 do
		if members[i].learned then
			break
		end
		replaced[#replaced + 1] = members[i].name
	end
	return replaced
end

--[[
	Gives a learned spell the WoW macro of the nearest spell it replaced that has one, settings and all, when
	it has no macro of its own yet. The sync then finds that macro by its tag, rewrites it to cast the new
	spell and renames it (see SyncAt in Features/Macro-Sync.lua, which reads macro.replaces).
]]
function ns.HandOverMacro(name, replaced)
	for _, from in ipairs(replaced) do
		if ns.HandOverMacroTag(from, name) then
			ns.MoveSpellSettings(from, name)
			return
		end
	end
end

--[[
	Whether a spell learned since the last build has a replaced spell's macro to take over, read from the
	spell IDs alone, so a spell learned with no page open still rewrites that macro (see RefreshForSpells in
	Features/Spellbook-Page.lua).
]]
function ns.HandOverDue()
	local class = select(2, UnitClass("player"))
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for i = #ids, 2, -1 do
			local to = ns.IsPlayerSpell(ids[i]) and SpellName(ids[i])
			if to and not ns.HasSpellMacroTag(to) then
				for j = i - 1, 1, -1 do
					if ns.IsPlayerSpell(ids[j]) then
						break
					end
					local from = SpellName(ids[j])
					if from and ns.HasSpellMacroTag(from) then
						return true
					end
				end
			end
		end
	end
	return false
end

-- Which of the class's SPELL_GROUPS spells the player knows, as one string of 1s and 0s.
local function GroupSpellsKnown()
	local class = select(2, UnitClass("player"))
	local known = {}
	for _, ids in ipairs((ns.SPELL_GROUPS or NO_IDS)[class] or NO_IDS) do
		for _, id in ipairs(ids) do
			known[#known + 1] = ns.IsPlayerSpell(id) and "1" or "0"
		end
	end
	return table.concat(known)
end

local groupSpellsKnown -- as the last call to ns.GroupSpellLearned found them

--[[
	Whether a SPELL_GROUPS spell was learned or lost since the last call, which can move a grouped macro to
	another spell (ns.CastSpellName), so a spell learned with no page open still rewrites it (see
	RefreshForSpells in Features/Spellbook-Page.lua). The first call only takes note.
]]
function ns.GroupSpellLearned()
	local known = GroupSpellsKnown()
	local changed = groupSpellsKnown ~= nil and known ~= groupSpellsKnown
	groupSpellsKnown = known
	return changed
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
	Folds the ranged weapon attacks (ns.RANGED_ATTACKS: Throw, Shoot Bow, Shoot Gun, Shoot Crossbow) into one
	Shoot macro when more than one is learned: only the one for the weapon worn works, so the one macro tries
	each by the weapon worn ("[worn:Bows] Shoot Bow", see CastBody in Features/Macro-Body.lua), and shows the
	one equipped (ns.CastSpellName), redrawn when the gear changes. The first of them learned
	carries it, with its settings, copies and WoW macro, so those stay put whatever is equipped; the others go
	off the page (hidden), their WoW macros still kept up to date where the player placed them.
]]
local function FoldRangedAttacks()
	local own = {}
	for _, macro in ipairs(ns.macros) do
		if not macro.copy and not macro.focus and not macro.rank and not macro.unlearned then
			own[macro.name] = macro
		end
	end
	local folded = {}
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = SpellName(attack.id)
		if name and own[name] then
			folded[#folded + 1] = name
		end
	end
	if #folded < 2 then
		return
	end
	local carrier, attacks = folded[1], {}
	for _, name in ipairs(folded) do
		attacks[name] = true
	end
	-- the client's own name for Shoot, or the carrier's while that spell's data hasn't loaded
	local label = C_Spell.GetSpellName(ns.SHOOT_SPELL_ID) or carrier
	for _, macro in ipairs(ns.macros) do
		if macro.name == carrier and not macro.unlearned then
			macro.rangedAttacks = attacks
			macro.label = label .. (macro.copy and " " .. macro.copy or "")
			macro.sortName = label
			macro.icon = C_Spell.GetSpellTexture(ns.CastSpellName(macro)) or macro.icon
			macro.body = MacroBody(macro)
		elseif attacks[macro.name] and not macro.unlearned then
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
				local copy = MakeRankMacro(macro, macro.ranks[i].text)
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
	--[[
		by section; within one, spellbook (or learn level) order, then by name, each focus copy right after its
		spell and each Duplicate copy after those, by number
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
		return not a.focus and b.focus == true
	end)
end
