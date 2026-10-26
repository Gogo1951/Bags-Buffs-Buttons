local _, ns = ...

-- [singleSpellId] = groupSpellId, -- Single Spell -> Group Spell
ns.GROUP_VERSIONS = {
	-- Druid
	[1126] = 21849, -- Mark of the Wild -> Gift of the Wild
	-- Mage
	[1459] = 23028, -- Arcane Intellect -> Arcane Brilliance
	[3561] = 10059, -- Teleport: Stormwind -> Portal: Stormwind
	[3562] = 11416, -- Teleport: Ironforge -> Portal: Ironforge
	[3565] = 11419, -- Teleport: Darnassus -> Portal: Darnassus
	[32271] = 32266, -- Teleport: Exodar -> Portal: Exodar
	[33690] = 33691, -- Teleport: Shattrath (Alliance) -> Portal: Shattrath
	[49359] = 49360, -- Teleport: Theramore -> Portal: Theramore
	[3567] = 11417, -- Teleport: Orgrimmar -> Portal: Orgrimmar
	[3563] = 11418, -- Teleport: Undercity -> Portal: Undercity
	[3566] = 11420, -- Teleport: Thunder Bluff -> Portal: Thunder Bluff
	[32272] = 32267, -- Teleport: Silvermoon -> Portal: Silvermoon
	[35715] = 35717, -- Teleport: Shattrath (Horde) -> Portal: Shattrath
	[49358] = 49361, -- Teleport: Stonard -> Portal: Stonard
	-- Paladin
	[19740] = 25782, -- Blessing of Might -> Greater Blessing of Might
	[19742] = 25894, -- Blessing of Wisdom -> Greater Blessing of Wisdom
	[20217] = 25898, -- Blessing of Kings -> Greater Blessing of Kings
	[1038] = 25895, -- Blessing of Salvation -> Greater Blessing of Salvation
	[19977] = 25890, -- Blessing of Light -> Greater Blessing of Light
	[20911] = 25899, -- Blessing of Sanctuary -> Greater Blessing of Sanctuary
	-- Priest
	[1243] = 21562, -- Power Word: Fortitude -> Prayer of Fortitude
	[14752] = 27681, -- Divine Spirit -> Prayer of Spirit
	[976] = 27683, -- Shadow Protection -> Prayer of Shadow Protection
}

-- [classToken] = { { spellId, ... } }, -- each group's spells in the order they are learned
ns.SPELL_GROUPS = {
	DRUID = {
		{ 5487, 9634 }, -- Bear Form, Dire Bear Form
		{ 33943, 40120 }, -- Flight Form, Swift Flight Form
		{ 8946, 2893 }, -- Cure Poison, Abolish Poison
	},
	MAGE = {
		{ 168, 7302 }, -- Frost Armor, Ice Armor
	},
	PALADIN = {
		{ 1152, 4987 }, -- Purify, Cleanse
		{ 498, 642 }, -- Divine Protection, Divine Shield
	},
	PRIEST = {
		{ 2050, 2054, 2060 }, -- Lesser Heal, Heal, Greater Heal
		{ 528, 552 }, -- Cure Disease, Abolish Disease
	},
	WARLOCK = {
		{ 687, 706, 28176 }, -- Demon Skin, Demon Armor, Fel Armor
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-24, TBC Anniversary 2.5.6.70006

Notes
	- Each row pairs a single-target spell with its group version, as [singleSpellId] = groupSpellId: Mark of the Wild with Gift of the Wild, Arcane Intellect with Arcane Brilliance, each mage Teleport with its Portal, each paladin Blessing with its Greater Blessing, and the priest buffs with their Prayers.
	- The "Right-Click For Group Version" option reads it (ResolveClassConfig in Features/Macro-Builder.lua): a learned single spell whose group version is also learned can cast the group version on a right-click.
	- Both names come from the client, so a pair whose spells this client does not know drops out at runtime until the Data Review prunes it from this folder.
	- SPELL_GROUPS lists spells with names of their own that one replaces another as the player trains (Demon Skin then Demon Armor, Cure Disease then Abolish Disease), by class, since two classes can share a spell's name (Cure Poison). The Grouped Spells submenu reads it: each spell in a group offers every spell of its group as a checkbox, and the macro casts the last one learned of those ticked.
	- Checked against this client's mage, druid, paladin and priest skill lines (SkillLineAbility): Theramore and Stonard, which this client's trainers teach at 35, were added from the tables for the next Validate Data run to confirm.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=2.5.6.70006
	https://wago.tools/db2/SpellName?build=2.5.6.70006

QuestieDB
	None.
]]
