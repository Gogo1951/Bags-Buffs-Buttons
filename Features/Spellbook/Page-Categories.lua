local _, ns = ...

--[[
	The page's sections under Sort By Category: the category a spell macro files under (ns.PageCategory), and
	the run it goes in within that category (ns.PageSubCategory). The rest of a macro's options are
	Features/Spellbook/Macro-Options.lua.
]]

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

-- The category each page tag (see PageTags in Features/Spellbook/Class-Config.lua) files a spell under, whatever its kind.
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

local NO_FORMS = {}

--[[
	The forms a spell needs, as the names of the forms' own spells ("Bear Form", "Dire Bear Form"), from the
	class lists' forms by spell ID. Never the tooltip's Requires line: it names each form as a form, which some
	locales name apart from the form's spell (zhCN Cat Form, esES Battle Stance), so it can't be matched
	against the stance bar's spell names in ns.KnownForms.
]]
local function RequiredForms(spellID)
	local names = {}
	for _, formSpellID in ipairs(ns.ClassConfig().requiredForms[spellID] or NO_FORMS) do
		local name = C_Spell.GetSpellName(formSpellID)
		if name then
			names[#names + 1] = name
		end
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
local basicAttacks

function ns.IsBasicAttack(macro)
	if not basicAttacks then
		basicAttacks = {}
		for _, id in ipairs(ns.BASIC_ATTACK_SPELL_IDS) do
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
	Basic Attacks. A Warrior's spell takes its stance from the class lists' stances, any other spell needing a
	form from the class lists' forms, counting only forms in knownForms (ns.KnownForms). A druid's spell goes under the first form it lists (Maul under Bear Form, though Dire Bear Form takes
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
