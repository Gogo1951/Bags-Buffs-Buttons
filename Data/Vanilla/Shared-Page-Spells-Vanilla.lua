local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [pageTag] = { spellId or { spellId, ... }, ... }, -- Spell Name
ns.SHARED_PAGE_SPELLS = {
	racials = {
		20600, -- Perception
		20594, -- Stoneform
		2481, -- Find Treasure
		{ 20580, 58984 }, -- Shadowmeld
		20589, -- Escape Artist
		{ 20572, 33697, 33702 }, -- Blood Fury
		7744, -- Will of the Forsaken
		20577, -- Cannibalize
		20549, -- War Stomp
		{ 20554, 26296, 26297 }, -- Berserking
		{ 28880, 59542, 59543, 59544, 59545, 59547, 59548, 121093 }, -- Gift of the Naaru
		{ 28730, 25046, 50613, 80483, 129597 }, -- Arcane Torrent
		28734, -- Mana Tap
		59752, -- Every Man for Himself
		68992, -- Darkflight
		68996, -- Two Forms
		87840, -- Running Wild
		69041, -- Rocket Barrage
		69070, -- Rocket Jump
		69046, -- Pack Hobgoblin
		107079, -- Quaking Palm
	},
	professions = {
		2259, -- Alchemy
		2018, -- Blacksmithing
		7411, -- Enchanting
		4036, -- Engineering
		2108, -- Leatherworking
		3908, -- Tailoring
		25229, -- Jewelcrafting
		45357, -- Inscription
		2550, -- Cooking
		3273, -- First Aid
		7620, -- Fishing
		2366, -- Herb Gathering
		2575, -- Mining
		2656, -- Smelting
		8613, -- Skinning
		13262, -- Disenchant
		31252, -- Prospecting
		51005, -- Milling
		818, -- Basic Campfire
		78670, -- Archaeology
		80451, -- Survey
		20219, -- Gnomish Engineer
		20222, -- Goblin Engineer
		10656, -- Dragonscale Leatherworking
		10658, -- Elemental Leatherworking
		10660, -- Tribal Leatherworking
		9787, -- Weaponsmith
		9788, -- Armorsmith
		17039, -- Master Swordsmith
		17040, -- Master Hammersmith
		17041, -- Master Axesmith
		28672, -- Transmutation Master
		28675, -- Potion Master
		28677, -- Elixir Master
		26797, -- Spellfire Tailoring
		26798, -- Mooncloth Tailoring
		26801, -- Shadoweave Tailoring
	},
	tracking = {
		2383, -- Find Herbs
		2580, -- Find Minerals
		43308, -- Find Fish
		1494, -- Track Beasts
		{ 19883, 5225 }, -- Track Humanoids
		19884, -- Track Undead
		19885, -- Track Hidden
		19880, -- Track Elementals
		19878, -- Track Demons
		19882, -- Track Giants
		19879, -- Track Dragonkin
		5502, -- Sense Undead
		5500, -- Sense Demons
	},
	-- the melee swing the General tab lists, which the game doesn't call harmful
	attacks = {
		6603, -- Attack
	},
}

-- { professionSpellId, specializationSpellId, ... }, -- Profession: Specializations
ns.PROFESSION_SPECIALIZATIONS = {
	{ 4036, 20219, 20222 }, -- Engineering: Gnomish Engineer, Goblin Engineer
	{ 2018, 9788, 9787, 17039, 17040, 17041 }, -- Blacksmithing: Armorsmith, Weaponsmith, Master Swordsmith, Master Hammersmith, Master Axesmith
	{ 2108, 10656, 10658, 10660 }, -- Leatherworking: Dragonscale, Elemental, Tribal Leatherworking
	{ 2259, 28672, 28675, 28677 }, -- Alchemy: Transmutation Master, Potion Master, Elixir Master
	{ 3908, 26797, 26798, 26801 }, -- Tailoring: Spellfire, Mooncloth, Shadoweave Tailoring
}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- SHARED_PAGE_SPELLS holds the spells every class shares, which the Spell Book page files under its own headings whatever their spellbook tab: each race's spells (racials, which Sort By Category gives a Racials section), the profession and tracking spells the General tab lists (professions, tracking), and its Attack (attacks). ns.PageCategory and the page-tag lookup in Features/Spellbook/Macro-Builder.lua read it.
	- An entry is a spell ID, or a list of the IDs one spell has across clients. Each is matched by name, so an ID this client doesn't have is skipped.
	- PROFESSION_SPECIALIZATIONS lists each profession's spell, then its specializations: passives the spellbook lists beside the profession that do nothing when cast. When one is learned, the page shows the profession's macro under the specialization's name and icon ("Goblin Engineer", still opening Engineering) and leaves the specialization's own off. A later one in the row wins, so a Master Swordsmith beats the Weaponsmith it builds on. FoldSpecializations in Features/Spellbook/Macro-Builder.lua reads it.
	- Every folder holds the same rows, copied from the one shared table these came from, until the Data Review validates each folder against its own client.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
