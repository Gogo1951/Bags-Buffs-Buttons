local _, ns = ...

--[[
	The per-spell macro options: which options a page macro offers, which the player turned on, and the
	defaults each kind of macro starts from. Features/Macro-Body.lua turns them into macro text.
]]

--[[
	Per-spell settings, on the character's profile, each a table keyed by the spell's name as this client
	gives it: "mouseover" (macro casts on the mouseover unit first), "cursor" (macro casts a ground-targeted
	spell where the cursor points), "focus" (the page also lists a copy of the macro that casts on the focus
	target), "pet" (a summon macro casts the pet's ability while that pet is out), "stance" (the macro switches to a stance the spell can be cast in first), "petAttack"
	(the macro also sends the pet to attack), "stopCast" (the macro stops the current cast first),
	"startAttack" (the macro starts melee auto-attack after the cast), "noToggle" (a form or aspect's macro
	casts "!Name", which never cancels it when it is already on), "castOnSelf" (a friendly spell's macro
	casts on the player when the target can't take it), "targetRank" (a ranked friendly spell's macro
	casts the highest rank its target's level can take, rewritten as the target changes), "fixedRank" (a
	ranked spell's macro always casts this rank, by its text, e.g. "Rank 3"), "targetTarget"
	(a friendly spell's macro tries the target's target after the target), "targetEnemy" (an enemy spell's
	macro targets the nearest enemy first when there is no living hostile target), "targetFriend" (a
	friendly spell's macro targets the nearest friend first when there is no living friendly target), "combatOnly" (the macro
	casts only in combat), "noCombat" (only out of combat; see ns.CombatCheck), "oncePerCombat" (the macro casts once until combat ends or the target changes),
	"oncePerTarget" (the macro casts once until the target changes), "stopAttack" (the macro stops melee
	first), "stopIfChanneling" (the macro does nothing while any spell is channelling), "stopIfStealthed" (the macro does nothing while the player is stealthed), "hideErrors" (the macro clears the error text after), "muteErrors" (the macro mutes error sounds while it runs), "cancelForm" (the macro leaves a form first), "autoShot" (the macro starts Auto Shot,
	or the wand, after the cast) or "groupVersion" (a right-click casts the spell's group version, or a group
	spell's single version). Each is true
	or false where the player set it, overriding the macro kind's default (see KindDefault), and nil where the
	macro follows that default, except "fixedRank", which holds the rank text, or nil for the highest rank.
	"useItems" holds a list of equipment slots instead of a flag: the macro uses
	each slot's item, in that order, before the cast. "groupedSpells" holds a list of spell names too: the
	spells of the macro's SPELL_GROUPS group ticked in its Grouped Spells submenu (see ns.CastSpellName), and
	"targetPriority" a list of units, who it casts on in turn (see ns.TargetPriority), which took over from
	"mouseover", "castOnSelf" and "targetTarget"; those are still read where no list was set.
]]
local function SpellSettings(key)
	return ns.db.profile[key]
end

ns.SpellSettings = SpellSettings

--[[
	The key a macro's own settings sit under: the spell's name, or for a copy made with Duplicate the name and
	its number ("Drain Soul #2"), and for a rank's macro (Show All Spell Ranks) the name and its rank
	("Fireball (Rank 3)"), which no spell is called, so a copy's settings are its own.
]]
local function SettingsKey(macro)
	if macro.copy then
		return macro.name .. " #" .. macro.copy
	elseif macro.rank then
		return macro.name .. " (" .. macro.rank .. ")"
	end
	return macro.name
end

ns.SettingsKey = SettingsKey

-- A macro's own setting for an option: true, false, or nil where it follows the default.
local function GetSetting(macro, key)
	return SpellSettings(key)[SettingsKey(macro)]
end

-- Stores a macro's own setting for an option; nil drops it.
local function StoreSetting(macro, key, value)
	SpellSettings(key)[SettingsKey(macro)] = value
end

--[[
	Whether the page also lists a macro for each lower rank known of a spell, after the spell's own, each fixed
	to its rank. Only where spells have ranks (ns.HAS_SPELL_RANKS).
]]
function ns.ShowsAllRanks()
	return ns.HAS_SPELL_RANKS and ns.db.profile.showAllRanks
end

function ns.SetShowAllRanks(on)
	ns.db.profile.showAllRanks = on
end

--[[
	Whether the page lists every learned spell of a SPELL_GROUPS group, or only the last one learned (Cleanse,
	not Purify). The ones left off the page still have their WoW macros rewritten.
]]
function ns.ShowsGroupedSpells()
	return ns.db.profile.showGroupedSpells
end

function ns.SetShowGroupedSpells(on)
	ns.db.profile.showGroupedSpells = on
end

-- Whether the page also lists the class spells not learned yet, in an Unlearned section after the rest.
function ns.ShowsUnlearned()
	return ns.db.profile.showUnlearned
end

function ns.SetShowUnlearned(on)
	ns.db.profile.showUnlearned = on
end

--[[
	Whether a plain spell on an action bar counts as its macro being placed even when the macro has options
	on (see ns.IsOnActionBars). Macros with no options on always count it.
]]
function ns.CountsSpellsOnBars()
	return ns.db.profile.countSpellsOnBars
end

function ns.SetCountSpellsOnBars(on)
	ns.db.profile.countSpellsOnBars = on
end

--[[
	How the page groups its macros: "category", under each kind of macro (ns.MACRO_KINDS), or "school", under
	each spellbook tab, as the book lists them.
]]
function ns.PageSort()
	return ns.db.profile.pageSort
end

function ns.SetPageSort(sort)
	ns.db.profile.pageSort = sort
end

--[[
	Whether the macro was marked placed by Mark All Spells As Placed, which stops it glowing wherever it is.
	A spell learned after the mark still glows until it is placed.
]]
function ns.IsMarkedPlaced(macro)
	return ns.db.profile.markedPlaced[macro.macroName] == true
end

function ns.MarkAllPlaced()
	for _, macro in ipairs(ns.macros) do
		if not macro.unlearned then
			ns.db.profile.markedPlaced[macro.macroName] = true
		end
	end
	for _, macro in ipairs(ns.ConsumablePageMacros()) do
		ns.db.profile.markedPlaced[macro.macroName] = true
	end
end

-- Undoes Mark All Spells As Placed, so every macro not on the bars glows again.
function ns.ClearPlacedMarks()
	wipe(ns.db.profile.markedPlaced)
end

function ns.HasPlacedMarks()
	return next(ns.db.profile.markedPlaced) ~= nil
end

--[[
	The kinds of spell macro, in the order the options list them. A spell's kind is what decides most of its
	menu: who it can be cast on, or where.
]]
ns.MACRO_KINDS = {
	{ key = "enemy", labelKey = "KIND_ENEMY", descKey = "KIND_ENEMY_DESCRIPTION" },
	{ key = "friendly", labelKey = "KIND_FRIENDLY", descKey = "KIND_FRIENDLY_DESCRIPTION" },
	{ key = "buff", labelKey = "KIND_BUFF", descKey = "KIND_BUFF_DESCRIPTION" },
	{ key = "resurrect", labelKey = "KIND_RESURRECT", descKey = "KIND_RESURRECT_DESCRIPTION" },
	{ key = "anyone", labelKey = "KIND_ANYONE", descKey = "KIND_ANYONE_DESCRIPTION" },
	{ key = "ground", labelKey = "KIND_GROUND", descKey = "KIND_GROUND_DESCRIPTION" },
	{ key = "form", labelKey = "KIND_FORM", descKey = "KIND_FORM_DESCRIPTION" },
	{ key = "self", labelKey = "KIND_SELF", descKey = "KIND_SELF_DESCRIPTION" },
}

-- A kind's row, by its key.
function ns.KindRow(kind)
	for _, row in ipairs(ns.MACRO_KINDS) do
		if row.key == kind then
			return row
		end
	end
	return nil
end

local TARGET_KINDS = { harm = "enemy", help = "friendly", exists = "anyone" }

--[[
	A spell macro's kind, from the fields Macro-Builder.lua gives it: a ground-targeted spell, then a buff cast
	on a friend (the class lists' buffs), then a resurrection cast on a dead friend (the class lists'
	resurrect), then one cast on an enemy, a friend or either, then a form, stance,
	aura or aspect (the stance bar's forms and the spells that cancel when cast again), and every other spell,
	cast on the player or around them.
]]
function ns.MacroKind(macro)
	if macro.cursor then
		return "ground"
	end
	if macro.buff and macro.target == "help" then
		return "buff"
	end
	if macro.resurrect and macro.target == "help" then
		return "resurrect"
	end
	if macro.target then
		return TARGET_KINDS[macro.target]
	end
	if macro.noGlow or macro.toggles then
		return "form"
	end
	return "self"
end

--[[
	What a spell macro is for, which the page sorts by under Sort By Category, in the order the page shows them.
	Unlike its kind, which says who the spell is cast on and so builds its macro, this is only the page's
	heading for it.
]]
ns.PAGE_CATEGORIES = {
	{ key = "attack", labelKey = "CATEGORY_ATTACKS" },
	{ key = "curse", labelKey = "CATEGORY_CURSES" },
	{ key = "finisher", labelKey = "CATEGORY_FINISHERS" },
	{ key = "shock", labelKey = "CATEGORY_SHOCKS" },
	{ key = "seal", labelKey = "CATEGORY_SEALS" },
	{ key = "hybrid", labelKey = "CATEGORY_HYBRID" },
	{ key = "heal", labelKey = "CATEGORY_HEALS" },
	{ key = "selfBuff", labelKey = "CATEGORY_SELF_BUFFS" },
	{ key = "totem", labelKey = "CATEGORY_TOTEMS" },
	{ key = "buff", labelKey = "CATEGORY_BUFFS" },
	{ key = "blessing", labelKey = "CATEGORY_BLESSINGS" },
	{ key = "offensive", labelKey = "CATEGORY_OFFENSIVE_COOLDOWNS" },
	{ key = "defensive", labelKey = "CATEGORY_DEFENSIVE_COOLDOWNS" },
	{ key = "crowdControl", labelKey = "CATEGORY_CROWD_CONTROL" },
	{ key = "utility", labelKey = "CATEGORY_UTILITY" },
	{ key = "threat", labelKey = "CATEGORY_THREAT" },
	{ key = "trap", labelKey = "CATEGORY_TRAPS" },
	{ key = "aspect", labelKey = "CATEGORY_ASPECTS" },
	{ key = "aura", labelKey = "CATEGORY_AURAS" },
	{ key = "stance", labelKey = "CATEGORY_STANCES" },
	{ key = "form", labelKey = "CATEGORY_FORMS" },
	{ key = "pet", labelKey = "CATEGORY_PETS" },
	{ key = "tracking", labelKey = "CATEGORY_TRACKING" },
	{ key = "resurrect", labelKey = "KIND_RESURRECT" },
	{ key = "teleport", labelKey = "CATEGORY_TELEPORTS" },
	{ key = "racial", labelKey = "CATEGORY_RACIALS" },
	{ key = "profession", labelKey = "CATEGORY_PROFESSIONS" },
}

-- The category each page tag (see PageTags in Features/Macro-Builder.lua) files a spell under, whatever its kind.
local TAG_CATEGORIES = {
	racials = "racial",
	professions = "profession",
	tracking = "tracking",
	threat = "threat",
	traps = "trap",
	totems = "totem",
	seals = "seal",
	blessings = "blessing",
	curses = "curse",
	shocks = "shock",
	finishers = "finisher",
	pets = "pet",
	teleports = "teleport",
	heals = "heal",
	crowdControl = "crowdControl",
	attacks = "attack",
	offensives = "offensive",
	defensives = "defensive",
	selfBuffs = "selfBuff",
	pageBuffs = "buff",
	noCooldown = "utility",
}

local KIND_CATEGORIES = {
	enemy = "attack",
	anyone = "hybrid",
	friendly = "heal",
	buff = "buff",
}

--[[
	The section a class's forms go under, by what the class calls them: warriors' and monks' stance bar spells
	and death knights' presences are stances, paladins' auras, hunters' aspects, and the rest (druid forms,
	Shadowform, Stealth, Ghost Wolf, Metamorphosis) forms. A stealth spell goes with them even off the stance
	bar, as Prowl is in Classic. A Mists paladin's stance bar holds its seals, which the class lists' seals file
	under Seals first.
]]
local FORM_CATEGORIES = {
	WARRIOR = "stance",
	MONK = "stance",
	DEATHKNIGHT = "stance",
	PALADIN = "aura",
	HUNTER = "aspect",
}

-- A base cooldown this long or longer makes a spell that isn't an attack or a heal an offensive cooldown.
local COOLDOWN_MS = 60 * 1000

local function HasLongCooldown(id)
	local ms = id and GetSpellBaseCooldown and GetSpellBaseCooldown(id)
	return ms ~= nil and ms >= COOLDOWN_MS
end

--[[
	A spell macro's page category (a ns.PAGE_CATEGORIES key), or nil for a macro with no kind, which goes
	under its own section after the categories. A resurrection is
	one whatever it's tagged; then the spell's page tag decides (Polymorph is crowd control, Barkskin a
	defensive cooldown, Inner Fire a buff, Fishing a profession). Untagged, a ground or self spell is an attack
	when it hurts (Blizzard, Arcane Explosion). A utility-tagged spell, or a ground or self spell that doesn't
	hurt, is an offensive cooldown when its base cooldown is a minute or longer (Arcane Power),
	else Utility (Cure Poison, Conjure Water). The rest follow their kind.
]]
function ns.PageCategory(macro)
	local kind = macro.kind
	if kind == nil then
		return nil
	end
	if ns.IsBasicAttack(macro) then
		return "attack"
	end
	if kind == "resurrect" then
		return "resurrect"
	end
	local tagged = TAG_CATEGORIES[macro.pageTag]
	if tagged then
		return tagged
	end
	if (kind == "form" or macro.stealth) and macro.pageTag ~= "utility" then
		return FORM_CATEGORIES[select(2, UnitClass("player"))] or "form"
	end
	if KIND_CATEGORIES[kind] and macro.pageTag ~= "utility" then
		return KIND_CATEGORIES[kind]
	end
	local untargeted = kind == "ground" or kind == "self"
	if untargeted and macro.spellID and C_Spell.IsSpellHarmful(macro.spellID) == true then
		return "attack"
	end
	return HasLongCooldown(macro.spellID) and "offensive" or "utility"
end

--[[
	A spell's tooltip line naming the forms it needs ("Requires Bear Form, Dire Bear Form"), built from the
	client's own SPELL_REQUIRED_FORM ("Requires %s"), so it reads in every locale.
]]
local REQUIRED_FORM_PATTERN = SPELL_REQUIRED_FORM
	and "^" .. SPELL_REQUIRED_FORM:gsub("[%(%)%.%+%-%*%?%[%]%^%$]", "%%%0"):gsub("%%s", "(.+)") .. "$"
local NO_FORMS = {}
local requiredForms = {} -- spell ID -> the names its tooltip's line lists, read once a tooltip has loaded

local function RequiredForms(spellID)
	if requiredForms[spellID] or not REQUIRED_FORM_PATTERN then
		return requiredForms[spellID] or NO_FORMS
	end
	local lines = ns.ScanTooltipLines("GetSpellByID", "SetSpellByID", spellID)
	local names = {}
	for _, line in ipairs(lines) do
		local list = line:match(REQUIRED_FORM_PATTERN)
		for name in (list or ""):gmatch("[^,]+") do
			names[#names + 1] = name:match("^%s*(.-)%s*$")
		end
	end
	-- an unloaded tooltip has no lines; read it again next time
	if #lines > 0 then
		requiredForms[spellID] = names
	end
	return names
end

-- The names of the forms and stances the player can be in: the stance bar's, and the class lists' stances.
function ns.KnownForms()
	local names = {}
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		local name = spellID and C_Spell.GetSpellName(spellID)
		if name then
			names[name] = true
		end
	end
	for name in pairs(ns.ClassConfig().stanceIds) do
		names[name] = true
	end
	return names
end

--[[
	The auto attacks, by spell ID: Attack, Auto Shot, Shoot (a wand), Shoot Bow, Shoot Gun, Shoot Crossbow and
	Throw. They always go under Attacks, in a Basic Attacks run of their own at its end. Their names are this
	client's, read once.
]]
local BASIC_ATTACK_IDS = { 6603, 75, 5019, 2480, 7918, 7919, 2764 }
local basicAttacks

function ns.IsBasicAttack(macro)
	if not basicAttacks then
		basicAttacks = {}
		for _, id in ipairs(BASIC_ATTACK_IDS) do
			local name = C_Spell.GetSpellName(id)
			if name then
				basicAttacks[name] = true
			end
		end
	end
	return basicAttacks[macro.name] == true
end

-- Where a run of a page category's spells goes in it: its own spells, then each form's, then the basic attacks.
local SUB_OWN, SUB_FORM, SUB_BASIC = 1, 2, 3

local function FormSub(form)
	if form then
		return form, SUB_FORM
	end
	return nil, SUB_OWN
end

--[[
	The run a spell macro goes in within its page category, as its heading and its place (SUB_OWN, SUB_FORM or
	SUB_BASIC): no heading for the category's own spells, a form's name ("Cat Form", "Berserker Stance"), or
	Basic Attacks. A Warrior's spell takes its stance from the class lists, a spell needing a form from its
	tooltip's Requires line, counting only names in knownForms (ns.KnownForms), so "Requires Daggers" gives
	none. A druid's spell goes under the first form it lists (Maul under Bear Form, though Dire Bear Form takes
	it too); anyone else's under its form only when it needs just the one.
]]
function ns.PageSubCategory(macro, knownForms)
	if ns.IsBasicAttack(macro) then
		return ns.L["SUBCATEGORY_BASIC_ATTACKS"], SUB_BASIC
	end
	if macro.stances then
		return FormSub(#macro.stances == 1 and macro.stances[1] or nil)
	end
	local forms = {}
	for _, name in ipairs(macro.spellID and RequiredForms(macro.spellID) or NO_FORMS) do
		if knownForms[name] then
			forms[#forms + 1] = name
		end
	end
	if #forms == 1 or select(2, UnitClass("player")) == "DRUID" then
		return FormSub(forms[1])
	end
	return nil, SUB_OWN
end

--[[
	The options a kind can turn on by default. The ones left out belong to one spell rather than a kind: the
	focus copy, the pet's ability, the stance, a fixed rank and the items used first.
]]
ns.DEFAULTABLE_OPTIONS = {
	"mouseover",
	"castOnSelf",
	"targetTarget",
	"cursor",
	"groupVersion",
	"targetRank",
	"stopAttack",
	"stopCast",
	"stopIfChanneling",
	"stopIfStealthed",
	"cancelForm",
	"targetEnemy",
	"targetFriend",
	"startAttack",
	"autoShot",
	"petAttack",
	"oncePerTarget",
	"oncePerCombat",
	"noToggle",
	"combatOnly",
	"noCombat",
	"hideErrors",
	"muteErrors",
}

local DEFAULTABLE = {}
for _, key in ipairs(ns.DEFAULTABLE_OPTIONS) do
	DEFAULTABLE[key] = true
end

-- Whether a kind ("enemy", "friendly", ...) turns an option on by default.
function ns.KindDefault(kind, key)
	return DEFAULTABLE[key] == true and ns.db.profile.kindDefaults[kind][key] == true
end

-- Stored as true or false, never nil, so turning off a default the add-on ships on (buffs' targetRank) sticks.
function ns.SetKindDefault(kind, key, on)
	ns.db.profile.kindDefaults[kind][key] = on == true
end

-- Drops a macro's own setting for an option, so it follows its kind's default.
function ns.ClearOwnSetting(macro, key)
	StoreSetting(macro, key, nil)
end

-- The default a macro follows for an option it has no setting of its own for.
local function MacroDefault(macro, key)
	return macro.kind ~= nil and ns.KindDefault(macro.kind, key)
end

--[[
	Sets an option on a macro, stored only where it differs from the macro kind's default, so the rest follow
	a change of default.
]]
local function SetOption(macro, key, on)
	if on == MacroDefault(macro, key) then
		StoreSetting(macro, key, nil)
	else
		StoreSetting(macro, key, on)
	end
end

--[[
	The page's spell macros of a kind, focus and Duplicate copies left out, building the page's list first when no page has
	built it yet.
]]
function ns.MacrosOfKind(kind)
	if #ns.macros == 0 then
		ns.CollectMacros()
	end
	local list = {}
	for _, macro in ipairs(ns.macros) do
		if macro.kind == kind and not macro.focus and not macro.copy and not macro.rank then
			list[#list + 1] = macro
		end
	end
	return list
end

-- Whether any macro turns "targetRank" on, by its own setting or its kind's default.
function ns.AnyTargetRank()
	for _, on in pairs(SpellSettings("targetRank")) do
		if on then
			return true
		end
	end
	for _, kind in ipairs(ns.MACRO_KINDS) do
		if ns.KindDefault(kind.key, "targetRank") then
			return true
		end
	end
	return false
end

--[[
	Enemy spell macros offer "petAttack", whatever the class: any class can have a pet out for a while (a
	Shadowfiend, a mind-controlled enemy). A focus copy shares its spell's setting.
]]
function ns.OffersPetAttack(macro)
	return macro.target == "harm"
end

--[[
	Every spell macro offers "startAttack" except a stealth spell's: attacking would break the stealth. Every
	spell macro offers "stopCast" too, whatever the class. A focus copy shares its spell's settings.
]]
function ns.OffersStopCast()
	return true
end

function ns.OffersStartAttack(macro)
	return not macro.stealth
end

-- A form or aspect, which casting again would cancel, offers "noToggle".
function ns.OffersNoToggle(macro)
	return macro.toggles == true
end

--[[
	A spell cast on a living friend (not a resurrection, whose dead friend is never the player) offers
	"castOnSelf", as does one cast on anyone. The focus copy ignores it.
]]
local function TargetsLivingFriend(macro)
	return macro.target == "help" and macro.kind ~= "resurrect"
end

function ns.OffersCastOnSelf(macro)
	return TargetsLivingFriend(macro) or macro.target == "exists"
end

--[[
	A friendly spell with more than one rank known offers "targetRank", and so does one whose right-click
	spell has (Arcane Brilliance, right-clicking for Arcane Intellect), which takes its ranks the same way. A
	focus copy shares its setting.
]]
function ns.OffersTargetRank(macro)
	local function ranked(ranks)
		return ranks ~= nil and #ranks > 1
	end
	return not macro.rank
		and ns.OffersCastOnSelf(macro)
		and (ranked(macro.ranks) or (ns.RightClickSpell(macro) ~= nil and ranked(macro.rightClickRanks)))
end

--[[
	A spell with more than one rank, known or not, offers a fixed rank (see ns.AbilityRank); only its known
	ranks (macro.ranks) can be chosen, the rest (macro.unknownRanks) are listed as not known. A rank's own
	macro is fixed to its rank, so offers no choice.
]]
function ns.OffersFixedRank(macro)
	return not macro.rank and macro.ranks ~= nil
end

-- An option every spell macro offers.
local function Always()
	return true
end

-- An enemy spell offers "targetEnemy".
local function TargetsHarm(macro)
	return macro.target == "harm"
end

-- A friendly spell offers "targetFriend", which picks a living friend, so not a resurrection.
local function TargetsHelp(macro)
	return TargetsLivingFriend(macro)
end

-- Whether each option is offered on a macro, by key; ns.OffersOption offers a key missing here on any spell with a target.
local OFFERED = {
	mouseover = function(macro)
		return macro.target ~= nil
	end,
	-- the Classic Era client, Season of Discovery included, has no focus target, so no focus copy; nor has a duplicate
	focus = function(macro)
		return macro.target ~= nil and ns.FLAVOR ~= "Vanilla" and not macro.copy
	end,
	cursor = function(macro)
		return macro.cursor
	end,
	pet = function(macro)
		return macro.petAbility ~= nil
	end,
	stance = function(macro)
		return macro.stances ~= nil
	end,
	petAttack = function(macro)
		return ns.OffersPetAttack(macro)
	end,
	stopCast = function(macro)
		return ns.OffersStopCast(macro)
	end,
	--[[
		melee after a heal, buff or resurrection is almost never wanted, so those kinds leave it out, except
		where it is on already, so it can be turned off
	]]
	startAttack = function(macro)
		if not ns.OffersStartAttack(macro) then
			return false
		end
		if macro.kind ~= "friendly" and macro.kind ~= "buff" and macro.kind ~= "resurrect" then
			return true
		end
		local on = GetSetting(macro, "startAttack")
		if on == nil then
			return MacroDefault(macro, "startAttack")
		end
		return on == true
	end,
	noToggle = function(macro)
		return ns.OffersNoToggle(macro)
	end,
	castOnSelf = function(macro)
		return ns.OffersCastOnSelf(macro)
	end,
	targetRank = function(macro)
		return ns.OffersTargetRank(macro)
	end,
	-- a heal or buff can go to the target's target: the tank, when the target is the enemy it is fighting
	targetTarget = TargetsLivingFriend,
	targetEnemy = TargetsHarm,
	targetFriend = TargetsHelp,
	combatOnly = Always,
	noCombat = Always,
	oncePerCombat = Always,
	oncePerTarget = Always,
	stopAttack = Always,
	stopIfChanneling = Always,
	stopIfStealthed = Always,
	hideErrors = Always,
	muteErrors = Always,
	--[[
		whatever the class; leaving a form makes no sense on a form itself (a toggle or the stance bar's own), or
		on stealth, which needs Cat Form
	]]
	cancelForm = function(macro)
		return not macro.toggles and not macro.noGlow and not macro.stealth
	end,
	-- a ranged enemy spell, but not the ranged attack itself
	autoShot = function(macro)
		local autoShot = ns.ClassConfig().autoShot
		return autoShot ~= nil and macro.target == "harm" and macro.name ~= autoShot
	end,
	--[[
		a single-target spell whose group version (Prayer of Fortitude, Portal: Ironforge) is learned, or a group
		spell whose single version is
	]]
	groupVersion = function(macro)
		return ns.RightClickSpell(macro) ~= nil
	end,
}

--[[
	Whether a macro offers an option: "mouseover", "cursor", "focus", "pet", "stance",
	"petAttack", "stopCast", "startAttack", "noToggle", "castOnSelf", "targetRank", "targetTarget",
	"targetEnemy", "targetFriend", "combatOnly", "noCombat", "oncePerCombat", "oncePerTarget", "stopAttack", "stopIfChanneling",
	"stopIfStealthed", "hideErrors",
	"muteErrors", "cancelForm", "autoShot" or "groupVersion".
]]
function ns.OffersOption(macro, key)
	local offered = OFFERED[key]
	if offered then
		return offered(macro) and true or false
	end
	return macro.target ~= nil
end

-- The full label of the "autoShot" option for the player's class (Auto Shot, or the wand), or nil.
function ns.AutoShotLabelKey()
	return ns.ClassConfig().autoShotLabelKey
end

-- The client's name for the ranged attack the "autoShot" option starts (Auto Shot, or the wand's Shoot), or nil.
function ns.AutoShotName()
	return ns.ClassConfig().autoShot
end

-- The spell the "groupVersion" option casts on a right-click: the group version, or a group spell's single version.
function ns.RightClickSpell(macro)
	return macro.groupSpell or macro.soloSpell
end

-- Whether a macro offers an option (see ns.OffersOption) and the player turned it on.
function ns.IsOptionOn(macro, key)
	if not ns.OffersOption(macro, key) then
		return false
	end
	local on = GetSetting(macro, key)
	if on == nil then
		return MacroDefault(macro, key)
	end
	return on == true
end

--[[
	Whether a macro offers a way to cast other than the plain spell's (any option but stopCast, startAttack
	and noToggle; castOnSelf and targetRank come with a target).
]]
function ns.HasCastOptions(macro)
	return macro.target ~= nil or macro.cursor or macro.petAbility ~= nil or macro.stances ~= nil
end

-- Every spell macro offers using equipped items before the cast. A focus copy shares its spell's slots.
function ns.OffersUseItems()
	return true
end

local NO_SLOTS = {}

-- The equipment slots a macro uses before its cast, in the order the player ticked them. Don't modify it.
function ns.UseItemSlots(macro)
	if not ns.OffersUseItems(macro) then
		return NO_SLOTS
	end
	return SpellSettings("useItems")[SettingsKey(macro)] or NO_SLOTS
end

-- A slot's place in a macro's UseItemSlots, or nil when the macro doesn't use it.
function ns.IsUsingSlot(macro, slot)
	for i, used in ipairs(ns.UseItemSlots(macro)) do
		if used == slot then
			return i
		end
	end
end

--[[
	Whether a macro has an options menu: every spell macro does, for stopCast or startAttack.
]]
-- A consumable's macro is Connoisseur's, set up on its Macros panel, so the page offers it no menu.
function ns.HasOptions(macro)
	if macro.consumable then
		return false
	end
	return ns.HasCastOptions(macro)
		or ns.OffersStopCast(macro)
		or ns.OffersStartAttack(macro)
		or ns.OffersUseItems(macro)
end

--[[
	The setters below only change the stored settings; ns.ChangeMacro runs one and rewrites the macro.
]]

-- Rebuilds the macro's body after a setting changes and rewrites the macro if it already exists.
local function Rewrite(macro)
	macro.body = ns.MacroBody(macro)
	if InCombatLockdown() then
		ns.QueueMacroSync()
		return
	end
	ns.SyncMacro(macro)
end

--[[
	Runs change (a function that calls the setters below) and rewrites the macro if it already exists. In
	combat the rewrite waits until combat ends. The focus setting adds or removes a page entry and most others
	also change the focus copy, so the page must be rebuilt after (see the menu in Macro-Menu.lua).
]]
function ns.ChangeMacro(macro, change)
	change()
	Rewrite(macro)
end

-- Sets a setting (any ns.OffersOption key) on or off.
function ns.SetOption(macro, key, on)
	SetOption(macro, key, on)
end

function ns.ToggleOption(macro, key)
	SetOption(macro, key, not ns.IsOptionOn(macro, key))
end

--[[
	The macro's combat check, a choice of one: "combatOnly" (it casts only in combat), "noCombat" (only out
	of combat), or nil for neither, the default.
]]
local COMBAT_CHECKS = { "combatOnly", "noCombat" }

function ns.CombatCheck(macro)
	for _, key in ipairs(COMBAT_CHECKS) do
		if ns.IsOptionOn(macro, key) then
			return key
		end
	end
	return nil
end

function ns.SetCombatCheck(macro, check)
	for _, key in ipairs(COMBAT_CHECKS) do
		SetOption(macro, key, key == check)
	end
end

--[[
	How often the macro casts, a choice of one: "oncePerCombat" (once until combat ends or the target
	changes), "oncePerTarget" (once until the target changes), or nil for every press, the default. Both on,
	as a release before the choice could store, is once per combat, as the macro text reads it.
]]
local REPEAT_RULES = { "oncePerCombat", "oncePerTarget" }

function ns.RepeatRule(macro)
	for _, key in ipairs(REPEAT_RULES) do
		if ns.IsOptionOn(macro, key) then
			return key
		end
	end
	return nil
end

function ns.SetRepeatRule(macro, rule)
	for _, key in ipairs(REPEAT_RULES) do
		SetOption(macro, key, key == rule)
	end
end

--[[
	The rank text the macro is fixed to, or nil when it isn't, or that rank isn't among its known ranks. A
	rank's own macro is always fixed to its rank.
]]
function ns.FixedRank(macro)
	if macro.rank then
		return macro.rank
	end
	local text = ns.OffersFixedRank(macro) and SpellSettings("fixedRank")[SettingsKey(macro)]
	for _, rank in ipairs(text and macro.ranks or NO_SLOTS) do
		if rank.text == text then
			return text
		end
	end
	return nil
end

--[[
	The macro's ability rank, a choice of one: a known rank's text it always casts (see ns.FixedRank),
	"targetRank" (by the level of who it casts on), or nil for the highest rank, the default.
]]
function ns.AbilityRank(macro)
	return ns.IsOptionOn(macro, "targetRank") and "targetRank" or ns.FixedRank(macro)
end

function ns.SetAbilityRank(macro, choice)
	SetOption(macro, "targetRank", choice == "targetRank")
	SpellSettings("fixedRank")[SettingsKey(macro)] = choice ~= "targetRank" and choice or nil
end

--------------------------------------------------------------------------------
-- Target Priority
--------------------------------------------------------------------------------

--[[
	Who a macro casts on, in turn: a list of up to TARGET_PRIORITY_SLOTS units ("targetPriority"), each tried
	only when it can take the spell, then a plain cast. Each unit is { unit, menu label key }, in the order the
	Target submenu lists them. A macro follows its kind's list (kindDefaults[kind].targetPriority) until it is
	given its own. A list nobody set comes from the checkboxes it replaced, Cast On Mouseover, Cast On Self and
	Cast On Target's Target: the mouseover, the target, the target's target, then the player, so a profile from
	before keeps casting as it did, without a migration.
]]
ns.TARGET_UNITS = {
	{ "target", "MENU_UNIT_TARGET" },
	{ "player", "MENU_UNIT_SELF" },
	{ "pet", "MENU_UNIT_PET" },
	{ "focus", "MENU_UNIT_FOCUS" },
	{ "targettarget", "MENU_UNIT_TARGETS_TARGET" },
	{ "mouseover", "MENU_UNIT_MOUSEOVER" },
}
ns.TARGET_PRIORITY_SLOTS = 3

local DEFAULT_PRIORITY = { "target" }
local LEGACY_TARGETING = { "mouseover", "castOnSelf", "targetTarget" }
--[[
	The units a kind can't pick: an enemy spell can't go on the player or the pet, nor a resurrection, which
	can't raise the player casting it or a pet, nor reach the target's target of a dead target
]]
local LEFT_OUT_UNITS = {
	enemy = { player = true, pet = true },
	resurrect = { player = true, pet = true, targettarget = true },
}

--[[
	Whether a kind's macros cast on someone, so take a target priority: a spell cast on an enemy, a friend,
	a dead friend or either. Ground spells, forms and the rest have no one to pick.
]]
local PRIORITY_KINDS = { enemy = true, friendly = true, buff = true, resurrect = true, anyone = true }

function ns.KindOffersTargetPriority(kind)
	return PRIORITY_KINDS[kind] == true
end

-- Whether a unit can be picked for a kind (see LEFT_OUT_UNITS), and never the focus without one.
function ns.KindOffersUnit(kind, unit)
	if unit == "focus" and ns.FLAVOR == "Vanilla" then
		return false
	end
	return not (LEFT_OUT_UNITS[kind] and LEFT_OUT_UNITS[kind][unit])
end

-- A macro's own list, a focus copy keeping its own focus-then-target cast.
function ns.OffersTargetPriority(macro)
	return not macro.focus and ns.KindOffersTargetPriority(macro.kind)
end

-- The list the old checkboxes give, from whether each is on.
local function LegacyPriority(isOn)
	local list = {}
	if isOn("mouseover") then
		list[#list + 1] = "mouseover"
	end
	list[#list + 1] = "target"
	if isOn("targetTarget") then
		list[#list + 1] = "targettarget"
	end
	if isOn("castOnSelf") then
		list[#list + 1] = "player"
	end
	return list
end

-- A list with the units a kind can't pick, and any unit a second time, left out; the target alone when that leaves none.
local function Usable(list, kind)
	local usable, seen = {}, {}
	for _, unit in ipairs(list) do
		if not seen[unit] and ns.KindOffersUnit(kind, unit) then
			seen[unit] = true
			usable[#usable + 1] = unit
		end
	end
	return #usable > 0 and usable or DEFAULT_PRIORITY
end

-- A kind's list: the one set as its default from a macro's menu, or the one its old checkbox defaults give.
function ns.KindTargetPriority(kind)
	local list = ns.db.profile.kindDefaults[kind].targetPriority
	if type(list) ~= "table" then
		list = LegacyPriority(function(key)
			return ns.KindDefault(kind, key)
		end)
	end
	return Usable(list, kind)
end

-- Sets a kind's list, which replaces its old checkbox defaults.
function ns.SetKindTargetPriority(kind, list)
	local defaults = ns.db.profile.kindDefaults[kind]
	defaults.targetPriority = list
	for _, key in ipairs(LEGACY_TARGETING) do
		defaults[key] = false
	end
end

-- Whether the macro has an old checkbox setting of its own, which it then keeps following until given a list.
local function HasLegacyTargeting(macro)
	for _, key in ipairs(LEGACY_TARGETING) do
		if GetSetting(macro, key) ~= nil then
			return true
		end
	end
	return false
end

-- The macro's list, in order. Don't modify it.
function ns.TargetPriority(macro)
	if not ns.OffersTargetPriority(macro) then
		return NO_SLOTS
	end
	local own = GetSetting(macro, "targetPriority")
	if type(own) == "table" then
		return Usable(own, macro.kind)
	end
	if HasLegacyTargeting(macro) then
		return Usable(
			LegacyPriority(function(key)
				return ns.IsOptionOn(macro, key)
			end),
			macro.kind
		)
	end
	return ns.KindTargetPriority(macro.kind)
end

-- Whether the macro tries a unit, such as the mouseover, which rewrites its Dynamic Rank as that unit changes.
function ns.TriesUnit(macro, unit)
	for _, tried in ipairs(ns.TargetPriority(macro)) do
		if tried == unit then
			return true
		end
	end
	return false
end

-- Whether the macro's list is anything but the target alone, which is just the plain cast.
function ns.HasTargetPriority(macro)
	local list = ns.TargetPriority(macro)
	return #list > 1 or (list[1] ~= nil and list[1] ~= "target")
end

-- Whether two lists hold the same units in the same order.
local function SameList(a, b)
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

--[[
	A list with unit picked at a place in it, from 1: a unit taken lower down moves up to this place, the one
	it replaces and those after it move down a place (the last drops off past three), and nil (None, never
	for the first) ends the list here.
]]
local function PlaceUnit(current, place, unit)
	local list = {}
	for i, tried in ipairs(current) do
		if i < place and tried ~= unit then
			list[#list + 1] = tried
		end
	end
	if unit then
		list[#list + 1] = unit
		for i, tried in ipairs(current) do
			if i >= place and tried ~= unit and #list < ns.TARGET_PRIORITY_SLOTS then
				list[#list + 1] = tried
			end
		end
	end
	return list
end

-- Picks the unit at a place in a kind's list (see PlaceUnit).
function ns.SetKindTargetPriorityUnit(kind, place, unit)
	ns.SetKindTargetPriority(kind, PlaceUnit(ns.KindTargetPriority(kind), place, unit))
end

--[[
	Picks the unit at a place in the macro's list (see PlaceUnit). Stored only where it differs from the kind's
	list, and the old checkbox settings go, since the list replaces them.
]]
function ns.SetTargetPriorityUnit(macro, place, unit)
	local list = PlaceUnit(ns.TargetPriority(macro), place, unit)
	for _, key in ipairs(LEGACY_TARGETING) do
		StoreSetting(macro, key, nil)
	end
	StoreSetting(macro, "targetPriority", not SameList(list, ns.KindTargetPriority(macro.kind)) and list or nil)
end

-- Makes the macro's list its kind's, and has the macro follow it.
function ns.MakeTargetPriorityDefault(macro)
	local list = {}
	for i, unit in ipairs(ns.TargetPriority(macro)) do
		list[i] = unit
	end
	ns.SetKindTargetPriority(macro.kind, list)
	StoreSetting(macro, "targetPriority", nil)
	for _, key in ipairs(LEGACY_TARGETING) do
		StoreSetting(macro, key, nil)
	end
end

-- Adds an equipment slot to the end of the macro's useItems list, or removes it.
function ns.ToggleUseSlot(macro, slot)
	local slots = {}
	local at = ns.IsUsingSlot(macro, slot)
	for i, used in ipairs(ns.UseItemSlots(macro)) do
		if i ~= at then
			slots[#slots + 1] = used
		end
	end
	if not at then
		slots[#slots + 1] = slot
	end
	SpellSettings("useItems")[SettingsKey(macro)] = #slots > 0 and slots or nil
end

--[[
	A spell in a SPELL_GROUPS group (Demon Skin, Demon Armor) offers the group's spells, a focus copy sharing its
	spell's. Ticked, a spell is one the macro may cast; the macro casts the last one learned of those ticked, so
	it moves up as the player trains. Every spell of the group is ticked to start with.
]]
function ns.OffersGroupedSpells(macro)
	return macro.groupMembers ~= nil
end

-- Every spell of the macro's group, in the group's order: the default ticks.
local function GroupNames(macro)
	local names = {}
	for i, member in ipairs(macro.groupMembers) do
		names[i] = member.name
	end
	return names
end

-- The names ticked in the macro's group, in the group's order. Don't modify it.
function ns.GroupedSpells(macro)
	if not ns.OffersGroupedSpells(macro) then
		return NO_SLOTS
	end
	return SpellSettings("groupedSpells")[SettingsKey(macro)] or GroupNames(macro)
end

function ns.IsGroupedSpellOn(macro, name)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked == name then
			return true
		end
	end
	return false
end

-- Whether the macro's group has any spell ticked but its own, which is when the group changes the macro.
function ns.IsGrouped(macro)
	for _, ticked in ipairs(ns.GroupedSpells(macro)) do
		if ticked ~= macro.name then
			return true
		end
	end
	return false
end

--[[
	Ticks or unticks a spell of the macro's group. Unticking the last one ticks the macro's own spell again,
	and the whole group ticked is stored as nil, the default.
]]
function ns.ToggleGroupedSpell(macro, name)
	local on = not ns.IsGroupedSpellOn(macro, name)
	local list = {}
	for _, member in ipairs(macro.groupMembers) do
		local ticked = on
		if member.name ~= name then
			ticked = ns.IsGroupedSpellOn(macro, member.name)
		end
		if ticked then
			list[#list + 1] = member.name
		end
	end
	if #list == 0 then
		list[1] = macro.name
	end
	SpellSettings("groupedSpells")[SettingsKey(macro)] = #list < #macro.groupMembers and list or nil
end

--[[
	The ranged weapon attacks the page's one Shoot macro stands for (see FoldRangedAttacks in
	Features/Macro-Builder.lua), in the order its cast line tries them: Throw, Shoot Bow, Shoot Gun and Shoot
	Crossbow, each by spell ID with the item subclass (Enum.ItemWeaponSubclass) of the weapon it needs, and
	that subclass's English name, which stands in where the client can't name it.
]]
ns.RANGED_ATTACKS = {
	{ id = 2764, subclass = 16, english = "Thrown" },
	{ id = 2480, subclass = 2, english = "Bows" },
	{ id = 7918, subclass = 3, english = "Guns" },
	{ id = 7919, subclass = 18, english = "Crossbows" },
}
local WEAPON_CLASS = 2 -- Enum.ItemClass.Weapon
local RANGED_SLOT = 18

--[[
	The name a [worn:] macro condition takes for a ranged attack's weapon: the client's own for its item
	subclass ("Bows"), which the condition matches in every locale.
]]
function ns.RangedWornName(attack)
	local subclassInfo = C_Item.GetItemSubClassInfo or GetItemSubClassInfo
	return subclassInfo and subclassInfo(WEAPON_CLASS, attack.subclass) or attack.english
end

--[[
	The Shoot macro's spell for the weapon in the ranged slot now, where the player knows it, else the macro's
	own (the first of them learned): its icon, its tooltip and the spell #showtooltip names. The cast line
	itself tries each by the weapon worn, so it never waits on this.
]]
local function EquippedRangedAttack(macro)
	local link = GetInventoryItemLink("player", RANGED_SLOT)
	local subclass = link and select(7, C_Item.GetItemInfoInstant(link))
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = attack.subclass == subclass and ns.SpellName(attack.id)
		if name and macro.rangedAttacks[name] then
			return name
		end
	end
	return macro.name
end

--[[
	The spell the macro casts: the Shoot macro's for the ranged weapon equipped; else of its group's ticked
	spells, the last one learned, or its own spell when its group has none of them learned, or it has no group.
]]
function ns.CastSpellName(macro)
	if macro.rangedAttacks then
		return EquippedRangedAttack(macro)
	end
	local cast
	for _, member in ipairs(ns.OffersGroupedSpells(macro) and macro.groupMembers or NO_SLOTS) do
		if member.learned and ns.IsGroupedSpellOn(macro, member.name) then
			cast = member.name
		end
	end
	return cast or macro.name
end
