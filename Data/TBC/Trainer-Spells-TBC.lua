local _, ns = ...

-- [classToken] = { { level, id, requires = { spellId }, faction, race = raceId, talent }, ... }, sorted by level
ns.TRAINER_SPELLS = {
	DRUID = {
		{ level = 1, id = 1126 }, -- Mark of the Wild
		{ level = 4, id = 8921 }, -- Moonfire
		{ level = 4, id = 774 }, -- Rejuvenation
		{ level = 6, id = 467 }, -- Thorns
		{ level = 6, id = 5177, requires = { 5176 } }, -- Wrath
		{ level = 8, id = 339 }, -- Entangling Roots
		{ level = 8, id = 5186, requires = { 5185 } }, -- Healing Touch
		{ level = 10, id = 99, requires = { 5487 } }, -- Demoralizing Roar
		{ level = 10, id = 5232, requires = { 1126 } }, -- Mark of the Wild
		{ level = 10, id = 8924, requires = { 8921 } }, -- Moonfire
		{ level = 10, id = 16689, requires = { 339 } }, -- Nature's Grasp
		{ level = 10, id = 1058, requires = { 774 } }, -- Rejuvenation
		{ level = 12, id = 5229, requires = { 5487 } }, -- Enrage
		{ level = 12, id = 8936 }, -- Regrowth
		{ level = 14, id = 5211, requires = { 5487 } }, -- Bash
		{ level = 14, id = 5187, requires = { 5186 } }, -- Healing Touch
		{ level = 14, id = 782, requires = { 467 } }, -- Thorns
		{ level = 14, id = 5178, requires = { 5177 } }, -- Wrath
		{ level = 16, id = 8925, requires = { 8924 } }, -- Moonfire
		{ level = 16, id = 1430, requires = { 1058 } }, -- Rejuvenation
		{ level = 16, id = 779, requires = { 5487 } }, -- Swipe
		{ level = 18, id = 1062, requires = { 339 } }, -- Entangling Roots
		{ level = 18, id = 770 }, -- Faerie Fire
		{ level = 18, id = 2637 }, -- Hibernate
		{ level = 18, id = 6808, requires = { 6807 } }, -- Maul
		{ level = 18, id = 16810, requires = { 16689, 1062 } }, -- Nature's Grasp
		{ level = 18, id = 8938, requires = { 8936 } }, -- Regrowth
		{ level = 20, id = 1735, requires = { 99 } }, -- Demoralizing Roar
		{ level = 20, id = 5188, requires = { 5187 } }, -- Healing Touch
		{ level = 20, id = 6756, requires = { 5232 } }, -- Mark of the Wild
		{ level = 20, id = 16864 }, -- Omen of Clarity
		{ level = 20, id = 20484 }, -- Rebirth
		{ level = 20, id = 2912 }, -- Starfire
		{ level = 20, id = 1079 }, -- Rip
		{ level = 20, id = 1082 }, -- Claw
		{ level = 20, id = 5215 }, -- Prowl
		{ level = 22, id = 8926, requires = { 8925 } }, -- Moonfire
		{ level = 22, id = 2090, requires = { 1430 } }, -- Rejuvenation
		{ level = 22, id = 5221, requires = { 768 } }, -- Shred
		{ level = 22, id = 2908 }, -- Soothe Animal
		{ level = 22, id = 5179, requires = { 5178 } }, -- Wrath
		{ level = 24, id = 1822, requires = { 768 } }, -- Rake
		{ level = 24, id = 8939, requires = { 8938 } }, -- Regrowth
		{ level = 24, id = 2782 }, -- Remove Curse
		{ level = 24, id = 780, requires = { 779 } }, -- Swipe
		{ level = 24, id = 1075, requires = { 782 } }, -- Thorns
		{ level = 24, id = 5217 }, -- Tiger's Fury
		{ level = 26, id = 2893 }, -- Abolish Poison
		{ level = 26, id = 1850, requires = { 768 } }, -- Dash
		{ level = 26, id = 5189, requires = { 5188 } }, -- Healing Touch
		{ level = 26, id = 6809, requires = { 6808 } }, -- Maul
		{ level = 26, id = 8949, requires = { 2912 } }, -- Starfire
		{ level = 28, id = 5209, requires = { 5487 } }, -- Challenging Roar
		{ level = 28, id = 16942, talent = true }, -- Sharpened Claws
		{ level = 28, id = 8998, requires = { 768 } }, -- Cower
		{ level = 28, id = 5195, requires = { 1062 } }, -- Entangling Roots
		{ level = 28, id = 8927, requires = { 8926 } }, -- Moonfire
		{ level = 28, id = 16811, requires = { 16810, 5195 } }, -- Nature's Grasp
		{ level = 28, id = 2091, requires = { 2090 } }, -- Rejuvenation
		{ level = 28, id = 9492, requires = { 1079 } }, -- Rip
		{ level = 28, id = 3029, requires = { 1082 } }, -- Claw
		{ level = 30, id = 6798, requires = { 5211 } }, -- Bash
		{ level = 30, id = 778, requires = { 770 } }, -- Faerie Fire
		{ level = 30, id = 5570, talent = true }, -- Insect Swarm
		{ level = 30, id = 5234, requires = { 6756 } }, -- Mark of the Wild
		{ level = 30, id = 20739, requires = { 20484 } }, -- Rebirth
		{ level = 30, id = 8940, requires = { 8939 } }, -- Regrowth
		{ level = 30, id = 6800, requires = { 5221 } }, -- Shred
		{ level = 30, id = 740 }, -- Tranquility
		{ level = 30, id = 783 }, -- Travel Form
		{ level = 30, id = 5180, requires = { 5179 } }, -- Wrath
		{ level = 30, id = 16857, talent = true }, -- Faerie Fire (Feral)
		{ level = 32, id = 9490, requires = { 1735 } }, -- Demoralizing Roar
		{ level = 32, id = 22568, requires = { 768 } }, -- Ferocious Bite
		{ level = 32, id = 6778, requires = { 5189 } }, -- Healing Touch
		{ level = 32, id = 6785, requires = { 768 } }, -- Ravage
		{ level = 32, id = 5225, requires = { 768 } }, -- Track Humanoids
		{ level = 34, id = 8972, requires = { 6809 } }, -- Maul
		{ level = 34, id = 8928, requires = { 8927 } }, -- Moonfire
		{ level = 34, id = 1823, requires = { 1822 } }, -- Rake
		{ level = 34, id = 3627, requires = { 2091 } }, -- Rejuvenation
		{ level = 34, id = 8950, requires = { 8949 } }, -- Starfire
		{ level = 34, id = 769, requires = { 780 } }, -- Swipe
		{ level = 34, id = 8914, requires = { 1075 } }, -- Thorns
		{ level = 36, id = 22842, requires = { 5487 } }, -- Frenzied Regeneration
		{ level = 36, id = 9005, requires = { 768 } }, -- Pounce
		{ level = 36, id = 8941, requires = { 8940 } }, -- Regrowth
		{ level = 36, id = 9493, requires = { 9492 } }, -- Rip
		{ level = 36, id = 6793, requires = { 5217 } }, -- Tiger's Fury
		{ level = 38, id = 5196, requires = { 5195 } }, -- Entangling Roots
		{ level = 38, id = 8903, requires = { 6778 } }, -- Healing Touch
		{ level = 38, id = 18657, requires = { 2637 } }, -- Hibernate
		{ level = 38, id = 16812, requires = { 16811, 5196 } }, -- Nature's Grasp
		{ level = 38, id = 8992, requires = { 6800 } }, -- Shred
		{ level = 38, id = 8955, requires = { 2908 } }, -- Soothe Animal
		{ level = 38, id = 6780, requires = { 5180 } }, -- Wrath
		{ level = 38, id = 5201, requires = { 3029 } }, -- Claw
		{ level = 40, id = 9000, requires = { 8998 } }, -- Cower
		{ level = 40, id = 9634, requires = { 5487 } }, -- Dire Bear Form
		{ level = 40, id = 20719, requires = { 768 } }, -- Feline Grace
		{ level = 40, id = 22827, requires = { 22568 } }, -- Ferocious Bite
		{ level = 40, id = 16914 }, -- Hurricane
		{ level = 40, id = 29166 }, -- Innervate
		{ level = 40, id = 8907, requires = { 5234 } }, -- Mark of the Wild
		{ level = 40, id = 8929, requires = { 8928 } }, -- Moonfire
		{ level = 40, id = 6783, requires = { 5215 } }, -- Prowl
		{ level = 40, id = 20742, requires = { 20739 } }, -- Rebirth
		{ level = 40, id = 8910, requires = { 3627 } }, -- Rejuvenation
		{ level = 40, id = 8918, requires = { 740 } }, -- Tranquility
		{ level = 42, id = 9747, requires = { 9490 } }, -- Demoralizing Roar
		{ level = 42, id = 9749, requires = { 778 } }, -- Faerie Fire
		{ level = 42, id = 9745, requires = { 8972 } }, -- Maul
		{ level = 42, id = 6787, requires = { 6785 } }, -- Ravage
		{ level = 42, id = 9750, requires = { 8941 } }, -- Regrowth
		{ level = 42, id = 8951, requires = { 8950 } }, -- Starfire
		{ level = 44, id = 22812 }, -- Barkskin
		{ level = 44, id = 9758, requires = { 8903 } }, -- Healing Touch
		{ level = 44, id = 1824, requires = { 1823 } }, -- Rake
		{ level = 44, id = 9752, requires = { 9493 } }, -- Rip
		{ level = 44, id = 9754, requires = { 769 } }, -- Swipe
		{ level = 44, id = 9756, requires = { 8914 } }, -- Thorns
		{ level = 46, id = 8983, requires = { 6798 } }, -- Bash
		{ level = 46, id = 9821, requires = { 1850 } }, -- Dash
		{ level = 46, id = 9833, requires = { 8929 } }, -- Moonfire
		{ level = 46, id = 9823, requires = { 9005 } }, -- Pounce
		{ level = 46, id = 9839, requires = { 8910 } }, -- Rejuvenation
		{ level = 46, id = 9829, requires = { 8992 } }, -- Shred
		{ level = 46, id = 8905, requires = { 6780 } }, -- Wrath
		{ level = 46, id = 22895, requires = { 22842 } }, -- Frenzied Regeneration
		{ level = 48, id = 9852, requires = { 5196 } }, -- Entangling Roots
		{ level = 48, id = 22828, requires = { 22827 } }, -- Ferocious Bite
		{ level = 48, id = 16813, requires = { 16812, 9852 } }, -- Nature's Grasp
		{ level = 48, id = 9856, requires = { 9750 } }, -- Regrowth
		{ level = 48, id = 9845, requires = { 6793 } }, -- Tiger's Fury
		{ level = 48, id = 9849, requires = { 5201 } }, -- Claw
		{ level = 50, id = 9888, requires = { 9758 } }, -- Healing Touch
		{ level = 50, id = 17401, requires = { 16914 } }, -- Hurricane
		{ level = 50, id = 9884, requires = { 8907 } }, -- Mark of the Wild
		{ level = 50, id = 9880, requires = { 9745 } }, -- Maul
		{ level = 50, id = 9866, requires = { 6787 } }, -- Ravage
		{ level = 50, id = 20747, requires = { 20742 } }, -- Rebirth
		{ level = 50, id = 9875, requires = { 8951 } }, -- Starfire
		{ level = 50, id = 9862, requires = { 8918 } }, -- Tranquility
		{ level = 50, id = 21849 }, -- Gift of the Wild
		{ level = 52, id = 9892, requires = { 9000 } }, -- Cower
		{ level = 52, id = 9898, requires = { 9747 } }, -- Demoralizing Roar
		{ level = 52, id = 9834, requires = { 9833 } }, -- Moonfire
		{ level = 52, id = 9840, requires = { 9839 } }, -- Rejuvenation
		{ level = 52, id = 9894, requires = { 9752 } }, -- Rip
		{ level = 54, id = 9907, requires = { 9749 } }, -- Faerie Fire
		{ level = 54, id = 9904, requires = { 1824 } }, -- Rake
		{ level = 54, id = 9857, requires = { 9856 } }, -- Regrowth
		{ level = 54, id = 9830, requires = { 9829 } }, -- Shred
		{ level = 54, id = 9901, requires = { 8955 } }, -- Soothe Animal
		{ level = 54, id = 9908, requires = { 9754 } }, -- Swipe
		{ level = 54, id = 9910, requires = { 9756 } }, -- Thorns
		{ level = 54, id = 9912, requires = { 8905 } }, -- Wrath
		{ level = 56, id = 22829, requires = { 22828 } }, -- Ferocious Bite
		{ level = 56, id = 9889, requires = { 9888 } }, -- Healing Touch
		{ level = 56, id = 9827, requires = { 9823 } }, -- Pounce
		{ level = 56, id = 22896, requires = { 22895 } }, -- Frenzied Regeneration
		{ level = 58, id = 9853, requires = { 9852 } }, -- Entangling Roots
		{ level = 58, id = 18658, requires = { 18657 } }, -- Hibernate
		{ level = 58, id = 9881, requires = { 9880 } }, -- Maul
		{ level = 58, id = 9835, requires = { 9834 } }, -- Moonfire
		{ level = 58, id = 17329, requires = { 16813, 9853 } }, -- Nature's Grasp
		{ level = 58, id = 9867, requires = { 9866 } }, -- Ravage
		{ level = 58, id = 9841, requires = { 9840 } }, -- Rejuvenation
		{ level = 58, id = 9876, requires = { 9875 } }, -- Starfire
		{ level = 58, id = 9850, requires = { 9849 } }, -- Claw
		{ level = 58, id = 33917, talent = true }, -- Mangle
		{ level = 60, id = 17402, requires = { 17401 } }, -- Hurricane
		{ level = 60, id = 9885, requires = { 9884 } }, -- Mark of the Wild
		{ level = 60, id = 9913, requires = { 6783 } }, -- Prowl
		{ level = 60, id = 20748, requires = { 20747 } }, -- Rebirth
		{ level = 60, id = 9858, requires = { 9857 } }, -- Regrowth
		{ level = 60, id = 9896, requires = { 9894 } }, -- Rip
		{ level = 60, id = 9863, requires = { 9862 } }, -- Tranquility
		{ level = 60, id = 9846, requires = { 9845 } }, -- Tiger's Fury
		{ level = 60, id = 21850, requires = { 21849 } }, -- Gift of the Wild
		{ level = 60, id = 25297, requires = { 9889 } }, -- Healing Touch
		{ level = 60, id = 25298, requires = { 9876 } }, -- Starfire
		{ level = 60, id = 25299, requires = { 9841 } }, -- Rejuvenation
		{ level = 60, id = 31018, requires = { 22829 } }, -- Ferocious Bite
		{ level = 60, id = 31709, requires = { 9892 } }, -- Cower
		{ level = 61, id = 26984, requires = { 9912 } }, -- Wrath
		{ level = 61, id = 27001, requires = { 9830 } }, -- Shred
		{ level = 62, id = 22570 }, -- Maim
		{ level = 62, id = 26978, requires = { 25297 } }, -- Healing Touch
		{ level = 62, id = 26998, requires = { 9898 } }, -- Demoralizing Roar
		{ level = 63, id = 24248, requires = { 31018 } }, -- Ferocious Bite
		{ level = 63, id = 26981, requires = { 25299 } }, -- Rejuvenation
		{ level = 63, id = 26987, requires = { 9835 } }, -- Moonfire
		{ level = 64, id = 26992, requires = { 9910 } }, -- Thorns
		{ level = 64, id = 26997, requires = { 9908 } }, -- Swipe
		{ level = 64, id = 27003, requires = { 9904 } }, -- Rake
		{ level = 64, id = 33763 }, -- Lifebloom
		{ level = 65, id = 26980, requires = { 9858 } }, -- Regrowth
		{ level = 65, id = 26999, requires = { 22896 } }, -- Frenzied Regeneration
		{ level = 65, id = 33357, requires = { 9821 } }, -- Dash
		{ level = 66, id = 26993, requires = { 9907 } }, -- Faerie Fire
		{ level = 66, id = 27005, requires = { 9867 } }, -- Ravage
		{ level = 66, id = 27006, requires = { 9827 } }, -- Pounce
		{ level = 66, id = 33745 }, -- Lacerate
		{ level = 67, id = 26986, requires = { 25298 } }, -- Starfire
		{ level = 67, id = 26996, requires = { 9881 } }, -- Maul
		{ level = 67, id = 27000, requires = { 9850 } }, -- Claw
		{ level = 67, id = 27008, requires = { 9896 } }, -- Rip
		{ level = 68, id = 26989, requires = { 9853 } }, -- Entangling Roots
		{ level = 68, id = 33943 }, -- Flight Form
		{ level = 69, id = 26979, requires = { 26978 } }, -- Healing Touch
		{ level = 69, id = 26982, requires = { 26981 } }, -- Rejuvenation
		{ level = 69, id = 26985, requires = { 26984 } }, -- Wrath
		{ level = 69, id = 26994, requires = { 20748 } }, -- Rebirth
		{ level = 69, id = 27004, requires = { 31709 } }, -- Cower
		{ level = 70, id = 26983, requires = { 9863 } }, -- Tranquility
		{ level = 70, id = 26988, requires = { 26987 } }, -- Moonfire
		{ level = 70, id = 26990, requires = { 9885 } }, -- Mark of the Wild
		{ level = 70, id = 26991, requires = { 21850 } }, -- Gift of the Wild
		{ level = 70, id = 26995, requires = { 9901 } }, -- Soothe Animal
		{ level = 70, id = 27002, requires = { 27001 } }, -- Shred
		{ level = 70, id = 27012, requires = { 17402 } }, -- Hurricane
		{ level = 70, id = 33786 }, -- Cyclone
	},
	HUNTER = {
		{ level = 1, id = 1494 }, -- Track Beasts
		{ level = 4, id = 13163 }, -- Aspect of the Monkey
		{ level = 4, id = 1978 }, -- Serpent Sting
		{ level = 5, id = 1742 }, -- Cower
		{ level = 6, id = 3044 }, -- Arcane Shot
		{ level = 6, id = 1130 }, -- Hunter's Mark
		{ level = 8, id = 5116 }, -- Concussive Shot
		{ level = 8, id = 3127 }, -- Parry
		{ level = 8, id = 14260 }, -- Raptor Strike
		{ level = 10, id = 13165 }, -- Aspect of the Hawk
		{ level = 10, id = 13549, requires = { 1978 } }, -- Serpent Sting
		{ level = 10, id = 19883 }, -- Track Humanoids
		{ level = 10, id = 4187 }, -- Great Stamina
		{ level = 10, id = 24545 }, -- Natural Armor
		{ level = 10, id = 14916 }, -- Growl
		{ level = 12, id = 14281, requires = { 3044 } }, -- Arcane Shot
		{ level = 12, id = 20736 }, -- Distracting Shot
		{ level = 12, id = 136, requires = { 1515 } }, -- Mend Pet
		{ level = 12, id = 2974 }, -- Wing Clip
		{ level = 12, id = 4188, requires = { 4187 } }, -- Great Stamina
		{ level = 12, id = 24549, requires = { 24545 } }, -- Natural Armor
		{ level = 14, id = 6197 }, -- Eagle Eye
		{ level = 14, id = 1002 }, -- Eyes of the Beast
		{ level = 14, id = 1513 }, -- Scare Beast
		{ level = 15, id = 1753, requires = { 1742 } }, -- Cower
		{ level = 16, id = 13795 }, -- Immolation Trap
		{ level = 16, id = 1495 }, -- Mongoose Bite
		{ level = 16, id = 14261, requires = { 14260 } }, -- Raptor Strike
		{ level = 18, id = 14318, requires = { 13165 } }, -- Aspect of the Hawk
		{ level = 18, id = 2643 }, -- Multi-Shot
		{ level = 18, id = 13550, requires = { 13549 } }, -- Serpent Sting
		{ level = 18, id = 19884 }, -- Track Undead
		{ level = 18, id = 4189, requires = { 4188 } }, -- Great Stamina
		{ level = 18, id = 24550, requires = { 24549 } }, -- Natural Armor
		{ level = 20, id = 19434 }, -- Aimed Shot
		{ level = 20, id = 14282, requires = { 14281 } }, -- Arcane Shot
		{ level = 20, id = 5118 }, -- Aspect of the Cheetah
		{ level = 20, id = 781 }, -- Disengage
		{ level = 20, id = 14274, requires = { 20736 } }, -- Distracting Shot
		{ level = 20, id = 674 }, -- Dual Wield
		{ level = 20, id = 1499 }, -- Freezing Trap
		{ level = 20, id = 3111, requires = { 136 } }, -- Mend Pet
		{ level = 20, id = 24493 }, -- Arcane Resistance
		{ level = 20, id = 23992 }, -- Fire Resistance
		{ level = 20, id = 24446 }, -- Frost Resistance
		{ level = 20, id = 14917 }, -- Growl
		{ level = 20, id = 24492 }, -- Nature Resistance
		{ level = 20, id = 24488 }, -- Shadow Resistance
		{ level = 22, id = 14323, requires = { 1130 } }, -- Hunter's Mark
		{ level = 22, id = 3043 }, -- Scorpid Sting
		{ level = 24, id = 1462 }, -- Beast Lore
		{ level = 24, id = 14262, requires = { 14261 } }, -- Raptor Strike
		{ level = 24, id = 19885 }, -- Track Hidden
		{ level = 24, id = 4190, requires = { 4189 } }, -- Great Stamina
		{ level = 24, id = 24551, requires = { 24550 } }, -- Natural Armor
		{ level = 25, id = 1754, requires = { 1753 } }, -- Cower
		{ level = 26, id = 14302, requires = { 13795 } }, -- Immolation Trap
		{ level = 26, id = 3045 }, -- Rapid Fire
		{ level = 26, id = 13551, requires = { 13550 } }, -- Serpent Sting
		{ level = 26, id = 19880 }, -- Track Elementals
		{ level = 28, id = 20900, requires = { 19434 } }, -- Aimed Shot
		{ level = 28, id = 14283, requires = { 14282 } }, -- Arcane Shot
		{ level = 28, id = 14319, requires = { 14318 } }, -- Aspect of the Hawk
		{ level = 28, id = 13809 }, -- Frost Trap
		{ level = 28, id = 3661, requires = { 3111 } }, -- Mend Pet
		{ level = 30, id = 13161 }, -- Aspect of the Beast
		{ level = 30, id = 19306, talent = true }, -- Counterattack
		{ level = 30, id = 15629, requires = { 14274 } }, -- Distracting Shot
		{ level = 30, id = 5384 }, -- Feign Death
		{ level = 30, id = 14269, requires = { 1495 } }, -- Mongoose Bite
		{ level = 30, id = 14326, requires = { 1513 } }, -- Scare Beast
		{ level = 30, id = 24497, requires = { 24493 } }, -- Arcane Resistance
		{ level = 30, id = 24439, requires = { 23992 } }, -- Fire Resistance
		{ level = 30, id = 24447, requires = { 24446 } }, -- Frost Resistance
		{ level = 30, id = 4191, requires = { 4190 } }, -- Great Stamina
		{ level = 30, id = 14918, requires = { 14917 } }, -- Growl
		{ level = 30, id = 24552, requires = { 24551 } }, -- Natural Armor
		{ level = 30, id = 24502, requires = { 24492 } }, -- Nature Resistance
		{ level = 30, id = 24505, requires = { 24488 } }, -- Shadow Resistance
		{ level = 30, id = 14288, requires = { 2643 } }, -- Multi-Shot
		{ level = 32, id = 1543 }, -- Flare
		{ level = 32, id = 14263, requires = { 14262 } }, -- Raptor Strike
		{ level = 32, id = 19878 }, -- Track Demons
		{ level = 34, id = 14272, requires = { 781 } }, -- Disengage
		{ level = 34, id = 13813 }, -- Explosive Trap
		{ level = 34, id = 13552, requires = { 13551 } }, -- Serpent Sting
		{ level = 35, id = 1755, requires = { 1754 } }, -- Cower
		{ level = 36, id = 20901, requires = { 20900 } }, -- Aimed Shot
		{ level = 36, id = 14284, requires = { 14283 } }, -- Arcane Shot
		{ level = 36, id = 14303, requires = { 14302 } }, -- Immolation Trap
		{ level = 36, id = 3662, requires = { 3661 } }, -- Mend Pet
		{ level = 36, id = 3034 }, -- Viper Sting
		{ level = 36, id = 4192, requires = { 4191 } }, -- Great Stamina
		{ level = 36, id = 24553, requires = { 24552 } }, -- Natural Armor
		{ level = 38, id = 14320, requires = { 14319 } }, -- Aspect of the Hawk
		{ level = 38, id = 14267, requires = { 2974 } }, -- Wing Clip
		{ level = 40, id = 13159 }, -- Aspect of the Pack
		{ level = 40, id = 15630, requires = { 15629 } }, -- Distracting Shot
		{ level = 40, id = 14310, requires = { 1499 } }, -- Freezing Trap
		{ level = 40, id = 14324, requires = { 14323 } }, -- Hunter's Mark
		{ level = 40, id = 8737 }, -- Mail
		{ level = 40, id = 14264, requires = { 14263 } }, -- Raptor Strike
		{ level = 40, id = 19882 }, -- Track Giants
		{ level = 40, id = 1510 }, -- Volley
		{ level = 40, id = 24500, requires = { 24497 } }, -- Arcane Resistance
		{ level = 40, id = 24444, requires = { 24439 } }, -- Fire Resistance
		{ level = 40, id = 24448, requires = { 24447 } }, -- Frost Resistance
		{ level = 40, id = 14919, requires = { 14918 } }, -- Growl
		{ level = 40, id = 24503, requires = { 24502 } }, -- Nature Resistance
		{ level = 40, id = 24506, requires = { 24505 } }, -- Shadow Resistance
		{ level = 42, id = 13553, requires = { 13552 } }, -- Serpent Sting
		{ level = 42, id = 4193, requires = { 4192 } }, -- Great Stamina
		{ level = 42, id = 24554, requires = { 24553 } }, -- Natural Armor
		{ level = 42, id = 14289, requires = { 14288 } }, -- Multi-Shot
		{ level = 44, id = 20902, requires = { 20901 } }, -- Aimed Shot
		{ level = 44, id = 14285, requires = { 14284 } }, -- Arcane Shot
		{ level = 44, id = 14316, requires = { 13813 } }, -- Explosive Trap
		{ level = 44, id = 13542, requires = { 3662 } }, -- Mend Pet
		{ level = 44, id = 14270, requires = { 14269 } }, -- Mongoose Bite
		{ level = 45, id = 1756, requires = { 1755 } }, -- Cower
		{ level = 46, id = 20043 }, -- Aspect of the Wild
		{ level = 46, id = 14304, requires = { 14303 } }, -- Immolation Trap
		{ level = 46, id = 14327, requires = { 14326 } }, -- Scare Beast
		{ level = 46, id = 14279, requires = { 3034 } }, -- Viper Sting
		{ level = 48, id = 14321, requires = { 14320 } }, -- Aspect of the Hawk
		{ level = 48, id = 14273, requires = { 14272 } }, -- Disengage
		{ level = 48, id = 14265, requires = { 14264 } }, -- Raptor Strike
		{ level = 48, id = 4194, requires = { 4193 } }, -- Great Stamina
		{ level = 48, id = 24555, requires = { 24554 } }, -- Natural Armor
		{ level = 50, id = 15631, requires = { 15630 } }, -- Distracting Shot
		{ level = 50, id = 13554, requires = { 13553 } }, -- Serpent Sting
		{ level = 50, id = 19879 }, -- Track Dragonkin
		{ level = 50, id = 14294, requires = { 1510 } }, -- Volley
		{ level = 50, id = 24501, requires = { 24500 } }, -- Arcane Resistance
		{ level = 50, id = 24445, requires = { 24444 } }, -- Fire Resistance
		{ level = 50, id = 24449, requires = { 24448 } }, -- Frost Resistance
		{ level = 50, id = 14920, requires = { 14919 } }, -- Growl
		{ level = 50, id = 24504, requires = { 24503 } }, -- Nature Resistance
		{ level = 50, id = 24507, requires = { 24506 } }, -- Shadow Resistance
		{ level = 50, id = 19386, talent = true }, -- Wyvern Sting
		{ level = 52, id = 20903, requires = { 20902 } }, -- Aimed Shot
		{ level = 52, id = 14286, requires = { 14285 } }, -- Arcane Shot
		{ level = 52, id = 13543, requires = { 13542 } }, -- Mend Pet
		{ level = 54, id = 14317, requires = { 14316 } }, -- Explosive Trap
		{ level = 54, id = 5041, requires = { 4194 } }, -- Great Stamina
		{ level = 54, id = 24629, requires = { 24555 } }, -- Natural Armor
		{ level = 54, id = 14290, requires = { 14289 } }, -- Multi-Shot
		{ level = 55, id = 16697, requires = { 1756 } }, -- Cower
		{ level = 56, id = 20190, requires = { 20043 } }, -- Aspect of the Wild
		{ level = 56, id = 14305, requires = { 14304 } }, -- Immolation Trap
		{ level = 56, id = 14266, requires = { 14265 } }, -- Raptor Strike
		{ level = 56, id = 14280, requires = { 14279 } }, -- Viper Sting
		{ level = 58, id = 14322, requires = { 14321 } }, -- Aspect of the Hawk
		{ level = 58, id = 14325, requires = { 14324 } }, -- Hunter's Mark
		{ level = 58, id = 14271, requires = { 14270 } }, -- Mongoose Bite
		{ level = 58, id = 13555, requires = { 13554 } }, -- Serpent Sting
		{ level = 58, id = 14295, requires = { 14294 } }, -- Volley
		{ level = 60, id = 20904, requires = { 20903 } }, -- Aimed Shot
		{ level = 60, id = 14287, requires = { 14286 } }, -- Arcane Shot
		{ level = 60, id = 15632, requires = { 15631 } }, -- Distracting Shot
		{ level = 60, id = 14311, requires = { 14310 } }, -- Freezing Trap
		{ level = 60, id = 13544, requires = { 13543 } }, -- Mend Pet
		{ level = 60, id = 14268, requires = { 14267 } }, -- Wing Clip
		{ level = 60, id = 5042, requires = { 5041 } }, -- Great Stamina
		{ level = 60, id = 14921, requires = { 14920 } }, -- Growl
		{ level = 60, id = 24630, requires = { 24629 } }, -- Natural Armor
		{ level = 60, id = 19801 }, -- Tranquilizing Shot
		{ level = 60, id = 25294, requires = { 14290 } }, -- Multi-Shot
		{ level = 60, id = 25295, requires = { 13555 } }, -- Serpent Sting
		{ level = 60, id = 25296, requires = { 14322 } }, -- Aspect of the Hawk
		{ level = 61, id = 27025, requires = { 14317 } }, -- Explosive Trap
		{ level = 62, id = 27015, requires = { 14273 } }, -- Disengage
		{ level = 62, id = 34120 }, -- Steady Shot
		{ level = 63, id = 27014, requires = { 14266 } }, -- Raptor Strike
		{ level = 64, id = 34074 }, -- Aspect of the Viper
		{ level = 65, id = 27023, requires = { 14305 } }, -- Immolation Trap
		{ level = 65, id = 27048, requires = { 16697 } }, -- Cower
		{ level = 66, id = 27018, requires = { 14280 } }, -- Viper Sting
		{ level = 66, id = 34026 }, -- Kill Command
		{ level = 67, id = 27016, requires = { 25295 } }, -- Serpent Sting
		{ level = 67, id = 27021, requires = { 25294 } }, -- Multi-Shot
		{ level = 67, id = 27022, requires = { 14295 } }, -- Volley
		{ level = 68, id = 27044, requires = { 25296 } }, -- Aspect of the Hawk
		{ level = 68, id = 27045, requires = { 20190 } }, -- Aspect of the Wild
		{ level = 68, id = 27046, requires = { 13544 } }, -- Mend Pet
		{ level = 68, id = 34600 }, -- Snake Trap
		{ level = 69, id = 27019, requires = { 14287 } }, -- Arcane Shot
		{ level = 69, id = 27020, requires = { 15632 } }, -- Distracting Shot
		{ level = 70, id = 27047, requires = { 14921 } }, -- Growl
		{ level = 70, id = 34477 }, -- Misdirection
		{ level = 70, id = 36916, requires = { 14271 } }, -- Mongoose Bite
	},
	MAGE = {
		{ level = 1, id = 1459 }, -- Arcane Intellect
		{ level = 4, id = 5504 }, -- Conjure Water
		{ level = 4, id = 116 }, -- Frostbolt
		{ level = 6, id = 587 }, -- Conjure Food
		{ level = 6, id = 2136 }, -- Fire Blast
		{ level = 6, id = 143, requires = { 133 } }, -- Fireball
		{ level = 8, id = 5143 }, -- Arcane Missiles
		{ level = 8, id = 205, requires = { 116 } }, -- Frostbolt
		{ level = 8, id = 118 }, -- Polymorph
		{ level = 10, id = 5505, requires = { 5504 } }, -- Conjure Water
		{ level = 10, id = 7300, requires = { 168 } }, -- Frost Armor
		{ level = 10, id = 122 }, -- Frost Nova
		{ level = 12, id = 597, requires = { 587 } }, -- Conjure Food
		{ level = 12, id = 604 }, -- Dampen Magic
		{ level = 12, id = 145, requires = { 143 } }, -- Fireball
		{ level = 12, id = 130 }, -- Slow Fall
		{ level = 14, id = 1449 }, -- Arcane Explosion
		{ level = 14, id = 1460, requires = { 1459 } }, -- Arcane Intellect
		{ level = 14, id = 2137, requires = { 2136 } }, -- Fire Blast
		{ level = 14, id = 837, requires = { 205 } }, -- Frostbolt
		{ level = 16, id = 5144, requires = { 5143 } }, -- Arcane Missiles
		{ level = 16, id = 2120 }, -- Flamestrike
		{ level = 18, id = 1008 }, -- Amplify Magic
		{ level = 18, id = 3140, requires = { 145 } }, -- Fireball
		{ level = 18, id = 475 }, -- Remove Lesser Curse
		{ level = 20, id = 1953 }, -- Blink
		{ level = 20, id = 10 }, -- Blizzard
		{ level = 20, id = 5506, requires = { 5505 } }, -- Conjure Water
		{ level = 20, id = 12051 }, -- Evocation
		{ level = 20, id = 543 }, -- Fire Ward
		{ level = 20, id = 7301, requires = { 7300 } }, -- Frost Armor
		{ level = 20, id = 7322, requires = { 837 } }, -- Frostbolt
		{ level = 20, id = 1463 }, -- Mana Shield
		{ level = 20, id = 12824, requires = { 118 } }, -- Polymorph
		{ level = 20, id = 3561, faction = "Alliance" }, -- Teleport: Stormwind
		{ level = 20, id = 3562, faction = "Alliance" }, -- Teleport: Ironforge
		{ level = 20, id = 3563, faction = "Horde" }, -- Teleport: Undercity
		{ level = 20, id = 3567, faction = "Horde" }, -- Teleport: Orgrimmar
		{ level = 20, id = 32271, faction = "Alliance" }, -- Teleport: Exodar
		{ level = 20, id = 32272, faction = "Horde" }, -- Teleport: Silvermoon
		{ level = 22, id = 8437, requires = { 1449 } }, -- Arcane Explosion
		{ level = 22, id = 990, requires = { 597 } }, -- Conjure Food
		{ level = 22, id = 2138, requires = { 2137 } }, -- Fire Blast
		{ level = 22, id = 6143 }, -- Frost Ward
		{ level = 22, id = 2948 }, -- Scorch
		{ level = 24, id = 5145, requires = { 5144 } }, -- Arcane Missiles
		{ level = 24, id = 2139 }, -- Counterspell
		{ level = 24, id = 8450, requires = { 604 } }, -- Dampen Magic
		{ level = 24, id = 8400, requires = { 3140 } }, -- Fireball
		{ level = 24, id = 2121, requires = { 2120 } }, -- Flamestrike
		{ level = 24, id = 11366, talent = true }, -- Pyroblast
		{ level = 26, id = 120 }, -- Cone of Cold
		{ level = 26, id = 865, requires = { 122 } }, -- Frost Nova
		{ level = 26, id = 8406, requires = { 7322 } }, -- Frostbolt
		{ level = 28, id = 1461, requires = { 1460 } }, -- Arcane Intellect
		{ level = 28, id = 6141, requires = { 10 } }, -- Blizzard
		{ level = 28, id = 759 }, -- Conjure Mana Agate
		{ level = 28, id = 8494, requires = { 1463 } }, -- Mana Shield
		{ level = 28, id = 8444, requires = { 2948 } }, -- Scorch
		{ level = 30, id = 8455, requires = { 1008 } }, -- Amplify Magic
		{ level = 30, id = 8438, requires = { 8437 } }, -- Arcane Explosion
		{ level = 30, id = 6127, requires = { 5506 } }, -- Conjure Water
		{ level = 30, id = 8412, requires = { 2138 } }, -- Fire Blast
		{ level = 30, id = 8457, requires = { 543 } }, -- Fire Ward
		{ level = 30, id = 8401, requires = { 8400 } }, -- Fireball
		{ level = 30, id = 7302 }, -- Ice Armor
		{ level = 30, id = 3565, faction = "Alliance" }, -- Teleport: Darnassus
		{ level = 30, id = 3566, faction = "Horde" }, -- Teleport: Thunder Bluff
		{ level = 30, id = 45438 }, -- Ice Block
		{ level = 32, id = 8416, requires = { 5145 } }, -- Arcane Missiles
		{ level = 32, id = 6129, requires = { 990 } }, -- Conjure Food
		{ level = 32, id = 8422, requires = { 2121 } }, -- Flamestrike
		{ level = 32, id = 8461, requires = { 6143 } }, -- Frost Ward
		{ level = 32, id = 8407, requires = { 8406 } }, -- Frostbolt
		{ level = 34, id = 8492, requires = { 120 } }, -- Cone of Cold
		{ level = 34, id = 6117 }, -- Mage Armor
		{ level = 34, id = 8445, requires = { 8444 } }, -- Scorch
		{ level = 35, id = 49358, faction = "Horde" }, -- Teleport: Stonard
		{ level = 35, id = 49359, faction = "Alliance" }, -- Teleport: Theramore
		{ level = 35, id = 49360, faction = "Alliance" }, -- Portal: Theramore
		{ level = 35, id = 49361, faction = "Horde" }, -- Portal: Stonard
		{ level = 36, id = 11113, talent = true }, -- Blast Wave
		{ level = 36, id = 8427, requires = { 6141 } }, -- Blizzard
		{ level = 36, id = 8451, requires = { 8450 } }, -- Dampen Magic
		{ level = 36, id = 8402, requires = { 8401 } }, -- Fireball
		{ level = 36, id = 8495, requires = { 8494 } }, -- Mana Shield
		{ level = 38, id = 8439, requires = { 8438 } }, -- Arcane Explosion
		{ level = 38, id = 3552, requires = { 759 } }, -- Conjure Mana Jade
		{ level = 38, id = 8413, requires = { 8412 } }, -- Fire Blast
		{ level = 38, id = 8408, requires = { 8407 } }, -- Frostbolt
		{ level = 40, id = 8417, requires = { 8416 } }, -- Arcane Missiles
		{ level = 40, id = 10138, requires = { 6127 } }, -- Conjure Water
		{ level = 40, id = 8458, requires = { 8457 } }, -- Fire Ward
		{ level = 40, id = 8423, requires = { 8422 } }, -- Flamestrike
		{ level = 40, id = 6131, requires = { 865 } }, -- Frost Nova
		{ level = 40, id = 7320, requires = { 7302 } }, -- Ice Armor
		{ level = 40, id = 12825, requires = { 12824 } }, -- Polymorph
		{ level = 40, id = 8446, requires = { 8445 } }, -- Scorch
		{ level = 40, id = 10059, faction = "Alliance" }, -- Portal: Stormwind
		{ level = 40, id = 11416, faction = "Alliance" }, -- Portal: Ironforge
		{ level = 40, id = 11417, faction = "Horde" }, -- Portal: Orgrimmar
		{ level = 40, id = 11418, faction = "Horde" }, -- Portal: Undercity
		{ level = 40, id = 32266, faction = "Alliance" }, -- Portal: Exodar
		{ level = 40, id = 32267, faction = "Horde" }, -- Portal: Silvermoon
		{ level = 42, id = 10169, requires = { 8455 } }, -- Amplify Magic
		{ level = 42, id = 10156, requires = { 1461 } }, -- Arcane Intellect
		{ level = 42, id = 10159, requires = { 8492 } }, -- Cone of Cold
		{ level = 42, id = 10144, requires = { 6129 } }, -- Conjure Food
		{ level = 42, id = 10148, requires = { 8402 } }, -- Fireball
		{ level = 42, id = 8462, requires = { 8461 } }, -- Frost Ward
		{ level = 44, id = 10185, requires = { 8427 } }, -- Blizzard
		{ level = 44, id = 10179, requires = { 8408 } }, -- Frostbolt
		{ level = 44, id = 10191, requires = { 8495 } }, -- Mana Shield
		{ level = 46, id = 10201, requires = { 8439 } }, -- Arcane Explosion
		{ level = 46, id = 10197, requires = { 8413 } }, -- Fire Blast
		{ level = 46, id = 11426, talent = true }, -- Ice Barrier
		{ level = 46, id = 22782, requires = { 6117 } }, -- Mage Armor
		{ level = 46, id = 10205, requires = { 8446 } }, -- Scorch
		{ level = 48, id = 10211, requires = { 8417 } }, -- Arcane Missiles
		{ level = 48, id = 10053, requires = { 3552 } }, -- Conjure Mana Citrine
		{ level = 48, id = 10173, requires = { 8451 } }, -- Dampen Magic
		{ level = 48, id = 10149, requires = { 10148 } }, -- Fireball
		{ level = 48, id = 10215, requires = { 8423 } }, -- Flamestrike
		{ level = 50, id = 10160, requires = { 10159 } }, -- Cone of Cold
		{ level = 50, id = 10139, requires = { 10138 } }, -- Conjure Water
		{ level = 50, id = 10223, requires = { 8458 } }, -- Fire Ward
		{ level = 50, id = 10180, requires = { 10179 } }, -- Frostbolt
		{ level = 50, id = 10219, requires = { 7320 } }, -- Ice Armor
		{ level = 50, id = 11419, faction = "Alliance" }, -- Portal: Darnassus
		{ level = 50, id = 11420, faction = "Horde" }, -- Portal: Thunder Bluff
		{ level = 52, id = 10186, requires = { 10185 } }, -- Blizzard
		{ level = 52, id = 10145, requires = { 10144 } }, -- Conjure Food
		{ level = 52, id = 10177, requires = { 8462 } }, -- Frost Ward
		{ level = 52, id = 10192, requires = { 10191 } }, -- Mana Shield
		{ level = 52, id = 10206, requires = { 10205 } }, -- Scorch
		{ level = 54, id = 10170, requires = { 10169 } }, -- Amplify Magic
		{ level = 54, id = 10202, requires = { 10201 } }, -- Arcane Explosion
		{ level = 54, id = 10199, requires = { 10197 } }, -- Fire Blast
		{ level = 54, id = 10150, requires = { 10149 } }, -- Fireball
		{ level = 54, id = 10230, requires = { 6131 } }, -- Frost Nova
		{ level = 56, id = 10157, requires = { 10156 } }, -- Arcane Intellect
		{ level = 56, id = 10212, requires = { 10211 } }, -- Arcane Missiles
		{ level = 56, id = 10216, requires = { 10215 } }, -- Flamestrike
		{ level = 56, id = 10181, requires = { 10180 } }, -- Frostbolt
		{ level = 56, id = 23028 }, -- Arcane Brilliance
		{ level = 56, id = 31661, talent = true }, -- Dragon's Breath
		{ level = 58, id = 10161, requires = { 10160 } }, -- Cone of Cold
		{ level = 58, id = 10054, requires = { 10053 } }, -- Conjure Mana Ruby
		{ level = 58, id = 22783, requires = { 22782 } }, -- Mage Armor
		{ level = 58, id = 10207, requires = { 10206 } }, -- Scorch
		{ level = 60, id = 10187, requires = { 10186 } }, -- Blizzard
		{ level = 60, id = 10174, requires = { 10173 } }, -- Dampen Magic
		{ level = 60, id = 10225, requires = { 10223 } }, -- Fire Ward
		{ level = 60, id = 10151, requires = { 10150 } }, -- Fireball
		{ level = 60, id = 10220, requires = { 10219 } }, -- Ice Armor
		{ level = 60, id = 10193, requires = { 10192 } }, -- Mana Shield
		{ level = 60, id = 12826, requires = { 12825 } }, -- Polymorph
		{ level = 60, id = 10140, requires = { 10139 } }, -- Conjure Water
		{ level = 60, id = 25304, requires = { 10181 } }, -- Frostbolt
		{ level = 60, id = 25306, requires = { 10151 } }, -- Fireball
		{ level = 60, id = 25345, requires = { 10212 } }, -- Arcane Missiles
		{ level = 60, id = 28271, requires = { 12826 } }, -- Polymorph
		{ level = 60, id = 28609, requires = { 10177 } }, -- Frost Ward
		{ level = 60, id = 28612, requires = { 10145 } }, -- Conjure Food
		{ level = 60, id = 33690, faction = "Alliance" }, -- Teleport: Shattrath
		{ level = 60, id = 35715, faction = "Horde" }, -- Teleport: Shattrath
		{ level = 61, id = 27078, requires = { 10199 } }, -- Fire Blast
		{ level = 62, id = 27080, requires = { 10202 } }, -- Arcane Explosion
		{ level = 62, id = 30482 }, -- Molten Armor
		{ level = 63, id = 27071, requires = { 25304 } }, -- Frostbolt
		{ level = 63, id = 27075, requires = { 25345 } }, -- Arcane Missiles
		{ level = 63, id = 27130, requires = { 10170 } }, -- Amplify Magic
		{ level = 64, id = 27086, requires = { 10216 } }, -- Flamestrike
		{ level = 64, id = 30451 }, -- Arcane Blast
		{ level = 65, id = 27073, requires = { 10207 } }, -- Scorch
		{ level = 65, id = 27087, requires = { 10161 } }, -- Cone of Cold
		{ level = 65, id = 33691, faction = "Alliance" }, -- Portal: Shattrath
		{ level = 65, id = 35717, faction = "Horde" }, -- Portal: Shattrath
		{ level = 65, id = 37420, requires = { 10140 } }, -- Conjure Water
		{ level = 66, id = 27070, requires = { 25306 } }, -- Fireball
		{ level = 66, id = 30455 }, -- Ice Lance
		{ level = 67, id = 27088, requires = { 10230 } }, -- Frost Nova
		{ level = 67, id = 33944, requires = { 10174 } }, -- Dampen Magic
		{ level = 68, id = 27085, requires = { 10187 } }, -- Blizzard
		{ level = 68, id = 27101 }, -- Conjure Mana Emerald
		{ level = 68, id = 27131, requires = { 10193 } }, -- Mana Shield
		{ level = 68, id = 66 }, -- Invisibility
		{ level = 69, id = 27072, requires = { 27071 } }, -- Frostbolt
		{ level = 69, id = 27124, requires = { 10220 } }, -- Ice Armor
		{ level = 69, id = 27125, requires = { 22783 } }, -- Mage Armor
		{ level = 69, id = 27128, requires = { 10225 } }, -- Fire Ward
		{ level = 69, id = 33946, requires = { 27130 } }, -- Amplify Magic
		{ level = 69, id = 38699, requires = { 27075 } }, -- Arcane Missiles
		{ level = 70, id = 27074, requires = { 27073 } }, -- Scorch
		{ level = 70, id = 27079, requires = { 27078 } }, -- Fire Blast
		{ level = 70, id = 27082, requires = { 27080 } }, -- Arcane Explosion
		{ level = 70, id = 27090, requires = { 37420 } }, -- Conjure Water
		{ level = 70, id = 27126, requires = { 10157 } }, -- Arcane Intellect
		{ level = 70, id = 27127, requires = { 23028 } }, -- Arcane Brilliance
		{ level = 70, id = 32796, requires = { 28609 } }, -- Frost Ward
		{ level = 70, id = 33717, requires = { 28612 } }, -- Conjure Food
		{ level = 70, id = 38692, requires = { 27070 } }, -- Fireball
		{ level = 70, id = 38697, requires = { 27072 } }, -- Frostbolt
		{ level = 70, id = 38704, requires = { 38699 } }, -- Arcane Missiles
		{ level = 70, id = 43987 }, -- Ritual of Refreshment
		{ level = 70, id = 30449 }, -- Spellsteal
	},
	PALADIN = {
		{ level = 1, id = 465 }, -- Devotion Aura
		{ level = 4, id = 19740 }, -- Blessing of Might
		{ level = 4, id = 20271 }, -- Judgement
		{ level = 6, id = 498 }, -- Divine Protection
		{ level = 6, id = 639, requires = { 635 } }, -- Holy Light
		{ level = 6, id = 21082 }, -- Seal of the Crusader
		{ level = 8, id = 853 }, -- Hammer of Justice
		{ level = 8, id = 3127 }, -- Parry
		{ level = 8, id = 1152 }, -- Purify
		{ level = 10, id = 1022 }, -- Blessing of Protection
		{ level = 10, id = 10290, requires = { 465 } }, -- Devotion Aura
		{ level = 10, id = 633 }, -- Lay on Hands
		{ level = 10, id = 20287, requires = { 20154 } }, -- Seal of Righteousness
		{ level = 12, id = 19834, requires = { 19740 } }, -- Blessing of Might
		{ level = 12, id = 20162, requires = { 21082 } }, -- Seal of the Crusader
		{ level = 14, id = 19742 }, -- Blessing of Wisdom
		{ level = 14, id = 647, requires = { 639 } }, -- Holy Light
		{ level = 14, id = 31789 }, -- Righteous Defense
		{ level = 16, id = 7294 }, -- Retribution Aura
		{ level = 16, id = 25780 }, -- Righteous Fury
		{ level = 18, id = 1044 }, -- Blessing of Freedom
		{ level = 18, id = 5573, requires = { 498 } }, -- Divine Protection
		{ level = 18, id = 20288, requires = { 20287 } }, -- Seal of Righteousness
		{ level = 20, id = 20217 }, -- Blessing of Kings
		{ level = 20, id = 26573 }, -- Consecration
		{ level = 20, id = 643, requires = { 10290 } }, -- Devotion Aura
		{ level = 20, id = 879 }, -- Exorcism
		{ level = 20, id = 19750 }, -- Flash of Light
		{ level = 22, id = 19835, requires = { 19834 } }, -- Blessing of Might
		{ level = 22, id = 19746 }, -- Concentration Aura
		{ level = 22, id = 1026, requires = { 647 } }, -- Holy Light
		{ level = 22, id = 20164 }, -- Seal of Justice
		{ level = 22, id = 20305, requires = { 20162 } }, -- Seal of the Crusader
		{ level = 24, id = 5599, requires = { 1022 } }, -- Blessing of Protection
		{ level = 24, id = 19850, requires = { 19742 } }, -- Blessing of Wisdom
		{ level = 24, id = 5588, requires = { 853 } }, -- Hammer of Justice
		{ level = 24, id = 10322, requires = { 7328 } }, -- Redemption
		{ level = 24, id = 2878 }, -- Turn Undead
		{ level = 26, id = 1038 }, -- Blessing of Salvation
		{ level = 26, id = 19939, requires = { 19750 } }, -- Flash of Light
		{ level = 26, id = 10298, requires = { 7294 } }, -- Retribution Aura
		{ level = 26, id = 20289, requires = { 20288 } }, -- Seal of Righteousness
		{ level = 28, id = 5614, requires = { 879 } }, -- Exorcism
		{ level = 28, id = 19876 }, -- Shadow Resistance Aura
		{ level = 30, id = 20116, requires = { 26573 } }, -- Consecration
		{ level = 30, id = 10291, requires = { 643 } }, -- Devotion Aura
		{ level = 30, id = 19752 }, -- Divine Intervention
		{ level = 30, id = 1042, requires = { 1026 } }, -- Holy Light
		{ level = 30, id = 2800, requires = { 633 } }, -- Lay on Hands
		{ level = 30, id = 20375, talent = true }, -- Seal of Command
		{ level = 30, id = 20165 }, -- Seal of Light
		{ level = 32, id = 19836, requires = { 19835 } }, -- Blessing of Might
		{ level = 32, id = 19888 }, -- Frost Resistance Aura
		{ level = 32, id = 20306, requires = { 20305 } }, -- Seal of the Crusader
		{ level = 34, id = 19852, requires = { 19850 } }, -- Blessing of Wisdom
		{ level = 34, id = 642 }, -- Divine Shield
		{ level = 34, id = 19940, requires = { 19939 } }, -- Flash of Light
		{ level = 34, id = 20290, requires = { 20289 } }, -- Seal of Righteousness
		{ level = 36, id = 5615, requires = { 5614 } }, -- Exorcism
		{ level = 36, id = 19891 }, -- Fire Resistance Aura
		{ level = 36, id = 10324, requires = { 10322 } }, -- Redemption
		{ level = 36, id = 10299, requires = { 10298 } }, -- Retribution Aura
		{ level = 38, id = 10278, requires = { 5599 } }, -- Blessing of Protection
		{ level = 38, id = 3472, requires = { 1042 } }, -- Holy Light
		{ level = 38, id = 20166 }, -- Seal of Wisdom
		{ level = 38, id = 5627, requires = { 2878 } }, -- Turn Undead
		{ level = 40, id = 19977 }, -- Blessing of Light
		{ level = 40, id = 20922, requires = { 20116 } }, -- Consecration
		{ level = 40, id = 1032, requires = { 10291 } }, -- Devotion Aura
		{ level = 40, id = 5589, requires = { 5588 } }, -- Hammer of Justice
		{ level = 40, id = 750 }, -- Plate Mail
		{ level = 40, id = 20347, requires = { 20165 } }, -- Seal of Light
		{ level = 40, id = 19895, requires = { 19876 } }, -- Shadow Resistance Aura
		{ level = 40, id = 20911, talent = true }, -- Blessing of Sanctuary
		{ level = 42, id = 19837, requires = { 19836 } }, -- Blessing of Might
		{ level = 42, id = 4987 }, -- Cleanse
		{ level = 42, id = 19941, requires = { 19940 } }, -- Flash of Light
		{ level = 42, id = 20291, requires = { 20290 } }, -- Seal of Righteousness
		{ level = 42, id = 20307, requires = { 20306 } }, -- Seal of the Crusader
		{ level = 44, id = 19853, requires = { 19852 } }, -- Blessing of Wisdom
		{ level = 44, id = 10312, requires = { 5615 } }, -- Exorcism
		{ level = 44, id = 19897, requires = { 19888 } }, -- Frost Resistance Aura
		{ level = 44, id = 24275 }, -- Hammer of Wrath
		{ level = 46, id = 6940 }, -- Blessing of Sacrifice
		{ level = 46, id = 10328, requires = { 3472 } }, -- Holy Light
		{ level = 46, id = 10300, requires = { 10299 } }, -- Retribution Aura
		{ level = 48, id = 19899, requires = { 19891 } }, -- Fire Resistance Aura
		{ level = 48, id = 20772, requires = { 10324 } }, -- Redemption
		{ level = 48, id = 20356, requires = { 20166 } }, -- Seal of Wisdom
		{ level = 48, id = 31895, requires = { 20164 } }, -- Seal of Justice
		{ level = 48, id = 20473, talent = true }, -- Holy Shock
		{ level = 50, id = 19978, requires = { 19977 } }, -- Blessing of Light
		{ level = 50, id = 20923, requires = { 20922 } }, -- Consecration
		{ level = 50, id = 10292, requires = { 1032 } }, -- Devotion Aura
		{ level = 50, id = 1020, requires = { 642 } }, -- Divine Shield
		{ level = 50, id = 19942, requires = { 19941 } }, -- Flash of Light
		{ level = 50, id = 20925, talent = true }, -- Holy Shield
		{ level = 50, id = 2812 }, -- Holy Wrath
		{ level = 50, id = 10310, requires = { 2800 } }, -- Lay on Hands
		{ level = 50, id = 20348, requires = { 20347 } }, -- Seal of Light
		{ level = 50, id = 20292, requires = { 20291 } }, -- Seal of Righteousness
		{ level = 52, id = 19838, requires = { 19837 } }, -- Blessing of Might
		{ level = 52, id = 10313, requires = { 10312 } }, -- Exorcism
		{ level = 52, id = 25782, requires = { 19838 } }, -- Greater Blessing of Might
		{ level = 52, id = 24274, requires = { 24275 } }, -- Hammer of Wrath
		{ level = 52, id = 20308, requires = { 20307 } }, -- Seal of the Crusader
		{ level = 52, id = 19896, requires = { 19895 } }, -- Shadow Resistance Aura
		{ level = 52, id = 10326, requires = { 5627 } }, -- Turn Evil
		{ level = 54, id = 20729, requires = { 6940 } }, -- Blessing of Sacrifice
		{ level = 54, id = 19854, requires = { 19853 } }, -- Blessing of Wisdom
		{ level = 54, id = 25894, requires = { 19854 } }, -- Greater Blessing of Wisdom
		{ level = 54, id = 10308, requires = { 5589 } }, -- Hammer of Justice
		{ level = 54, id = 10329, requires = { 10328 } }, -- Holy Light
		{ level = 56, id = 19898, requires = { 19897 } }, -- Frost Resistance Aura
		{ level = 56, id = 10301, requires = { 10300 } }, -- Retribution Aura
		{ level = 58, id = 19943, requires = { 19942 } }, -- Flash of Light
		{ level = 58, id = 20293, requires = { 20292 } }, -- Seal of Righteousness
		{ level = 58, id = 20357, requires = { 20356 } }, -- Seal of Wisdom
		{ level = 60, id = 19979, requires = { 19978 } }, -- Blessing of Light
		{ level = 60, id = 20924, requires = { 20923 } }, -- Consecration
		{ level = 60, id = 10293, requires = { 10292 } }, -- Devotion Aura
		{ level = 60, id = 10314, requires = { 10313 } }, -- Exorcism
		{ level = 60, id = 19900, requires = { 19899 } }, -- Fire Resistance Aura
		{ level = 60, id = 25898, requires = { 20217 } }, -- Greater Blessing of Kings
		{ level = 60, id = 25890, requires = { 19979 } }, -- Greater Blessing of Light
		{ level = 60, id = 25916, requires = { 19740 } }, -- Greater Blessing of Might
		{ level = 60, id = 25895, requires = { 1038 } }, -- Greater Blessing of Salvation
		{ level = 60, id = 25918, requires = { 19742 } }, -- Greater Blessing of Wisdom
		{ level = 60, id = 24239, requires = { 24274 } }, -- Hammer of Wrath
		{ level = 60, id = 10318, requires = { 2812 } }, -- Holy Wrath
		{ level = 60, id = 20773, requires = { 20772 } }, -- Redemption
		{ level = 60, id = 20349, requires = { 20348 } }, -- Seal of Light
		{ level = 60, id = 25290, requires = { 19854 } }, -- Blessing of Wisdom
		{ level = 60, id = 25291, requires = { 19838 } }, -- Blessing of Might
		{ level = 60, id = 25292, requires = { 10329 } }, -- Holy Light
		{ level = 60, id = 25899 }, -- Greater Blessing of Sanctuary
		{ level = 60, id = 31935, talent = true }, -- Avenger's Shield
		{ level = 61, id = 27158, requires = { 20308 } }, -- Seal of the Crusader
		{ level = 62, id = 27135, requires = { 25292 } }, -- Holy Light
		{ level = 62, id = 27147, requires = { 20729 } }, -- Blessing of Sacrifice
		{ level = 62, id = 32223 }, -- Crusader Aura
		{ level = 63, id = 27151, requires = { 19896 } }, -- Shadow Resistance Aura
		{ level = 64, id = 31801, faction = "Alliance" }, -- Seal of Vengeance
		{ level = 64, id = 31892, faction = "Horde" }, -- Seal of Blood
		{ level = 65, id = 27142, requires = { 25290 } }, -- Blessing of Wisdom
		{ level = 65, id = 27143, requires = { 25918 } }, -- Greater Blessing of Wisdom
		{ level = 66, id = 27137, requires = { 19943 } }, -- Flash of Light
		{ level = 66, id = 27150, requires = { 10301 } }, -- Retribution Aura
		{ level = 66, id = 27155, requires = { 20293 } }, -- Seal of Righteousness
		{ level = 67, id = 27166, requires = { 20357 } }, -- Seal of Wisdom
		{ level = 68, id = 27138, requires = { 10314 } }, -- Exorcism
		{ level = 68, id = 27152, requires = { 19898 } }, -- Frost Resistance Aura
		{ level = 68, id = 27180, requires = { 24239 } }, -- Hammer of Wrath
		{ level = 69, id = 27139, requires = { 10318 } }, -- Holy Wrath
		{ level = 69, id = 27144, requires = { 19979 } }, -- Blessing of Light
		{ level = 69, id = 27145, requires = { 25890 } }, -- Greater Blessing of Light
		{ level = 69, id = 27154, requires = { 10310 } }, -- Lay on Hands
		{ level = 69, id = 27160, requires = { 20349 } }, -- Seal of Light
		{ level = 70, id = 27136, requires = { 27135 } }, -- Holy Light
		{ level = 70, id = 27140, requires = { 25291 } }, -- Blessing of Might
		{ level = 70, id = 27141, requires = { 25916 } }, -- Greater Blessing of Might
		{ level = 70, id = 27148, requires = { 27147 } }, -- Blessing of Sacrifice
		{ level = 70, id = 27149, requires = { 10293 } }, -- Devotion Aura
		{ level = 70, id = 27153, requires = { 19900 } }, -- Fire Resistance Aura
		{ level = 70, id = 27169, requires = { 25899 } }, -- Greater Blessing of Sanctuary
		{ level = 70, id = 27173, requires = { 20924 } }, -- Consecration
		{ level = 70, id = 31884 }, -- Avenging Wrath
		{ level = 70, id = 348700, faction = "Alliance" }, -- Seal of the Martyr
		{ level = 70, id = 348704, faction = "Horde" }, -- Seal of Corruption
	},
	PRIEST = {
		{ level = 1, id = 1243 }, -- Power Word: Fortitude
		{ level = 4, id = 2052, requires = { 2050 } }, -- Lesser Heal
		{ level = 4, id = 589 }, -- Shadow Word: Pain
		{ level = 6, id = 17 }, -- Power Word: Shield
		{ level = 6, id = 591, requires = { 585 } }, -- Smite
		{ level = 8, id = 586 }, -- Fade
		{ level = 8, id = 139 }, -- Renew
		{ level = 10, id = 2053, requires = { 2052 } }, -- Lesser Heal
		{ level = 10, id = 8092 }, -- Mind Blast
		{ level = 10, id = 2006 }, -- Resurrection
		{ level = 10, id = 594, requires = { 589 } }, -- Shadow Word: Pain
		{ level = 10, id = 2652, race = 5 }, -- Touch of Weakness
		{ level = 10, id = 2652, race = 10 }, -- Touch of Weakness
		{ level = 10, id = 9035, race = 8 }, -- Hex of Weakness
		{ level = 10, id = 10797, race = 4 }, -- Starshards
		{ level = 10, id = 13908, race = 1 }, -- Desperate Prayer
		{ level = 10, id = 13908, race = 3 }, -- Desperate Prayer
		{ level = 10, id = 32548, race = 11 }, -- Symbol of Hope
		{ level = 12, id = 588 }, -- Inner Fire
		{ level = 12, id = 1244, requires = { 1243 } }, -- Power Word: Fortitude
		{ level = 12, id = 592, requires = { 17 } }, -- Power Word: Shield
		{ level = 14, id = 528 }, -- Cure Disease
		{ level = 14, id = 8122 }, -- Psychic Scream
		{ level = 14, id = 6074, requires = { 139 } }, -- Renew
		{ level = 14, id = 598, requires = { 591 } }, -- Smite
		{ level = 16, id = 2054 }, -- Heal
		{ level = 16, id = 8102, requires = { 8092 } }, -- Mind Blast
		{ level = 18, id = 527 }, -- Dispel Magic
		{ level = 18, id = 600, requires = { 592 } }, -- Power Word: Shield
		{ level = 18, id = 970, requires = { 594 } }, -- Shadow Word: Pain
		{ level = 18, id = 19236, requires = { 13908 }, race = 3 }, -- Desperate Prayer
		{ level = 18, id = 19296, requires = { 10797 }, race = 4 }, -- Starshards
		{ level = 18, id = 19236, requires = { 13908 }, race = 1 }, -- Desperate Prayer
		{ level = 20, id = 2944, race = 5 }, -- Devouring Plague
		{ level = 20, id = 9578, requires = { 586 } }, -- Fade
		{ level = 20, id = 6346 }, -- Fear Ward
		{ level = 20, id = 2061 }, -- Flash Heal
		{ level = 20, id = 14914 }, -- Holy Fire
		{ level = 20, id = 7128, requires = { 588 } }, -- Inner Fire
		{ level = 20, id = 453 }, -- Mind Soothe
		{ level = 20, id = 6075, requires = { 6074 } }, -- Renew
		{ level = 20, id = 9484 }, -- Shackle Undead
		{ level = 20, id = 19261, requires = { 2652 }, race = 5 }, -- Touch of Weakness
		{ level = 20, id = 19281, requires = { 9035 }, race = 8 }, -- Hex of Weakness
		{ level = 20, id = 19261, requires = { 2652 }, race = 10 }, -- Touch of Weakness
		{ level = 20, id = 2651, race = 4 }, -- Elune's Grace
		{ level = 20, id = 13896, race = 1 }, -- Feedback
		{ level = 20, id = 18137, race = 8 }, -- Shadowguard
		{ level = 20, id = 32676, race = 10 }, -- Consume Magic
		{ level = 20, id = 44041, race = 3 }, -- Chastise
		{ level = 20, id = 44041, race = 11 }, -- Chastise
		{ level = 22, id = 2055, requires = { 2054 } }, -- Heal
		{ level = 22, id = 8103, requires = { 8102 } }, -- Mind Blast
		{ level = 22, id = 2096 }, -- Mind Vision
		{ level = 22, id = 2010, requires = { 2006 } }, -- Resurrection
		{ level = 22, id = 984, requires = { 598 } }, -- Smite
		{ level = 24, id = 15262, requires = { 14914 } }, -- Holy Fire
		{ level = 24, id = 8129 }, -- Mana Burn
		{ level = 24, id = 1245, requires = { 1244 } }, -- Power Word: Fortitude
		{ level = 24, id = 3747, requires = { 600 } }, -- Power Word: Shield
		{ level = 26, id = 9472, requires = { 2061 } }, -- Flash Heal
		{ level = 26, id = 6076, requires = { 6075 } }, -- Renew
		{ level = 26, id = 992, requires = { 970 } }, -- Shadow Word: Pain
		{ level = 26, id = 19238, requires = { 19236 }, race = 3 }, -- Desperate Prayer
		{ level = 26, id = 19299, requires = { 19296 }, race = 4 }, -- Starshards
		{ level = 26, id = 19238, requires = { 19236 }, race = 1 }, -- Desperate Prayer
		{ level = 28, id = 19276, requires = { 2944 }, race = 5 }, -- Devouring Plague
		{ level = 28, id = 6063, requires = { 2055 } }, -- Heal
		{ level = 28, id = 15237, talent = true }, -- Holy Nova
		{ level = 28, id = 8104, requires = { 8103 } }, -- Mind Blast
		{ level = 28, id = 15407, talent = true }, -- Mind Flay
		{ level = 28, id = 8124, requires = { 8122 } }, -- Psychic Scream
		{ level = 28, id = 19308, requires = { 18137 }, race = 8 }, -- Shadowguard
		{ level = 30, id = 14752 }, -- Divine Spirit
		{ level = 30, id = 9579, requires = { 9578 } }, -- Fade
		{ level = 30, id = 19271, requires = { 13896 }, race = 1 }, -- Feedback
		{ level = 30, id = 15263, requires = { 15262 } }, -- Holy Fire
		{ level = 30, id = 602, requires = { 7128 } }, -- Inner Fire
		{ level = 30, id = 605 }, -- Mind Control
		{ level = 30, id = 6065, requires = { 3747 } }, -- Power Word: Shield
		{ level = 30, id = 596 }, -- Prayer of Healing
		{ level = 30, id = 976 }, -- Shadow Protection
		{ level = 30, id = 1004, requires = { 984 } }, -- Smite
		{ level = 30, id = 19262, requires = { 19261 }, race = 5 }, -- Touch of Weakness
		{ level = 30, id = 19282, requires = { 19281 }, race = 8 }, -- Hex of Weakness
		{ level = 30, id = 19262, requires = { 19261 }, race = 10 }, -- Touch of Weakness
		{ level = 30, id = 44043, requires = { 44041 }, race = 3 }, -- Chastise
		{ level = 30, id = 44043, requires = { 44041 }, race = 11 }, -- Chastise
		{ level = 32, id = 552 }, -- Abolish Disease
		{ level = 32, id = 9473, requires = { 9472 } }, -- Flash Heal
		{ level = 32, id = 8131, requires = { 8129 } }, -- Mana Burn
		{ level = 32, id = 6077, requires = { 6076 } }, -- Renew
		{ level = 34, id = 6064, requires = { 6063 } }, -- Heal
		{ level = 34, id = 1706 }, -- Levitate
		{ level = 34, id = 8105, requires = { 8104 } }, -- Mind Blast
		{ level = 34, id = 10880, requires = { 2010 } }, -- Resurrection
		{ level = 34, id = 2767, requires = { 992 } }, -- Shadow Word: Pain
		{ level = 34, id = 19240, requires = { 19238 }, race = 3 }, -- Desperate Prayer
		{ level = 34, id = 19302, requires = { 19299 }, race = 4 }, -- Starshards
		{ level = 34, id = 19240, requires = { 19238 }, race = 1 }, -- Desperate Prayer
		{ level = 36, id = 19277, requires = { 19276 }, race = 5 }, -- Devouring Plague
		{ level = 36, id = 988, requires = { 527 } }, -- Dispel Magic
		{ level = 36, id = 15264, requires = { 15263 } }, -- Holy Fire
		{ level = 36, id = 8192, requires = { 453 } }, -- Mind Soothe
		{ level = 36, id = 2791, requires = { 1245 } }, -- Power Word: Fortitude
		{ level = 36, id = 6066, requires = { 6065 } }, -- Power Word: Shield
		{ level = 36, id = 19309, requires = { 19308 }, race = 8 }, -- Shadowguard
		{ level = 38, id = 9474, requires = { 9473 } }, -- Flash Heal
		{ level = 38, id = 6078, requires = { 6077 } }, -- Renew
		{ level = 38, id = 6060, requires = { 1004 } }, -- Smite
		{ level = 40, id = 14818, requires = { 14752 } }, -- Divine Spirit
		{ level = 40, id = 9592, requires = { 9579 } }, -- Fade
		{ level = 40, id = 19273, requires = { 19271 }, race = 1 }, -- Feedback
		{ level = 40, id = 2060 }, -- Greater Heal
		{ level = 40, id = 1006, requires = { 602 } }, -- Inner Fire
		{ level = 40, id = 10874, requires = { 8131 } }, -- Mana Burn
		{ level = 40, id = 8106, requires = { 8105 } }, -- Mind Blast
		{ level = 40, id = 996, requires = { 596 } }, -- Prayer of Healing
		{ level = 40, id = 9485, requires = { 9484 } }, -- Shackle Undead
		{ level = 40, id = 19264, requires = { 19262 }, race = 5 }, -- Touch of Weakness
		{ level = 40, id = 19283, requires = { 19282 }, race = 8 }, -- Hex of Weakness
		{ level = 40, id = 19264, requires = { 19262 }, race = 10 }, -- Touch of Weakness
		{ level = 40, id = 44044, requires = { 44043 }, race = 3 }, -- Chastise
		{ level = 40, id = 44044, requires = { 44043 }, race = 11 }, -- Chastise
		{ level = 42, id = 15265, requires = { 15264 } }, -- Holy Fire
		{ level = 42, id = 10898, requires = { 6066 } }, -- Power Word: Shield
		{ level = 42, id = 10888, requires = { 8124 } }, -- Psychic Scream
		{ level = 42, id = 10957, requires = { 976 } }, -- Shadow Protection
		{ level = 42, id = 10892, requires = { 2767 } }, -- Shadow Word: Pain
		{ level = 42, id = 19241, requires = { 19240 }, race = 3 }, -- Desperate Prayer
		{ level = 42, id = 19303, requires = { 19302 }, race = 4 }, -- Starshards
		{ level = 42, id = 19241, requires = { 19240 }, race = 1 }, -- Desperate Prayer
		{ level = 44, id = 19278, requires = { 19277 }, race = 5 }, -- Devouring Plague
		{ level = 44, id = 10915, requires = { 9474 } }, -- Flash Heal
		{ level = 44, id = 10911, requires = { 605 } }, -- Mind Control
		{ level = 44, id = 10909, requires = { 2096 } }, -- Mind Vision
		{ level = 44, id = 10927, requires = { 6078 } }, -- Renew
		{ level = 44, id = 19310, requires = { 19309 }, race = 8 }, -- Shadowguard
		{ level = 46, id = 10963, requires = { 2060 } }, -- Greater Heal
		{ level = 46, id = 10945, requires = { 8106 } }, -- Mind Blast
		{ level = 46, id = 10881, requires = { 10880 } }, -- Resurrection
		{ level = 46, id = 10933, requires = { 6060 } }, -- Smite
		{ level = 48, id = 15266, requires = { 15265 } }, -- Holy Fire
		{ level = 48, id = 10875, requires = { 10874 } }, -- Mana Burn
		{ level = 48, id = 10937, requires = { 2791 } }, -- Power Word: Fortitude
		{ level = 48, id = 10899, requires = { 10898 } }, -- Power Word: Shield
		{ level = 48, id = 21562 }, -- Prayer of Fortitude
		{ level = 50, id = 14819, requires = { 14818 } }, -- Divine Spirit
		{ level = 50, id = 10941, requires = { 9592 } }, -- Fade
		{ level = 50, id = 19274, requires = { 19273 }, race = 1 }, -- Feedback
		{ level = 50, id = 10916, requires = { 10915 } }, -- Flash Heal
		{ level = 50, id = 10951, requires = { 1006 } }, -- Inner Fire
		{ level = 50, id = 10960, requires = { 996 } }, -- Prayer of Healing
		{ level = 50, id = 10928, requires = { 10927 } }, -- Renew
		{ level = 50, id = 10893, requires = { 10892 } }, -- Shadow Word: Pain
		{ level = 50, id = 19242, requires = { 19241 }, race = 3 }, -- Desperate Prayer
		{ level = 50, id = 19265, requires = { 19264 }, race = 5 }, -- Touch of Weakness
		{ level = 50, id = 19284, requires = { 19283 }, race = 8 }, -- Hex of Weakness
		{ level = 50, id = 19304, requires = { 19303 }, race = 4 }, -- Starshards
		{ level = 50, id = 19242, requires = { 19241 }, race = 1 }, -- Desperate Prayer
		{ level = 50, id = 19265, requires = { 19264 }, race = 10 }, -- Touch of Weakness
		{ level = 50, id = 44045, requires = { 44044 }, race = 3 }, -- Chastise
		{ level = 50, id = 44045, requires = { 44044 }, race = 11 }, -- Chastise
		{ level = 50, id = 724, talent = true }, -- Lightwell
		{ level = 52, id = 19279, requires = { 19278 }, race = 5 }, -- Devouring Plague
		{ level = 52, id = 10964, requires = { 10963 } }, -- Greater Heal
		{ level = 52, id = 10946, requires = { 10945 } }, -- Mind Blast
		{ level = 52, id = 10953, requires = { 8192 } }, -- Mind Soothe
		{ level = 52, id = 19311, requires = { 19310 }, race = 8 }, -- Shadowguard
		{ level = 54, id = 15267, requires = { 15266 } }, -- Holy Fire
		{ level = 54, id = 10900, requires = { 10899 } }, -- Power Word: Shield
		{ level = 54, id = 10934, requires = { 10933 } }, -- Smite
		{ level = 56, id = 10917, requires = { 10916 } }, -- Flash Heal
		{ level = 56, id = 10876, requires = { 10875 } }, -- Mana Burn
		{ level = 56, id = 10890, requires = { 10888 } }, -- Psychic Scream
		{ level = 56, id = 10929, requires = { 10928 } }, -- Renew
		{ level = 56, id = 10958, requires = { 10957 } }, -- Shadow Protection
		{ level = 56, id = 27683 }, -- Prayer of Shadow Protection
		{ level = 56, id = 34861, talent = true }, -- Circle of Healing
		{ level = 58, id = 10965, requires = { 10964 } }, -- Greater Heal
		{ level = 58, id = 10947, requires = { 10946 } }, -- Mind Blast
		{ level = 58, id = 10912, requires = { 10911 } }, -- Mind Control
		{ level = 58, id = 20770, requires = { 10881 } }, -- Resurrection
		{ level = 58, id = 10894, requires = { 10893 } }, -- Shadow Word: Pain
		{ level = 58, id = 19243, requires = { 19242 }, race = 3 }, -- Desperate Prayer
		{ level = 58, id = 19305, requires = { 19304 }, race = 4 }, -- Starshards
		{ level = 58, id = 19243, requires = { 19242 }, race = 1 }, -- Desperate Prayer
		{ level = 60, id = 19280, requires = { 19279 }, race = 5 }, -- Devouring Plague
		{ level = 60, id = 27841, requires = { 14819 } }, -- Divine Spirit
		{ level = 60, id = 10942, requires = { 10941 } }, -- Fade
		{ level = 60, id = 19275, requires = { 19274 }, race = 1 }, -- Feedback
		{ level = 60, id = 15261, requires = { 15267 } }, -- Holy Fire
		{ level = 60, id = 10952, requires = { 10951 } }, -- Inner Fire
		{ level = 60, id = 10938, requires = { 10937 } }, -- Power Word: Fortitude
		{ level = 60, id = 10901, requires = { 10900 } }, -- Power Word: Shield
		{ level = 60, id = 10961, requires = { 10960 } }, -- Prayer of Healing
		{ level = 60, id = 27681, requires = { 27841 } }, -- Prayer of Spirit
		{ level = 60, id = 10955, requires = { 9485 } }, -- Shackle Undead
		{ level = 60, id = 19266, requires = { 19265 }, race = 5 }, -- Touch of Weakness
		{ level = 60, id = 19285, requires = { 19284 }, race = 8 }, -- Hex of Weakness
		{ level = 60, id = 19312, requires = { 19311 }, race = 8 }, -- Shadowguard
		{ level = 60, id = 19266, requires = { 19265 }, race = 10 }, -- Touch of Weakness
		{ level = 60, id = 21564, requires = { 21562 } }, -- Prayer of Fortitude
		{ level = 60, id = 25314, requires = { 10965 } }, -- Greater Heal
		{ level = 60, id = 25315, requires = { 10929 } }, -- Renew
		{ level = 60, id = 25316, requires = { 10961 } }, -- Prayer of Healing
		{ level = 60, id = 44046, requires = { 44045 }, race = 3 }, -- Chastise
		{ level = 60, id = 44046, requires = { 44045 }, race = 11 }, -- Chastise
		{ level = 60, id = 34914, talent = true }, -- Vampiric Touch
		{ level = 61, id = 25233, requires = { 10917 } }, -- Flash Heal
		{ level = 61, id = 25363, requires = { 10934 } }, -- Smite
		{ level = 62, id = 32379 }, -- Shadow Word: Death
		{ level = 63, id = 25210, requires = { 25314 } }, -- Greater Heal
		{ level = 63, id = 25372, requires = { 10947 } }, -- Mind Blast
		{ level = 63, id = 25379, requires = { 10876 } }, -- Mana Burn
		{ level = 64, id = 32546 }, -- Binding Heal
		{ level = 65, id = 25217, requires = { 10901 } }, -- Power Word: Shield
		{ level = 65, id = 25221, requires = { 25315 } }, -- Renew
		{ level = 65, id = 25367, requires = { 10894 } }, -- Shadow Word: Pain
		{ level = 66, id = 25384, requires = { 15261 } }, -- Holy Fire
		{ level = 66, id = 25429, requires = { 10942 } }, -- Fade
		{ level = 66, id = 25437, requires = { 19243 }, race = 1 }, -- Desperate Prayer
		{ level = 66, id = 25437, requires = { 19243 }, race = 3 }, -- Desperate Prayer
		{ level = 66, id = 25446, requires = { 19305 }, race = 4 }, -- Starshards
		{ level = 66, id = 34433 }, -- Shadowfiend
		{ level = 67, id = 25235, requires = { 25233 } }, -- Flash Heal
		{ level = 67, id = 25596, requires = { 10953 } }, -- Mind Soothe
		{ level = 68, id = 25213, requires = { 25210 } }, -- Greater Heal
		{ level = 68, id = 25308, requires = { 25316 } }, -- Prayer of Healing
		{ level = 68, id = 25433, requires = { 10958 } }, -- Shadow Protection
		{ level = 68, id = 25435, requires = { 20770 } }, -- Resurrection
		{ level = 68, id = 25467, requires = { 19280 }, race = 5 }, -- Devouring Plague
		{ level = 68, id = 25477, requires = { 19312 }, race = 8 }, -- Shadowguard
		{ level = 68, id = 33076 }, -- Prayer of Mending
		{ level = 69, id = 25364, requires = { 25363 } }, -- Smite
		{ level = 69, id = 25375, requires = { 25372 } }, -- Mind Blast
		{ level = 69, id = 25431, requires = { 10952 } }, -- Inner Fire
		{ level = 70, id = 25218, requires = { 25217 } }, -- Power Word: Shield
		{ level = 70, id = 25222, requires = { 25221 } }, -- Renew
		{ level = 70, id = 25368, requires = { 25367 } }, -- Shadow Word: Pain
		{ level = 70, id = 25380, requires = { 25379 } }, -- Mana Burn
		{ level = 70, id = 25389, requires = { 10938 } }, -- Power Word: Fortitude
		{ level = 70, id = 25392, requires = { 21564 } }, -- Prayer of Fortitude
		{ level = 70, id = 25441, requires = { 19275 }, race = 1 }, -- Feedback
		{ level = 70, id = 25461, requires = { 19266 }, race = 5 }, -- Touch of Weakness
		{ level = 70, id = 25461, requires = { 19266 }, race = 10 }, -- Touch of Weakness
		{ level = 70, id = 25470, requires = { 19285 }, race = 8 }, -- Hex of Weakness
		{ level = 70, id = 32375 }, -- Mass Dispel
		{ level = 70, id = 32996, requires = { 32379 } }, -- Shadow Word: Death
		{ level = 70, id = 32999, requires = { 27681 } }, -- Prayer of Spirit
		{ level = 70, id = 39374, requires = { 27683 } }, -- Prayer of Shadow Protection
		{ level = 70, id = 44047, requires = { 44046 }, race = 3 }, -- Chastise
		{ level = 70, id = 44047, requires = { 44046 }, race = 11 }, -- Chastise
	},
	ROGUE = {
		{ level = 1, id = 1784 }, -- Stealth
		{ level = 4, id = 53 }, -- Backstab
		{ level = 4, id = 921 }, -- Pick Pocket
		{ level = 6, id = 1776 }, -- Gouge
		{ level = 6, id = 1757, requires = { 1752 } }, -- Sinister Strike
		{ level = 8, id = 5277 }, -- Evasion
		{ level = 8, id = 6760, requires = { 2098 } }, -- Eviscerate
		{ level = 10, id = 674 }, -- Dual Wield
		{ level = 10, id = 6770 }, -- Sap
		{ level = 10, id = 5171 }, -- Slice and Dice
		{ level = 10, id = 2983 }, -- Sprint
		{ level = 12, id = 2589, requires = { 53 } }, -- Backstab
		{ level = 12, id = 1766 }, -- Kick
		{ level = 12, id = 3127 }, -- Parry
		{ level = 14, id = 8647 }, -- Expose Armor
		{ level = 14, id = 703 }, -- Garrote
		{ level = 14, id = 1758, requires = { 1757 } }, -- Sinister Strike
		{ level = 16, id = 6761, requires = { 6760 } }, -- Eviscerate
		{ level = 16, id = 1966 }, -- Feint
		{ level = 16, id = 1804 }, -- Pick Lock
		{ level = 18, id = 8676 }, -- Ambush
		{ level = 18, id = 1777, requires = { 1776 } }, -- Gouge
		{ level = 20, id = 2590, requires = { 2589 } }, -- Backstab
		{ level = 20, id = 1943 }, -- Rupture
		{ level = 20, id = 1785, requires = { 1784 } }, -- Stealth
		{ level = 22, id = 1725 }, -- Distract
		{ level = 22, id = 8631, requires = { 703 } }, -- Garrote
		{ level = 22, id = 1759, requires = { 1758 } }, -- Sinister Strike
		{ level = 22, id = 1856 }, -- Vanish
		{ level = 24, id = 2836 }, -- Detect Traps
		{ level = 24, id = 6762, requires = { 6761 } }, -- Eviscerate
		{ level = 26, id = 8724, requires = { 8676 } }, -- Ambush
		{ level = 26, id = 1833 }, -- Cheap Shot
		{ level = 26, id = 8649, requires = { 8647 } }, -- Expose Armor
		{ level = 26, id = 1767, requires = { 1766 } }, -- Kick
		{ level = 28, id = 2591, requires = { 2590 } }, -- Backstab
		{ level = 28, id = 6768, requires = { 1966 } }, -- Feint
		{ level = 28, id = 8639, requires = { 1943 } }, -- Rupture
		{ level = 28, id = 2070, requires = { 6770 } }, -- Sap
		{ level = 30, id = 1842, requires = { 2836 } }, -- Disarm Trap
		{ level = 30, id = 8632, requires = { 8631 } }, -- Garrote
		{ level = 30, id = 408 }, -- Kidney Shot
		{ level = 30, id = 1760, requires = { 1759 } }, -- Sinister Strike
		{ level = 32, id = 8623, requires = { 6762 } }, -- Eviscerate
		{ level = 32, id = 8629, requires = { 1777 } }, -- Gouge
		{ level = 34, id = 8725, requires = { 8724 } }, -- Ambush
		{ level = 34, id = 8696, requires = { 2983 } }, -- Sprint
		{ level = 34, id = 2094 }, -- Blind
		{ level = 36, id = 8721, requires = { 2591 } }, -- Backstab
		{ level = 36, id = 8650, requires = { 8649 } }, -- Expose Armor
		{ level = 36, id = 8640, requires = { 8639 } }, -- Rupture
		{ level = 38, id = 8633, requires = { 8632 } }, -- Garrote
		{ level = 38, id = 8621, requires = { 1760 } }, -- Sinister Strike
		{ level = 40, id = 8624, requires = { 8623 } }, -- Eviscerate
		{ level = 40, id = 8637, requires = { 6768 } }, -- Feint
		{ level = 40, id = 1860 }, -- Safe Fall
		{ level = 40, id = 1786, requires = { 1785 } }, -- Stealth
		{ level = 42, id = 11267, requires = { 8725 } }, -- Ambush
		{ level = 42, id = 1768, requires = { 1767 } }, -- Kick
		{ level = 42, id = 6774, requires = { 5171 } }, -- Slice and Dice
		{ level = 42, id = 1857, requires = { 1856 } }, -- Vanish
		{ level = 44, id = 11279, requires = { 8721 } }, -- Backstab
		{ level = 44, id = 11273, requires = { 8640 } }, -- Rupture
		{ level = 46, id = 11197, requires = { 8650 } }, -- Expose Armor
		{ level = 46, id = 11289, requires = { 8633 } }, -- Garrote
		{ level = 46, id = 11285, requires = { 8629 } }, -- Gouge
		{ level = 46, id = 11293, requires = { 8621 } }, -- Sinister Strike
		{ level = 46, id = 16511, talent = true }, -- Hemorrhage
		{ level = 48, id = 11299, requires = { 8624 } }, -- Eviscerate
		{ level = 48, id = 11297, requires = { 2070 } }, -- Sap
		{ level = 50, id = 11268, requires = { 11267 } }, -- Ambush
		{ level = 50, id = 8643, requires = { 408 } }, -- Kidney Shot
		{ level = 50, id = 26669, requires = { 5277 } }, -- Evasion
		{ level = 50, id = 1329, talent = true }, -- Mutilate
		{ level = 52, id = 11280, requires = { 11279 } }, -- Backstab
		{ level = 52, id = 11303, requires = { 8637 } }, -- Feint
		{ level = 52, id = 11274, requires = { 11273 } }, -- Rupture
		{ level = 54, id = 11290, requires = { 11289 } }, -- Garrote
		{ level = 54, id = 11294, requires = { 11293 } }, -- Sinister Strike
		{ level = 56, id = 11300, requires = { 11299 } }, -- Eviscerate
		{ level = 56, id = 11198, requires = { 11197 } }, -- Expose Armor
		{ level = 58, id = 11269, requires = { 11268 } }, -- Ambush
		{ level = 58, id = 1769, requires = { 1768 } }, -- Kick
		{ level = 58, id = 11305, requires = { 8696 } }, -- Sprint
		{ level = 60, id = 11281, requires = { 11280 } }, -- Backstab
		{ level = 60, id = 11286, requires = { 11285 } }, -- Gouge
		{ level = 60, id = 11275, requires = { 11274 } }, -- Rupture
		{ level = 60, id = 1787, requires = { 1786 } }, -- Stealth
		{ level = 60, id = 25300, requires = { 11281 } }, -- Backstab
		{ level = 60, id = 25302, requires = { 11303 } }, -- Feint
		{ level = 60, id = 31016, requires = { 11300 } }, -- Eviscerate
		{ level = 61, id = 26839, requires = { 11290 } }, -- Garrote
		{ level = 62, id = 26861, requires = { 11294 } }, -- Sinister Strike
		{ level = 62, id = 26889, requires = { 1857 } }, -- Vanish
		{ level = 62, id = 32645 }, -- Envenom
		{ level = 64, id = 26679 }, -- Deadly Throw
		{ level = 64, id = 26865, requires = { 31016 } }, -- Eviscerate
		{ level = 64, id = 27448, requires = { 25302 } }, -- Feint
		{ level = 66, id = 26866, requires = { 11198 } }, -- Expose Armor
		{ level = 66, id = 27441, requires = { 11269 } }, -- Ambush
		{ level = 66, id = 31224 }, -- Cloak of Shadows
		{ level = 67, id = 38764, requires = { 11286 } }, -- Gouge
		{ level = 68, id = 26863, requires = { 25300 } }, -- Backstab
		{ level = 68, id = 26867, requires = { 11275 } }, -- Rupture
		{ level = 69, id = 32684, requires = { 32645 } }, -- Envenom
		{ level = 69, id = 38768, requires = { 1769 } }, -- Kick
		{ level = 70, id = 5938 }, -- Shiv
		{ level = 70, id = 26862, requires = { 26861 } }, -- Sinister Strike
		{ level = 70, id = 26884, requires = { 26839 } }, -- Garrote
	},
	SHAMAN = {
		{ level = 1, id = 8017 }, -- Rockbiter Weapon
		{ level = 4, id = 8042 }, -- Earth Shock
		{ level = 6, id = 2484 }, -- Earthbind Totem
		{ level = 6, id = 332, requires = { 331 } }, -- Healing Wave
		{ level = 8, id = 8044, requires = { 8042 } }, -- Earth Shock
		{ level = 8, id = 529, requires = { 403 } }, -- Lightning Bolt
		{ level = 8, id = 324 }, -- Lightning Shield
		{ level = 8, id = 8018, requires = { 8017 } }, -- Rockbiter Weapon
		{ level = 8, id = 5730 }, -- Stoneclaw Totem
		{ level = 10, id = 8050 }, -- Flame Shock
		{ level = 10, id = 8024 }, -- Flametongue Weapon
		{ level = 10, id = 8075 }, -- Strength of Earth Totem
		{ level = 12, id = 2008 }, -- Ancestral Spirit
		{ level = 12, id = 547, requires = { 332 } }, -- Healing Wave
		{ level = 12, id = 370 }, -- Purge
		{ level = 12, id = 1535 }, -- Fire Nova Totem
		{ level = 14, id = 8045, requires = { 8044 } }, -- Earth Shock
		{ level = 14, id = 548, requires = { 529 } }, -- Lightning Bolt
		{ level = 14, id = 8154, requires = { 8071 } }, -- Stoneskin Totem
		{ level = 16, id = 526 }, -- Cure Poison
		{ level = 16, id = 325, requires = { 324 } }, -- Lightning Shield
		{ level = 16, id = 8019, requires = { 8018 } }, -- Rockbiter Weapon
		{ level = 18, id = 8052, requires = { 8050 } }, -- Flame Shock
		{ level = 18, id = 8027, requires = { 8024 } }, -- Flametongue Weapon
		{ level = 18, id = 913, requires = { 547 } }, -- Healing Wave
		{ level = 18, id = 6390, requires = { 5730 } }, -- Stoneclaw Totem
		{ level = 18, id = 8143 }, -- Tremor Totem
		{ level = 20, id = 8056 }, -- Frost Shock
		{ level = 20, id = 8033 }, -- Frostbrand Weapon
		{ level = 20, id = 2645 }, -- Ghost Wolf
		{ level = 20, id = 8004 }, -- Lesser Healing Wave
		{ level = 20, id = 915, requires = { 548 } }, -- Lightning Bolt
		{ level = 20, id = 6363, requires = { 3599 } }, -- Searing Totem
		{ level = 22, id = 2870 }, -- Cure Disease
		{ level = 22, id = 8166 }, -- Poison Cleansing Totem
		{ level = 22, id = 131 }, -- Water Breathing
		{ level = 22, id = 8498, requires = { 1535 } }, -- Fire Nova Totem
		{ level = 24, id = 20609, requires = { 2008 } }, -- Ancestral Spirit
		{ level = 24, id = 8046, requires = { 8045 } }, -- Earth Shock
		{ level = 24, id = 8181 }, -- Frost Resistance Totem
		{ level = 24, id = 939, requires = { 913 } }, -- Healing Wave
		{ level = 24, id = 905, requires = { 325 } }, -- Lightning Shield
		{ level = 24, id = 10399, requires = { 8019 } }, -- Rockbiter Weapon
		{ level = 24, id = 8155, requires = { 8154 } }, -- Stoneskin Totem
		{ level = 24, id = 8160, requires = { 8075 } }, -- Strength of Earth Totem
		{ level = 26, id = 6196 }, -- Far Sight
		{ level = 26, id = 8030, requires = { 8027 } }, -- Flametongue Weapon
		{ level = 26, id = 943, requires = { 915 } }, -- Lightning Bolt
		{ level = 26, id = 8190 }, -- Magma Totem
		{ level = 26, id = 5675 }, -- Mana Spring Totem
		{ level = 28, id = 8184 }, -- Fire Resistance Totem
		{ level = 28, id = 8053, requires = { 8052 } }, -- Flame Shock
		{ level = 28, id = 8227 }, -- Flametongue Totem
		{ level = 28, id = 8038, requires = { 8033 } }, -- Frostbrand Weapon
		{ level = 28, id = 8008, requires = { 8004 } }, -- Lesser Healing Wave
		{ level = 28, id = 6391, requires = { 6390 } }, -- Stoneclaw Totem
		{ level = 28, id = 546 }, -- Water Walking
		{ level = 30, id = 36936 }, -- Totemic Call
		{ level = 30, id = 556 }, -- Astral Recall
		{ level = 30, id = 8177 }, -- Grounding Totem
		{ level = 30, id = 6375, requires = { 5394 } }, -- Healing Stream Totem
		{ level = 30, id = 10595 }, -- Nature Resistance Totem
		{ level = 30, id = 20608 }, -- Reincarnation
		{ level = 30, id = 6364, requires = { 6363 } }, -- Searing Totem
		{ level = 30, id = 8232 }, -- Windfury Weapon
		{ level = 32, id = 421 }, -- Chain Lightning
		{ level = 32, id = 959, requires = { 939 } }, -- Healing Wave
		{ level = 32, id = 6041, requires = { 943 } }, -- Lightning Bolt
		{ level = 32, id = 945, requires = { 905 } }, -- Lightning Shield
		{ level = 32, id = 8012, requires = { 370 } }, -- Purge
		{ level = 32, id = 8512 }, -- Windfury Totem
		{ level = 32, id = 8499, requires = { 8498 } }, -- Fire Nova Totem
		{ level = 34, id = 8058, requires = { 8056 } }, -- Frost Shock
		{ level = 34, id = 16314, requires = { 10399 } }, -- Rockbiter Weapon
		{ level = 34, id = 6495 }, -- Sentry Totem
		{ level = 34, id = 10406, requires = { 8155 } }, -- Stoneskin Totem
		{ level = 36, id = 20610, requires = { 20609 } }, -- Ancestral Spirit
		{ level = 36, id = 10412, requires = { 8046 } }, -- Earth Shock
		{ level = 36, id = 16339, requires = { 8030 } }, -- Flametongue Weapon
		{ level = 36, id = 8010, requires = { 8008 } }, -- Lesser Healing Wave
		{ level = 36, id = 10585, requires = { 8190 } }, -- Magma Totem
		{ level = 36, id = 10495, requires = { 5675 } }, -- Mana Spring Totem
		{ level = 36, id = 15107 }, -- Windwall Totem
		{ level = 38, id = 8170 }, -- Disease Cleansing Totem
		{ level = 38, id = 8249, requires = { 8227 } }, -- Flametongue Totem
		{ level = 38, id = 10478, requires = { 8181 } }, -- Frost Resistance Totem
		{ level = 38, id = 10456, requires = { 8038 } }, -- Frostbrand Weapon
		{ level = 38, id = 10391, requires = { 6041 } }, -- Lightning Bolt
		{ level = 38, id = 6392, requires = { 6391 } }, -- Stoneclaw Totem
		{ level = 38, id = 8161, requires = { 8160 } }, -- Strength of Earth Totem
		{ level = 40, id = 1064 }, -- Chain Heal
		{ level = 40, id = 930, requires = { 421 } }, -- Chain Lightning
		{ level = 40, id = 10447, requires = { 8053 } }, -- Flame Shock
		{ level = 40, id = 6377, requires = { 6375 } }, -- Healing Stream Totem
		{ level = 40, id = 8005, requires = { 959 } }, -- Healing Wave
		{ level = 40, id = 8134, requires = { 945 } }, -- Lightning Shield
		{ level = 40, id = 8737 }, -- Mail
		{ level = 40, id = 6365, requires = { 6364 } }, -- Searing Totem
		{ level = 40, id = 8235, requires = { 8232 } }, -- Windfury Weapon
		{ level = 42, id = 10537, requires = { 8184 } }, -- Fire Resistance Totem
		{ level = 42, id = 8835 }, -- Grace of Air Totem
		{ level = 42, id = 10613, requires = { 8512 } }, -- Windfury Totem
		{ level = 42, id = 11314, requires = { 8499 } }, -- Fire Nova Totem
		{ level = 44, id = 10466, requires = { 8010 } }, -- Lesser Healing Wave
		{ level = 44, id = 10392, requires = { 10391 } }, -- Lightning Bolt
		{ level = 44, id = 10600, requires = { 10595 } }, -- Nature Resistance Totem
		{ level = 44, id = 16315, requires = { 16314 } }, -- Rockbiter Weapon
		{ level = 44, id = 10407, requires = { 10406 } }, -- Stoneskin Totem
		{ level = 46, id = 10622, requires = { 1064 } }, -- Chain Heal
		{ level = 46, id = 16341, requires = { 16339 } }, -- Flametongue Weapon
		{ level = 46, id = 10472, requires = { 8058 } }, -- Frost Shock
		{ level = 46, id = 10586, requires = { 10585 } }, -- Magma Totem
		{ level = 46, id = 10496, requires = { 10495 } }, -- Mana Spring Totem
		{ level = 46, id = 15111, requires = { 15107 } }, -- Windwall Totem
		{ level = 48, id = 20776, requires = { 20610 } }, -- Ancestral Spirit
		{ level = 48, id = 2860, requires = { 930 } }, -- Chain Lightning
		{ level = 48, id = 10413, requires = { 10412 } }, -- Earth Shock
		{ level = 48, id = 10526, requires = { 8249 } }, -- Flametongue Totem
		{ level = 48, id = 16355, requires = { 10456 } }, -- Frostbrand Weapon
		{ level = 48, id = 10395, requires = { 8005 } }, -- Healing Wave
		{ level = 48, id = 10431, requires = { 8134 } }, -- Lightning Shield
		{ level = 48, id = 16190, talent = true }, -- Mana Tide Totem
		{ level = 48, id = 10427, requires = { 6392 } }, -- Stoneclaw Totem
		{ level = 50, id = 10462, requires = { 6377 } }, -- Healing Stream Totem
		{ level = 50, id = 15207, requires = { 10392 } }, -- Lightning Bolt
		{ level = 50, id = 10437, requires = { 6365 } }, -- Searing Totem
		{ level = 50, id = 10486, requires = { 8235 } }, -- Windfury Weapon
		{ level = 50, id = 25908 }, -- Tranquil Air Totem
		{ level = 52, id = 10448, requires = { 10447 } }, -- Flame Shock
		{ level = 52, id = 10467, requires = { 10466 } }, -- Lesser Healing Wave
		{ level = 52, id = 10442, requires = { 8161 } }, -- Strength of Earth Totem
		{ level = 52, id = 10614, requires = { 10613 } }, -- Windfury Totem
		{ level = 52, id = 11315, requires = { 11314 } }, -- Fire Nova Totem
		{ level = 54, id = 10623, requires = { 10622 } }, -- Chain Heal
		{ level = 54, id = 10479, requires = { 10478 } }, -- Frost Resistance Totem
		{ level = 54, id = 16316, requires = { 16315 } }, -- Rockbiter Weapon
		{ level = 54, id = 10408, requires = { 10407 } }, -- Stoneskin Totem
		{ level = 56, id = 10605, requires = { 2860 } }, -- Chain Lightning
		{ level = 56, id = 16342, requires = { 16341 } }, -- Flametongue Weapon
		{ level = 56, id = 10627, requires = { 8835 } }, -- Grace of Air Totem
		{ level = 56, id = 10396, requires = { 10395 } }, -- Healing Wave
		{ level = 56, id = 15208, requires = { 15207 } }, -- Lightning Bolt
		{ level = 56, id = 10432, requires = { 10431 } }, -- Lightning Shield
		{ level = 56, id = 10587, requires = { 10586 } }, -- Magma Totem
		{ level = 56, id = 10497, requires = { 10496 } }, -- Mana Spring Totem
		{ level = 56, id = 15112, requires = { 15111 } }, -- Windwall Totem
		{ level = 58, id = 10538, requires = { 10537 } }, -- Fire Resistance Totem
		{ level = 58, id = 16387, requires = { 10526 } }, -- Flametongue Totem
		{ level = 58, id = 10473, requires = { 10472 } }, -- Frost Shock
		{ level = 58, id = 16356, requires = { 16355 } }, -- Frostbrand Weapon
		{ level = 58, id = 10428, requires = { 10427 } }, -- Stoneclaw Totem
		{ level = 60, id = 20777, requires = { 20776 } }, -- Ancestral Spirit
		{ level = 60, id = 10414, requires = { 10413 } }, -- Earth Shock
		{ level = 60, id = 10463, requires = { 10462 } }, -- Healing Stream Totem
		{ level = 60, id = 10468, requires = { 10467 } }, -- Lesser Healing Wave
		{ level = 60, id = 10601, requires = { 10600 } }, -- Nature Resistance Totem
		{ level = 60, id = 10438, requires = { 10437 } }, -- Searing Totem
		{ level = 60, id = 16362, requires = { 10486 } }, -- Windfury Weapon
		{ level = 60, id = 25357, requires = { 10396 } }, -- Healing Wave
		{ level = 60, id = 25359, requires = { 10627 } }, -- Grace of Air Totem
		{ level = 60, id = 25361, requires = { 10442 } }, -- Strength of Earth Totem
		{ level = 60, id = 29228, requires = { 10448 } }, -- Flame Shock
		{ level = 60, id = 974, talent = true }, -- Earth Shield
		{ level = 61, id = 25422, requires = { 10623 } }, -- Chain Heal
		{ level = 61, id = 25546, requires = { 11315 } }, -- Fire Nova Totem
		{ level = 61, id = 25585, requires = { 10614 } }, -- Windfury Totem
		{ level = 62, id = 24398 }, -- Water Shield
		{ level = 62, id = 25448, requires = { 15208 } }, -- Lightning Bolt
		{ level = 62, id = 25479, requires = { 16316 } }, -- Rockbiter Weapon
		{ level = 63, id = 25391, requires = { 25357 } }, -- Healing Wave
		{ level = 63, id = 25439, requires = { 10605 } }, -- Chain Lightning
		{ level = 63, id = 25469, requires = { 10432 } }, -- Lightning Shield
		{ level = 63, id = 25508, requires = { 10408 } }, -- Stoneskin Totem
		{ level = 64, id = 3738 }, -- Wrath of Air Totem
		{ level = 64, id = 25489, requires = { 16342 } }, -- Flametongue Weapon
		{ level = 65, id = 25528, requires = { 25361 } }, -- Strength of Earth Totem
		{ level = 65, id = 25552, requires = { 10587 } }, -- Magma Totem
		{ level = 65, id = 25570, requires = { 10497 } }, -- Mana Spring Totem
		{ level = 65, id = 25577, requires = { 15112 } }, -- Windwall Totem
		{ level = 66, id = 2062 }, -- Earth Elemental Totem
		{ level = 66, id = 25420, requires = { 10468 } }, -- Lesser Healing Wave
		{ level = 66, id = 25500, requires = { 16356 } }, -- Frostbrand Weapon
		{ level = 67, id = 25449, requires = { 25448 } }, -- Lightning Bolt
		{ level = 67, id = 25525, requires = { 10428 } }, -- Stoneclaw Totem
		{ level = 67, id = 25557, requires = { 16387 } }, -- Flametongue Totem
		{ level = 67, id = 25560, requires = { 10479 } }, -- Frost Resistance Totem
		{ level = 68, id = 25423, requires = { 25422 } }, -- Chain Heal
		{ level = 68, id = 25464, requires = { 10473 } }, -- Frost Shock
		{ level = 68, id = 25505, requires = { 16362 } }, -- Windfury Weapon
		{ level = 68, id = 25563, requires = { 10538 } }, -- Fire Resistance Totem
		{ level = 68, id = 2894 }, -- Fire Elemental Totem
		{ level = 69, id = 25454, requires = { 10414 } }, -- Earth Shock
		{ level = 69, id = 25533, requires = { 10438 } }, -- Searing Totem
		{ level = 69, id = 25567, requires = { 10463 } }, -- Healing Stream Totem
		{ level = 69, id = 25574, requires = { 10601 } }, -- Nature Resistance Totem
		{ level = 69, id = 33736, requires = { 24398 } }, -- Water Shield
		{ level = 70, id = 2825, faction = "Horde" }, -- Bloodlust
		{ level = 70, id = 25396, requires = { 25391 } }, -- Healing Wave
		{ level = 70, id = 25442, requires = { 25439 } }, -- Chain Lightning
		{ level = 70, id = 25457, requires = { 29228 } }, -- Flame Shock
		{ level = 70, id = 25472, requires = { 25469 } }, -- Lightning Shield
		{ level = 70, id = 25485, requires = { 25479 } }, -- Rockbiter Weapon
		{ level = 70, id = 25509, requires = { 25508 } }, -- Stoneskin Totem
		{ level = 70, id = 25547, requires = { 25546 } }, -- Fire Nova Totem
		{ level = 70, id = 25587, requires = { 25585 } }, -- Windfury Totem
		{ level = 70, id = 32182, faction = "Alliance" }, -- Heroism
	},
	WARLOCK = {
		{ level = 1, id = 348 }, -- Immolate
		{ level = 4, id = 172 }, -- Corruption
		{ level = 4, id = 702 }, -- Curse of Weakness
		{ level = 6, id = 1454 }, -- Life Tap
		{ level = 6, id = 695, requires = { 686 } }, -- Shadow Bolt
		{ level = 8, id = 980 }, -- Curse of Agony
		{ level = 8, id = 5782 }, -- Fear
		{ level = 10, id = 6201, requires = { 1120 } }, -- Create Healthstone
		{ level = 10, id = 696, requires = { 687 } }, -- Demon Skin
		{ level = 10, id = 1120 }, -- Drain Soul
		{ level = 10, id = 707, requires = { 348 } }, -- Immolate
		{ level = 12, id = 1108, requires = { 702 } }, -- Curse of Weakness
		{ level = 12, id = 755 }, -- Health Funnel
		{ level = 12, id = 705, requires = { 695 } }, -- Shadow Bolt
		{ level = 14, id = 6222, requires = { 172 } }, -- Corruption
		{ level = 14, id = 704 }, -- Curse of Recklessness
		{ level = 14, id = 689 }, -- Drain Life
		{ level = 16, id = 1455, requires = { 1454 } }, -- Life Tap
		{ level = 16, id = 5697 }, -- Unending Breath
		{ level = 18, id = 1014, requires = { 980 } }, -- Curse of Agony
		{ level = 18, id = 693, requires = { 1120 } }, -- Create Soulstone
		{ level = 18, id = 5676 }, -- Searing Pain
		{ level = 20, id = 706 }, -- Demon Armor
		{ level = 20, id = 3698, requires = { 755 } }, -- Health Funnel
		{ level = 20, id = 1094, requires = { 707 } }, -- Immolate
		{ level = 20, id = 5740 }, -- Rain of Fire
		{ level = 20, id = 698 }, -- Ritual of Summoning
		{ level = 20, id = 1088, requires = { 705 } }, -- Shadow Bolt
		{ level = 22, id = 6202, requires = { 6201 } }, -- Create Healthstone
		{ level = 22, id = 6205, requires = { 1108 } }, -- Curse of Weakness
		{ level = 22, id = 699, requires = { 689 } }, -- Drain Life
		{ level = 22, id = 126 }, -- Eye of Kilrogg
		{ level = 24, id = 6223, requires = { 6222 } }, -- Corruption
		{ level = 24, id = 5138 }, -- Drain Mana
		{ level = 24, id = 8288, requires = { 1120 } }, -- Drain Soul
		{ level = 24, id = 5500 }, -- Sense Demons
		{ level = 24, id = 17877, talent = true }, -- Shadowburn
		{ level = 26, id = 1714 }, -- Curse of Tongues
		{ level = 26, id = 132 }, -- Detect Invisibility
		{ level = 26, id = 1456, requires = { 1455 } }, -- Life Tap
		{ level = 26, id = 17919, requires = { 5676 } }, -- Searing Pain
		{ level = 28, id = 6217, requires = { 1014 } }, -- Curse of Agony
		{ level = 28, id = 710 }, -- Banish
		{ level = 28, id = 6366 }, -- Create Firestone
		{ level = 28, id = 7658, requires = { 704 } }, -- Curse of Recklessness
		{ level = 28, id = 3699, requires = { 3698 } }, -- Health Funnel
		{ level = 28, id = 1106, requires = { 1088 } }, -- Shadow Bolt
		{ level = 30, id = 20752, requires = { 693 } }, -- Create Soulstone
		{ level = 30, id = 1086, requires = { 706 } }, -- Demon Armor
		{ level = 30, id = 709, requires = { 699 } }, -- Drain Life
		{ level = 30, id = 1949 }, -- Hellfire
		{ level = 30, id = 2941, requires = { 1094 } }, -- Immolate
		{ level = 30, id = 1098 }, -- Subjugate Demon
		{ level = 30, id = 5784 }, -- Summon Felsteed
		{ level = 32, id = 7646, requires = { 6205 } }, -- Curse of Weakness
		{ level = 32, id = 6213, requires = { 5782 } }, -- Fear
		{ level = 32, id = 6229 }, -- Shadow Ward
		{ level = 32, id = 1490 }, -- Curse of the Elements
		{ level = 34, id = 7648, requires = { 6223 } }, -- Corruption
		{ level = 34, id = 5699, requires = { 6202 } }, -- Create Healthstone
		{ level = 34, id = 6226, requires = { 5138 } }, -- Drain Mana
		{ level = 34, id = 6219, requires = { 5740 } }, -- Rain of Fire
		{ level = 34, id = 17920, requires = { 17919 } }, -- Searing Pain
		{ level = 36, id = 17951, requires = { 6366 } }, -- Create Firestone
		{ level = 36, id = 2362, requires = { 1120 } }, -- Create Spellstone
		{ level = 36, id = 3700, requires = { 3699 } }, -- Health Funnel
		{ level = 36, id = 11687, requires = { 1456 } }, -- Life Tap
		{ level = 36, id = 7641, requires = { 1106 } }, -- Shadow Bolt
		{ level = 38, id = 11711, requires = { 6217 } }, -- Curse of Agony
		{ level = 38, id = 7651, requires = { 709 } }, -- Drain Life
		{ level = 38, id = 8289, requires = { 8288 } }, -- Drain Soul
		{ level = 38, id = 18265, talent = true }, -- Siphon Life
		{ level = 40, id = 20755, requires = { 20752 } }, -- Create Soulstone
		{ level = 40, id = 11733, requires = { 1086 } }, -- Demon Armor
		{ level = 40, id = 5484 }, -- Howl of Terror
		{ level = 40, id = 11665, requires = { 2941 } }, -- Immolate
		{ level = 42, id = 7659, requires = { 7658 } }, -- Curse of Recklessness
		{ level = 42, id = 11707, requires = { 7646 } }, -- Curse of Weakness
		{ level = 42, id = 6789 }, -- Death Coil
		{ level = 42, id = 11683, requires = { 1949 } }, -- Hellfire
		{ level = 42, id = 17921, requires = { 17920 } }, -- Searing Pain
		{ level = 42, id = 11739, requires = { 6229 } }, -- Shadow Ward
		{ level = 44, id = 11671, requires = { 7648 } }, -- Corruption
		{ level = 44, id = 11703, requires = { 6226 } }, -- Drain Mana
		{ level = 44, id = 11693, requires = { 3700 } }, -- Health Funnel
		{ level = 44, id = 11659, requires = { 7641 } }, -- Shadow Bolt
		{ level = 44, id = 11725, requires = { 1098 } }, -- Subjugate Demon
		{ level = 46, id = 17952, requires = { 17951 } }, -- Create Firestone
		{ level = 46, id = 11729, requires = { 5699 } }, -- Create Healthstone
		{ level = 46, id = 11699, requires = { 7651 } }, -- Drain Life
		{ level = 46, id = 11688, requires = { 11687 } }, -- Life Tap
		{ level = 46, id = 11677, requires = { 6219 } }, -- Rain of Fire
		{ level = 46, id = 11721, requires = { 1490 } }, -- Curse of the Elements
		{ level = 48, id = 11712, requires = { 11711 } }, -- Curse of Agony
		{ level = 48, id = 18647, requires = { 710 } }, -- Banish
		{ level = 48, id = 17727, requires = { 2362 } }, -- Create Spellstone
		{ level = 48, id = 6353 }, -- Soul Fire
		{ level = 48, id = 17962, talent = true }, -- Conflagrate
		{ level = 50, id = 20756, requires = { 20755 } }, -- Create Soulstone
		{ level = 50, id = 11719, requires = { 1714 } }, -- Curse of Tongues
		{ level = 50, id = 17925, requires = { 6789 } }, -- Death Coil
		{ level = 50, id = 11734, requires = { 11733 } }, -- Demon Armor
		{ level = 50, id = 11667, requires = { 11665 } }, -- Immolate
		{ level = 50, id = 17922, requires = { 17921 } }, -- Searing Pain
		{ level = 50, id = 18220, talent = true }, -- Dark Pact
		{ level = 52, id = 11708, requires = { 11707 } }, -- Curse of Weakness
		{ level = 52, id = 11675, requires = { 8289 } }, -- Drain Soul
		{ level = 52, id = 11694, requires = { 11693 } }, -- Health Funnel
		{ level = 52, id = 11660, requires = { 11659 } }, -- Shadow Bolt
		{ level = 52, id = 11740, requires = { 11739 } }, -- Shadow Ward
		{ level = 54, id = 11672, requires = { 11671 } }, -- Corruption
		{ level = 54, id = 11700, requires = { 11699 } }, -- Drain Life
		{ level = 54, id = 11704, requires = { 11703 } }, -- Drain Mana
		{ level = 54, id = 11684, requires = { 11683 } }, -- Hellfire
		{ level = 54, id = 17928, requires = { 5484 } }, -- Howl of Terror
		{ level = 56, id = 17953, requires = { 17952 } }, -- Create Firestone
		{ level = 56, id = 11717, requires = { 7659 } }, -- Curse of Recklessness
		{ level = 56, id = 6215, requires = { 6213 } }, -- Fear
		{ level = 56, id = 11689, requires = { 11688 } }, -- Life Tap
		{ level = 56, id = 17924, requires = { 6353 } }, -- Soul Fire
		{ level = 58, id = 11713, requires = { 11712 } }, -- Curse of Agony
		{ level = 58, id = 11730, requires = { 11729 } }, -- Create Healthstone
		{ level = 58, id = 17926, requires = { 17925 } }, -- Death Coil
		{ level = 58, id = 11678, requires = { 11677 } }, -- Rain of Fire
		{ level = 58, id = 17923, requires = { 17922 } }, -- Searing Pain
		{ level = 58, id = 11726, requires = { 11725 } }, -- Subjugate Demon
		{ level = 60, id = 603 }, -- Curse of Doom
		{ level = 60, id = 20757, requires = { 20756 } }, -- Create Soulstone
		{ level = 60, id = 17728, requires = { 17727 } }, -- Create Spellstone
		{ level = 60, id = 11735, requires = { 11734 } }, -- Demon Armor
		{ level = 60, id = 11695, requires = { 11694 } }, -- Health Funnel
		{ level = 60, id = 11668, requires = { 11667 } }, -- Immolate
		{ level = 60, id = 11661, requires = { 11660 } }, -- Shadow Bolt
		{ level = 60, id = 11722, requires = { 11721 } }, -- Curse of the Elements
		{ level = 60, id = 25307, requires = { 11661 } }, -- Shadow Bolt
		{ level = 60, id = 25309, requires = { 11668 } }, -- Immolate
		{ level = 60, id = 25311, requires = { 11672 } }, -- Corruption
		{ level = 60, id = 28610, requires = { 11740 } }, -- Shadow Ward
		{ level = 60, id = 30108, talent = true }, -- Unstable Affliction
		{ level = 60, id = 30283, talent = true }, -- Shadowfury
		{ level = 61, id = 27224, requires = { 11708 } }, -- Curse of Weakness
		{ level = 62, id = 27219, requires = { 11700 } }, -- Drain Life
		{ level = 62, id = 28176 }, -- Fel Armor
		{ level = 63, id = 27221, requires = { 11704 } }, -- Drain Mana
		{ level = 64, id = 27211, requires = { 17924 } }, -- Soul Fire
		{ level = 64, id = 29722 }, -- Incinerate
		{ level = 65, id = 27210, requires = { 17923 } }, -- Searing Pain
		{ level = 65, id = 27216, requires = { 25311 } }, -- Corruption
		{ level = 66, id = 27250, requires = { 17953 } }, -- Create Firestone
		{ level = 66, id = 28172, requires = { 17728 } }, -- Create Spellstone
		{ level = 66, id = 29858 }, -- Soulshatter
		{ level = 67, id = 27217, requires = { 11675 } }, -- Drain Soul
		{ level = 67, id = 27218, requires = { 11713 } }, -- Curse of Agony
		{ level = 67, id = 27259, requires = { 11695 } }, -- Health Funnel
		{ level = 68, id = 27213, requires = { 11684 } }, -- Hellfire
		{ level = 68, id = 27222, requires = { 11689 } }, -- Life Tap
		{ level = 68, id = 27223, requires = { 17926 } }, -- Death Coil
		{ level = 68, id = 27230, requires = { 11730 } }, -- Create Healthstone
		{ level = 68, id = 29893 }, -- Ritual of Souls
		{ level = 69, id = 27209, requires = { 25307 } }, -- Shadow Bolt
		{ level = 69, id = 27212, requires = { 11678 } }, -- Rain of Fire
		{ level = 69, id = 27215, requires = { 25309 } }, -- Immolate
		{ level = 69, id = 27220, requires = { 27219 } }, -- Drain Life
		{ level = 69, id = 27226, requires = { 11717 } }, -- Curse of Recklessness
		{ level = 69, id = 27228, requires = { 11722 } }, -- Curse of the Elements
		{ level = 69, id = 28189, requires = { 28176 } }, -- Fel Armor
		{ level = 69, id = 30909, requires = { 27224 } }, -- Curse of Weakness
		{ level = 70, id = 27238, requires = { 20757 } }, -- Create Soulstone
		{ level = 70, id = 27243 }, -- Seed of Corruption
		{ level = 70, id = 27260, requires = { 11735 } }, -- Demon Armor
		{ level = 70, id = 30459, requires = { 27210 } }, -- Searing Pain
		{ level = 70, id = 30545, requires = { 27211 } }, -- Soul Fire
		{ level = 70, id = 30908, requires = { 27221 } }, -- Drain Mana
		{ level = 70, id = 30910, requires = { 603 } }, -- Curse of Doom
		{ level = 70, id = 32231, requires = { 29722 } }, -- Incinerate
	},
	WARRIOR = {
		{ level = 1, id = 6673 }, -- Battle Shout
		{ level = 4, id = 100 }, -- Charge
		{ level = 4, id = 772 }, -- Rend
		{ level = 6, id = 3127 }, -- Parry
		{ level = 6, id = 6343 }, -- Thunder Clap
		{ level = 8, id = 1715 }, -- Hamstring
		{ level = 8, id = 284, requires = { 78 } }, -- Heroic Strike
		{ level = 10, id = 2687 }, -- Bloodrage
		{ level = 10, id = 6546, requires = { 772 } }, -- Rend
		{ level = 12, id = 5242, requires = { 6673 } }, -- Battle Shout
		{ level = 12, id = 7384 }, -- Overpower
		{ level = 12, id = 72 }, -- Shield Bash
		{ level = 14, id = 1160 }, -- Demoralizing Shout
		{ level = 14, id = 6572, requires = { 71 } }, -- Revenge
		{ level = 16, id = 285, requires = { 284 } }, -- Heroic Strike
		{ level = 16, id = 694 }, -- Mocking Blow
		{ level = 16, id = 2565, requires = { 71 } }, -- Shield Block
		{ level = 18, id = 676, requires = { 71 } }, -- Disarm
		{ level = 18, id = 8198, requires = { 6343 } }, -- Thunder Clap
		{ level = 20, id = 845 }, -- Cleave
		{ level = 20, id = 674 }, -- Dual Wield
		{ level = 20, id = 6547, requires = { 6546 } }, -- Rend
		{ level = 20, id = 20230 }, -- Retaliation
		{ level = 22, id = 6192, requires = { 5242 } }, -- Battle Shout
		{ level = 22, id = 5246 }, -- Intimidating Shout
		{ level = 22, id = 7405, requires = { 7386 } }, -- Sunder Armor
		{ level = 24, id = 6190, requires = { 1160 } }, -- Demoralizing Shout
		{ level = 24, id = 5308 }, -- Execute
		{ level = 24, id = 1608, requires = { 285 } }, -- Heroic Strike
		{ level = 24, id = 6574, requires = { 6572 } }, -- Revenge
		{ level = 26, id = 1161 }, -- Challenging Shout
		{ level = 26, id = 6178, requires = { 100 } }, -- Charge
		{ level = 26, id = 7400, requires = { 694 } }, -- Mocking Blow
		{ level = 28, id = 7887, requires = { 7384 } }, -- Overpower
		{ level = 28, id = 871, requires = { 71 } }, -- Shield Wall
		{ level = 28, id = 8204, requires = { 8198 } }, -- Thunder Clap
		{ level = 30, id = 7369, requires = { 845 } }, -- Cleave
		{ level = 30, id = 6548, requires = { 6547 } }, -- Rend
		{ level = 30, id = 1464 }, -- Slam
		{ level = 32, id = 18499, requires = { 2458 } }, -- Berserker Rage
		{ level = 32, id = 11549, requires = { 6192 } }, -- Battle Shout
		{ level = 32, id = 20658, requires = { 5308 } }, -- Execute
		{ level = 32, id = 7372, requires = { 1715 } }, -- Hamstring
		{ level = 32, id = 11564, requires = { 1608 } }, -- Heroic Strike
		{ level = 32, id = 1671, requires = { 72 } }, -- Shield Bash
		{ level = 34, id = 11554, requires = { 6190 } }, -- Demoralizing Shout
		{ level = 34, id = 7379, requires = { 6574 } }, -- Revenge
		{ level = 34, id = 8380, requires = { 7405 } }, -- Sunder Armor
		{ level = 36, id = 7402, requires = { 7400 } }, -- Mocking Blow
		{ level = 36, id = 1680, requires = { 2458 } }, -- Whirlwind
		{ level = 38, id = 6552, requires = { 2458 } }, -- Pummel
		{ level = 38, id = 8820, requires = { 1464 } }, -- Slam
		{ level = 38, id = 8205, requires = { 8204 } }, -- Thunder Clap
		{ level = 40, id = 11608, requires = { 7369 } }, -- Cleave
		{ level = 40, id = 20660, requires = { 20658 } }, -- Execute
		{ level = 40, id = 11565, requires = { 11564 } }, -- Heroic Strike
		{ level = 40, id = 750 }, -- Plate Mail
		{ level = 40, id = 11572, requires = { 6548 } }, -- Rend
		{ level = 42, id = 11550, requires = { 11549 } }, -- Battle Shout
		{ level = 42, id = 20616, requires = { 20252 } }, -- Intercept
		{ level = 44, id = 11555, requires = { 11554 } }, -- Demoralizing Shout
		{ level = 44, id = 11584, requires = { 7887 } }, -- Overpower
		{ level = 44, id = 11600, requires = { 7379 } }, -- Revenge
		{ level = 46, id = 11578, requires = { 6178 } }, -- Charge
		{ level = 46, id = 20559, requires = { 7402 } }, -- Mocking Blow
		{ level = 46, id = 11604, requires = { 8820 } }, -- Slam
		{ level = 46, id = 11596, requires = { 8380 } }, -- Sunder Armor
		{ level = 48, id = 23881, talent = true }, -- Bloodthirst
		{ level = 48, id = 20661, requires = { 20660 } }, -- Execute
		{ level = 48, id = 11566, requires = { 11565 } }, -- Heroic Strike
		{ level = 48, id = 12294, talent = true }, -- Mortal Strike
		{ level = 48, id = 23922, talent = true }, -- Shield Slam
		{ level = 48, id = 11580, requires = { 8205 } }, -- Thunder Clap
		{ level = 50, id = 11609, requires = { 11608 } }, -- Cleave
		{ level = 50, id = 1719, requires = { 2458 } }, -- Recklessness
		{ level = 50, id = 11573, requires = { 11572 } }, -- Rend
		{ level = 52, id = 11551, requires = { 11550 } }, -- Battle Shout
		{ level = 52, id = 20617, requires = { 20616 } }, -- Intercept
		{ level = 52, id = 1672, requires = { 1671 } }, -- Shield Bash
		{ level = 54, id = 11556, requires = { 11555 } }, -- Demoralizing Shout
		{ level = 54, id = 7373, requires = { 7372 } }, -- Hamstring
		{ level = 54, id = 11601, requires = { 11600 } }, -- Revenge
		{ level = 54, id = 11605, requires = { 11604 } }, -- Slam
		{ level = 56, id = 20662, requires = { 20661 } }, -- Execute
		{ level = 56, id = 11567, requires = { 11566 } }, -- Heroic Strike
		{ level = 56, id = 20560, requires = { 20559 } }, -- Mocking Blow
		{ level = 58, id = 6554, requires = { 6552 } }, -- Pummel
		{ level = 58, id = 11597, requires = { 11596 } }, -- Sunder Armor
		{ level = 58, id = 11581, requires = { 11580 } }, -- Thunder Clap
		{ level = 60, id = 20569, requires = { 11609 } }, -- Cleave
		{ level = 60, id = 11585, requires = { 11584 } }, -- Overpower
		{ level = 60, id = 11574, requires = { 11573 } }, -- Rend
		{ level = 60, id = 25286, requires = { 11567 } }, -- Heroic Strike
		{ level = 60, id = 25288, requires = { 11601 } }, -- Revenge
		{ level = 60, id = 25289, requires = { 11551 } }, -- Battle Shout
		{ level = 60, id = 20243, talent = true }, -- Devastate
		{ level = 60, id = 29801, talent = true }, -- Rampage
		{ level = 61, id = 25241, requires = { 11605 } }, -- Slam
		{ level = 61, id = 25272, requires = { 20617 } }, -- Intercept
		{ level = 62, id = 25202, requires = { 11556 } }, -- Demoralizing Shout
		{ level = 62, id = 34428 }, -- Victory Rush
		{ level = 63, id = 25269, requires = { 25288 } }, -- Revenge
		{ level = 64, id = 23920 }, -- Spell Reflection
		{ level = 64, id = 29704, requires = { 1672 } }, -- Shield Bash
		{ level = 65, id = 25234, requires = { 20662 } }, -- Execute
		{ level = 65, id = 25266, requires = { 20560 } }, -- Mocking Blow
		{ level = 66, id = 29707, requires = { 25286 } }, -- Heroic Strike
		{ level = 67, id = 25212, requires = { 7373 } }, -- Hamstring
		{ level = 67, id = 25225, requires = { 11597 } }, -- Sunder Armor
		{ level = 67, id = 25264, requires = { 11581 } }, -- Thunder Clap
		{ level = 68, id = 469 }, -- Commanding Shout
		{ level = 68, id = 25208, requires = { 11574 } }, -- Rend
		{ level = 68, id = 25231, requires = { 20569 } }, -- Cleave
		{ level = 69, id = 2048, requires = { 25289 } }, -- Battle Shout
		{ level = 69, id = 25242, requires = { 25241 } }, -- Slam
		{ level = 69, id = 25275, requires = { 25272 } }, -- Intercept
		{ level = 70, id = 3411 }, -- Intervene
		{ level = 70, id = 25203, requires = { 25202 } }, -- Demoralizing Shout
		{ level = 70, id = 25236, requires = { 25234 } }, -- Execute
		{ level = 70, id = 30324, requires = { 29707 } }, -- Heroic Strike
		{ level = 70, id = 30357, requires = { 25269 } }, -- Revenge
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-24, TBC Anniversary 2.5.6.70006

Notes
	- Every class spell this client's class trainers teach, one row per rank, so the spellbook page can list the spells a character hasn't learned yet. Features/Unlearned-Spells.lua shows only each spell's rank 1; the higher ranks keep the list in level order and let it tell rank 1 apart.
	- level is the level the trainer offers the rank, which is the spell's learn level. A talent row is the exception (below).
	- The client's own learn level (Validate Data's SPELL_LEVEL_LEARNED) reads 0 or 1 for spells with no level of their own: weapon and armor skills, Parry, Pick Lock, the hunter's pet skills and talents. Those rows keep the trainer's level.
	- requires is the spell the trainer wants first, usually the previous rank. Rows added from the game tables take the rank the tables say it replaces, or else the same spell's previous rank in this table, which agrees with all but 3 of the 860 hand-made rows that follow an earlier rank.
	- faction and race mark rows only one faction or race can learn. A spell several races of the class learn, but not all of them, gets one row per race (Desperate Prayer: Human and Dwarf).
	- talent marks the rank 1 of a talent whose higher ranks the trainer teaches, listed at the level of its first trainer rank so it shows until learned. The talent's own trainer ranks are left out. Talents with no trainer ranks are in the class lists' extraSpells instead.
	- Left out on purpose: starting spells, spells learned by quest or with a form (warrior stances, warlock pets, druid forms, Growl and Maul with Bear Form; the class lists' extraSpells list these), passive and hidden spells, effects other spells fire, pet family abilities learned by taming, rogue poison recipes and the Poisons skill.
	- The rows began as What's Training's WoW Forever trainer lists (Data/LICENSE-Trainer-Data), made by tools/gen_trainer_data.py and copied from Data/Camelot/. Rows this client doesn't have were pruned, and this client's own trainer spells were added from its game tables: ranks 61 to 70, TBC's new spells, and the ones Forever changed or dropped.
	- How the added rows were found: a spell on one of the class's own skill lines (or Pet - Generic, for hunters), learned at the trainer (SkillLineAbility), at level 1 to 70. This client has no teaching spells, so effects were removed instead: spells another spell fires (SpellEffect; only 2 hand-made rows are), names no row has ("... Effect", "... Bleed", "Judgement of ..."), and a second spell of the same name, rank and level. Passive and hidden spells, talents and their ranks, and extraSpells entries were removed too.
	- A later check against the same tables added seven trainer spells the name test had dropped, since no hand-made row shares their name: Steady Shot, Arcane Blast, Ice Lance, Invisibility, Spellsteal, Fire Elemental Totem and Tranquil Air Totem.
	- The Ahn'Qiraj book ranks of Classic (Heroic Strike rank 9 and the like) are in: this client has no book for them, so the trainer teaches them at 60.
	- Ruled out by hand: Seal of Righteousness rank 1 and Summon Imp (starting spells), Summon Dreadsteed and Swift Flight Form (quests), Poisons and Mind-numbing Poison I to III (the rows hold no poison skill or recipes), pet Growl rank 1 (every pet starts with it), and effects the tests above let through: Execute 20647, Holy Vengeance, Blood Corruption, Lightwell Renew, Chilled, Create Soulwell, Enraged Defense.
	- Likely unobtainable, so not added: Curse of Idiocy (1010), Black Arrow (3674, 14296) and Mass Resurrection (32841), IDs no trainer here teaches.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=2.5.6.70006
	https://wago.tools/db2/SkillLine?build=2.5.6.70006
	https://wago.tools/db2/SpellLevels?build=2.5.6.70006
	https://wago.tools/db2/SpellName?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Talent?build=2.5.6.70006

QuestieDB
	None.
]]
