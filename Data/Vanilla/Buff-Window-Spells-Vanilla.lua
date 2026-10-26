local _, ns = ...
local Data = ns.Data

if ns.IS_DISCOVERY then
	return
end

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
		single = { { 1126, 1 }, { 5232, 10 }, { 6756, 20 }, { 5234, 30 }, { 8907, 40 }, { 9884, 50 }, { 9885, 60 } },
		group = { 21849, 21850 },
		default = ALL,
	}, -- Mark of the Wild
	{
		class = "DRUID",
		single = { { 467, 6 }, { 782, 14 }, { 1075, 24 }, { 8914, 34 }, { 9756, 44 }, { 9910, 54 } },
		default = TANK,
	}, -- Thorns
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		single = { { 1459, 1 }, { 1460, 14 }, { 1461, 28 }, { 10156, 42 }, { 10157, 56 } },
		group = { 23028 },
		manaOnly = true,
		default = ALL,
	}, -- Arcane Intellect
	{
		class = "MAGE",
		single = { { 1008, 18 }, { 8455, 30 }, { 10169, 42 }, { 10170, 54 } },
		default = OFF,
	}, -- Amplify Magic
	{
		class = "MAGE",
		single = { { 604, 12 }, { 8450, 24 }, { 8451, 36 }, { 10173, 48 }, { 10174, 60 } },
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
		single = { { 19742, 14 }, { 19850, 24 }, { 19852, 34 }, { 19853, 44 }, { 19854, 54 }, { 25290, 60 } },
		greater = { 25894, 25918 },
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
		},
		greater = { 25782, 25916 },
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
		single = { { 19977, 40 }, { 19978, 50 }, { 19979, 60 } },
		greater = { 25890 },
		exclusive = BLESSING,
		default = OFF,
	}, -- Blessing of Light
	{
		class = "PALADIN",
		single = { { 20911, 30 }, { 20912, 40 }, { 20913, 50 }, { 20914, 60 } },
		greater = { 25899 },
		exclusive = BLESSING,
		default = OFF,
	}, -- Blessing of Sanctuary
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		single = { { 1243, 1 }, { 1244, 12 }, { 1245, 24 }, { 2791, 36 }, { 10937, 48 }, { 10938, 60 } },
		group = { 21562, 21564 },
		default = ALL,
	}, -- Power Word: Fortitude
	{
		class = "PRIEST",
		single = { { 14752, 30 }, { 14818, 40 }, { 14819, 50 }, { 27841, 60 } },
		group = { 27681 },
		manaOnly = true,
		default = ALL,
	}, -- Divine Spirit
	{
		class = "PRIEST",
		single = { { 976, 30 }, { 10957, 42 }, { 10958, 56 } },
		group = { 27683 },
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
		single = { { 132, 26 }, { 2970, 38 }, { 11743, 50 } },
		default = OFF,
	}, -- Detect Greater Invisibility, Detect Invisibility, Detect Lesser Invisibility
}

-- { beast = spell id, demons = { [npc id] = spell id } }: the icon a pet's row wears, from its summoning spell
ns.BUFF_WINDOW_PET_ICONS = {
	beast = 883, -- Call Pet
	demons = {
		[416] = 688, -- Imp: Summon Imp
		[1860] = 697, -- Voidwalker: Summon Voidwalker
		[1863] = 712, -- Succubus: Summon Succubus
		[417] = 691, -- Felhunter: Summon Felhunter
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
		ranks = { { 19506, 40 }, { 20905, 50 }, { 20906, 60 } },
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
		ranks = { { 20043, 46 }, { 20190, 56 } },
		exclusive = ASPECT,
		default = OFF,
	}, -- Aspect of the Wild
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		ranks = { { 168, 1 }, { 7300, 10 }, { 7301, 20 }, { 7302, 30 }, { 7320, 40 }, { 10219, 50 }, { 10220, 60 } },
		exclusive = MAGE_ARMOR,
		default = 3,
	}, -- Frost Armor, Ice Armor
	{
		class = "MAGE",
		ranks = { { 6117, 34 }, { 22782, 46 }, { 22783, 58 } },
		exclusive = MAGE_ARMOR,
		default = 3,
	}, -- Mage Armor
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		ranks = { { 465, 1 }, { 10290, 10 }, { 643, 20 }, { 10291, 30 }, { 1032, 40 }, { 10292, 50 }, { 10293, 60 } },
		exclusive = PALADIN_AURA,
		default = MISSING,
	}, -- Devotion Aura
	{
		class = "PALADIN",
		ranks = { { 7294, 16 }, { 10298, 26 }, { 10299, 36 }, { 10300, 46 }, { 10301, 56 } },
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
		ranks = { { 19876, 28 }, { 19895, 40 }, { 19896, 52 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Shadow Resistance Aura
	{
		class = "PALADIN",
		ranks = { { 19888, 32 }, { 19897, 44 }, { 19898, 56 } },
		exclusive = PALADIN_AURA,
		default = OFF,
	}, -- Frost Resistance Aura
	{
		class = "PALADIN",
		ranks = { { 19891, 36 }, { 19899, 48 }, { 19900, 60 } },
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
		ranks = { { 25780, 16 } },
		default = OFF,
	}, -- Righteous Fury
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		ranks = { { 588, 12 }, { 7128, 20 }, { 602, 30 }, { 1006, 40 }, { 10951, 50 }, { 10952, 60 } },
		default = 3,
	}, -- Inner Fire
	{
		class = "PRIEST",
		ranks = { { 18137, 20 }, { 19308, 28 }, { 19309, 36 }, { 19310, 44 }, { 19311, 52 }, { 19312, 60 } },
		default = 3,
	}, -- Shadowguard
	{
		class = "PRIEST",
		ranks = { { 2652, 10 }, { 19261, 20 }, { 19262, 30 }, { 19264, 40 }, { 19265, 50 }, { 19266, 60 } },
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
		ranks = { { 324, 8 }, { 325, 16 }, { 905, 24 }, { 945, 32 }, { 8134, 40 }, { 10431, 48 }, { 10432, 56 } },
		exclusive = SHAMAN_SHIELD,
		default = 3,
	}, -- Lightning Shield
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		ranks = { { 687, 1 }, { 696, 10 }, { 706, 20 }, { 1086, 30 }, { 11733, 40 }, { 11734, 50 }, { 11735, 60 } },
		exclusive = WARLOCK_ARMOR,
		default = 3,
	}, -- Demon Skin, Demon Armor
	{
		class = "WARLOCK",
		ranks = { { 18788, 30 } },
		auras = { 18789, 18790, 18791, 18792 },
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
		ranks = { { 6673, 1 }, { 5242, 12 }, { 6192, 22 }, { 11549, 32 }, { 11550, 42 }, { 11551, 52 }, { 25289, 60 } },
		default = MISSING,
	}, -- Battle Shout
}

-- { class, duration (minutes), ranks = { { spell id, level learned, enchant id } } or items = { { item id, level required, enchant id } } }, -- Name
ns.BUFF_WINDOW_WEAPON_ENCHANTS = {
	-- Rogue ---------------------------------------------------------------------
	{
		class = "ROGUE",
		items = { { 3775, 20, 22 }, { 3776, 50, 603 } },
	}, -- Crippling Poison
	{
		class = "ROGUE",
		items = { { 2892, 30, 7 }, { 2893, 38, 8 }, { 8984, 46, 626 }, { 8985, 54, 627 }, { 20844, 60, 2630 } },
	}, -- Deadly Poison
	{
		class = "ROGUE",
		items = {
			{ 6947, 20, 323 },
			{ 5654, 24, 42 },
			{ 6949, 28, 324 },
			{ 6950, 36, 325 },
			{ 8926, 44, 623 },
			{ 8927, 52, 624 },
			{ 8928, 60, 625 },
		},
	}, -- Instant Poison, Instant Toxin
	{
		class = "ROGUE",
		items = { { 5237, 24, 35 }, { 6951, 38, 23 }, { 9186, 52, 643 } },
	}, -- Mind-numbing Poison
	{
		class = "ROGUE",
		items = { { 10918, 32, 703 }, { 10920, 40, 704 }, { 10921, 48, 705 }, { 10922, 56, 706 } },
	}, -- Wound Poison
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		duration = 5,
		ranks = {
			{ 8024, 10, 5 },
			{ 8027, 18, 4 },
			{ 8030, 26, 3 },
			{ 16339, 36, 523 },
			{ 16341, 46, 1665 },
			{ 16342, 56, 1666 },
		},
	}, -- Flametongue Weapon
	{
		class = "SHAMAN",
		duration = 5,
		ranks = { { 8033, 20, 2 }, { 8038, 28, 12 }, { 10456, 38, 524 }, { 16355, 48, 1667 }, { 16356, 58, 1668 } },
	}, -- Frostbrand Weapon
	{
		class = "SHAMAN",
		duration = 5,
		ranks = {
			{ 8017, 1, 29 },
			{ 8018, 8, 6 },
			{ 8019, 16, 1 },
			{ 10399, 24, 503 },
			{ 16314, 34, 1663 },
			{ 16315, 44, 683 },
			{ 16316, 54, 1664 },
		},
	}, -- Rockbiter Weapon
	{
		class = "SHAMAN",
		duration = 5,
		ranks = { { 8232, 30, 283 }, { 8235, 40, 284 }, { 10486, 50, 525 }, { 16362, 60, 1669 } },
	}, -- Windfury Weapon
}

-- The weapons each class keeps a poison or imbue on. A Classic Era shaman can't dual wield.
ns.BUFF_WINDOW_WEAPON_HANDS = {
	ROGUE = { MAIN, OFF_HAND },
	SHAMAN = { MAIN },
}

--[[
    Every other temporary weapon enchant, for any class: oils, sharpening
    stones, weightstones, fishing lures. weapon types is the item spell's
    weapon-subclass mask (0 for any weapon but a fishing pole); kind is the
    Weapon Buffs panel group it's listed under, and item level ranks it there
    and in the window, strongest first.
]]
local OIL, STONE, LURE = "OIL", "STONE", "LURE"

-- { item id, level required, enchant id, weapon types, kind, item level, zones }, -- Name
ns.BUFF_WINDOW_WEAPON_ITEMS = {
	{ 6533, 0, 266, 1048576, LURE, 30 }, -- Aquadynamic Fish Attractor
	{ 6811, 0, 264, 1048576, LURE, 20 }, -- Aquadynamic Fish Lens
	{ 23123, 50, 2685, 0, OIL, 55 }, -- Blessed Wizard Oil
	{ 6532, 0, 265, 1048576, LURE, 30 }, -- Bright Baubles
	{ 20748, 45, 2629, 0, OIL, 55 }, -- Brilliant Mana Oil
	{ 20749, 45, 2628, 0, OIL, 55 }, -- Brilliant Wizard Oil
	{ 2863, 5, 13, 33219, STONE, 15 }, -- Coarse Sharpening Stone
	{ 3240, 5, 20, 9264, STONE, 15 }, -- Coarse Weightstone
	{ 23122, 50, 2684, 1097203, STONE, 55 }, -- Consecrated Sharpening Stone
	{ 12404, 35, 1643, 33219, STONE, 45 }, -- Dense Sharpening Stone
	{ 12643, 35, 1703, 9264, STONE, 45 }, -- Dense Weightstone
	{ 18262, 50, 2506, 42483, STONE, 60 }, -- Elemental Sharpening Stone
	{ 7307, 0, 265, 1048576, LURE, 30 }, -- Flesh Eating Worm
	{ 3829, 30, 26, 173555, OIL, 40 }, -- Frost Oil
	{ 2871, 15, 14, 33219, STONE, 25 }, -- Heavy Sharpening Stone
	{ 3241, 15, 21, 9264, STONE, 25 }, -- Heavy Weightstone
	{ 20747, 40, 2625, 0, OIL, 50 }, -- Lesser Mana Oil
	{ 20746, 30, 2626, 0, OIL, 40 }, -- Lesser Wizard Oil
	{ 20745, 20, 2624, 0, OIL, 30 }, -- Minor Mana Oil
	{ 20744, 5, 2623, 0, OIL, 15 }, -- Minor Wizard Oil
	{ 6530, 0, 264, 1048576, LURE, 20 }, -- Nightcrawlers
	{ 2862, 1, 40, 33219, STONE, 5 }, -- Rough Sharpening Stone
	{ 3239, 1, 19, 9264, STONE, 5 }, -- Rough Weightstone
	{ 3824, 24, 25, 173555, OIL, 34 }, -- Shadow Oil
	{ 6529, 0, 263, 1048576, LURE, 10 }, -- Shiny Bauble
	{ 7964, 25, 483, 33219, STONE, 35 }, -- Solid Sharpening Stone
	{ 7965, 25, 484, 9264, STONE, 35 }, -- Solid Weightstone
	{ 20750, 40, 2627, 0, OIL, 50 }, -- Wizard Oil
}

-- { class, create = { { spell id, level learned } }, auras, items (lowest rank first), default }
ns.BUFF_WINDOW_SOULSTONE = {
	class = "WARLOCK",
	create = { { 693, 18 }, { 20752, 30 }, { 20755, 40 }, { 20756, 50 }, { 20757, 60 } },
	auras = { 20707, 20762, 20763, 20764, 20765 },
	items = { 5232, 16892, 16893, 16895, 16896 },
	default = 3,
}

-- { class, ranks = { spell ids } }, -- Name
ns.BUFF_WINDOW_RESURRECTIONS = {
	{ class = "PALADIN", ranks = { 7328, 10322, 10324, 20772, 20773 } }, -- Redemption
	{ class = "PRIEST", ranks = { 2006, 2010, 10880, 10881, 20770 } }, -- Resurrection
	{ class = "SHAMAN", ranks = { 2008, 20609, 20610, 20776, 20777 } }, -- Ancestral Spirit
}

--[[
How We Got the Data

Last Validated
	2026-10-22, Classic Era 1.15.9.70003

Notes
	- Every buff one player can put on another that lasts more than two minutes: the ones worth keeping up on a group, and the ones a player may want to hand out on request. Only the rows for the player's own class are read, and only the ranks the player knows are cast.
	- Paladin blessings share exclusive = BLESSING: a target holds one blessing from each paladin, and a second replaces the first. So once one of yours is on a player, the window stops offering your others to them, and only offers that one again when it runs low. With none of yours on them, every blessing you turned on is offered and you pick.
	- greater lists every rank of a blessing's Greater version. It only counts toward "already has it" -- a Greater Blessing covers a class across the raid, not a party, so it is never offered as a party's group icon.
	- noCasters drops the buff for the classes in Data.CASTER_CLASSES, who get nothing from melee attack power (Blessing of Might).
	- Left out for lasting two minutes or less: Power Infusion, Innervate, Levitate, Slow Fall, Battle Shout (a warrior keeps Battle Shout up as a self buff instead, below). Left out for being item uses rather than spells: the stat scrolls. The Soulstone has a table of its own, below.
	- single is every rank of the single-target buff, and group every rank of its party-wide version. A player counts as buffed by any rank of either, because each rank's aura carries its own ID.
	- Each single-target rank carries the level it is learned at, because Classic doesn't pick a rank for the target: casting a rank on a player more than 10 levels below its learn level fails with "Target is too low level". The button casts the highest known rank the target can take, by its rank text ("Name(Rank 2)"), and offers nothing when even rank 1 is too high. Group versions always cast their highest rank, by name.
	- The learn levels are the client's own, checked against the SPELL_LEVEL_LEARNED column of a Validate Data run from this client.
	- manaOnly drops the buff for classes with no mana (Data.NO_MANA_CLASSES), where Intellect and Spirit do nothing worth a reagent or a global cooldown.
	- default is who the buff is offered to until the player picks: ALL, TANK, HEALER or OFF, from Data.BUFF_AUDIENCE in Data/Data.lua. The everyday raid buffs start on ALL (Kings, Wisdom and Might among them, since not every paladin has Kings), Thorns and Fear Ward on TANK, and the situational ones OFF. A player's own choice is never overwritten.
	- Amplify and Dampen Magic replace each other on the target, so turning both on offers each to everyone carrying the other.
	- The setting is keyed by the first single-target ID, the lowest rank.
	- BUFF_WINDOW_PET_ICONS picks the icon in front of a pet's name: a warlock demon wears its own summoning spell's icon, found by the creature ID inside the pet's GUID, and any other pet wears Call Pet's. Only the spell IDs are stored; the icons come from the client.
	- BUFF_WINDOW_SELF_SPELLS are the long buffs a player can only put on themselves, behind the window's Self Buffs row: armors, shields, Inner Fire, Omen of Clarity, Trueshot Aura, Shadowform, Demonic Sacrifice, Soul Link, the paladin auras and hunter aspects, which have no timer and only need to be up, and Battle Shout, which a warrior shouts for the group but is listed here to keep up on themselves; a rogue's poisons are weapon enchants, below.
	- Talent buffs (Omen of Clarity, Trueshot Aura, Shadowform, Demonic Sacrifice, Soul Link) carry the level their talent tier opens at, and a row only shows for a player who took the talent.
	- auras names the buffs a cast leaves when they aren't the cast's own ID: Demonic Sacrifice leaves one of four, by the demon sacrificed (Burning Wish, Fel Stamina, Touch of Shadow, Fel Energy), and Soul Link's cast is a dummy that puts up 25228.
	- Demonic Sacrifice and Soul Link share exclusive = WARLOCK_DEMON: a Soul Link warlock keeps a demon out, so with Soul Link up the sacrifice stops asking, and the other way round. Soul Link starts OFF, and needsPet keeps it from asking while there is no demon to link to.
	- ranks is every rank, with the level it is learned at; the row casts the highest one known. Where ranks change name (Frost Armor into Ice Armor, Demon Skin into Demon Armor) they share a row, since they are one line of the same buff.
	- exclusive groups the self buffs only one of which can be up at a time (an armor, a paladin aura, an aspect, a shaman shield): with any one of yours up, the rest of its family stop asking. Turn on every one you might use, and the window offers them all only when none is up.
	- default is when the self buff shows until the player picks: minutes left (3) to recast before it drops, MISSING for one with no timer (an aura or aspect is either up or not), or OFF. Battle Shout starts on MISSING too: it lasts two minutes, so any minutes-left choice would only ask once it's gone anyway. Every aspect but Hawk starts off: Cheetah and the rest are swapped in for a moment, and Hawk is the one to come back to. A player's own choice is never overwritten.
	- The self-buff learn levels are checked the same way.
	- Shadowguard (Troll) and Touch of Weakness (Undead) are priest racial self buffs. Only a priest of that race knows them, and a row offers only the ranks the player knows. Their learn levels come from SpellLevels.
	- Left out of the self buffs: tracking, stealth, mounts, pet spells, Feign Death, totems, and cooldowns spent on the next action (Presence of Mind, Nature's Swiftness, Inner Focus, Cold Blood, Divine Favor, Elemental Mastery, Combustion). Moonkin Aura is left out because Moonkin Form puts it up, not a cast.
	- BUFF_WINDOW_WEAPON_ENCHANTS are the rogue poisons and shaman imbues. Each hand has its own timing per row on the Self-Buffs panel, and every row starts on for every hand: the window only offers an imbue you know or a poison in your bags, so a row you can't use yet stays out of the way.
	- A poison row is every item of its line with the level it requires, from Consumable Connoisseur's Poisons-Vanilla.lua (validated 2026-10-16 on this client); Instant Toxin is a lower Instant Poison and shares its row. The button uses the best one in the rogue's bags they can use, on that hand's slot. The setting is keyed by the first item ID.
	- An imbue row is every rank, as a self buff's, and its duration: 5 minutes on this client, so under a 5- or 10-minute Reapply an imbue is offered only once it's gone, rather than the moment it lands. A poison lasts longer than any Reapply choice, so carries none.
	- Each poison item and imbue rank carries the enchant id it puts on the weapon, which is what GetWeaponEnchantInfo reports, so the window can tell which of the player's picks a hand holds. Pulled from this client's SpellEffect (the ENCHANT_ITEM_TEMPORARY effect's misc value) and ItemEffect tables on wago.tools.
	- BUFF_WINDOW_WEAPON_HANDS is which hands each class is asked about. A Classic Era shaman can't dual wield, so only the main hand.
	- BUFF_WINDOW_SOULSTONE is the Soulstone reminder: create is every Create Soulstone rank (cast by its bare name, since each tier here is its own spell), auras the Soulstone Resurrection buff each stone leaves, and items the stones, lowest first, the same lists as Consumable Connoisseur's Soulstones-Vanilla.lua and Conjure-Spells-Vanilla.lua.
	- BUFF_WINDOW_RESURRECTIONS is what the Buff Key casts first, on a dead target: every rank of each class's resurrection, cast by its bare name, which resolves to the highest known. Paladins, priests and shamans are listed.
	- This client's tables also carry Season of Discovery's rune buffs (Beacon of Light, Earth Shield, Spirit of the Alpha, Water Shield, Fel Armor, Aspect of the Viper, Aspect of the Falcon, Heart of the Lion, the second Righteous Fury) and Commanding Shout, and its weapon items: the Blackfathom Sharpening Stone and Mana Oil, the Weapon Cleaning Cloth, Enchanted Repellent, the Weighted Consecrated Sharpening Stone, the reissued Blessed Wizard Oil and Consecrated Sharpening Stone (238234, 238241), and the Sebacious, Numbing, Atrophic and Occult poisons. They belong to Data/Discovery/, so they're left out here.
	- BUFF_WINDOW_WEAPON_ITEMS is every other temporary weapon enchant, offered to any class: each item with the level it requires, the enchant id it puts on (SpellEffect's ENCHANT_ITEM_TEMPORARY misc value, through ItemEffect), and the weapon types its spell takes (SpellEquippedItems' EquippedItemSubclass mask, 0 for any weapon). kind files it under Oils, Stones or Lures on the Weapon Buffs panel: LURE for a fishing pole's, STONE for a sharpening stone or weightstone, OIL for the rest (oils, coatings, Bloodboil Poison, Scourgebane, the Weapon Cleaning Cloth). item level (ItemSparse) ranks them, strongest first: it orders a line Rough to Dense where the required level can't (every lure needs level 0). Fishing lures take only a fishing pole, a sharpening stone only a bladed weapon, a weightstone only a blunt one. Picked from the IDs supplied on 2026-10-19, keeping only items whose spell enchants a hand weapon or fishing pole. Left out: rogue-only poisons (the rogue rows above), armor runes and other enchants that go on armor, shield coatings, and test or placeholder items. zones, on an item whose tooltip says it only works in certain places, names those places: instances by the map ID GetInstanceInfo reports and outdoor zones by the UiMap ID C_Map.GetBestMapForUnit reports, both from this client's Map and UiMap tables. The window offers such an item only there (Features/Buff-Window-Self.lua); an item without zones, anywhere. No item on this client carries one.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SkillLineAbility?build=1.15.9.70003
	https://wago.tools/db2/SkillLine?build=1.15.9.70003
	https://wago.tools/db2/SpellLevels?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/SpellEquippedItems?build=1.15.9.70003
	https://wago.tools/db2/Item?build=1.15.9.70003
	https://wago.tools/db2/Talent?build=1.15.9.70003

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicItemDB.lua
]]
