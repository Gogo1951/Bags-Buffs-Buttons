local _, ns = ...

-- [classToken] = { { level, id, requires = { spellId }, faction, race = raceId, talent }, ... }, sorted by level
ns.TRAINER_SPELLS = {}

--[[
How We Got the Data

Last Validated
	2026-10-24, Mists of Pandaria Classic 5.5.4.70579

Notes
	- Empty on purpose. On this client every class spell is learned on reaching its level, and class trainers teach none, so there are no trainer rows to list.
	- The Mists TOC doesn't load Features/Unlearned-Spells.lua or Features/Trainer-Recording.lua, the features that read trainer rows. The table is still declared so the rank lookup in Features/Macro-Builder.lua (LearnLevels) reads every flavor the same way; this client has no ranks for it to find.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70579

QuestieDB
	None.
]]
