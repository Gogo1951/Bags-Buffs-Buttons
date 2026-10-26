local _, ns = ...

-- [singleSpellId] = groupSpellId, -- Single Spell -> Group Spell
ns.GROUP_VERSIONS = {
	-- Mage
	[3561] = 10059, -- Teleport: Stormwind -> Portal: Stormwind
	[3562] = 11416, -- Teleport: Ironforge -> Portal: Ironforge
	[3565] = 11419, -- Teleport: Darnassus -> Portal: Darnassus
	[32271] = 32266, -- Teleport: Exodar -> Portal: Exodar
	[33690] = 33691, -- Teleport: Shattrath (Alliance) -> Portal: Shattrath
	[49359] = 49360, -- Teleport: Theramore -> Portal: Theramore
	[88342] = 88345, -- Teleport: Tol Barad (Alliance) -> Portal: Tol Barad
	[132621] = 132620, -- Teleport: Vale of Eternal Blossoms (Alliance) -> Portal: Vale of Eternal Blossoms
	[3567] = 11417, -- Teleport: Orgrimmar -> Portal: Orgrimmar
	[3563] = 11418, -- Teleport: Undercity -> Portal: Undercity
	[3566] = 11420, -- Teleport: Thunder Bluff -> Portal: Thunder Bluff
	[32272] = 32267, -- Teleport: Silvermoon -> Portal: Silvermoon
	[35715] = 35717, -- Teleport: Shattrath (Horde) -> Portal: Shattrath
	[49358] = 49361, -- Teleport: Stonard -> Portal: Stonard
	[88344] = 88346, -- Teleport: Tol Barad (Horde) -> Portal: Tol Barad
	[132627] = 132626, -- Teleport: Vale of Eternal Blossoms (Horde) -> Portal: Vale of Eternal Blossoms
	[53140] = 53142, -- Teleport: Dalaran -> Portal: Dalaran
	[120145] = 120146, -- Ancient Teleport: Dalaran -> Ancient Portal: Dalaran
}

-- [classToken] = { { spellId, ... } }, -- each group's spells in the order they are learned
ns.SPELL_GROUPS = {}

--[[
How We Got the Data

Last Validated
	2026-10-24, Mists of Pandaria Classic 5.5.4.70579

Notes
	- Each row pairs a single-target spell with its group version, as [singleSpellId] = groupSpellId. On this client that is only each mage Teleport with its Portal: Mark of the Wild, Arcane Brilliance, the paladin Blessings and Power Word: Fortitude already reach the whole group, and Gift of the Wild, Arcane Intellect, the Greater Blessings and the priest Prayers are gone.
	- The "Right-Click For Group Version" option reads it (ResolveClassConfig in Features/Macro-Builder.lua): a learned single spell whose group version is also learned can cast the group version on a right-click.
	- Both names come from the client, so a pair whose spells this client does not know drops out at runtime until the Data Review prunes it from this folder.
	- SPELL_GROUPS lists spells with names of their own that one replaces another as the player trains (Demon Skin then Demon Armor, Cure Disease then Abolish Disease), by class, since two classes can share a spell's name (Cure Poison). The Grouped Spells submenu reads it: each spell in a group offers every spell of its group as a checkbox, and the macro casts the last one learned of those ticked.
	- Built from this client's game tables after its Validate Data report, which found the table empty: every Teleport and Portal on the mage skill line (SkillLineAbility), paired by destination. Shattrath, Tol Barad and the Vale of Eternal Blossoms have one pair per faction, the Alliance one carrying the lower IDs, as the portal objects they summon do (SpellEffect).

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70579
	https://wago.tools/db2/SpellName?build=5.5.4.70579
	https://wago.tools/db2/SpellEffect?build=5.5.4.70579

QuestieDB
	None.
]]
