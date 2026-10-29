local _, ns = ...

-- Stealth Abilities
ns.SHADOWMELD_SPELL_ID = 20580

ns.STEALTH_SPELL_ID = 1784

-- Cannibalize (Forsaken)
ns.CANNIBALIZE_SPELL_ID = 20577
ns.CANNIBALIZE_CREATURE_TYPE_IDS = { 6, 7 }
ns.CANNIBALIZE_RESTORES_MANA = false

-- Races
ns.NIGHT_ELF_RACE_ID = 4

-- Druid Forms
ns.DRUID_DIRE_BEAR_FORM_SPELL_ID = 9634
ns.DRUID_BEAR_FORM_SPELL_ID = 5487
ns.DRUID_CAT_FORM_SPELL_ID = 768

-- Rogue Poisons Skill
ns.POISONS_SPELL_ID = 2842

-- Hunter Pet Spells
ns.CALL_PET_SPELL_ID = 883
ns.DISMISS_PET_SPELL_ID = 2641
ns.FEED_PET_SPELL_ID = 6991
ns.MEND_PET_SPELL_ID = 136
ns.REVIVE_PET_SPELL_ID = 982

-- Well Fed Buff
-- A "Well Fed" food buff, read for the buff's name; it is named Well Fed in every locale on every client.
ns.WELL_FED_SPELL_ID = 19705

-- Global Cooldown
-- Read for the global cooldown's own timer, which a cooldown check compares against.
ns.GLOBAL_COOLDOWN_SPELL_ID = 61304

-- Ranged Attack
-- Shoot, read for the one label the page gives its folded ranged-attack macro.
ns.SHOOT_SPELL_ID = 5019

-- Auto Attacks
-- Attack, Auto Shot, Shoot (a wand), Shoot Bow, Shoot Gun, Shoot Crossbow and Throw: the page's Basic Attacks.
ns.BASIC_ATTACK_SPELL_IDS = { 6603, 75, 5019, 2480, 7918, 7919, 2764 }

-- Ranged Weapon Attacks
-- { id = spellId, subclass = the weapon's Enum.ItemWeaponSubclass }, in the order the Shoot macro tries them.
ns.RANGED_ATTACKS = {
	{ id = 2764, subclass = 16 }, -- Throw
	{ id = 2480, subclass = 2 }, -- Shoot Bow
	{ id = 7918, subclass = 3 }, -- Shoot Gun
	{ id = 7919, subclass = 18 }, -- Shoot Crossbow
}

-- Call Pet Flyout
-- MoP Classic's spellbook holds Call Pet as this flyout; a book without one never matches it.
ns.CALL_PET_FLYOUT_ID = 9

-- Season of Discovery Spells
-- Season of Discovery's spell IDs start here, the same cut the Vanilla data tables make.
ns.SOD_FIRST_SPELL_ID = 300000

-- Restocker Example
-- Refreshing Spring Water, the staple the Restocker page's Example lines show short.
ns.SAMPLE_RESTOCK_ITEM_ID = 159

-- Mana Runes
-- The two runes the Mana Gem panel names, read for their names.
ns.DEMONIC_RUNE_ITEM_ID = 12662
ns.DARK_RUNE_ITEM_ID = 20520

-- Pet Buff Food
-- [itemID] = { buffSpellID, rank, settingKey, requiredLevel }, -- Item Name
ns.PET_BUFF_FOODS = {
	[33874] = { 43771, 2, "KiblersBits", 55 }, -- Kibler's Bits
	[27656] = { 33272, 1, "SporelingSnacks", 55 }, -- Sporeling Snack
}

-- Professions
-- The profession skill lines the usability gates read ranks from. Each is found
-- in the skill list by the name the client gives its ID.
ns.FIRST_AID_SKILL_LINE_ID = 129
ns.ALCHEMY_SKILL_LINE_ID = 171
ns.ENGINEERING_SKILL_LINE_ID = 202

-- The Engineering specialization Diagnostics checks the player for.
ns.GOBLIN_ENGINEER_SPELL_ID = 20222

-- Thanks for the Buff
-- [constant] = spell id, -- Spell Name
ns.GAME_IDS = {
	PHASE_SHIFT_SPELL_ID = 4511, -- Phase Shift
	SAMPLE_BUFF_SPELL_ID = 1459, -- Arcane Intellect
	SAMPLE_GOOD_NEWS_SPELL_ID = 10060, -- Power Infusion
	SAMPLE_SERVICE_SPELL_ID = 10059, -- Portal: Stormwind
}

-- { texture file ID, button it starts on }, -- Icon File Name
ns.THANK_YOU_MACRO_ICONS = {
	{ 135453, 2 }, -- inv_valentinescard01
	{ 134141, 3 }, -- inv_misc_gift_02
	{ 134927, 4 }, -- inv_rosebouquet01
	{ 133783, 5 }, -- inv_misc_celebrationcake_01
	{ 135767 }, -- spell_brokenheart
	{ 133939 }, -- inv_misc_flower_02
	{ 135263 }, -- inv_summerfest_fireflower
	{ 133196 }, -- inv_holiday_beerfestpretzel01
	{ 133201 }, -- inv_holiday_brewfestbuff_01
	{ 134505 }, -- inv_misc_toy_01
	{ 135448 }, -- inv_valentinepinkrocket
	{ 132387 }, -- inv_ammo_snowball
	{ 133785 }, -- inv_misc_coin_02
	{ 134237 }, -- inv_misc_key_03
	{ 133471 }, -- inv_letter_15
	{ 134481 }, -- inv_misc_ticket_darkmoon_01
	{ 134333 }, -- inv_misc_orb_01
	{ 133730 }, -- inv_misc_bone_humanskull_01
	{ 134153 }, -- inv_misc_head_dragon_01
	{ 132834 }, -- inv_egg_03
}

--[[
How We Got the Data

Last Validated
	2026-10-22, TBC Anniversary 2.5.6.70006

Notes
	- Single spell, item, race and skill-line IDs the feature code reads by name, grouped by use. The client supplies every name the player sees from these IDs.
	- Shadowmeld and Stealth are the spells the Food and Water macros cast for Stealth Eating and Shadowmeld Drinking. Stealth is rank 1: C_Spell.GetSpellName resolves the base name "Stealth", which a bare /cast fires at the highest rank the rogue knows.
	- Cannibalize is the Forsaken racial, which channels off a corpse of the creature types listed (6 Undead, 7 Humanoid). It restores health only on this client, so CANNIBALIZE_RESTORES_MANA decides whether the Water macro may cast it.
	- Poisons (2842) is the rogue poison-crafting skill, the same ID on Era and TBC. Knowing it gates the Poisons macro (a rogue without it can't apply poisons at all) and provides the middle-click crafting branch.
	- Well Fed (19705) is read for the buff's name, which is Well Fed in every locale on every client. The two mana runes are read for the names the Mana Gem panel shows.
	- ns.PET_BUFF_FOODS holds the Hunter and Warlock pet buff foods: the pet-buff override offers the highest rank the bags hold, settingKey names each food's petBuffTypes toggle, and requiredLevel is the level a player needs before the food is offered.
	- The profession skill lines are the ones the usability gates read ranks from; each is found in the skill list by the name the client gives its ID. The Goblin Engineer specialization is what Diagnostics checks the player for.
	- Thanks for the Buff: Spell IDs that feature code needs by name rather than from a list: the sample spells the options panels use for their preview messages.
	- Thanks for the Buff: SAMPLE_GOOD_NEWS_SPELL_ID (Power Infusion) is the spell linked in the Good News sample whisper (Options/Options-Send-Good-News.lua).
	- Thanks for the Buff: THANK_YOU_MACRO_ICONS are the icons a Thank You Button macro can wear (Options/Options-Thank-You-Button.lua): bold, distinct item art nobody keeps on a bar, so a Thank You macro stands out. Each is a texture file ID present under the same ID on Classic Era, TBC Anniversary and WoW Forever. The client gives an icon no name, so the Icon dropdown shows each one as its picture alone, in this order. The second field is the button that starts on it, so buttons 2 through 5 each start on their own icon.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ManifestInterfaceData?build=2.5.6.70006

QuestieDB
	None.
]]
