local _, ns = ...

-- [singleSpellId] = groupSpellId, -- Single Spell -> Group Spell
ns.GROUP_VERSIONS = {}

-- [classToken] = { { spellId, ... } }, -- each group's spells in the order they are learned
ns.SPELL_GROUPS = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Each row pairs a single-target spell with its group version, as [singleSpellId] = groupSpellId: Mark of the Wild with Gift of the Wild, Arcane Intellect with Arcane Brilliance, each mage Teleport with its Portal, each paladin Blessing with its Greater Blessing, and the priest buffs with their Prayers.
	- The "Right-Click For Group Version" option reads it (ResolveClassConfig in Features/Macro-Builder.lua): a learned single spell whose group version is also learned can cast the group version on a right-click.
	- Both names come from the client, so a pair whose spells this client does not know drops out at runtime until the Data Review prunes it from this folder.
	- SPELL_GROUPS lists spells with names of their own that one replaces another as the player trains (Demon Skin then Demon Armor, Cure Disease then Abolish Disease), by class, since two classes can share a spell's name (Cure Poison). The Grouped Spells submenu reads it: each spell in a group offers every spell of its group as a checkbox, and the macro casts the last one learned of those ticked.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
