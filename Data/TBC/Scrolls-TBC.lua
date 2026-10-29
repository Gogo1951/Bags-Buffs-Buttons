local _, ns = ...

-- [scrollType] = { items = { ... }, conflictSpells = { ... } }
ns.SCROLL_DATA = {
	Agility = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27498, 33077, 60, 20 }, -- Scroll of Agility V
			{ 10309, 12174, 55, 17 }, -- Scroll of Agility IV
			{ 4425, 8117, 40, 13 }, -- Scroll of Agility III
			{ 1477, 8116, 25, 9 }, -- Scroll of Agility II
			{ 3012, 8115, 10, 5 }, -- Scroll of Agility
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[28497] = 35, -- Elixir of Mighty Agility
			[11334] = 25, -- Elixir of Greater Agility
			[17538] = 25, -- Elixir of the Mongoose
			[10669] = 25, -- Ground Scorpok Assay
			[42735] = 18, -- Flask of Chromatic Wonder
			[11328] = 15, -- Elixir of Agility
			[33726] = 15, -- Elixir of Mastery
			[3160] = 8, -- Elixir of Lesser Agility
			[2374] = 4, -- Elixir of Minor Agility
		},
	},
	Intellect = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27499, 33078, 60, 20 }, -- Scroll of Intellect V
			{ 10308, 12176, 50, 16 }, -- Scroll of Intellect IV
			{ 4419, 8098, 35, 12 }, -- Scroll of Intellect III
			{ 2290, 8097, 20, 8 }, -- Scroll of Intellect II
			{ 955, 8096, 5, 4 }, -- Scroll of Intellect
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[27127] = 40, -- Arcane Brilliance (Rank 2)
			[27126] = 40, -- Arcane Intellect (Rank 6)
			[23028] = 31, -- Arcane Brilliance (Rank 1)
			[10157] = 31, -- Arcane Intellect (Rank 5)
			[10156] = 22, -- Arcane Intellect (Rank 4)
			[1461] = 15, -- Arcane Intellect (Rank 3)
			[1460] = 7, -- Arcane Intellect (Rank 2)
			[1459] = 2, -- Arcane Intellect (Rank 1)
			[17627] = 65, -- Flask of Distilled Wisdom
			[39627] = 30, -- Elixir of Draenic Wisdom
			[16327] = 30, -- Juju Guile
			[10692] = 25, -- Cerebral Cortex Compound
			[11396] = 25, -- Elixir of Greater Intellect
			[17535] = 18, -- Elixir of the Sages
			[42735] = 18, -- Flask of Chromatic Wonder
			[33726] = 15, -- Elixir of Mastery
			[3166] = 6, -- Elixir of Wisdom
		},
	},
	Protection = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27500, 33079, 60, 300 }, -- Scroll of Protection V
			{ 10305, 12175, 45, 240 }, -- Scroll of Protection IV
			{ 4421, 8095, 30, 180 }, -- Scroll of Protection III
			{ 1478, 8094, 15, 120 }, -- Scroll of Protection II
			{ 3013, 8091, 1, 60 }, -- Scroll of Protection
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[28502] = 550, -- Elixir of Major Defense
			[11348] = 450, -- Elixir of Superior Defense
			[11349] = 250, -- Elixir of Greater Defense
			[15233] = 200, -- Crystal Ward
			[3220] = 150, -- Elixir of Defense
			[673] = 50, -- Elixir of Minor Defense
		},
	},
	Stamina = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27502, 33081, 60, 20 }, -- Scroll of Stamina V
			{ 10307, 12178, 50, 16 }, -- Scroll of Stamina IV
			{ 4422, 8101, 35, 12 }, -- Scroll of Stamina III
			{ 1711, 8100, 20, 8 }, -- Scroll of Stamina II
			{ 1180, 8099, 5, 4 }, -- Scroll of Stamina
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[25389] = 79, -- Power Word: Fortitude (Rank 7)
			[25392] = 79, -- Prayer of Fortitude (Rank 3)
			[10938] = 54, -- Power Word: Fortitude (Rank 6)
			[21564] = 54, -- Prayer of Fortitude (Rank 2)
			[10937] = 43, -- Power Word: Fortitude (Rank 5)
			[21562] = 43, -- Prayer of Fortitude (Rank 1)
			[2791] = 32, -- Power Word: Fortitude (Rank 4)
			[1245] = 20, -- Power Word: Fortitude (Rank 3)
			[1244] = 8, -- Power Word: Fortitude (Rank 2)
			[1243] = 3, -- Power Word: Fortitude (Rank 1)
			[10668] = 25, -- Lung Juice Cocktail
			[24382] = 25, -- Spirit of Zanza
			[17537] = 18, -- Elixir of Brute Force
			[42735] = 18, -- Flask of Chromatic Wonder
			[33726] = 15, -- Elixir of Mastery
		},
	},
	Spirit = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27501, 33080, 60, 30 }, -- Scroll of Spirit V
			{ 10306, 12177, 45, 15 }, -- Scroll of Spirit IV
			{ 4424, 8114, 30, 11 }, -- Scroll of Spirit III
			{ 1712, 8113, 15, 7 }, -- Scroll of Spirit II
			{ 1181, 8112, 1, 3 }, -- Scroll of Spirit
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[25312] = 50, -- Divine Spirit (Rank 5)
			[32999] = 50, -- Prayer of Spirit (Rank 2)
			[27841] = 40, -- Divine Spirit (Rank 4)
			[27681] = 40, -- Prayer of Spirit (Rank 1)
			[14819] = 33, -- Divine Spirit (Rank 3)
			[14818] = 23, -- Divine Spirit (Rank 2)
			[14752] = 17, -- Divine Spirit (Rank 1)
			[15231] = 30, -- Crystal Force
			[39627] = 30, -- Elixir of Draenic Wisdom
			[10693] = 25, -- Gizzard Gum
			[24382] = 25, -- Spirit of Zanza
			[17535] = 18, -- Elixir of the Sages
			[42735] = 18, -- Flask of Chromatic Wonder
			[33726] = 15, -- Elixir of Mastery
		},
	},
	Strength = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27503, 33082, 60, 20 }, -- Scroll of Strength V
			{ 10310, 12179, 55, 17 }, -- Scroll of Strength IV
			{ 4426, 8120, 40, 13 }, -- Scroll of Strength III
			{ 2289, 8119, 25, 9 }, -- Scroll of Strength II
			{ 954, 8118, 10, 5 }, -- Scroll of Strength
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[28490] = 35, -- Elixir of Major Strength
			[16323] = 30, -- Juju Power
			[11405] = 25, -- Elixir of Giants
			[10667] = 25, -- R.O.I.D.S.
			[17537] = 18, -- Elixir of Brute Force
			[42735] = 18, -- Flask of Chromatic Wonder
			[33726] = 15, -- Elixir of Mastery
			[8212] = 8, -- Elixir of Giant Growth
			[3164] = 8, -- Elixir of Ogre's Strength
			[2367] = 4, -- Elixir of Lion's Strength
		},
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-23, TBC Anniversary 2.5.6.70006

Notes
	- The stat scrolls, read by Features/Scanner-Auras.lua (FindBestScroll) to pick a scroll whose buff the player lacks. Each type lists its scrolls as { itemID, buffID, requiredLevel, amount }: the buff is the aura the scroll leaves, requiredLevel the level the tooltip requires, amount the stat it grants.
	- conflictSpells lists the buffs a scroll can't stack with, keyed by spell ID, with the amount each grants; a scroll is skipped while the player has a conflicting buff at least as strong. Class buffs come first. Agility, Protection and Strength list no class buffs; Protection stacks with Devotion Aura, Stoneskin and the like.
	- After the class buffs come every elixir, flask and other consumable buff in ns.ELIXIR_BUFF_IDS and ns.FLASK_BUFF_IDS (Data/{Game}/Elixirs-{Game}.lua) that raises the same stat: a SpellEffect Mod Stat aura (29) for the stat, or a Mod Resistance aura (22) on armor for Protection, at its amount on this build. A buff that raises two stats, such as Elixir of the Sages, is listed under both. Only Elixir of the Mongoose blocking Scroll of Agility is confirmed in game (GitHub issue #3); the rest follow the same rule without an in-game check. That errs toward skipping a scroll that would have stacked rather than building a scroll line that fails on use.
	- Buff 11328 is the Elixir of Agility's, whose spell is named Deprecated Alchemy Elixir Template; it's listed by the item.
	- Elixir of Mastery and Flask of Chromatic Wonder raise every stat, so they're listed under all five stat types.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006

QuestieDB
	None.
]]
