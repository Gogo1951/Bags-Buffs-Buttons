local _, ns = ...

--[[
	The per-spell macro options: which options a page macro offers, which the player turned on, and the
	defaults each kind of macro starts from. Features/Spellbook/Macro-Body.lua turns them into macro text. The
	page categories are Features/Spellbook/Page-Categories.lua, and the target priority
	Features/Spellbook/Target-Priority.lua.
]]

--[[
	Per-spell settings, on the character's profile, each a table keyed by the spell's name as this client
	gives it: "cursor" (macro casts a ground-targeted
	spell where the cursor points), "focus" (the page also lists a copy of the macro that casts on the focus
	target), "pet" (a summon macro casts the pet's ability while that pet is out), "stance" (the macro switches to a stance the spell can be cast in first), "petAttack"
	(the macro also sends the pet to attack), "stopCast" (the macro stops the current cast first),
	"startAttack" (the macro starts melee auto-attack after the cast), "noToggle" (a form or aspect's macro
	casts "!Name", which never cancels it when it is already on), "targetRank" (a ranked friendly spell's macro
	casts the highest rank its target's level can take, rewritten as the target changes), "fixedRank" (a
	ranked spell's macro always casts this rank, by its text, e.g. "Rank 3"), "targetEnemy" (an enemy spell's
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
	"targetPriority" a list of units, who it casts on in turn (see ns.TargetPriority).
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

-- Both read by the target priority (Features/Spellbook/Target-Priority.lua), which stores a list the same way.
ns.GetMacroSetting = GetSetting
ns.StoreMacroSetting = StoreSetting

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
	The options a kind can turn on by default. The ones left out belong to one spell rather than a kind: the
	focus copy, the pet's ability, the stance, a fixed rank and the items used first.
]]
ns.DEFAULTABLE_OPTIONS = {
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
	Whether a spell can be cast on a living friend (not a resurrection, whose dead friend is never the player)
	or on anyone, which is what Target Rank needs (ns.OffersTargetRank).
]]
local function TargetsLivingFriend(macro)
	return macro.target == "help" and macro.kind ~= "resurrect"
end

local function TargetsFriendOrAnyone(macro)
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
		and TargetsFriendOrAnyone(macro)
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

-- Whether each option is offered on a macro, by key; ns.OffersOption offers no key missing here.
local OFFERED = {
	-- the Classic Era client, Season of Discovery included, has no focus target, so no focus copy; nor has a duplicate or a rank
	focus = function(macro)
		return macro.target ~= nil and ns.FLAVOR ~= "Vanilla" and not macro.copy and not macro.rank
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
	targetRank = function(macro)
		return ns.OffersTargetRank(macro)
	end,
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
	Whether a macro offers an option: "cursor", "focus", "pet", "stance",
	"petAttack", "stopCast", "startAttack", "noToggle", "targetRank",
	"targetEnemy", "targetFriend", "combatOnly", "noCombat", "oncePerCombat", "oncePerTarget", "stopAttack", "stopIfChanneling",
	"stopIfStealthed", "hideErrors",
	"muteErrors", "cancelForm", "autoShot" or "groupVersion".
]]
function ns.OffersOption(macro, key)
	local offered = OFFERED[key]
	return offered ~= nil and offered(macro) and true or false
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

-- Every spell macro offers using equipped items before the cast. A focus copy shares its spell's slots.
function ns.OffersUseItems()
	return true
end

local NO_SLOTS = {}

-- Shared with Features/Spellbook/Target-Priority.lua, so the empty list it returns is this same one.
ns.NO_SLOTS = NO_SLOTS

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
	Whether a macro has an options menu: every spell macro does, since every one offers stopCast. A
	consumable's macro is Connoisseur's, set up on its Macros panel, so the page offers it no menu.
]]
function ns.HasOptions(macro)
	return not macro.consumable
end

--[[
	The setters below only change the stored settings; the menus then rebuild the page, which rewrites every
	macro already made (ns.RefreshSpellbookPage).
]]

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
	changes), "oncePerTarget" (once until the target changes), or nil for every press, the default. Both on
	is read as once per combat, as the macro text reads it.
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
