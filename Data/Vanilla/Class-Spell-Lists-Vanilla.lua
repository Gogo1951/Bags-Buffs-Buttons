local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [classToken] = { mouseoverEnemy, mouseoverFriend, resurrect, utility, attacks, crowdControl, offensives, defensives, selfBuffs, pageBuffs, heals, noCooldown, traps, totems, seals, blessings, curses, shocks, finishers, pets, teleports, threat, buffs, cursor, channeled, stealth = { spellId }, noToggle = { spellId }, stanceSlots = { stanceSpellId }, stances = { [spellId] = { stanceSpellId } }, forms = { [spellId] = { formSpellId } }, petAbilities = { [summonSpellId] = { abilityId, familyId } }, extraSpells = { spellId }, autoShot = spellId }
ns.CLASS_SPELL_LISTS = {
	DRUID = {
		mouseoverEnemy = {
			{ 5177, 5176, 5178, 5179, 5180, 6780, 8905, 9912 }, -- Wrath
			{ 2912, 8949, 8950, 8951, 9875, 9876, 25298 }, -- Starfire
			{ 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835 }, -- Moonfire
			{ 5570, 24974, 24975, 24976, 24977 }, -- Insect Swarm
			{ 339, 1062, 5195, 5196, 9852, 9853 }, -- Entangling Roots
			{ 770, 778, 9749, 9907 }, -- Faerie Fire
			{ 16857, 17390, 17391, 17392 }, -- Faerie Fire (Feral)
			{ 2637, 18657, 18658 }, -- Hibernate
			{ 2908, 8955, 9901 }, -- Soothe Animal
		},
		mouseoverFriend = {
			{ 5186, 5185, 5187, 5188, 5189, 6778, 8903, 9758, 9888, 9889, 25297 }, -- Healing Touch
			{ 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858 }, -- Regrowth
			{ 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299 }, -- Rejuvenation
			18562, -- Swiftmend
			{ 20484, 20739, 20742, 20747, 20748 }, -- Rebirth
			2782, -- Remove Curse
			2893, -- Abolish Poison
			8946, -- Cure Poison
			29166, -- Innervate
			{ 1126, 5232, 5234, 6756, 8907, 9884, 9885 }, -- Mark of the Wild
			{ 21849, 21850 }, -- Gift of the Wild
			{ 467, 782, 1075, 8914, 9756, 9910 }, -- Thorns
		},
		resurrect = {
			{ 20484, 20739, 20742, 20747, 20748 }, -- Rebirth
		},
		utility = {
			2893, -- Abolish Poison
			8946, -- Cure Poison
			2782, -- Remove Curse
			29166, -- Innervate
		},
		crowdControl = {
			{ 339, 1062, 5195, 5196, 9852, 9853 }, -- Entangling Roots
			{ 2637, 18657, 18658 }, -- Hibernate
			{ 5211, 6798, 8983 }, -- Bash
			{ 9005, 9823, 9827 }, -- Pounce
			16979, -- Feral Charge
			{ 99, 1735, 9490, 9747, 9898 }, -- Demoralizing Roar
		},
		offensives = {
			{ 5217, 6793, 9845, 9846 }, -- Tiger's Fury
		},
		defensives = {
			22812, -- Barkskin
			{ 22842, 22895, 22896 }, -- Frenzied Regeneration
		},
		selfBuffs = {
			16864, -- Omen of Clarity
			{ 16689, 16810, 16811, 16812, 16813, 17329 }, -- Nature's Grasp
		},
		heals = {
			{ 740, 8918, 9862, 9863 }, -- Tranquility
		},
		threat = {
			6795, -- Growl
			5209, -- Challenging Roar
			{ 8998, 9000, 9892 }, -- Cower
			{ 2908, 8955, 9901 }, -- Soothe Animal
		},
		noCooldown = {
			29166, -- Innervate
			{ 1850, 9821 }, -- Dash
		},
		finishers = {
			{ 22568, 22827, 22828, 22829, 31018 }, -- Ferocious Bite
			{ 1079, 9492, 9493, 9752, 9894, 9896 }, -- Rip
		},
		teleports = {
			18960, -- Teleport: Moonglade
		},
		buffs = {
			{ 1126, 5232, 6756, 5234, 8907, 9884, 9885 }, -- Mark of the Wild
			{ 467, 782, 1075, 8914, 9756, 9910 }, -- Thorns
			21849, -- Gift of the Wild
		},
		cursor = {
			{ 16914, 17401, 17402 }, -- Hurricane
		},
		channeled = {
			{ 740, 8918, 9862, 9863 }, -- Tranquility
			{ 16914, 17401, 17402 }, -- Hurricane
		},
		stealth = {
			{ 6783, 5215, 9913 }, -- Prowl
		},
		extraSpells = {
			5487, -- Bear Form
			768, -- Cat Form
			1066, -- Aquatic Form
			8946, -- Cure Poison
			18960, -- Teleport: Moonglade
		},
		forms = {
			[99] = { 5487, 9634 }, -- Demoralizing Roar: Bear Form, Dire Bear Form
			[769] = { 5487, 9634 }, -- Swipe: Bear Form, Dire Bear Form
			[779] = { 5487, 9634 }, -- Swipe: Bear Form, Dire Bear Form
			[780] = { 5487, 9634 }, -- Swipe: Bear Form, Dire Bear Form
			[1079] = { 768 }, -- Rip: Cat Form
			[1082] = { 768 }, -- Claw: Cat Form
			[1735] = { 5487, 9634 }, -- Demoralizing Roar: Bear Form, Dire Bear Form
			[1822] = { 768 }, -- Rake: Cat Form
			[1823] = { 768 }, -- Rake: Cat Form
			[1824] = { 768 }, -- Rake: Cat Form
			[1850] = { 768 }, -- Dash: Cat Form
			[3029] = { 768 }, -- Claw: Cat Form
			[5201] = { 768 }, -- Claw: Cat Form
			[5209] = { 5487, 9634 }, -- Challenging Roar: Bear Form, Dire Bear Form
			[5211] = { 5487, 9634 }, -- Bash: Bear Form, Dire Bear Form
			[5215] = { 768 }, -- Prowl: Cat Form
			[5217] = { 768 }, -- Tiger's Fury: Cat Form
			[5221] = { 768 }, -- Shred: Cat Form
			[5225] = { 768 }, -- Track Humanoids: Cat Form
			[5229] = { 5487, 9634 }, -- Enrage: Bear Form, Dire Bear Form
			[6783] = { 768 }, -- Prowl: Cat Form
			[6785] = { 768 }, -- Ravage: Cat Form
			[6787] = { 768 }, -- Ravage: Cat Form
			[6793] = { 768 }, -- Tiger's Fury: Cat Form
			[6795] = { 5487, 9634 }, -- Growl: Bear Form, Dire Bear Form
			[6798] = { 5487, 9634 }, -- Bash: Bear Form, Dire Bear Form
			[6800] = { 768 }, -- Shred: Cat Form
			[6807] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[6808] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[6809] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[8972] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[8983] = { 5487, 9634 }, -- Bash: Bear Form, Dire Bear Form
			[8992] = { 768 }, -- Shred: Cat Form
			[8998] = { 768 }, -- Cower: Cat Form
			[9000] = { 768 }, -- Cower: Cat Form
			[9005] = { 768 }, -- Pounce: Cat Form
			[9490] = { 5487, 9634 }, -- Demoralizing Roar: Bear Form, Dire Bear Form
			[9492] = { 768 }, -- Rip: Cat Form
			[9493] = { 768 }, -- Rip: Cat Form
			[9745] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[9747] = { 5487, 9634 }, -- Demoralizing Roar: Bear Form, Dire Bear Form
			[9752] = { 768 }, -- Rip: Cat Form
			[9754] = { 5487, 9634 }, -- Swipe: Bear Form, Dire Bear Form
			[9821] = { 768 }, -- Dash: Cat Form
			[9823] = { 768 }, -- Pounce: Cat Form
			[9827] = { 768 }, -- Pounce: Cat Form
			[9829] = { 768 }, -- Shred: Cat Form
			[9830] = { 768 }, -- Shred: Cat Form
			[9845] = { 768 }, -- Tiger's Fury: Cat Form
			[9846] = { 768 }, -- Tiger's Fury: Cat Form
			[9849] = { 768 }, -- Claw: Cat Form
			[9850] = { 768 }, -- Claw: Cat Form
			[9866] = { 768 }, -- Ravage: Cat Form
			[9867] = { 768 }, -- Ravage: Cat Form
			[9880] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[9881] = { 5487, 9634 }, -- Maul: Bear Form, Dire Bear Form
			[9892] = { 768 }, -- Cower: Cat Form
			[9894] = { 768 }, -- Rip: Cat Form
			[9896] = { 768 }, -- Rip: Cat Form
			[9898] = { 5487, 9634 }, -- Demoralizing Roar: Bear Form, Dire Bear Form
			[9904] = { 768 }, -- Rake: Cat Form
			[9908] = { 5487, 9634 }, -- Swipe: Bear Form, Dire Bear Form
			[9913] = { 768 }, -- Prowl: Cat Form
			[16857] = { 768, 5487, 9634 }, -- Faerie Fire (Feral): Cat Form, Bear Form, Dire Bear Form
			[16979] = { 5487, 9634 }, -- Feral Charge: Bear Form, Dire Bear Form
			[17390] = { 768, 5487, 9634 }, -- Faerie Fire (Feral): Cat Form, Bear Form, Dire Bear Form
			[17391] = { 768, 5487, 9634 }, -- Faerie Fire (Feral): Cat Form, Bear Form, Dire Bear Form
			[17392] = { 768, 5487, 9634 }, -- Faerie Fire (Feral): Cat Form, Bear Form, Dire Bear Form
			[22568] = { 768 }, -- Ferocious Bite: Cat Form
			[22570] = { 768 }, -- Mangle: Cat Form
			[22827] = { 768 }, -- Ferocious Bite: Cat Form
			[22828] = { 768 }, -- Ferocious Bite: Cat Form
			[22829] = { 768 }, -- Ferocious Bite: Cat Form
			[22842] = { 5487, 9634 }, -- Frenzied Regeneration: Bear Form, Dire Bear Form
			[22895] = { 5487, 9634 }, -- Frenzied Regeneration: Bear Form, Dire Bear Form
			[22896] = { 5487, 9634 }, -- Frenzied Regeneration: Bear Form, Dire Bear Form
			[24907] = { 24858 }, -- Moonkin Aura: Moonkin Form
			[31018] = { 768 }, -- Ferocious Bite: Cat Form
		},
	},
	HUNTER = {
		autoShot = 75, -- Auto Shot
		mouseoverEnemy = {
			{ 3044, 14281, 14282, 14283, 14284, 14285, 14286, 14287 }, -- Arcane Shot
			{ 19434, 20900, 20901, 20902, 20903, 20904 }, -- Aimed Shot
			{ 2643, 14288, 14289, 14290, 25294 }, -- Multi-Shot
			1985, -- Sniper Shot
			5116, -- Concussive Shot
			{ 20736, 14274, 15629, 15630, 15631, 15632 }, -- Distracting Shot
			19503, -- Scatter Shot
			{ 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295 }, -- Serpent Sting
			{ 3043, 14275, 14276, 14277 }, -- Scorpid Sting
			{ 3034, 14279, 14280 }, -- Viper Sting
			{ 19386, 24131, 24132, 24133, 24134, 24135 }, -- Wyvern Sting
			{ 1130, 14323, 14324, 14325 }, -- Hunter's Mark
			{ 1513, 14326, 14327 }, -- Scare Beast
			1462, -- Beast Lore
		},
		mouseoverFriend = {},
		crowdControl = {
			19503, -- Scatter Shot
			{ 19386, 24131, 24132, 24133, 24134, 24135 }, -- Wyvern Sting
			{ 1513, 14326, 14327 }, -- Scare Beast
			19577, -- Intimidation
			5116, -- Concussive Shot
			{ 2974, 14267, 14268 }, -- Wing Clip
		},
		defensives = {
			{ 781, 14272, 14273 }, -- Disengage
		},
		pageBuffs = {
			19506, -- Trueshot Aura
		},
		threat = {
			{ 20736, 14274, 15629, 15630, 15631, 15632 }, -- Distracting Shot
		},
		noCooldown = {
			5384, -- Feign Death
			6197, -- Eagle Eye
			1543, -- Flare
			{ 1130, 14323, 14324, 14325 }, -- Hunter's Mark
			19801, -- Tranquilizing Shot
		},
		traps = {
			{ 1499, 14310, 14311 }, -- Freezing Trap
			13809, -- Frost Trap
			{ 13795, 14302, 14303, 14304, 14305 }, -- Immolation Trap
			{ 13813, 14316, 14317 }, -- Explosive Trap
		},
		pets = {
			883, -- Call Pet
			2641, -- Dismiss Pet
			982, -- Revive Pet
			{ 136, 3111, 3661, 3662, 13542, 13543, 13544 }, -- Mend Pet
			6991, -- Feed Pet
			{ 1515, 13481, 13535 }, -- Tame Beast
			1462, -- Beast Lore
			5149, -- Beast Training
			1002, -- Eyes of the Beast
		},
		cursor = {
			{ 1510, 14294, 14295 }, -- Volley
			1543, -- Flare
		},
		channeled = {
			{ 1510, 14294, 14295 }, -- Volley
			1002, -- Eyes of the Beast
			6197, -- Eagle Eye
			{ 136, 3111, 3661, 3662, 13542, 13543, 13544 }, -- Mend Pet
		},
		stealth = {},
		noToggle = {
			13161, -- Aspect of the Beast
			5118, -- Aspect of the Cheetah
			{ 13165, 14318, 14319, 14320, 14321, 14322, 25296 }, -- Aspect of the Hawk
			13163, -- Aspect of the Monkey
			13159, -- Aspect of the Pack
			{ 20043, 20190 }, -- Aspect of the Wild
		},
		extraSpells = {
			{ 1515, 13481, 13535 }, -- Tame Beast
			5149, -- Beast Training
			883, -- Call Pet
			2641, -- Dismiss Pet
			6991, -- Feed Pet
			982, -- Revive Pet
		},
	},
	MAGE = {
		autoShot = 5019, -- Shoot
		mouseoverEnemy = {
			{ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304 }, -- Frostbolt
			{ 143, 133, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306 }, -- Fireball
			{ 2136, 2137, 2138, 8412, 8413, 10197, 10199 }, -- Fire Blast
			{ 2948, 8444, 8445, 8446, 10205, 10206, 10207 }, -- Scorch
			{ 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809 }, -- Pyroblast
			{ 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 }, -- Arcane Missiles
			{ 118, 12824, 12825, 12826, 28271, 28272 }, -- Polymorph
			28270, -- Polymorph: Cow
			2139, -- Counterspell
		},
		mouseoverFriend = {
			{ 1459, 1460, 1461, 10156, 10157 }, -- Arcane Intellect
			{ 1008, 8455, 10169, 10170 }, -- Amplify Magic
			{ 604, 8450, 8451, 10173, 10174 }, -- Dampen Magic
			475, -- Remove Lesser Curse
			130, -- Slow Fall
			23028, -- Arcane Brilliance
		},
		utility = {
			475, -- Remove Lesser Curse
			130, -- Slow Fall
		},
		crowdControl = {
			{ 118, 12824, 12825, 12826, 28271, 28272 }, -- Polymorph
			28270, -- Polymorph: Cow
			{ 122, 865, 6131, 10230 }, -- Frost Nova
			28272, -- Polymorph: Pig
			28271, -- Polymorph: Turtle
		},
		defensives = {
			11958, -- Ice Block
			11426, -- Ice Barrier
			{ 1463, 8494, 8495, 10191, 10192, 10193 }, -- Mana Shield
			{ 543, 8457, 8458, 10223, 10225 }, -- Fire Ward
			{ 6143, 8461, 8462, 10177, 28609 }, -- Frost Ward
		},
		pageBuffs = {
			{ 604, 8450, 8451, 10173, 10174 }, -- Dampen Magic
			{ 1008, 8455, 10169, 10170 }, -- Amplify Magic
		},
		noCooldown = {
			1953, -- Blink
			130, -- Slow Fall
			2855, -- Detect Magic
			2139, -- Counterspell
		},
		teleports = {
			3561, -- Teleport: Stormwind
			10059, -- Portal: Stormwind
			3562, -- Teleport: Ironforge
			11416, -- Portal: Ironforge
			3565, -- Teleport: Darnassus
			11419, -- Portal: Darnassus
			3567, -- Teleport: Orgrimmar
			11417, -- Portal: Orgrimmar
			3563, -- Teleport: Undercity
			11418, -- Portal: Undercity
			3566, -- Teleport: Thunder Bluff
			11420, -- Portal: Thunder Bluff
		},
		selfBuffs = {
			{ 7300, 7301 }, -- Frost Armor
			{ 7302, 7320, 10219, 10220 }, -- Ice Armor
			{ 6117, 22782, 22783 }, -- Mage Armor
		},
		buffs = {
			{ 1459, 1460, 1461, 10156, 10157 }, -- Arcane Intellect
			{ 1008, 8455, 10169, 10170 }, -- Amplify Magic
			{ 604, 8450, 8451, 10173, 10174 }, -- Dampen Magic
			23028, -- Arcane Brilliance
		},
		cursor = {
			{ 2120, 2121, 8422, 8423, 10215, 10216 }, -- Flamestrike
			{ 10, 6141, 8427, 10185, 10186, 10187 }, -- Blizzard
		},
		channeled = {
			{ 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 }, -- Arcane Missiles
			{ 10, 6141, 8427, 10185, 10186, 10187 }, -- Blizzard
			12051, -- Evocation
		},
		stealth = {},
		extraSpells = {
			28272, -- Polymorph
		},
	},
	PALADIN = {
		mouseoverEnemy = {
			20271, -- Judgement
			{ 879, 5614, 5615, 10312, 10313, 10314 }, -- Exorcism
			{ 24275, 24239, 24274 }, -- Hammer of Wrath
			{ 853, 5588, 5589, 10308 }, -- Hammer of Justice
			20066, -- Repentance
			{ 2878, 5627, 10326 }, -- Turn Undead
			{ 20473, 20929, 20930, 25902, 25903, 25911, 25912, 25913, 25914 }, -- Holy Shock
		},
		mouseoverFriend = {
			{ 639, 635, 647, 1026, 1042, 3472, 10328, 10329, 19968, 19980, 19981, 19982, 25292 }, -- Holy Light
			{ 19750, 19939, 19940, 19941, 19942, 19943, 19993 }, -- Flash of Light
			{ 20473, 20929, 20930, 25902, 25903, 25911, 25912, 25913, 25914 }, -- Holy Shock
			{ 633, 2800, 10310 }, -- Lay on Hands
			1044, -- Blessing of Freedom
			20217, -- Blessing of Kings
			{ 19977, 19978, 19979 }, -- Blessing of Light
			{ 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, -- Blessing of Might
			{ 1022, 5599, 10278 }, -- Blessing of Protection
			{ 6940, 20729 }, -- Blessing of Sacrifice
			1038, -- Blessing of Salvation
			{ 20911, 20912, 20913, 20914 }, -- Blessing of Sanctuary
			{ 19742, 19850, 19852, 19853, 19854, 25290 }, -- Blessing of Wisdom
			25898, -- Greater Blessing of Kings
			25890, -- Greater Blessing of Light
			{ 25782, 25916 }, -- Greater Blessing of Might
			25895, -- Greater Blessing of Salvation
			25899, -- Greater Blessing of Sanctuary
			{ 25894, 25918 }, -- Greater Blessing of Wisdom
			1152, -- Purify
			4987, -- Cleanse
			{ 10322, 7328, 10324, 20772, 20773 }, -- Redemption
			19752, -- Divine Intervention
		},
		resurrect = {
			{ 10322, 7328, 10324, 20772, 20773 }, -- Redemption
		},
		utility = {
			4987, -- Cleanse
			1152, -- Purify
			19752, -- Divine Intervention
		},
		crowdControl = {
			{ 853, 5588, 5589, 10308 }, -- Hammer of Justice
			20066, -- Repentance
			{ 2878, 5627, 10326 }, -- Turn Undead
		},
		defensives = {
			{ 642, 1020 }, -- Divine Shield
			{ 498, 5573 }, -- Divine Protection
			20925, -- Holy Shield
			{ 633, 2800, 10310 }, -- Lay on Hands
			20216, -- Divine Favor
		},
		threat = {
			25780, -- Righteous Fury
		},
		noCooldown = {
			19752, -- Divine Intervention
			13819, -- Summon Warhorse
			23214, -- Summon Charger
		},
		seals = {
			{ 20287, 20288, 20289, 20290, 20291, 20292, 20293 }, -- Seal of Righteousness
			{ 21082, 20162, 20305, 20306, 20307, 20308 }, -- Seal of the Crusader
			20164, -- Seal of Justice
			{ 20165, 20347, 20348, 20349 }, -- Seal of Light
			{ 20166, 20356, 20357 }, -- Seal of Wisdom
			20375, -- Seal of Command
		},
		blessings = {
			20217, -- Blessing of Kings
			{ 19977, 19978, 19979 }, -- Blessing of Light
			{ 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, -- Blessing of Might
			1038, -- Blessing of Salvation
			{ 20911, 20912, 20913, 20914 }, -- Blessing of Sanctuary
			{ 19742, 19850, 19852, 19853, 19854, 25290 }, -- Blessing of Wisdom
			25898, -- Greater Blessing of Kings
			25890, -- Greater Blessing of Light
			{ 25782, 25916 }, -- Greater Blessing of Might
			25895, -- Greater Blessing of Salvation
			25899, -- Greater Blessing of Sanctuary
			{ 25894, 25918 }, -- Greater Blessing of Wisdom
			{ 1022, 5599, 10278 }, -- Blessing of Protection
			{ 6940, 20729 }, -- Blessing of Sacrifice
			1044, -- Blessing of Freedom
		},
		buffs = {
			20217, -- Blessing of Kings
			{ 19742, 19850, 19852, 19853, 19854, 25290 }, -- Blessing of Wisdom
			{ 19740, 19834, 19835, 19836, 19837, 19838, 25291 }, -- Blessing of Might
			1038, -- Blessing of Salvation
			{ 19977, 19978, 19979 }, -- Blessing of Light
			{ 20911, 20912, 20913, 20914 }, -- Blessing of Sanctuary
			25782, -- Greater Blessing of Might
			25894, -- Greater Blessing of Wisdom
			25898, -- Greater Blessing of Kings
			25895, -- Greater Blessing of Salvation
			25890, -- Greater Blessing of Light
			25899, -- Greater Blessing of Sanctuary
		},
		cursor = {},
		channeled = {},
		stealth = {},
		extraSpells = {
			7328, -- Redemption
			5502, -- Sense Undead
			13819, -- Summon Warhorse
			23214, -- Summon Charger
		},
	},
	PRIEST = {
		autoShot = 5019, -- Shoot
		mouseoverEnemy = {
			{ 591, 585, 598, 984, 1004, 6060, 10933, 10934 }, -- Smite
			{ 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267 }, -- Holy Fire
			{ 8092, 8102, 8103, 8104, 8105, 8106, 10945, 10946, 10947 }, -- Mind Blast
			{ 589, 594, 970, 992, 2767, 10892, 10893, 10894 }, -- Shadow Word: Pain
			{ 15407, 17311, 17312, 17313, 17314, 18807 }, -- Mind Flay
			{ 2944, 19276, 19277, 19278, 19279, 19280 }, -- Devouring Plague
			{ 19296, 10797, 19299, 19302, 19303, 19304, 19305 }, -- Starshards
			{ 19281, 9035, 19282, 19283, 19284, 19285 }, -- Hex of Weakness
			{ 8129, 8131, 10874, 10875, 10876 }, -- Mana Burn
			15286, -- Vampiric Embrace
			{ 9484, 9485, 10955 }, -- Shackle Undead
			{ 605, 10911, 10912 }, -- Mind Control
			{ 453, 8192, 10953 }, -- Mind Soothe
			15487, -- Silence
		},
		mouseoverFriend = {
			{ 2052, 2050, 2053 }, -- Lesser Heal
			{ 2054, 2055, 6063, 6064 }, -- Heal
			{ 2060, 10963, 10964, 10965, 25314 }, -- Greater Heal
			{ 2061, 9472, 9473, 9474, 10915, 10916, 10917 }, -- Flash Heal
			{ 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315 }, -- Renew
			{ 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 }, -- Power Word: Shield
			{ 527, 988 }, -- Dispel Magic
			528, -- Cure Disease
			552, -- Abolish Disease
			{ 2006, 2010, 10880, 10881, 20770 }, -- Resurrection
			1706, -- Levitate
			{ 1243, 1244, 1245, 2791, 10937, 10938 }, -- Power Word: Fortitude
			{ 21562, 21564 }, -- Prayer of Fortitude
			{ 14752, 14818, 14819, 27841 }, -- Divine Spirit
			27681, -- Prayer of Spirit
			{ 976, 10957, 10958 }, -- Shadow Protection
			27683, -- Prayer of Shadow Protection
			6346, -- Fear Ward
			10060, -- Power Infusion
		},
		resurrect = {
			{ 2006, 2010, 10880, 10881, 20770 }, -- Resurrection
		},
		utility = {
			552, -- Abolish Disease
			528, -- Cure Disease
			{ 527, 988 }, -- Dispel Magic
			1706, -- Levitate
			10060, -- Power Infusion
		},
		crowdControl = {
			{ 8122, 8124, 10888, 10890 }, -- Psychic Scream
			{ 605, 10911, 10912 }, -- Mind Control
			{ 9484, 9485, 10955 }, -- Shackle Undead
			15487, -- Silence
		},
		defensives = {
			{ 13908, 19236, 19238, 19240, 19241, 19242, 19243 }, -- Desperate Prayer
		},
		pageBuffs = {
			6346, -- Fear Ward
			{ 2651, 19289, 19291, 19292, 19293 }, -- Elune's Grace
			{ 13896, 19271, 19273, 19274, 19275 }, -- Feedback
		},
		heals = {
			{ 596, 996, 10960, 10961, 25316 }, -- Prayer of Healing
			15237, -- Holy Nova
			724, -- Lightwell
		},
		threat = {
			{ 586, 9578, 9579, 9592, 10941, 10942 }, -- Fade
			{ 453, 8192, 10953 }, -- Mind Soothe
		},
		noCooldown = {
			1706, -- Levitate
			{ 2096, 10909 }, -- Mind Vision
		},
		selfBuffs = {
			{ 588, 7128, 602, 1006, 10951, 10952 }, -- Inner Fire
			{ 18137, 19308, 19309, 19310, 19311, 19312 }, -- Shadowguard
			{ 2652, 19261, 19262, 19264, 19265, 19266 }, -- Touch of Weakness
			14751, -- Inner Focus
		},
		buffs = {
			{ 1243, 1244, 1245, 2791, 10937, 10938 }, -- Power Word: Fortitude
			{ 14752, 14818, 14819, 27841 }, -- Divine Spirit
			{ 976, 10957, 10958 }, -- Shadow Protection
			6346, -- Fear Ward
			21562, -- Prayer of Fortitude
			27681, -- Prayer of Spirit
			27683, -- Prayer of Shadow Protection
		},
		cursor = {},
		channeled = {
			{ 15407, 17311, 17312, 17313, 17314, 18807 }, -- Mind Flay
			{ 605, 10911, 10912 }, -- Mind Control
		},
		stealth = {},
	},
	ROGUE = {
		mouseoverEnemy = {
			{ 1766, 1767, 1768, 1769 }, -- Kick
			{ 1776, 1777, 8629, 11285, 11286 }, -- Gouge
			2094, -- Blind
			{ 6770, 2070, 11297 }, -- Sap
			921, -- Pick Pocket
		},
		mouseoverFriend = {},
		crowdControl = {
			{ 6770, 2070, 11297 }, -- Sap
			{ 1776, 1777, 8629, 11285, 11286 }, -- Gouge
			2094, -- Blind
			1833, -- Cheap Shot
		},
		defensives = {
			5277, -- Evasion
			{ 1856, 1857 }, -- Vanish
		},
		threat = {
			{ 1966, 6768, 8637, 11303, 25302 }, -- Feint
		},
		noCooldown = {
			{ 2983, 8696, 11305 }, -- Sprint
			1804, -- Pick Lock
			2836, -- Detect Traps
			1842, -- Disarm Trap
			1725, -- Distract
			921, -- Pick Pocket
			{ 1766, 1767, 1768, 1769 }, -- Kick
		},
		finishers = {
			{ 6760, 6761, 6762, 8623, 8624, 11299, 11300, 31016 }, -- Eviscerate
			{ 5171, 6774 }, -- Slice and Dice
			{ 1943, 8639, 8640, 11273, 11274, 11275 }, -- Rupture
			{ 408, 8643 }, -- Kidney Shot
			{ 8647, 8649, 8650, 11197, 11198 }, -- Expose Armor
		},
		cursor = {
			1725, -- Distract
		},
		channeled = {},
		stealth = {
			{ 1784, 1785, 1786, 1787 }, -- Stealth
		},
		extraSpells = {
			14278, -- Ghostly Strike
			14183, -- Premeditation
			{ 16511, 17347, 17348 }, -- Hemorrhage
			14185, -- Preparation
			14251, -- Riposte
			13877, -- Blade Flurry
			13750, -- Adrenaline Rush
			{ 14166, 14165, 14167 }, -- Improved Slice and Dice
		},
		forms = {
			[703] = { 1784 }, -- Garrote: Stealth
			[921] = { 1784 }, -- Pick Pocket: Stealth
			[1833] = { 1784 }, -- Cheap Shot: Stealth
			[2070] = { 1784 }, -- Sap: Stealth
			[6770] = { 1784 }, -- Sap: Stealth
			[8631] = { 1784 }, -- Garrote: Stealth
			[8632] = { 1784 }, -- Garrote: Stealth
			[8633] = { 1784 }, -- Garrote: Stealth
			[8676] = { 1784 }, -- Ambush: Stealth
			[8724] = { 1784 }, -- Ambush: Stealth
			[8725] = { 1784 }, -- Ambush: Stealth
			[11267] = { 1784 }, -- Ambush: Stealth
			[11268] = { 1784 }, -- Ambush: Stealth
			[11269] = { 1784 }, -- Ambush: Stealth
			[11289] = { 1784 }, -- Garrote: Stealth
			[11290] = { 1784 }, -- Garrote: Stealth
			[11297] = { 1784 }, -- Sap: Stealth
			[14183] = { 1784 }, -- Premeditation: Stealth
			[399985] = { 1784 }, -- Shadowstrike: Stealth
		},
	},
	SHAMAN = {
		mouseoverEnemy = {
			{ 529, 403, 548, 915, 943, 6041, 10391, 10392, 15207, 15208 }, -- Lightning Bolt
			{ 421, 930, 2860, 10605 }, -- Chain Lightning
			{ 8042, 8044, 8045, 8046, 10412, 10413, 10414 }, -- Earth Shock
			{ 8050, 8052, 8053, 10447, 10448, 29228 }, -- Flame Shock
			{ 8056, 8058, 10472, 10473 }, -- Frost Shock
			{ 370, 8012 }, -- Purge
		},
		mouseoverFriend = {
			{ 332, 331, 547, 913, 939, 959, 8005, 10395, 10396, 25357 }, -- Healing Wave
			{ 8004, 8008, 8010, 10466, 10467, 10468 }, -- Lesser Healing Wave
			{ 1064, 10622, 10623 }, -- Chain Heal
			{ 2008, 20609, 20610, 20776, 20777 }, -- Ancestral Spirit
			526, -- Cure Poison
			2870, -- Cure Disease
			131, -- Water Breathing
			546, -- Water Walking
		},
		resurrect = {
			{ 2008, 20609, 20610, 20776, 20777 }, -- Ancestral Spirit
		},
		utility = {
			2870, -- Cure Disease
			526, -- Cure Poison
		},
		noCooldown = {
			6196, -- Far Sight
			{ 370, 8012 }, -- Purge
		},
		shocks = {
			{ 8042, 8044, 8045, 8046, 10412, 10413, 10414 }, -- Earth Shock
			{ 8050, 8052, 8053, 10447, 10448, 29228 }, -- Flame Shock
			{ 8056, 8058, 10472, 10473 }, -- Frost Shock
		},
		totems = {
			{ 3599, 6363, 6364, 6365, 10437, 10438 }, -- Searing Totem
			{ 8190, 10585, 10586, 10587 }, -- Magma Totem
			{ 1535, 8498, 8499, 11314, 11315 }, -- Fire Nova Totem
			{ 8227, 8249, 10526, 16387 }, -- Flametongue Totem
			{ 8181, 10478, 10479 }, -- Frost Resistance Totem
			{ 8184, 10537, 10538 }, -- Fire Resistance Totem
			{ 10595, 10600, 10601 }, -- Nature Resistance Totem
			2484, -- Earthbind Totem
			{ 5730, 6390, 6391, 6392, 10427, 10428 }, -- Stoneclaw Totem
			{ 8071, 8154, 8155, 10406, 10407, 10408 }, -- Stoneskin Totem
			{ 8075, 8160, 8161, 10442, 25361 }, -- Strength of Earth Totem
			8143, -- Tremor Totem
			8177, -- Grounding Totem
			{ 8512, 10613, 10614 }, -- Windfury Totem
			{ 8835, 10627, 25359 }, -- Grace of Air Totem
			{ 15107, 15111, 15112 }, -- Windwall Totem
			25908, -- Tranquil Air Totem
			6495, -- Sentry Totem
			{ 5394, 6375, 6377, 10462, 10463 }, -- Healing Stream Totem
			{ 5675, 10495, 10496, 10497 }, -- Mana Spring Totem
			16190, -- Mana Tide Totem
			8166, -- Poison Cleansing Totem
			8170, -- Disease Cleansing Totem
		},
		teleports = {
			556, -- Astral Recall
		},
		selfBuffs = {
			{ 324, 325, 905, 945, 8134, 10431, 10432 }, -- Lightning Shield
			{ 8017, 8018, 8019, 10399, 16314, 16315, 16316 }, -- Rockbiter Weapon
			{ 8024, 8027, 8030, 16339, 16341, 16342 }, -- Flametongue Weapon
			{ 8033, 8038, 10456, 16355, 16356 }, -- Frostbrand Weapon
			{ 8232, 8235, 10486, 16362 }, -- Windfury Weapon
		},
		buffs = {
			131, -- Water Breathing
			546, -- Water Walking
		},
		cursor = {},
		channeled = {},
		stealth = {},
		extraSpells = {
			8071, -- Stoneskin Totem
			3599, -- Searing Totem
			5394, -- Healing Stream Totem
		},
	},
	WARLOCK = {
		autoShot = 5019, -- Shoot
		mouseoverEnemy = {
			{ 695, 686, 705, 1088, 1106, 7641, 11659, 11660, 11661, 25307 }, -- Shadow Bolt
			{ 348, 707, 1094, 2941, 11665, 11667, 11668, 25309 }, -- Immolate
			{ 172, 6222, 6223, 7648, 11671, 11672, 25311 }, -- Corruption
			{ 980, 1014, 6217, 11711, 11712, 11713 }, -- Curse of Agony
			603, -- Curse of Doom
			18223, -- Curse of Exhaustion
			1010, -- Curse of Idiocy
			{ 704, 7658, 7659, 11717 }, -- Curse of Recklessness
			{ 17862, 17937 }, -- Curse of Shadow
			{ 1714, 11719 }, -- Curse of Tongues
			{ 702, 1108, 6205, 7646, 11707, 11708 }, -- Curse of Weakness
			{ 1490, 11721, 11722 }, -- Curse of the Elements
			{ 689, 699, 709, 7651, 11699, 11700 }, -- Drain Life
			{ 1120, 8288, 8289, 11675 }, -- Drain Soul
			{ 5138, 6226, 11703, 11704, 18394 }, -- Drain Mana
			{ 5782, 6213, 6215 }, -- Fear
			{ 5676, 17919, 17920, 17921, 17922, 17923 }, -- Searing Pain
			{ 17877, 18867, 18868, 18869, 18870, 18871 }, -- Shadowburn
			{ 17962, 18930, 18931, 18932 }, -- Conflagrate
			{ 18265, 18879, 18880, 18881 }, -- Siphon Life
			{ 6789, 17925, 17926 }, -- Death Coil
			{ 6353, 17924 }, -- Soul Fire
			{ 710, 18647 }, -- Banish
			{ 1098, 11725, 11726 }, -- Subjugate Demon
		},
		mouseoverFriend = {
			5697, -- Unending Breath
			2970, -- Detect Invisibility
		},
		utility = {
			2970, -- Detect Invisibility
		},
		crowdControl = {
			{ 5782, 6213, 6215 }, -- Fear
			{ 5484, 17928 }, -- Howl of Terror
			{ 6789, 17925, 17926 }, -- Death Coil
			{ 710, 18647 }, -- Banish
		},
		defensives = {
			{ 6229, 11739, 11740, 28610 }, -- Shadow Ward
		},
		pageBuffs = {
			2970, -- Detect Invisibility
			5697, -- Unending Breath
		},
		threat = {
			{ 5676, 17919, 17920, 17921, 17922, 17923 }, -- Searing Pain
		},
		noCooldown = {
			698, -- Ritual of Summoning
			18540, -- Ritual of Doom
			126, -- Eye of Kilrogg
		},
		pets = {
			688, -- Summon Imp
			697, -- Summon Voidwalker
			712, -- Summon Succubus
			713, -- Summon Incubus
			691, -- Summon Felhunter
			{ 755, 3698, 3699, 3700, 11693, 11694, 11695 }, -- Health Funnel
			18708, -- Fel Domination
			18788, -- Demonic Sacrifice
		},
		curses = {
			{ 980, 1014, 6217, 11711, 11712, 11713 }, -- Curse of Agony
			603, -- Curse of Doom
			18223, -- Curse of Exhaustion
			1010, -- Curse of Idiocy
			{ 704, 7658, 7659, 11717 }, -- Curse of Recklessness
			{ 17862, 17937 }, -- Curse of Shadow
			{ 1714, 11719 }, -- Curse of Tongues
			{ 702, 1108, 6205, 7646, 11707, 11708 }, -- Curse of Weakness
			{ 1490, 11721, 11722 }, -- Curse of the Elements
		},
		selfBuffs = {
			696, -- Demon Skin
			{ 706, 1086, 11733, 11734, 11735 }, -- Demon Armor
			19028, -- Soul Link
		},
		buffs = {
			5697, -- Unending Breath
			{ 132, 2970, 11743 }, -- Detect Greater Invisibility, Detect Invisibility, Detect Lesser Invisibility
		},
		cursor = {
			{ 5740, 6219, 11677, 11678 }, -- Rain of Fire
			1122, -- Inferno
		},
		channeled = {
			{ 689, 699, 709, 7651, 11699, 11700 }, -- Drain Life
			{ 5138, 6226, 11703, 11704, 18394 }, -- Drain Mana
			{ 1120, 8288, 8289, 11675 }, -- Drain Soul
			{ 755, 3698, 3699, 3700, 11693, 11694, 11695 }, -- Health Funnel
			{ 1949, 11683, 11684 }, -- Hellfire
			{ 5740, 6219, 11677, 11678 }, -- Rain of Fire
		},
		stealth = {},
		petAbilities = {
			[712] = { abilityId = 6358, familyId = 17 }, -- Summon Succubus: Seduction
			[688] = { abilityId = 2947, familyId = 23 }, -- Summon Imp: Fire Shield
			[691] = { abilityId = 19244, familyId = 15 }, -- Summon Felhunter: Spell Lock
			[713] = { abilityId = 6358, familyId = 302 }, -- Summon Incubus: Seduction
			[697] = { abilityId = 7812, familyId = 16 }, -- Summon Voidwalker: Sacrifice
		},
		extraSpells = {
			18288, -- Amplify Curse
			18223, -- Curse of Exhaustion
			18788, -- Demonic Sacrifice
			18708, -- Fel Domination
			19028, -- Soul Link
			697, -- Summon Voidwalker
			712, -- Summon Succubus
			713, -- Summon Incubus
			691, -- Summon Felhunter
			1122, -- Inferno
			18540, -- Ritual of Doom
			23161, -- Summon Dreadsteed
		},
	},
	WARRIOR = {
		mouseoverEnemy = {
			{ 100, 6178, 11578 }, -- Charge
			{ 20616, 20252, 20617 }, -- Intercept
			355, -- Taunt
			{ 694, 7400, 7402, 20559, 20560 }, -- Mocking Blow
			{ 72, 1671, 1672 }, -- Shield Bash
			{ 6552, 6554 }, -- Pummel
		},
		mouseoverFriend = {},
		crowdControl = {
			5246, -- Intimidating Shout
			12809, -- Concussion Blow
			676, -- Disarm
			{ 1715, 7372, 7373 }, -- Hamstring
			{ 6343, 8198, 8204, 8205, 11580, 11581 }, -- Thunder Clap
			12323, -- Piercing Howl
			{ 1160, 6190, 11554, 11555, 11556 }, -- Demoralizing Shout
		},
		defensives = {
			871, -- Shield Wall
			{ 12975, 12976 }, -- Last Stand
			2565, -- Shield Block
		},
		pageBuffs = {
			{ 6673, 5242, 6192, 11549, 11550, 11551, 25289 }, -- Battle Shout
		},
		threat = {
			355, -- Taunt
			{ 694, 7400, 7402, 20559, 20560 }, -- Mocking Blow
			1161, -- Challenging Shout
		},
		noCooldown = {
			{ 72, 1671, 1672 }, -- Shield Bash
			{ 6552, 6554 }, -- Pummel
			{ 100, 6178, 11578 }, -- Charge
			{ 20616, 20252, 20617 }, -- Intercept
			{ 7386, 7405, 8380, 11596, 11597 }, -- Sunder Armor
		},
		cursor = {},
		channeled = {},
		stealth = {},
		stanceSlots = { 2457, 71, 2458 }, -- Battle, Defensive, Berserker Stance
		stances = {
			[355] = { 71 }, -- Taunt: Defensive Stance
			[100] = { 2457 }, -- Charge: Battle Stance
			[5308] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[772] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[12292] = { 2457 }, -- Sweeping Strikes: Battle Stance
			[6343] = { 2457 }, -- Thunder Clap: Battle Stance
			[2565] = { 71 }, -- Shield Block: Defensive Stance
			[7384] = { 2457 }, -- Overpower: Battle Stance
			[694] = { 2457 }, -- Mocking Blow: Battle Stance
			[1719] = { 2458 }, -- Recklessness: Berserker Stance
			[1715] = { 2457, 2458 }, -- Hamstring: Battle Stance, Berserker Stance
			[72] = { 71, 2457 }, -- Shield Bash: Defensive Stance, Battle Stance
			[20616] = { 2458 }, -- Intercept: Berserker Stance
			[18499] = { 2458 }, -- Berserker Rage: Berserker Stance
			[6572] = { 71 }, -- Revenge: Defensive Stance
			[20230] = { 2457 }, -- Retaliation: Battle Stance
			[6552] = { 2458 }, -- Pummel: Berserker Stance
			[1680] = { 2458 }, -- Whirlwind: Berserker Stance
			[871] = { 71 }, -- Shield Wall: Defensive Stance
			[676] = { 71 }, -- Disarm: Defensive Stance
		},
		extraSpells = {
			71, -- Defensive Stance
			355, -- Taunt
			7386, -- Sunder Armor
			2458, -- Berserker Stance
			20252, -- Intercept
			{ 12975, 12976 }, -- Last Stand
			12809, -- Concussion Blow
			{ 23922, 23923, 23924, 23925 }, -- Shield Slam
			12323, -- Piercing Howl
			12328, -- Death Wish
			{ 23881, 23880, 23885, 23886, 23887, 23888, 23889, 23890, 23891, 23892, 23893, 23894 }, -- Bloodthirst
			{ 12292, 12723 }, -- Sweeping Strikes
			{ 12294, 21551, 21552, 21553 }, -- Mortal Strike
		},
		forms = {
			[72] = { 2457, 71 }, -- Shield Bash: Battle Stance, Defensive Stance
			[100] = { 2457 }, -- Charge: Battle Stance
			[355] = { 71 }, -- Taunt: Defensive Stance
			[676] = { 71 }, -- Disarm: Defensive Stance
			[694] = { 2457 }, -- Mocking Blow: Battle Stance
			[772] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[871] = { 71 }, -- Shield Wall: Defensive Stance
			[1671] = { 2457, 71 }, -- Shield Bash: Battle Stance, Defensive Stance
			[1672] = { 2457, 71 }, -- Shield Bash: Battle Stance, Defensive Stance
			[1680] = { 2458 }, -- Whirlwind: Berserker Stance
			[1715] = { 2457, 2458 }, -- Hamstring: Battle Stance, Berserker Stance
			[1719] = { 2458 }, -- Recklessness: Berserker Stance
			[2565] = { 71 }, -- Shield Block: Defensive Stance
			[5308] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[6178] = { 2457 }, -- Charge: Battle Stance
			[6343] = { 2457 }, -- Thunder Clap: Battle Stance
			[6546] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[6547] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[6548] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[6552] = { 2458 }, -- Pummel: Berserker Stance
			[6554] = { 2458 }, -- Pummel: Berserker Stance
			[6572] = { 71 }, -- Revenge: Defensive Stance
			[6574] = { 71 }, -- Revenge: Defensive Stance
			[7372] = { 2457, 2458 }, -- Hamstring: Battle Stance, Berserker Stance
			[7373] = { 2457, 2458 }, -- Hamstring: Battle Stance, Berserker Stance
			[7379] = { 71 }, -- Revenge: Defensive Stance
			[7384] = { 2457 }, -- Overpower: Battle Stance
			[7400] = { 2457 }, -- Mocking Blow: Battle Stance
			[7402] = { 2457 }, -- Mocking Blow: Battle Stance
			[7887] = { 2457 }, -- Overpower: Battle Stance
			[8198] = { 2457 }, -- Thunder Clap: Battle Stance
			[8204] = { 2457 }, -- Thunder Clap: Battle Stance
			[8205] = { 2457 }, -- Thunder Clap: Battle Stance
			[11572] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[11573] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[11574] = { 2457, 71 }, -- Rend: Battle Stance, Defensive Stance
			[11578] = { 2457 }, -- Charge: Battle Stance
			[11580] = { 2457 }, -- Thunder Clap: Battle Stance
			[11581] = { 2457 }, -- Thunder Clap: Battle Stance
			[11584] = { 2457 }, -- Overpower: Battle Stance
			[11585] = { 2457 }, -- Overpower: Battle Stance
			[11600] = { 71 }, -- Revenge: Defensive Stance
			[11601] = { 71 }, -- Revenge: Defensive Stance
			[12292] = { 2457 }, -- Sweeping Strikes: Battle Stance
			[18499] = { 2458 }, -- Berserker Rage: Berserker Stance
			[20230] = { 2457 }, -- Retaliation: Battle Stance
			[20252] = { 2458 }, -- Intercept: Berserker Stance
			[20559] = { 2457 }, -- Mocking Blow: Battle Stance
			[20560] = { 2457 }, -- Mocking Blow: Battle Stance
			[20616] = { 2458 }, -- Intercept: Berserker Stance
			[20617] = { 2458 }, -- Intercept: Berserker Stance
			[20658] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[20660] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[20661] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[20662] = { 2457, 2458 }, -- Execute: Battle Stance, Berserker Stance
			[25288] = { 71 }, -- Revenge: Defensive Stance
		},
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-24, Classic Era 1.15.9.70003

Notes
	- Each class's lists for the spellbook page: the spells whose macros get the mouseover, cursor, channeled and stealth options; the stance bar order and the stances each spell needs; the ability each demon or pet summon's macro can cast; the spells listed until learned that no trainer row covers (extraSpells: quest-learned spells and talents without trainer ranks). Features/Macro-Builder.lua reads them.
	- An entry is a spell ID, or a list of every rank's ID where some locales name the ranks differently. Spells are matched by the name this client gives them, so one ID per spell is enough otherwise.
	- Hand-picked: the game tables can't say which option a spell belongs to, so there's no family test. Every ID was checked against this client's spell table.
	- Copied from Data/Camelot/ and pruned of the IDs this client doesn't have.
	- Season of Discovery's spells are left out, though this client knows them: they live in Data/Discovery/. These are the IDs in SoD's range (300000 and up) that the TBC Anniversary client doesn't have. The paladin's Swift Judgement default macro went with them.
	- resurrect: the mouseoverFriend spells that bring back a dead player, so their macros look for a dead unit ([help,dead]) instead of a living one. Features/Macro-Options.lua gives them the Resurrection kind.
	- utility: the mouseoverFriend spells that aren't heals (cures, dispels, Innervate, Power Infusion), so Sort By Category files them under Offensive Cooldowns where their cooldown is a minute or longer, else Utility, instead of Heals.
	- crowdControl, offensives, defensives, selfBuffs, pageBuffs, heals, noCooldown, attacks, traps, totems, seals, blessings, curses, shocks, finishers, pets, teleports and threat: the page's own headings for spells their kind would file wrong under Sort By Category (Polymorph, the slows like Hamstring and Thunder Clap, and Demoralizing Shout and Demoralizing Roar under Crowd Control, Tiger's Fury under Offensive Cooldowns, Disengage, Barkskin, Desperate Prayer, which only goes on the priest, and the absorb shields and wards under Defensive Cooldowns, the buffs a class keeps up that only go on itself (the armors, Inner Fire, Inner Focus, the shaman's shields and weapon imbues) under Self Buffs, Prayer of Healing under Heals, Dash, Feign Death, Hunter's Mark, Detect Magic, Charge, Intercept, Sunder Armor, interrupts and enemy dispels under Utility, Mind Sear under Attacks). traps, totems, seals, blessings, curses, shocks, finishers, pets and teleports give the hunter's traps, the shaman's totems and shocks, the paladin's seals and blessings (one blessing per paladin on a target, Protection, Sacrifice and Freedom included), the warlock's curses (one per target, so they're chosen between), the rogue's and the druid's finishing moves (every spell that spends combo points, Kidney Shot and Maim included) the hunter's and warlock's pet spells (summoning, healing, reviving, taming and training a pet), and the mage's teleports and portals (from the Group-Versions file's mage rows) with the druid's Teleport: Moonglade, the shaman's Astral Recall and Mists' Death Gate and Zen Pilgrimage sections of their own, ahead of any other tag. threat gives the taunts (Taunt, Growl, the challenging shouts and roars, Mocking Blow, Righteous Defense, Hand of Reckoning, Dark Command, Provoke) and the threat spells (Cower, Fade, Feint, Distracting Shot, Righteous Fury, Searing Pain, Soothe Animal, Mind Soothe) Taunts And Threat. They only sort the page; no macro reads them. A spell on two takes the first in PAGE_TAGS (Features/Macro-Builder.lua). Data/Data.lua's ns.SHARED_PAGE_SPELLS holds the professions, tracking and racials every class shares.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/SpellName?build=2.5.6.70006

QuestieDB
	None.
]]
