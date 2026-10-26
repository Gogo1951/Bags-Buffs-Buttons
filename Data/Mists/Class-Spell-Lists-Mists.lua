local _, ns = ...

-- [classToken] = { mouseoverEnemy, mouseoverFriend, resurrect, utility, attacks, crowdControl, offensives, defensives, selfBuffs, pageBuffs, heals, noCooldown, traps, totems, seals, blessings, curses, shocks, finishers, pets, teleports, threat, buffs, cursor, channeled, stealth = { spellId }, noToggle = { spellId }, stanceSlots = { stanceSpellId }, stances = { [spellId] = { stanceSpellId } }, petAbilities = { [summonSpellId] = { abilityId, familyId } }, extraSpells = { spellId }, autoShot = spellId }
ns.CLASS_SPELL_LISTS = {
	DEATHKNIGHT = {
		mouseoverEnemy = {
			45477, -- Icy Touch
			47541, -- Death Coil
			49184, -- Howling Blast
			77575, -- Outbreak
			45524, -- Chains of Ice
			49576, -- Death Grip
			56222, -- Dark Command
			47528, -- Mind Freeze
			47476, -- Strangulate
			108194, -- Asphyxiate
			111673, -- Control Undead
			77606, -- Dark Simulacrum
			108196, -- Death Siphon
			123693, -- Plague Leech
			49206, -- Summon Gargoyle
			108199, -- Gorefiend's Grasp
		},
		mouseoverFriend = {
			61999, -- Raise Ally
			49016, -- Unholy Frenzy
			108199, -- Gorefiend's Grasp
		},
		resurrect = {
			61999, -- Raise Ally
		},
		utility = {
			49016, -- Unholy Frenzy
		},
		crowdControl = {
			47476, -- Strangulate
			108194, -- Asphyxiate
			108200, -- Remorseless Winter
			49576, -- Death Grip
			108199, -- Gorefiend's Grasp
			45524, -- Chains of Ice
		},
		defensives = {
			48792, -- Icebound Fortitude
			48707, -- Anti-Magic Shell
			55233, -- Vampiric Blood
			49222, -- Bone Shield
			49028, -- Dancing Rune Weapon
			49039, -- Lichborne
			48743, -- Death Pact
			119975, -- Conversion
		},
		pageBuffs = {
			57330, -- Horn of Winter
		},
		threat = {
			56222, -- Dark Command
		},
		noCooldown = {
			3714, -- Path of Frost
			47528, -- Mind Freeze
		},
		teleports = {
			50977, -- Death Gate
		},
		cursor = {
			43265, -- Death and Decay
			51052, -- Anti-Magic Zone
		},
		channeled = {
			42650, -- Army of the Dead
		},
		stealth = {},
	},
	DRUID = {
		mouseoverEnemy = {
			5176, -- Wrath
			2912, -- Starfire
			78674, -- Starsurge
			8921, -- Moonfire
			93402, -- Sunfire
			339, -- Entangling Roots
			770, -- Faerie Fire
			33786, -- Cyclone
			2637, -- Hibernate
			2908, -- Soothe
			102359, -- Mass Entanglement
			6795, -- Growl
			106839, -- Skull Bash
			78675, -- Solar Beam
			5211, -- Mighty Bash
		},
		mouseoverFriend = {
			5185, -- Healing Touch
			8936, -- Regrowth
			774, -- Rejuvenation
			50464, -- Nourish
			33763, -- Lifebloom
			18562, -- Swiftmend
			48438, -- Wild Growth
			102351, -- Cenarion Ward
			102342, -- Ironbark
			88423, -- Nature's Cure
			2782, -- Remove Corruption
			20484, -- Rebirth
			50769, -- Revive
			29166, -- Innervate
			1126, -- Mark of the Wild
			110309, -- Symbiosis
		},
		resurrect = {
			20484, -- Rebirth
			50769, -- Revive
		},
		utility = {
			29166, -- Innervate
			102342, -- Ironbark
			1126, -- Mark of the Wild
			88423, -- Nature's Cure
			2782, -- Remove Corruption
			110309, -- Symbiosis
		},
		crowdControl = {
			33786, -- Cyclone
			339, -- Entangling Roots
			2637, -- Hibernate
			5211, -- Mighty Bash
			132469, -- Typhoon
			102359, -- Mass Entanglement
			99, -- Disorienting Roar
			102793, -- Ursol's Vortex
			78675, -- Solar Beam
			99, -- Demoralizing Roar
		},
		offensives = {
			5217, -- Tiger's Fury
		},
		defensives = {
			22812, -- Barkskin
			61336, -- Survival Instincts
			106922, -- Might of Ursoc
			22842, -- Frenzied Regeneration
			102342, -- Ironbark
			62606, -- Savage Defense
		},
		pageBuffs = {
			1126, -- Mark of the Wild
		},
		heals = {
			740, -- Tranquility
		},
		threat = {
			6795, -- Growl
		},
		noCooldown = {
			29166, -- Innervate
			1850, -- Dash
			106898, -- Stampeding Roar
			2908, -- Soothe
			106839, -- Skull Bash
		},
		finishers = {
			22568, -- Ferocious Bite
			1079, -- Rip
			22570, -- Maim
			52610, -- Savage Roar
		},
		teleports = {
			18960, -- Teleport: Moonglade
		},
		cursor = {
			16914, -- Hurricane
			102793, -- Ursol's Vortex
		},
		channeled = {
			740, -- Tranquility
			16914, -- Hurricane
			127663, -- Astral Communion
		},
		stealth = {
			5215, -- Prowl
		},
	},
	HUNTER = {
		mouseoverEnemy = {
			3044, -- Arcane Shot
			19434, -- Aimed Shot
			56641, -- Steady Shot
			77767, -- Cobra Shot
			53209, -- Chimera Shot
			53301, -- Explosive Shot
			3674, -- Black Arrow
			53351, -- Kill Shot
			2643, -- Multi-Shot
			1978, -- Serpent Sting
			82654, -- Widow Venom
			5116, -- Concussive Shot
			147362, -- Counter Shot
			34490, -- Silencing Shot
			19503, -- Scatter Shot
			19386, -- Wyvern Sting
			20736, -- Distracting Shot
			19801, -- Tranquilizing Shot
			1130, -- Hunter's Mark
			1513, -- Scare Beast
			1462, -- Beast Lore
			34026, -- Kill Command
			131894, -- A Murder of Crows
			120679, -- Dire Beast
			117050, -- Glaive Toss
			109259, -- Powershot
			120360, -- Barrage
			121818, -- Stampede
		},
		mouseoverFriend = {
			34477, -- Misdirection
			53271, -- Master's Call
		},
		utility = {
			53271, -- Master's Call
			34477, -- Misdirection
		},
		crowdControl = {
			19503, -- Scatter Shot
			19386, -- Wyvern Sting
			109248, -- Binding Shot
			19577, -- Intimidation
			1513, -- Scare Beast
			34490, -- Silencing Shot
			5116, -- Concussive Shot
			2974, -- Wing Clip
		},
		defensives = {
			19263, -- Deterrence
			781, -- Disengage
		},
		threat = {
			20736, -- Distracting Shot
		},
		noCooldown = {
			5384, -- Feign Death
			34477, -- Misdirection
			53271, -- Master's Call
			6197, -- Eagle Eye
			1543, -- Flare
			51753, -- Camouflage
			1130, -- Hunter's Mark
			19801, -- Tranquilizing Shot
			147362, -- Counter Shot
		},
		traps = {
			1499, -- Freezing Trap
			13809, -- Ice Trap
			13813, -- Explosive Trap
			34600, -- Snake Trap
		},
		pets = {
			883, -- Call Pet 1
			83242, -- Call Pet 2
			83243, -- Call Pet 3
			83244, -- Call Pet 4
			83245, -- Call Pet 5
			2641, -- Dismiss Pet
			982, -- Revive Pet
			136, -- Mend Pet
			1515, -- Tame Beast
			1462, -- Beast Lore
			55709, -- Heart of the Phoenix
		},
		cursor = {
			1543, -- Flare
			109248, -- Binding Shot
		},
		channeled = {
			120360, -- Barrage
			6197, -- Eagle Eye
			1515, -- Tame Beast
		},
		stealth = {},
		noToggle = {
			13165, -- Aspect of the Hawk
			109260, -- Aspect of the Iron Hawk
			5118, -- Aspect of the Cheetah
			13159, -- Aspect of the Pack
		},
	},
	MAGE = {
		mouseoverEnemy = {
			116, -- Frostbolt
			133, -- Fireball
			44614, -- Frostfire Bolt
			30451, -- Arcane Blast
			44425, -- Arcane Barrage
			5143, -- Arcane Missiles
			30455, -- Ice Lance
			2136, -- Fire Blast
			2948, -- Scorch
			11366, -- Pyroblast
			108853, -- Inferno Blast
			44457, -- Living Bomb
			114923, -- Nether Tempest
			112948, -- Frost Bomb
			44572, -- Deep Freeze
			102051, -- Frostjaw
			118, -- Polymorph
			2139, -- Counterspell
			30449, -- Spellsteal
			31589, -- Slow
			11129, -- Combustion
		},
		mouseoverFriend = {
			1459, -- Arcane Brilliance
			475, -- Remove Curse
			130, -- Slow Fall
			111264, -- Ice Ward
		},
		utility = {
			1459, -- Arcane Brilliance
			111264, -- Ice Ward
			475, -- Remove Curse
			130, -- Slow Fall
		},
		crowdControl = {
			118, -- Polymorph
			122, -- Frost Nova
			31661, -- Dragon's Breath
			113724, -- Ring of Frost
			44572, -- Deep Freeze
			102051, -- Frostjaw
			31589, -- Slow
		},
		defensives = {
			45438, -- Ice Block
			115610, -- Temporal Shield
			1463, -- Incanter's Ward
			110959, -- Greater Invisibility
			66, -- Invisibility
			111264, -- Ice Ward
			11426, -- Ice Barrier
		},
		pageBuffs = {
			1459, -- Arcane Brilliance
			61316, -- Dalaran Brilliance
		},
		noCooldown = {
			1953, -- Blink
			130, -- Slow Fall
			30449, -- Spellsteal
			2139, -- Counterspell
		},
		teleports = {
			3561, -- Teleport: Stormwind
			10059, -- Portal: Stormwind
			3562, -- Teleport: Ironforge
			11416, -- Portal: Ironforge
			3565, -- Teleport: Darnassus
			11419, -- Portal: Darnassus
			32271, -- Teleport: Exodar
			32266, -- Portal: Exodar
			{ 33690, 35715 }, -- Teleport: Shattrath
			{ 33691, 35717 }, -- Portal: Shattrath
			49359, -- Teleport: Theramore
			49360, -- Portal: Theramore
			{ 88342, 88344 }, -- Teleport: Tol Barad
			{ 88345, 88346 }, -- Portal: Tol Barad
			{ 132621, 132627 }, -- Teleport: Vale of Eternal Blossoms
			{ 132620, 132626 }, -- Portal: Vale of Eternal Blossoms
			3567, -- Teleport: Orgrimmar
			11417, -- Portal: Orgrimmar
			3563, -- Teleport: Undercity
			11418, -- Portal: Undercity
			3566, -- Teleport: Thunder Bluff
			11420, -- Portal: Thunder Bluff
			32272, -- Teleport: Silvermoon
			32267, -- Portal: Silvermoon
			49358, -- Teleport: Stonard
			49361, -- Portal: Stonard
			53140, -- Teleport: Dalaran
			53142, -- Portal: Dalaran
			120145, -- Ancient Teleport: Dalaran
			120146, -- Ancient Portal: Dalaran
		},
		selfBuffs = {
			7302, -- Frost Armor
			6117, -- Mage Armor
			30482, -- Molten Armor
		},
		cursor = {
			10, -- Blizzard
			2120, -- Flamestrike
			113724, -- Ring of Frost
			116011, -- Rune of Power
		},
		channeled = {
			5143, -- Arcane Missiles
			10, -- Blizzard
			12051, -- Evocation
		},
		stealth = {},
	},
	MONK = {
		mouseoverEnemy = {
			117952, -- Crackling Jade Lightning
			115546, -- Provoke
			115078, -- Paralysis
			116705, -- Spear Hand Strike
			116095, -- Disable
			117368, -- Grapple Weapon
			115080, -- Touch of Death
			122057, -- Clash
			122470, -- Touch of Karma
			115098, -- Chi Wave
			123904, -- Invoke Xuen, the White Tiger
			137639, -- Storm, Earth, and Fire
		},
		mouseoverFriend = {
			115175, -- Soothing Mist
			116694, -- Surging Mist
			124682, -- Enveloping Mist
			115151, -- Renewing Mist
			116849, -- Life Cocoon
			115450, -- Detox
			115178, -- Resuscitate
			115921, -- Legacy of the Emperor
			116841, -- Tiger's Lust
			124081, -- Zen Sphere
			115098, -- Chi Wave
			116844, -- Ring of Peace
		},
		resurrect = {
			115178, -- Resuscitate
		},
		utility = {
			115450, -- Detox
			115921, -- Legacy of the Emperor
			116849, -- Life Cocoon
			116844, -- Ring of Peace
			116841, -- Tiger's Lust
		},
		crowdControl = {
			115078, -- Paralysis
			119381, -- Leg Sweep
			119392, -- Charging Ox Wave
			117368, -- Grapple Weapon
			116844, -- Ring of Peace
			116095, -- Disable
		},
		defensives = {
			115203, -- Fortifying Brew
			115176, -- Zen Meditation
			122278, -- Dampen Harm
			122783, -- Diffuse Magic
			122470, -- Touch of Karma
			115295, -- Guard
			115308, -- Elusive Brew
			116849, -- Life Cocoon
		},
		pageBuffs = {
			115921, -- Legacy of the Emperor
			116781, -- Legacy of the White Tiger
		},
		heals = {
			115310, -- Revival
			116670, -- Uplift
		},
		threat = {
			115546, -- Provoke
		},
		noCooldown = {
			109132, -- Roll
			101643, -- Transcendence
			119996, -- Transcendence: Transfer
			116841, -- Tiger's Lust
			116705, -- Spear Hand Strike
		},
		teleports = {
			126892, -- Zen Pilgrimage
		},
		cursor = {
			115180, -- Dizzying Haze
			115460, -- Healing Sphere
			115315, -- Summon Black Ox Statue
			115313, -- Summon Jade Serpent Statue
		},
		channeled = {
			117952, -- Crackling Jade Lightning
			113656, -- Fists of Fury
			115175, -- Soothing Mist
			101546, -- Spinning Crane Kick
			115294, -- Mana Tea
			115176, -- Zen Meditation
		},
		stealth = {},
	},
	PALADIN = {
		mouseoverEnemy = {
			20271, -- Judgment
			879, -- Exorcism
			24275, -- Hammer of Wrath
			31935, -- Avenger's Shield
			2812, -- Denounce
			853, -- Hammer of Justice
			105593, -- Fist of Justice
			20066, -- Repentance
			10326, -- Turn Evil
			62124, -- Reckoning
			96231, -- Rebuke
			20473, -- Holy Shock
			114157, -- Execution Sentence
			114165, -- Holy Prism
		},
		mouseoverFriend = {
			635, -- Holy Light
			82326, -- Divine Light
			19750, -- Flash of Light
			82327, -- Holy Radiance
			85673, -- Word of Glory
			114163, -- Eternal Flame
			20473, -- Holy Shock
			633, -- Lay on Hands
			53563, -- Beacon of Light
			20925, -- Sacred Shield
			1044, -- Hand of Freedom
			1022, -- Hand of Protection
			6940, -- Hand of Sacrifice
			1038, -- Hand of Salvation
			114039, -- Hand of Purity
			4987, -- Cleanse
			7328, -- Redemption
			114157, -- Execution Sentence
			114165, -- Holy Prism
			20217, -- Blessing of Kings
			19740, -- Blessing of Might
		},
		resurrect = {
			7328, -- Redemption
		},
		utility = {
			4987, -- Cleanse
			1044, -- Hand of Freedom
			1022, -- Hand of Protection
			114039, -- Hand of Purity
			6940, -- Hand of Sacrifice
			1038, -- Hand of Salvation
		},
		crowdControl = {
			853, -- Hammer of Justice
			105593, -- Fist of Justice
			20066, -- Repentance
			115750, -- Blinding Light
			10326, -- Turn Evil
		},
		defensives = {
			642, -- Divine Shield
			498, -- Divine Protection
			31850, -- Ardent Defender
			86659, -- Guardian of Ancient Kings
			1022, -- Hand of Protection
			6940, -- Hand of Sacrifice
			114039, -- Hand of Purity
			31821, -- Devotion Aura
			633, -- Lay on Hands
			31842, -- Divine Favor
		},
		heals = {
			85222, -- Light of Dawn
		},
		threat = {
			25780, -- Righteous Fury
			62124, -- Hand of Reckoning
		},
		noCooldown = {
			1044, -- Hand of Freedom
			1038, -- Hand of Salvation
			96231, -- Rebuke
		},
		seals = {
			31801, -- Seal of Truth
			20154, -- Seal of Righteousness
			20164, -- Seal of Justice
			20165, -- Seal of Insight
		},
		blessings = {
			20217, -- Blessing of Kings
			19740, -- Blessing of Might
		},
		cursor = {
			114158, -- Light's Hammer
		},
		channeled = {},
		stealth = {},
	},
	PRIEST = {
		mouseoverEnemy = {
			585, -- Smite
			14914, -- Holy Fire
			88625, -- Holy Word: Chastise
			8092, -- Mind Blast
			15407, -- Mind Flay
			73510, -- Mind Spike
			589, -- Shadow Word: Pain
			32379, -- Shadow Word: Death
			34914, -- Vampiric Touch
			2944, -- Devouring Plague
			48045, -- Mind Sear
			47540, -- Penance
			121135, -- Cascade
			528, -- Dispel Magic
			9484, -- Shackle Undead
			605, -- Dominate Mind
			64044, -- Psychic Horror
			15487, -- Silence
			34433, -- Shadowfiend
			123040, -- Mindbender
		},
		mouseoverFriend = {
			2061, -- Flash Heal
			2050, -- Heal
			2060, -- Greater Heal
			32546, -- Binding Heal
			139, -- Renew
			17, -- Power Word: Shield
			33076, -- Prayer of Mending
			596, -- Prayer of Healing
			34861, -- Circle of Healing
			47540, -- Penance
			121135, -- Cascade
			47788, -- Guardian Spirit
			33206, -- Pain Suppression
			108968, -- Void Shift
			73325, -- Leap of Faith
			527, -- Purify
			2006, -- Resurrection
			6346, -- Fear Ward
			1706, -- Levitate
			21562, -- Power Word: Fortitude
			48045, -- Mind Sear
		},
		resurrect = {
			2006, -- Resurrection
		},
		utility = {
			6346, -- Fear Ward
			47788, -- Guardian Spirit
			73325, -- Leap of Faith
			1706, -- Levitate
			33206, -- Pain Suppression
			21562, -- Power Word: Fortitude
			527, -- Purify
			108968, -- Void Shift
		},
		attacks = {
			48045, -- Mind Sear
		},
		crowdControl = {
			8122, -- Psychic Scream
			605, -- Mind Control
			9484, -- Shackle Undead
			88625, -- Holy Word: Chastise
			64044, -- Psychic Horror
			15487, -- Silence
			108920, -- Void Tendrils
			108921, -- Psyfiend
		},
		defensives = {
			47585, -- Dispersion
			33206, -- Pain Suppression
			47788, -- Guardian Spirit
			19236, -- Desperate Prayer
			62618, -- Power Word: Barrier
			112833, -- Spectral Guise
		},
		pageBuffs = {
			21562, -- Power Word: Fortitude
			6346, -- Fear Ward
		},
		heals = {
			132157, -- Holy Nova
			64843, -- Divine Hymn
			126135, -- Lightwell
		},
		threat = {
			586, -- Fade
		},
		noCooldown = {
			1706, -- Levitate
			73325, -- Leap of Faith
			2096, -- Mind Vision
			108968, -- Void Shift
		},
		selfBuffs = {
			588, -- Inner Fire
			73413, -- Inner Will
			89485, -- Inner Focus
		},
		cursor = {
			32375, -- Mass Dispel
			62618, -- Power Word: Barrier
			126135, -- Lightwell
			121536, -- Angelic Feather
			108921, -- Psyfiend
		},
		channeled = {
			15407, -- Mind Flay
			48045, -- Mind Sear
			47540, -- Penance
			64843, -- Divine Hymn
			64901, -- Hymn of Hope
			605, -- Dominate Mind
			2096, -- Mind Vision
		},
		stealth = {},
	},
	ROGUE = {
		mouseoverEnemy = {
			1766, -- Kick
			1776, -- Gouge
			2094, -- Blind
			6770, -- Sap
			921, -- Pick Pocket
			121733, -- Throw
			26679, -- Deadly Throw
			114014, -- Shuriken Toss
			73981, -- Redirect
			137619, -- Marked for Death
			51722, -- Dismantle
			36554, -- Shadowstep
		},
		mouseoverFriend = {
			57934, -- Tricks of the Trade
			36554, -- Shadowstep
		},
		utility = {
			57934, -- Tricks of the Trade
			36554, -- Shadowstep
		},
		crowdControl = {
			6770, -- Sap
			1776, -- Gouge
			2094, -- Blind
			1833, -- Cheap Shot
			51722, -- Dismantle
		},
		defensives = {
			5277, -- Evasion
			31224, -- Cloak of Shadows
			1856, -- Vanish
			74001, -- Combat Readiness
			76577, -- Smoke Bomb
		},
		threat = {
			1966, -- Feint
		},
		noCooldown = {
			2983, -- Sprint
			36554, -- Shadowstep
			57934, -- Tricks of the Trade
			1804, -- Pick Lock
			921, -- Pick Pocket
			1725, -- Distract
			1842, -- Disarm Trap
			108212, -- Burst of Speed
			114018, -- Shroud of Concealment
			1766, -- Kick
		},
		finishers = {
			2098, -- Eviscerate
			5171, -- Slice and Dice
			1943, -- Rupture
			408, -- Kidney Shot
			32645, -- Envenom
			121411, -- Crimson Tempest
			73651, -- Recuperate
			26679, -- Deadly Throw
		},
		cursor = {
			1725, -- Distract
		},
		channeled = {},
		stealth = {
			1784, -- Stealth
		},
	},
	SHAMAN = {
		mouseoverEnemy = {
			403, -- Lightning Bolt
			421, -- Chain Lightning
			51505, -- Lava Burst
			117014, -- Elemental Blast
			8042, -- Earth Shock
			8050, -- Flame Shock
			8056, -- Frost Shock
			370, -- Purge
			57994, -- Wind Shear
			51514, -- Hex
			76780, -- Bind Elemental
		},
		mouseoverFriend = {
			8004, -- Healing Surge
			331, -- Healing Wave
			77472, -- Greater Healing Wave
			1064, -- Chain Heal
			61295, -- Riptide
			974, -- Earth Shield
			77130, -- Purify Spirit
			51886, -- Cleanse Spirit
			2008, -- Ancestral Spirit
			546, -- Water Walking
		},
		resurrect = {
			2008, -- Ancestral Spirit
		},
		utility = {
			51886, -- Cleanse Spirit
			77130, -- Purify Spirit
			546, -- Water Walking
		},
		crowdControl = {
			51514, -- Hex
			51490, -- Thunderstorm
		},
		defensives = {
			30823, -- Shamanistic Rage
			108271, -- Astral Shift
		},
		heals = {
			73920, -- Healing Rain
		},
		noCooldown = {
			6196, -- Far Sight
			370, -- Purge
			57994, -- Wind Shear
		},
		shocks = {
			8042, -- Earth Shock
			8050, -- Flame Shock
			8056, -- Frost Shock
		},
		totems = {
			3599, -- Searing Totem
			8190, -- Magma Totem
			2894, -- Fire Elemental Totem
			2062, -- Earth Elemental Totem
			2484, -- Earthbind Totem
			51485, -- Earthgrab Totem
			8143, -- Tremor Totem
			108270, -- Stone Bulwark Totem
			8177, -- Grounding Totem
			108269, -- Capacitor Totem
			5394, -- Healing Stream Totem
			108280, -- Healing Tide Totem
			16190, -- Mana Tide Totem
			98008, -- Spirit Link Totem
			108273, -- Windwalk Totem
			120668, -- Stormlash Totem
		},
		teleports = {
			556, -- Astral Recall
		},
		selfBuffs = {
			324, -- Lightning Shield
			52127, -- Water Shield
			8024, -- Flametongue Weapon
			8232, -- Windfury Weapon
			8033, -- Frostbrand Weapon
			51730, -- Earthliving Weapon
			8017, -- Rockbiter Weapon
		},
		cursor = {
			61882, -- Earthquake
			73920, -- Healing Rain
			108287, -- Totemic Projection
			6196, -- Far Sight
		},
		channeled = {
			6196, -- Far Sight
		},
		stealth = {},
	},
	WARLOCK = {
		mouseoverEnemy = {
			686, -- Shadow Bolt
			29722, -- Incinerate
			116858, -- Chaos Bolt
			17962, -- Conflagrate
			348, -- Immolate
			17877, -- Shadowburn
			6353, -- Soul Fire
			105174, -- Hand of Gul'dan
			77799, -- Fel Flame
			48181, -- Haunt
			103103, -- Malefic Grasp
			689, -- Drain Life
			1120, -- Drain Soul
			172, -- Corruption
			980, -- Agony
			30108, -- Unstable Affliction
			27243, -- Seed of Corruption
			86121, -- Soul Swap
			109466, -- Curse of Enfeeblement
			1490, -- Curse of the Elements
			18223, -- Curse of Exhaustion
			5782, -- Fear
			710, -- Banish
			6789, -- Mortal Coil
			80240, -- Havoc
			1098, -- Subjugate Demon
			18540, -- Summon Doomguard
		},
		mouseoverFriend = {
			5697, -- Unending Breath
			20707, -- Soulstone
			109773, -- Dark Intent
		},
		utility = {
			109773, -- Dark Intent
			20707, -- Soulstone
			5697, -- Unending Breath
		},
		crowdControl = {
			5782, -- Fear
			5484, -- Howl of Terror
			6789, -- Mortal Coil
			710, -- Banish
			30283, -- Shadowfury
			111397, -- Blood Horror
			1098, -- Enslave Demon
		},
		defensives = {
			104773, -- Unending Resolve
			110913, -- Dark Bargain
			108416, -- Sacrificial Pact
			108359, -- Dark Regeneration
			6229, -- Twilight Ward
			29858, -- Soulshatter
		},
		pageBuffs = {
			109773, -- Dark Intent
			5697, -- Unending Breath
		},
		noCooldown = {
			20707, -- Soulstone
			698, -- Ritual of Summoning
			29893, -- Ritual of Souls
			48018, -- Demonic Circle: Summon
			48020, -- Demonic Circle: Teleport
			126, -- Eye of Kilrogg
			111771, -- Demonic Gateway
		},
		pets = {
			688, -- Summon Imp
			697, -- Summon Voidwalker
			712, -- Summon Succubus
			713, -- Summon Incubus
			691, -- Summon Felhunter
			30146, -- Summon Felguard
			112866, -- Summon Fel Imp
			112867, -- Summon Voidlord
			112868, -- Summon Shivarra
			112869, -- Summon Observer
			112870, -- Summon Wrathguard
			111859, -- Grimoire: Imp
			111895, -- Grimoire: Voidwalker
			111896, -- Grimoire: Succubus
			111897, -- Grimoire: Felhunter
			111898, -- Grimoire: Felguard
			108503, -- Grimoire of Sacrifice
			755, -- Health Funnel
			119898, -- Command Demon
			120451, -- Flames of Xoroth
		},
		curses = {
			109466, -- Curse of Enfeeblement
			1490, -- Curse of the Elements
			18223, -- Curse of Exhaustion
		},
		cursor = {
			5740, -- Rain of Fire
			30283, -- Shadowfury
			1122, -- Summon Infernal
			111771, -- Demonic Gateway
		},
		channeled = {
			689, -- Drain Life
			1120, -- Drain Soul
			103103, -- Malefic Grasp
			755, -- Health Funnel
			1949, -- Hellfire
			5740, -- Rain of Fire
			126, -- Eye of Kilrogg
			698, -- Ritual of Summoning
		},
		stealth = {},
		petAbilities = {
			[688] = { abilityId = 119899, familyId = 23 }, -- Summon Imp: Cauterize Master
			[697] = { abilityId = 118093, familyId = 16 }, -- Summon Voidwalker: Disarm
			[712] = { abilityId = 6360, familyId = 17 }, -- Summon Succubus: Whiplash
			[713] = { abilityId = 6360, familyId = 302 }, -- Summon Incubus: Whiplash
			[691] = { abilityId = 19647, familyId = 15 }, -- Summon Felhunter: Spell Lock
			[30146] = { abilityId = 89751, familyId = 29 }, -- Summon Felguard: Felstorm
			[112866] = { abilityId = 119899, familyId = 100 }, -- Summon Fel Imp: Cauterize Master
			[112867] = { abilityId = 118093, familyId = 101 }, -- Summon Voidlord: Disarm
			[112868] = { abilityId = 115770, familyId = 102 }, -- Summon Shivarra: Fellash
			[112869] = { abilityId = 115781, familyId = 103 }, -- Summon Observer: Optical Blast
			[112870] = { abilityId = 115831, familyId = 104 }, -- Summon Wrathguard: Wrathstorm
		},
	},
	WARRIOR = {
		mouseoverEnemy = {
			100, -- Charge
			355, -- Taunt
			6552, -- Pummel
			57755, -- Heroic Throw
			107570, -- Storm Bolt
			64382, -- Shattering Throw
			676, -- Disarm
			5246, -- Intimidating Shout
		},
		mouseoverFriend = {
			3411, -- Intervene
			114029, -- Safeguard
			114030, -- Vigilance
		},
		utility = {
			3411, -- Intervene
			114029, -- Safeguard
			114030, -- Vigilance
		},
		crowdControl = {
			5246, -- Intimidating Shout
			46968, -- Shockwave
			107570, -- Storm Bolt
			676, -- Disarm
			1715, -- Hamstring
			6343, -- Thunder Clap
			12323, -- Piercing Howl
			1160, -- Demoralizing Shout
		},
		defensives = {
			871, -- Shield Wall
			12975, -- Last Stand
			118038, -- Die by the Sword
			55694, -- Enraged Regeneration
			2565, -- Shield Block
			112048, -- Shield Barrier
			23920, -- Spell Reflection
			97462, -- Rallying Cry
			114203, -- Demoralizing Banner
			114028, -- Mass Spell Reflection
			114030, -- Vigilance
			114029, -- Safeguard
		},
		pageBuffs = {
			6673, -- Battle Shout
			469, -- Commanding Shout
		},
		threat = {
			355, -- Taunt
		},
		noCooldown = {
			114192, -- Mocking Banner
			6552, -- Pummel
			100, -- Charge
			7386, -- Sunder Armor
		},
		cursor = {
			6544, -- Heroic Leap
			114203, -- Demoralizing Banner
			114192, -- Mocking Banner
		},
		channeled = {},
		stealth = {},
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-24, Mists of Pandaria Classic 5.5.4.70579

Notes
	- Each class's lists for the spellbook page: the spells whose macros get the mouseover, cursor and channeled options, stealth, the aspects that offer "!Name" casting, the ability each demon summon's macro can cast. Features/Macro-Builder.lua reads them.
	- One ID per spell: this client has no spell ranks, and spells are matched by the name this client gives them.
	- Built from this client's game tables after its Validate Data report, which found every table here empty, so the next Validate Data run is the first to check these rows.
	- The class's spells are the ones on its class skill line, its specializations or its talents (SkillLineAbility, SpecializationSpells, Talent), leaving out passive and hidden spells and the effects other spells fire.
	- mouseoverEnemy: spells cast on an enemy unit (SpellEffect target) from range, plus the melee-range interrupts, crowd control and taunts. Melee strikes are left out; any harmful spell with a range gets the mouseover option anyway (TargetsEnemy in Features/Macro-Builder.lua).
	- mouseoverFriend: spells cast on a friendly unit, resurrections, and the raid buffs cast on a target. A spell that heals a friend or hurts an enemy (Holy Shock, Penance, Chi Wave, Cascade, Holy Prism, Execution Sentence, Mind Sear, Gorefiend's Grasp, Shadowstep) is on both lists, so its macro casts on any unit.
	- resurrect: the mouseoverFriend spells that bring back a dead player, so their macros look for a dead unit ([help,dead]) instead of a living one. Features/Macro-Options.lua gives them the Resurrection kind. Soulstone stays off it: it also goes on a living player.
	- utility: the mouseoverFriend spells that aren't heals (cures, dispels, Innervate, Power Infusion), so Sort By Category files them under Offensive Cooldowns where their cooldown is a minute or longer, else Utility, instead of Heals.
	- crowdControl, offensives, defensives, selfBuffs, pageBuffs, heals, noCooldown, attacks, traps, totems, seals, blessings, curses, shocks, finishers, pets, teleports and threat: the page's own headings for spells their kind would file wrong under Sort By Category (Polymorph, the slows like Hamstring and Thunder Clap, and Demoralizing Shout and Demoralizing Roar under Crowd Control, Tiger's Fury under Offensive Cooldowns, Disengage, Barkskin, Desperate Prayer, which only goes on the priest, and the absorb shields and wards under Defensive Cooldowns, the buffs a class keeps up that only go on itself (the armors, Inner Fire, Inner Focus, the shaman's shields and weapon imbues) under Self Buffs, Prayer of Healing under Heals, Dash, Feign Death, Hunter's Mark, Detect Magic, Charge, Intercept, Sunder Armor, interrupts and enemy dispels under Utility, Mind Sear under Attacks). traps, totems, seals, blessings, curses, shocks, finishers, pets and teleports give the hunter's traps, the shaman's totems and shocks, the paladin's seals and blessings (one blessing per paladin on a target, Protection, Sacrifice and Freedom included), the warlock's curses (one per target, so they're chosen between), the rogue's and the druid's finishing moves (every spell that spends combo points, Kidney Shot and Maim included) the hunter's and warlock's pet spells (summoning, healing, reviving, taming and training a pet), and the mage's teleports and portals (from the Group-Versions file's mage rows) with the druid's Teleport: Moonglade, the shaman's Astral Recall and Mists' Death Gate and Zen Pilgrimage sections of their own, ahead of any other tag. threat gives the taunts (Taunt, Growl, the challenging shouts and roars, Mocking Blow, Righteous Defense, Hand of Reckoning, Dark Command, Provoke) and the threat spells (Cower, Fade, Feint, Distracting Shot, Righteous Fury, Searing Pain, Soothe Animal, Mind Soothe) Taunts And Threat. They only sort the page; no macro reads them. A spell on two takes the first in PAGE_TAGS (Features/Macro-Builder.lua). Data/Data.lua's ns.SHARED_PAGE_SPELLS holds the professions, tracking and racials every class shares. Mists' IDs for spells its class lists don't hold were filled in by hand, so the next Validate Data run is the first to check them.
	- cursor: spells the player places on the ground (SpellTargetRestrictions asks for a location), leaving out Typhoon and Eagle Eye, which the tables flag but which don't take a location.
	- channeled: spells the tables mark as channeled (SpellMisc attributes).
	- Wild Mushroom is on no list: Balance places it on the ground and Restoration on a friend, under one name.
	- Left out on purpose: Death Coil on the friendly list (it heals only Undead allies), Frostbolt and Provoke on it (their friendly target is the mage's Water Elemental and the monk's statue).
	- Warriors have no stances or stanceSlots: no warrior spell needs a stance on this client (SpellShapeshift), so the stance option never applies. The other forms, stances, presences, seals and Shadowform sit on the stance bar, which the builder reads directly.
	- noToggle is the hunter aspects, which cancel when cast again and aren't on the stance bar.
	- petAbilities: each demon's ability is the one Command Demon names for it in this client's spell description, the Grimoire of Supremacy demons included.
	- extraSpells is left out: it lists spells for the Unlearned section, and the Mists TOC doesn't load Features/Unlearned-Spells.lua.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70579
	https://wago.tools/db2/SkillLine?build=5.5.4.70579
	https://wago.tools/db2/SpecializationSpells?build=5.5.4.70579
	https://wago.tools/db2/ChrSpecialization?build=5.5.4.70579
	https://wago.tools/db2/Talent?build=5.5.4.70579
	https://wago.tools/db2/SpellName?build=5.5.4.70579
	https://wago.tools/db2/Spell?build=5.5.4.70579
	https://wago.tools/db2/SpellMisc?build=5.5.4.70579
	https://wago.tools/db2/SpellEffect?build=5.5.4.70579
	https://wago.tools/db2/SpellTargetRestrictions?build=5.5.4.70579
	https://wago.tools/db2/SpellShapeshift?build=5.5.4.70579
	https://wago.tools/db2/SpellShapeshiftForm?build=5.5.4.70579
	https://wago.tools/db2/CreatureFamily?build=5.5.4.70579

QuestieDB
	None.
]]
