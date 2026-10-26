local _, ns = ...
local Data = ns.Data

local ALL, TANK, OFF = Data.BUFF_AUDIENCE.ALL, Data.BUFF_AUDIENCE.TANK, Data.BUFF_AUDIENCE.OFF
local BLESSING = "BLESSING"
local ASPECT, MAGE_ARMOR, PALADIN_AURA = "ASPECT", "MAGE_ARMOR", "PALADIN_AURA"
local SHAMAN_SHIELD, WARLOCK_ARMOR, WARLOCK_DEMON = "SHAMAN_SHIELD", "WARLOCK_ARMOR", "WARLOCK_DEMON"
local MISSING = Data.SELF_REFRESH_MISSING
local MAIN, OFF_HAND = "MAIN", "OFF"

-- { class, single = { { spell id, level learned } }, group = { spell ids }, greater = { spell ids }, exclusive, manaOnly, noCasters, default }, -- Name
ns.BUFF_WINDOW_SPELLS = {
	-- Druid ---------------------------------------------------------------------
	{
		class = "DRUID",
		single = {
			{ 1126, 1 },
			{ 5232, 10 },
			{ 6756, 20 },
			{ 5234, 30 },
			{ 8907, 40 },
			{ 9884, 50 },
			{ 9885, 60 },
			{ 26990, 70 },
		},
		group = { 21849, 21850, 26991 },
		default = ALL,
	}, -- Mark of the Wild
	{
		class = "DRUID",
		single = { { 467, 6 }, { 782, 14 }, { 1075, 24 }, { 8914, 34 }, { 9756, 44 }, { 9910, 54 }, { 26992, 64 } },
		default = TANK,
	}, -- Thorns
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		single = { { 1459, 1 }, { 1460, 14 }, { 1461, 28 }, { 10156, 42 }, { 10157, 56 }, { 27126, 70 } },
		group = { 23028, 27127 },
		manaOnly = true,
		default = ALL,
	}, -- Arcane Intellect
	{
		class = "MAGE",
		single = { { 1008, 18 }, { 8455, 30 }, { 10169, 42 }, { 10170, 54 }, { 27130, 63 }, { 33946, 69 } },
		default = OFF,
	}, -- Amplify Magic
	{
		class = "MAGE",
		single = { { 604, 12 }, { 8450, 24 }, { 8451, 36 }, { 10173, 48 }, { 10174, 60 }, { 33944, 67 } },
		default = OFF,
	}, -- Dampen Magic
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		single = { { 20217, 20 } },
		greater = { 25898 },
		exclusive = BLESSING,
		default = ALL,
	}, -- Blessing of Kings
	{
		class = "PALADIN",
		single = {
			{ 19742, 14 },
			{ 19850, 24 },
			{ 19852, 34 },
			{ 19853, 44 },
			{ 19854, 54 },
			{ 25290, 60 },
			{ 27142, 65 },
		},
		greater = { 25894, 25918, 27143 },
		exclusive = BLESSING,
		manaOnly = true,
		default = ALL,
	}, -- Blessing of Wisdom
	{
		class = "PALADIN",
		single = {
			{ 19740, 4 },
			{ 19834, 12 },
			{ 19835, 22 },
			{ 19836, 32 },
			{ 19837, 42 },
			{ 19838, 52 },
			{ 25291, 60 },
			{ 27140, 70 },
		},
		greater = { 25782, 25916, 27141 },
		exclusive = BLESSING,
		noCasters = true,
		default = ALL,
	}, -- Blessing of Might
	{
		class = "PALADIN",
		single = { { 1038, 26 } },
		greater = { 25895 },
		exclusive = BLESSING,
		default = OFF,
	}, -- Blessing of Salvation
	{
		class = "PALADIN",
		single = { { 19977, 40 }, { 19978, 50 }, { 19979, 60 }, { 27144, 69 } },
		greater = { 25890, 27145 },
		exclusive = BLESSING,
		default = OFF,
	}, -- Blessing of Light
	{
		class = "PALADIN",
		single = { { 20911, 30 }, { 20912, 40 }, { 20913, 50 }, { 20914, 60 }, { 27168, 70 } },
		greater = { 25899, 27169 },
		exclusive = BLESSING,
		default = OFF,
	}, -- Blessing of Sanctuary
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		single = { { 1243, 1 }, { 1244, 12 }, { 1245, 24 }, { 2791, 36 }, { 10937, 48 }, { 10938, 60 }, { 25389, 70 } },
		group = { 21562, 21564, 25392 },
		default = ALL,
	}, -- Power Word: Fortitude
	{
		class = "PRIEST",
		single = { { 14752, 30 }, { 14818, 40 }, { 14819, 50 }, { 27841, 60 }, { 25312, 70 } },
		group = { 27681, 32999 },
		manaOnly = true,
		default = ALL,
	}, -- Divine Spirit
	{
		class = "PRIEST",
		single = { { 976, 30 }, { 10957, 42 }, { 10958, 56 }, { 25433, 68 } },
		group = { 27683, 39374 },
		default = OFF,
	}, -- Shadow Protection
	{
		class = "PRIEST",
		single = { { 6346, 20 } },
		default = TANK,
	}, -- Fear Ward
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		single = { { 974, 50 }, { 32593, 60 }, { 32594, 70 } },
		default = OFF,
	}, -- Earth Shield
	{
		class = "SHAMAN",
		single = { { 131, 22 } },
		default = OFF,
	}, -- Water Breathing
	{
		class = "SHAMAN",
		single = { { 546, 28 } },
		default = OFF,
	}, -- Water Walking
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		single = { { 5697, 16 } },
		default = OFF,
	}, -- Unending Breath
	{
		class = "WARLOCK",
		single = { { 132, 26 } },
		default = OFF,
	}, -- Detect Invisibility
}

-- { beast = spell id, demons = { [npc id] = spell id } }: the icon a pet's row wears, from its summoning spell
ns.BUFF_WINDOW_PET_ICONS = {
	beast = 883, -- Call Pet
	demons = {
		[416] = 688, -- Imp: Summon Imp
		[1860] = 697, -- Voidwalker: Summon Voidwalker
		[1863] = 712, -- Succubus: Summon Succubus
		[417] = 691, -- Felhunter: Summon Felhunter
		[17252] = 30146, -- Felguard: Summon Felguard
	},
}

-- { class, ranks = { { spell id, level learned } }, auras, exclusive, needsPet, default (minutes left, MISSING or OFF) }, -- Name
ns.BUFF_WINDOW_SELF_SPELLS = {
	-- Druid ---------------------------------------------------------------------
	{
		class = "DRUID",
		ranks = { { 16864, 20 } },
		default = 3,
	}, -- Omen of Clarity
	-- Hunter --------------------------------------------------------------------
	{
		class = "HUNTER",
		ranks = { { 19506, 40 }, { 20905, 50 }, { 20906, 60 }, { 27066, 70 } },
		default = 3,
	}, -- Trueshot Aura
	{
		class = "HUNTER",
		ranks = {
			{ 13165, 10 },
			{ 14318, 18 },
			{ 14319, 28 },
			{ 14320, 38 },
			{ 14321, 48 },
			{ 14322, 58 },
			{ 25296, 60 },
			{ 27044, 68 },
		},
		exclusive = ASPECT,
		default = MISSING,
	}, -- Aspect of the Hawk
	{
		class = "HUNTER",
		ranks = { { 13163, 4 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Monkey
	{
		class = "HUNTER",
		ranks = { { 5118, 20 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Cheetah
	{
		class = "HUNTER",
		ranks = { { 13161, 30 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Beast
	{
		class = "HUNTER",
		ranks = { { 13159, 40 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Pack
	{
		class = "HUNTER",
		ranks = { { 20043, 46 }, { 20190, 56 }, { 27045, 68 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Wild
	{
		class = "HUNTER",
		ranks = { { 34074, 64 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Viper
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		ranks = {
			{ 168, 1 },
			{ 7300, 10 },
			{ 7301, 20 },
			{ 7302, 30 },
			{ 7320, 40 },
			{ 10219, 50 },
			{ 10220, 60 },
			{ 27124, 69 },
		},
		exclusive = MAGE_ARMOR,
		default = 3,
	}, -- Frost Armor, Ice Armor
	{
		class = "MAGE",
		ranks = { { 6117, 34 }, { 22782, 46 }, { 22783, 58 }, { 27125, 69 } },
		exclusive = MAGE_ARMOR,
		default = 3,
	}, -- Mage Armor
	{
		class = "MAGE",
		ranks = { { 30482, 62 } },
		exclusive = MAGE_ARMOR,
		default = 3,
	}, -- Molten Armor
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		ranks = {
			{ 465, 1 },
			{ 10290, 10 },
			{ 643, 20 },
			{ 10291, 30 },
			{ 1032, 40 },
			{ 10292, 50 },
			{ 10293, 60 },
			{ 27149, 70 },
		},
		exclusive = PALADIN_AURA,
		default = MISSING,
	}, -- Devotion Aura
	{
		class = "PALADIN",
		ranks = { { 7294, 16 }, { 10298, 26 }, { 10299, 36 }, { 10300, 46 }, { 10301, 56 }, { 27150, 66 } },
		exclusive = PALADIN_AURA,
		default = MISSING,
	}, -- Retribution Aura
	{
		class = "PALADIN",
		ranks = { { 19746, 22 } },
		exclusive = PALADIN_AURA,
		default = MISSING,
	}, -- Concentration Aura
	{
		class = "PALADIN",
		ranks = { { 19876, 28 }, { 19895, 40 }, { 19896, 52 }, { 27151, 63 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Shadow Resistance Aura
	{
		class = "PALADIN",
		ranks = { { 19888, 32 }, { 19897, 44 }, { 19898, 56 }, { 27152, 68 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Frost Resistance Aura
	{
		class = "PALADIN",
		ranks = { { 19891, 36 }, { 19899, 48 }, { 19900, 60 }, { 27153, 70 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Fire Resistance Aura
	{
		class = "PALADIN",
		ranks = { { 20218, 30 } },
		exclusive = PALADIN_AURA,
		default = MISSING,
	}, -- Sanctity Aura
	{
		class = "PALADIN",
		ranks = { { 32223, 62 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Crusader Aura
	{
		class = "PALADIN",
		ranks = { { 25780, 16 } },
		default = OFF,
	}, -- Righteous Fury
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		ranks = { { 588, 12 }, { 7128, 20 }, { 602, 30 }, { 1006, 40 }, { 10951, 50 }, { 10952, 60 }, { 25431, 69 } },
		default = 3,
	}, -- Inner Fire
	{
		class = "PRIEST",
		ranks = {
			{ 18137, 20 },
			{ 19308, 28 },
			{ 19309, 36 },
			{ 19310, 44 },
			{ 19311, 52 },
			{ 19312, 60 },
			{ 25477, 68 },
		},
		default = 3,
	}, -- Shadowguard
	{
		class = "PRIEST",
		ranks = {
			{ 2652, 10 },
			{ 19261, 20 },
			{ 19262, 30 },
			{ 19264, 40 },
			{ 19265, 50 },
			{ 19266, 60 },
			{ 25461, 70 },
		},
		default = 3,
	}, -- Touch of Weakness
	{
		class = "PRIEST",
		ranks = { { 15473, 40 } },
		default = MISSING,
	}, -- Shadowform
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		ranks = {
			{ 324, 8 },
			{ 325, 16 },
			{ 905, 24 },
			{ 945, 32 },
			{ 8134, 40 },
			{ 10431, 48 },
			{ 10432, 56 },
			{ 25469, 63 },
			{ 25472, 70 },
		},
		exclusive = SHAMAN_SHIELD,
		default = 3,
	}, -- Lightning Shield
	{
		class = "SHAMAN",
		ranks = { { 24398, 62 }, { 33736, 69 } },
		exclusive = SHAMAN_SHIELD,
		default = 3,
	}, -- Water Shield
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		ranks = {
			{ 687, 1 },
			{ 696, 10 },
			{ 706, 20 },
			{ 1086, 30 },
			{ 11733, 40 },
			{ 11734, 50 },
			{ 11735, 60 },
			{ 27260, 70 },
		},
		exclusive = WARLOCK_ARMOR,
		default = 3,
	}, -- Demon Skin, Demon Armor
	{
		class = "WARLOCK",
		ranks = { { 28176, 62 }, { 28189, 69 } },
		exclusive = WARLOCK_ARMOR,
		default = 3,
	}, -- Fel Armor
	{
		class = "WARLOCK",
		ranks = { { 18788, 30 } },
		auras = { 18789, 18790, 18791, 18792, 35701 },
		exclusive = WARLOCK_DEMON,
		default = MISSING,
	}, -- Demonic Sacrifice
	{
		class = "WARLOCK",
		ranks = { { 19028, 40 } },
		auras = { 25228 },
		exclusive = WARLOCK_DEMON,
		needsPet = true,
		default = OFF,
	}, -- Soul Link
	-- Warrior -------------------------------------------------------------------
	{
		class = "WARRIOR",
		ranks = {
			{ 6673, 1 },
			{ 5242, 12 },
			{ 6192, 22 },
			{ 11549, 32 },
			{ 11550, 42 },
			{ 11551, 52 },
			{ 25289, 60 },
			{ 2048, 69 },
		},
		default = MISSING,
	}, -- Battle Shout
}

-- { class, duration (minutes), ranks = { { spell id, level learned, enchant id } } or items = { { item id, level required, enchant id } } }, -- Name
ns.BUFF_WINDOW_WEAPON_ENCHANTS = {
	-- Rogue ---------------------------------------------------------------------
	{
		class = "ROGUE",
		items = { { 21835, 68, 2640 } },
	}, -- Anesthetic Poison
	{
		class = "ROGUE",
		items = { { 3775, 20, 22 }, { 3776, 50, 603 } },
	}, -- Crippling Poison
	{
		class = "ROGUE",
		items = {
			{ 2892, 30, 7 },
			{ 2893, 38, 8 },
			{ 8984, 46, 626 },
			{ 8985, 54, 627 },
			{ 20844, 60, 2630 },
			{ 22053, 62, 2642 },
			{ 22054, 70, 2643 },
		},
	}, -- Deadly Poison
	{
		class = "ROGUE",
		items = {
			{ 6947, 20, 323 },
			{ 6949, 28, 324 },
			{ 6950, 36, 325 },
			{ 8926, 44, 623 },
			{ 8927, 52, 624 },
			{ 8928, 60, 625 },
			{ 21927, 68, 2641 },
		},
	}, -- Instant Poison
	{
		class = "ROGUE",
		items = { { 5237, 24, 35 }, { 6951, 38, 23 }, { 9186, 52, 643 } },
	}, -- Mind-numbing Poison
	{
		class = "ROGUE",
		items = { { 10918, 32, 703 }, { 10920, 40, 704 }, { 10921, 48, 705 }, { 10922, 56, 706 }, { 22055, 64, 2644 } },
	}, -- Wound Poison
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		duration = 30,
		ranks = {
			{ 8024, 10, 5 },
			{ 8027, 18, 4 },
			{ 8030, 26, 3 },
			{ 16339, 36, 523 },
			{ 16341, 46, 1665 },
			{ 16342, 56, 1666 },
			{ 25489, 64, 2634 },
		},
	}, -- Flametongue Weapon
	{
		class = "SHAMAN",
		duration = 30,
		ranks = {
			{ 8033, 20, 2 },
			{ 8038, 28, 12 },
			{ 10456, 38, 524 },
			{ 16355, 48, 1667 },
			{ 16356, 58, 1668 },
			{ 25500, 66, 2635 },
		},
	}, -- Frostbrand Weapon
	{
		class = "SHAMAN",
		duration = 30,
		ranks = {
			{ 8017, 1, { 29, 3021, 3022, 3023 } },
			{ 8018, 8, { 6, 3024, 3025, 3026 } },
			{ 8019, 16, { 1, 3027, 3028, 3029 } },
			{ 10399, 24, { 503, 3030, 3031, 3032 } },
			{ 16314, 34, { 1663, 3033, 3034, 3035 } },
			{ 16315, 44, { 683, 3036, 3037, 3038 } },
			{ 16316, 54, { 1664, 3039, 3040, 3041 } },
			{ 25479, 62, { 2632, 3042, 3043, 3044 } },
			{ 25485, 70, { 2633, 3018, 3019, 3020 } },
		},
	}, -- Rockbiter Weapon
	{
		class = "SHAMAN",
		duration = 30,
		ranks = { { 8232, 30, 283 }, { 8235, 40, 284 }, { 10486, 50, 525 }, { 16362, 60, 1669 }, { 25505, 68, 2636 } },
	}, -- Windfury Weapon
}

-- The weapons each class keeps a poison or imbue on.
ns.BUFF_WINDOW_WEAPON_HANDS = {
	ROGUE = { MAIN, OFF_HAND },
	SHAMAN = { MAIN, OFF_HAND },
}

--[[
    Every other temporary weapon enchant, for any class: oils, sharpening
    stones, weightstones, fishing lures. weapon types is the item spell's
    weapon-subclass mask (0 for any weapon but a fishing pole); kind is the
    Weapon Buffs panel group it's listed under, and item level ranks it there
    and in the window, strongest first.
]]
local OIL, STONE, LURE = "OIL", "STONE", "LURE"
local ON_QUEL_DANAS = { instances = { 585, 580 }, uiMaps = { 1957 } } -- Magisters' Terrace, Sunwell Plateau; Isle of Quel'Danas

-- { item id, level required, enchant id, weapon types, kind, item level, zones }, -- Name
ns.BUFF_WINDOW_WEAPON_ITEMS = {
	{ 23529, 60, 2713, 33219, STONE, 70 }, -- Adamantite Sharpening Stone
	{ 28421, 60, 2955, 9264, STONE, 70 }, -- Adamantite Weightstone
	{ 6533, 0, 266, 1048576, LURE, 30 }, -- Aquadynamic Fish Attractor
	{ 6811, 0, 264, 1048576, LURE, 20 }, -- Aquadynamic Fish Lens
	{ 34538, 70, 3265, 0, OIL, 70, ON_QUEL_DANAS }, -- Blessed Weapon Coating
	{ 23123, 50, 2685, 0, OIL, 55 }, -- Blessed Wizard Oil
	{ 31535, 0, 3102, 173555, OIL, 105 }, -- Bloodboil Poison
	{ 6532, 0, 265, 1048576, LURE, 30 }, -- Bright Baubles
	{ 20748, 45, 2629, 0, OIL, 55 }, -- Brilliant Mana Oil
	{ 20749, 45, 2628, 0, OIL, 55 }, -- Brilliant Wizard Oil
	{ 2863, 5, 13, 33219, STONE, 15 }, -- Coarse Sharpening Stone
	{ 3240, 5, 20, 9264, STONE, 15 }, -- Coarse Weightstone
	{ 23122, 50, 2684, 1097203, STONE, 55 }, -- Consecrated Sharpening Stone
	{ 12404, 35, 1643, 33219, STONE, 45 }, -- Dense Sharpening Stone
	{ 12643, 35, 1703, 9264, STONE, 45 }, -- Dense Weightstone
	{ 18262, 50, 2506, 42483, STONE, 60 }, -- Elemental Sharpening Stone
	{ 23528, 50, 2712, 33219, STONE, 60 }, -- Fel Sharpening Stone
	{ 28420, 50, 2954, 9264, STONE, 60 }, -- Fel Weightstone
	{ 7307, 0, 265, 1048576, LURE, 30 }, -- Flesh Eating Worm
	{ 3829, 30, 26, 173555, OIL, 40 }, -- Frost Oil
	{ 2871, 15, 14, 33219, STONE, 25 }, -- Heavy Sharpening Stone
	{ 3241, 15, 21, 9264, STONE, 25 }, -- Heavy Weightstone
	{ 20747, 40, 2625, 0, OIL, 50 }, -- Lesser Mana Oil
	{ 20746, 30, 2626, 0, OIL, 40 }, -- Lesser Wizard Oil
	{ 20745, 20, 2624, 0, OIL, 30 }, -- Minor Mana Oil
	{ 20744, 5, 2623, 0, OIL, 15 }, -- Minor Wizard Oil
	{ 6530, 0, 264, 1048576, LURE, 20 }, -- Nightcrawlers
	{ 34539, 70, 3266, 0, OIL, 70, ON_QUEL_DANAS }, -- Righteous Weapon Coating
	{ 2862, 1, 40, 33219, STONE, 5 }, -- Rough Sharpening Stone
	{ 3239, 1, 19, 9264, STONE, 5 }, -- Rough Weightstone
	{ 30696, 0, 3093, 173555, OIL, 52 }, -- Scourgebane
	{ 3824, 24, 25, 173555, OIL, 34 }, -- Shadow Oil
	{ 34861, 0, 266, 1048576, LURE, 30 }, -- Sharpened Fish Hook
	{ 6529, 0, 263, 1048576, LURE, 10 }, -- Shiny Bauble
	{ 7964, 25, 483, 33219, STONE, 35 }, -- Solid Sharpening Stone
	{ 7965, 25, 484, 9264, STONE, 35 }, -- Solid Weightstone
	{ 22521, 52, 2677, 0, OIL, 62 }, -- Superior Mana Oil
	{ 22522, 58, 2678, 0, OIL, 68 }, -- Superior Wizard Oil
	{ 20750, 40, 2627, 0, OIL, 50 }, -- Wizard Oil
}

-- { class, create = { { spell id, level learned } }, auras, items (lowest rank first), default }
ns.BUFF_WINDOW_SOULSTONE = {
	class = "WARLOCK",
	create = { { 693, 18 }, { 20752, 30 }, { 20755, 40 }, { 20756, 50 }, { 20757, 60 }, { 27238, 70 } },
	auras = { 20707, 20762, 20763, 20764, 20765, 27239 },
	items = { 5232, 16892, 16893, 16895, 16896, 22116 },
	default = 3,
}

-- { class, ranks = { spell ids } }, -- Name
ns.BUFF_WINDOW_RESURRECTIONS = {
	{ class = "PALADIN", ranks = { 7328, 10322, 10324, 20772, 20773 } }, -- Redemption
	{ class = "PRIEST", ranks = { 2006, 2010, 10880, 10881, 20770, 25435 } }, -- Resurrection
	{ class = "SHAMAN", ranks = { 2008, 20609, 20610, 20776, 20777 } }, -- Ancestral Spirit
}

--[[
How We Got the Data

Last Validated
	2026-10-22, TBC Anniversary 2.5.6.70006

Notes
	- Every buff one player can put on another that lasts more than two minutes: the ones worth keeping up on a group, and the ones a player may want to hand out on request. Only the rows for the player's own class are read, and only the ranks the player knows are cast.
	- Paladin blessings share exclusive = BLESSING: a target holds one blessing from each paladin, and a second replaces the first. So once one of yours is on a player, the window stops offering your others to them, and only offers that one again when it runs low. With none of yours on them, every blessing you turned on is offered and you pick.
	- greater lists every rank of a blessing's Greater version. It only counts toward "already has it" -- a Greater Blessing covers a class across the raid, not a party, so it is never offered as a party's group icon.
	- noCasters drops the buff for the classes in Data.CASTER_CLASSES, who get nothing from melee attack power (Blessing of Might).
	- Left out for lasting two minutes or less: Power Infusion, Innervate, Levitate, Slow Fall, Battle Shout (a warrior keeps Battle Shout up as a self buff instead, below). Left out for being item uses rather than spells: the stat scrolls. The Soulstone has a table of its own, below.
	- single is every rank of the single-target buff, and group every rank of its party-wide version. A player counts as buffed by any rank of either, because each rank's aura carries its own ID.
	- Each single-target rank carries the level it is learned at, because Classic doesn't pick a rank for the target: casting a rank on a player more than 10 levels below its learn level fails with "Target is too low level". The button casts the highest known rank the target can take, by its rank text ("Name(Rank 2)"), and offers nothing when even rank 1 is too high. Group versions always cast their highest rank, by name.
	- The learn levels are the client's own, checked against the SPELL_LEVEL_LEARNED column of a Validate Data run from this client.
	- Earth Shield starts OFF even though it belongs on a tank: only one can be up per shaman, so offering it to every tank would offer it to some who can't have it.
	- manaOnly drops the buff for classes with no mana (Data.NO_MANA_CLASSES), where Intellect and Spirit do nothing worth a reagent or a global cooldown.
	- default is who the buff is offered to until the player picks: ALL, TANK, HEALER or OFF, from Data.BUFF_AUDIENCE in Data/Data.lua. The everyday raid buffs start on ALL (Kings, Wisdom and Might among them, since not every paladin has Kings), Thorns and Fear Ward on TANK, and the situational ones OFF. A player's own choice is never overwritten.
	- Amplify and Dampen Magic replace each other on the target, so turning both on offers each to everyone carrying the other.
	- The setting is keyed by the first single-target ID, the lowest rank.
	- BUFF_WINDOW_PET_ICONS picks the icon in front of a pet's name: a warlock demon wears its own summoning spell's icon, found by the creature ID inside the pet's GUID, and any other pet wears Call Pet's. Only the spell IDs are stored; the icons come from the client.
	- BUFF_WINDOW_SELF_SPELLS are the long buffs a player can only put on themselves, behind the window's Self Buffs row: armors, shields, Inner Fire, Omen of Clarity, Trueshot Aura, Shadowform, Demonic Sacrifice, Soul Link, the paladin auras and hunter aspects, which have no timer and only need to be up, and Battle Shout, which a warrior shouts for the group but is listed here to keep up on themselves (Commanding Shout stays out, as a choice made per group); a rogue's poisons are weapon enchants, below.
	- Talent buffs (Omen of Clarity, Trueshot Aura, Shadowform, Demonic Sacrifice, Soul Link) carry the level their talent tier opens at, and a row only shows for a player who took the talent.
	- auras names the buffs a cast leaves when they aren't the cast's own ID: Demonic Sacrifice leaves one of five, by the demon sacrificed (Burning Wish, Fel Stamina, Touch of Shadow, Fel Energy, and the Felguard's own Touch of Shadow, 35701), and Soul Link's cast is a dummy that puts up 25228.
	- Demonic Sacrifice and Soul Link share exclusive = WARLOCK_DEMON: a Soul Link warlock keeps a demon out, so with Soul Link up the sacrifice stops asking, and the other way round. Soul Link starts OFF, and needsPet keeps it from asking while there is no demon to link to.
	- ranks is every rank, with the level it is learned at; the row casts the highest one known. Where ranks change name (Frost Armor into Ice Armor, Demon Skin into Demon Armor) they share a row, since they are one line of the same buff.
	- exclusive groups the self buffs only one of which can be up at a time (an armor, a paladin aura, an aspect, a shaman shield): with any one of yours up, the rest of its family stop asking. Turn on every one you might use, and the window offers them all only when none is up.
	- default is when the self buff shows until the player picks: minutes left (3) to recast before it drops, MISSING for one with no timer (an aura or aspect is either up or not), or OFF. Battle Shout starts on MISSING too: it lasts two minutes, so any minutes-left choice would only ask once it's gone anyway. Every aspect but Hawk starts off: Cheetah and the rest are swapped in for a moment, and Hawk is the one to come back to. A player's own choice is never overwritten.
	- The self-buff learn levels are checked the same way.
	- Shadowguard (Troll) and Touch of Weakness (Undead) are priest racial self buffs. Only a priest of that race knows them, and a row offers only the ranks the player knows. Their learn levels come from SpellLevels.
	- Left out of the self buffs: tracking, stealth, mounts, pet spells, Feign Death, totems, and cooldowns spent on the next action (Presence of Mind, Nature's Swiftness, Inner Focus, Cold Blood, Divine Favor, Elemental Mastery, Combustion). Moonkin Aura is left out because Moonkin Form puts it up, not a cast.
	- Ancestral Healing and Inspiration are left out: they're talent procs that land after a heal, not casts.
	- BUFF_WINDOW_WEAPON_ENCHANTS are the rogue poisons and shaman imbues. Each hand has its own timing per row on the Self-Buffs panel, and every row starts on for every hand: the window only offers an imbue you know or a poison in your bags, so a row you can't use yet stays out of the way.
	- A poison row is every item of its line with the level it requires, from Consumable Connoisseur's Poisons-TBC.lua (validated 2026-10-16 on this client). The button uses the best one in the rogue's bags they can use, on that hand's slot. The setting is keyed by the first item ID.
	- An imbue row is every rank, as a self buff's, and its duration: 30 minutes on this client. A row's duration only matters once it's no longer than a Reapply choice, when the imbue is offered only once it's gone (a poison lasts longer than any, so carries none). Rockbiter's last rank (25485) is learned at 70, which this client's SPELL_LEVEL_LEARNED confirms.
	- An imbue picks its own weapon and can't be pointed at one: the main hand, unless it has an enchant and a bare off-hand weapon is waiting. The window only offers the hand the next cast lands on (Features/Buff-Window-Self.lua).
	- Rockbiter here grows with weapon speed, so each of its ranks lists every enchant id it can put on (SpellItemEnchantment's "Rockbiter N" rows), and its cast is a script effect that names none in SpellEffect.
	- Each poison item and imbue rank carries the enchant id it puts on the weapon, which is what GetWeaponEnchantInfo reports, so the window can tell which of the player's picks a hand holds. Pulled from this client's SpellEffect (the ENCHANT_ITEM_TEMPORARY effect's misc value) and ItemEffect tables on wago.tools.
	- BUFF_WINDOW_WEAPON_HANDS is which hands each class is asked about: both, since a TBC shaman can dual wield.
	- BUFF_WINDOW_SOULSTONE is the Soulstone reminder: create is every Create Soulstone rank (cast by its bare name, which casts the best rank known), auras the Soulstone Resurrection buff each stone leaves, and items the stones, lowest first, the same lists as Consumable Connoisseur's Soulstones-TBC.lua and Conjure-Spells-TBC.lua.
	- BUFF_WINDOW_RESURRECTIONS is what the Buff Key casts first, on a dead target: every rank of each class's resurrection, cast by its bare name, which resolves to the highest known. Paladins, priests and shamans are listed. Rebirth stays out: it's a combat resurrection on a 20-minute cooldown. Mass Resurrection (32841) stays out too: this client's tables carry it with a priest skill row, but it isn't a rank of Resurrection, and no Validate Data run has shown a priest can learn it here.
	- BUFF_WINDOW_WEAPON_ITEMS is every other temporary weapon enchant, offered to any class: each item with the level it requires, the enchant id it puts on (SpellEffect's ENCHANT_ITEM_TEMPORARY misc value, through ItemEffect), and the weapon types its spell takes (SpellEquippedItems' EquippedItemSubclass mask, 0 for any weapon). kind files it under Oils, Stones or Lures on the Weapon Buffs panel: LURE for a fishing pole's, STONE for a sharpening stone or weightstone, OIL for the rest (oils, coatings, Bloodboil Poison, Scourgebane, the Weapon Cleaning Cloth). item level (ItemSparse) ranks them, strongest first: it orders a line Rough to Dense where the required level can't (every lure needs level 0). Fishing lures take only a fishing pole, a sharpening stone only a bladed weapon, a weightstone only a blunt one. Picked from the IDs supplied on 2026-10-19, plus every item this client's tables say puts a temporary enchant on a hand weapon, keeping only items whose spell enchants a hand weapon or fishing pole. Left out: rogue-only poisons (the rogue rows above), armor runes and other enchants that go on armor, shield coatings, and test or placeholder items. zones, on an item whose tooltip says it only works in certain places, names those places: instances by the map ID GetInstanceInfo reports and outdoor zones by the UiMap ID C_Map.GetBestMapForUnit reports, both from this client's Map and UiMap tables. The window offers such an item only there (Features/Buff-Window-Self.lua); an item without zones, anywhere. Here the Blessed and Righteous Weapon Coatings carry one: Magisters' Terrace (Map 585), Sunwell Plateau (Map 580, "The Sunwell") and the Isle of Quel'Danas (UiMap 1957).
	- Also left out of the weapon items: the Weather-Beaten Fishing Hat, whose lure only works while the hat is worn, and which using from the bags would put on instead; and Instant Toxin (5654), a poison that neither QuestieDB nor any spell on this client gives a source for, so likely unobtainable here.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SkillLineAbility?build=2.5.6.70006
	https://wago.tools/db2/SkillLine?build=2.5.6.70006
	https://wago.tools/db2/SpellLevels?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006
	https://wago.tools/db2/SpellItemEnchantment?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/SpellEquippedItems?build=2.5.6.70006
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/Talent?build=2.5.6.70006
	https://wago.tools/db2/Map?build=2.5.6.70006
	https://wago.tools/db2/UiMap?build=2.5.6.70006

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/TBC/tbcItemDB.lua
]]
