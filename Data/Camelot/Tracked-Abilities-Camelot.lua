local _, ns = ...
local Data = ns.Data
local L = ns.L

local SOLO, SERVICE = Data.BUFF.SOLO, Data.BUFF.SERVICE
local AURA, CAST = Data.DETECT.AURA, Data.DETECT.CAST

-- { name, labelItem, class, type, detect, opened, noDuration, received, receivable, given, triggers = { { spell, aura, item } } }, -- Name
ns.TRACKED_ABILITIES = {
	-- Druid ---------------------------------------------------------------------
	{
		class = "DRUID",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 29166 } },
	}, -- Innervate
	{
		class = "DRUID",
		type = SOLO,
		detect = CAST,
		received = 1,
		receivable = false,
		given = 1,
		triggers = {
			{ spell = 20484 },
			{ spell = 20739 },
			{ spell = 20742 },
			{ spell = 20747 },
			{ spell = 20748 },
		},
	}, -- Rebirth
	-- Mage ----------------------------------------------------------------------
	{
		class = "MAGE",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1008 }, { spell = 8455 }, { spell = 10169 }, { spell = 10170 } },
	}, -- Amplify Magic
	{
		class = "MAGE",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 604 }, { spell = 8450 }, { spell = 8451 }, { spell = 10173 }, { spell = 10174 } },
	}, -- Dampen Magic
	{
		name = L["GROUP_PORTALS"],
		class = "MAGE",
		type = SERVICE,
		detect = CAST,
		opened = true,
		received = 1,
		triggers = {
			{ spell = 10059 },
			{ spell = 11416 },
			{ spell = 11417 },
			{ spell = 11418 },
			{ spell = 11419 },
			{ spell = 11420 },
		},
	}, -- Portals
	-- Paladin -------------------------------------------------------------------
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 19752 } },
	}, -- Divine Intervention
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1044 } },
	}, -- Blessing of Freedom
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 1022 }, { spell = 5599 }, { spell = 10278 } },
	}, -- Blessing of Protection
	{
		class = "PALADIN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 6940 }, { spell = 20729 } },
	}, -- Blessing of Sacrifice
	{
		class = "PALADIN",
		type = SOLO,
		detect = CAST,
		received = 1,
		receivable = false,
		given = 1,
		triggers = { { spell = 633 }, { spell = 2800 }, { spell = 10310 } },
	}, -- Lay on Hands
	-- Priest --------------------------------------------------------------------
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = {
			{ spell = 1277462 },
			{ spell = 1277634 },
			{ spell = 1277638 },
			{ spell = 1277639 },
			{ spell = 1277640 },
		},
	}, -- Contingency Plan
	{
		class = "PRIEST",
		type = SOLO,
		detect = CAST,
		received = 1,
		receivable = false,
		given = 1,
		triggers = {
			{ spell = 1277370 },
			{ spell = 1277371 },
			{ spell = 1277372 },
			{ spell = 1277374 },
			{ spell = 1277376 },
			{ spell = 1277377 },
			{ spell = 1277378 },
		},
	}, -- Divine Grace
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		noDuration = true,
		received = 1,
		given = 1,
		triggers = { { spell = 6346 } },
	}, -- Fear Ward
	{
		class = "PRIEST",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 10060 } },
	}, -- Power Infusion
	-- Shaman --------------------------------------------------------------------
	{
		class = "SHAMAN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 131 } },
	}, -- Water Breathing
	{
		class = "SHAMAN",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 546 } },
	}, -- Water Walking
	-- Warlock -------------------------------------------------------------------
	{
		class = "WARLOCK",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 5697 } },
	}, -- Unending Breath
	{
		class = "WARLOCK",
		type = SERVICE,
		detect = CAST,
		opened = true,
		received = 1,
		triggers = { { spell = 698 } },
	}, -- Ritual of Summoning
	-- Soulstone (item, Warlock) -------------------------------------------------
	{
		labelItem = 16893,
		class = "WARLOCK",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 5232, spell = 20707 },
			{ item = 16892, spell = 20762 },
			{ item = 16893, spell = 20763 },
			{ item = 16895, spell = 20764 },
			{ item = 16896, spell = 20765 },
		},
	}, -- Soulstone
	-- Feasts (item) -------------------------------------------------------------
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279957, spell = 1307257 } } }, -- Cookie's Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 238641, spell = 1225906 } } }, -- Specklefin Feast
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279944, spell = 1307392 } } }, -- Sharpening Wheel
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279956, spell = 1307259 } } }, -- Mana Well
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279960, spell = 1307254 } } }, -- Lodestone
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279962, spell = 1307251 } } }, -- Incense Candle
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279967, spell = 1307245 } } }, -- Fish Bowl
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279968, spell = 1307244 } } }, -- First Aid Kit
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279976, spell = 1307234 } } }, -- Enchanted Lute
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279978, spell = 1307230 } } }, -- Camp Tent
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279979, spell = 1307229 } } }, -- Camp Chair
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279938, spell = 1307397 } } }, -- Trapper's Workbench
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279940, spell = 1307396 } } }, -- Toxin Study
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279941, spell = 1307395 } } }, -- Tanning Rack
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279943, spell = 1307393 } } }, -- Spinning Wheel
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279945, spell = 1307391 } } }, -- Sewing Machine
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279947, spell = 1307387 } } }, -- Seed Hybridizer
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279948, spell = 1307386 } } }, -- Rock Garden
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279951, spell = 1307265 } } }, -- Plague Doctor's Laboratory
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279952, spell = 1307264 } } }, -- Molten Foundry
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279955, spell = 1307261 } } }, -- Master Forge
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279959, spell = 1307255 } } }, -- Loom
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279964, spell = 1307248 } } }, -- Greenhouse
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279965, spell = 1307247 } } }, -- Fishing Rack
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279966, spell = 1307246 } } }, -- Fishing Hut
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279969, spell = 1307243 } } }, -- Field Guide
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279970, spell = 1307242 } } }, -- Fermenter
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279985, spell = 1307223 } } }, -- Arcane Salvager
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279987, spell = 1307176 } } }, -- Arcane Forge
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279988, spell = 1307175 } } }, -- Anvil
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 279990, spell = 1307172 } } }, -- Alchemy Laboratory
	{
		labelItem = 279972,
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = { { item = 279972, spell = 1307240 }, { item = 279973, spell = 1307239 } },
	}, -- Faction Banner
	-- Stat Scrolls (item) -------------------------------------------------------
	{
		labelItem = 1181,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 1181, spell = 8112 },
			{ item = 1712, spell = 8113 },
			{ item = 4424, spell = 8114 },
			{ item = 10306, spell = 12177 },
		},
	}, -- Scroll of Spirit
	{
		labelItem = 1180,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 1180, spell = 8099 },
			{ item = 1711, spell = 8100 },
			{ item = 4422, spell = 8101 },
			{ item = 10307, spell = 12178 },
		},
	}, -- Scroll of Stamina
	{
		labelItem = 954,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 954, spell = 8118 },
			{ item = 2289, spell = 8119 },
			{ item = 4426, spell = 8120 },
			{ item = 10310, spell = 12179 },
		},
	}, -- Scroll of Strength
	{
		labelItem = 3013,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 3013, spell = 8091 },
			{ item = 1478, spell = 8094 },
			{ item = 4421, spell = 8095 },
			{ item = 10305, spell = 12175 },
		},
	}, -- Scroll of Protection
	{
		labelItem = 955,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 955, spell = 8096 },
			{ item = 2290, spell = 8097 },
			{ item = 4419, spell = 8098 },
			{ item = 10308, spell = 12176 },
		},
	}, -- Scroll of Intellect
	{
		labelItem = 3012,
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ item = 3012, spell = 8115 },
			{ item = 1477, spell = 8116 },
			{ item = 4425, spell = 8117 },
			{ item = 10309, spell = 12174 },
		},
	}, -- Scroll of Agility
	-- Repair & Utility (item) ---------------------------------------------------
	{
		name = L["GROUP_REPAIR_BOTS"],
		type = SERVICE,
		detect = CAST,
		received = 1,
		triggers = {
			{ item = 18232, spell = 22700 },
			{ item = 279949, spell = 1307385 },
			{ item = 279950, spell = 1307266 },
		},
	}, -- Repair Bots (Field Repair Bot 74A, Forever's camp Repair Bot and Reagent Bot)
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 10725, spell = 23133 } } }, -- Gnomish Battle Chicken
	{
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 23060 }, { spell = 1317480 } },
	}, -- Battle Squawk
}

--[[
How We Got the Data

Last Validated
	2026-10-19, WoW Forever 1.60.1.70450

Notes
	- The buffs, cooldowns and services other players spend on you, behind the Buffs from Teammates, Group Services and Good News panels. Buffs from Strangers has no list: any helpful buff from a player outside your group counts.
	- Hand-picked, not queried. One entry is one checkbox. The name after each entry is for people; the panels take names, icons and tooltips from the game. StyLua spreads long entries over several lines, so find one by the name on its closing brace.
	- name is a locale string (L["GROUP_*"]) for a group whose members have different names (Portals, Repair Bots). Without it the toggle shows the first trigger's name in the player's language.
	- labelItem is an item whose game name labels a group named after one of its own items (Soulstone, the stat scrolls), so the label is the game's own in every locale. It takes the place of name.
	- class is the class heading on the Buffs from Teammates panel. Without one the row sits in the generic Items or Group Services list.
	- type is SOLO (cast on you) or SERVICE (set out for the group), from Data.BUFF in Data/Data.lua. No row here is GROUP (cast on your whole party), since every party-wide buff the add-on tracks came later than Classic Era.
	- detect is AURA or CAST, from Data.DETECT in Data/Data.lua. No row here is RESURRECT, which needs the combat log's resurrection event this client doesn't have, so Jumper Cables is left out: tracking the cast instead would thank people for failed jolts.
	- opened makes a service announce as "opened" (portals, summons) instead of "set out" (the camp features, repair bots, the battle chicken).
	- noDuration marks a buff spent by an event rather than by time, so Good News leaves out its duration: Fear Ward lasts until the next fear, Contingency Plan until its ward triggers. It matters most on short buffs like Contingency Plan, which would otherwise slip under the under-a-minute cap and whisper a countdown that means nothing. A long one like Fear Ward is caught by that cap anyway and carries the flag because it's true.
	- received is the default for the shared thank-you list (watchedBuffs) behind the Teammates and Group Services panels: 1 starts the checkbox on, 0 off. A player's own choice is never overwritten.
	- receivable = false marks a cast this client can't see landing on you, because it has no combat log (Rebirth, Lay on Hands, Divine Grace). The row gets no thank-you toggle and reaches only Good News.
	- given is the default for the separate Good News list (goodNews.watched), with the same meaning. Services leave it out, since a service has no single recipient and never reaches Good News.
	- triggers lists the ranks or variants one toggle covers: a spell alone, a spell with an aura where the aura's ID differs from the cast's (no row here needs one), or an item with its spell, which shows the item's icon and name and lists every item in the group in the tooltip. Features/Tracked-Lookups.lua builds the lookups from them.
	- Battle Squawk and Gnomish Battle Chicken are two rows because they're two events for two audiences: using the trinket sets the chicken out, a Group Service, while the squawk is a buff the chicken casts on one person. Battle Squawk carries no item on purpose. Item 10725 would relabel its toggle as a second Gnomish Battle Chicken checkbox and reword the message to "used their Gnomish Battle Chicken on you", which isn't what happened. Its caster is the pet, not the owner: credit reaches the owner through ResolveSource for a received buff, and through the pet branch of OnUnitSpellcastSent for Good News.
	- On Forever, item 10725 also carries 1317480 Battle Squawk as a second effect, alongside 23060, so the Battle Squawk row watches both auras.
	- Rows marked (Forever) exist only on WoW Forever: Contingency Plan, Divine Grace, Specklefin Feast, and the camp features. Specklefin Feast, like Cookie's Feast, serves a feast to a group of players. Every camp feature that serves others is a Group Service: Cookie's Feast, the camp Repair Bot and Reagent Bot, the Tier 1 features that buff you and others sitting nearby (Sharpening Wheel, Mana Well, Lodestone, Incense Candle, Fish Bowl, First Aid Kit, Faction Banner, Enchanted Lute, Camp Tent, Camp Chair), and the Tier 2 and 3 features that carry a Tier 1's benefit. They all share the camping cooldown. Iron Oven and Anarchist's Workbench are left out, since they're crafting stations that do nothing for anyone else. The campfire kits (Basic, Journeyman, Expert) are left out: every camp starts with one, and the features set around it are what serve others. Ritual of Doom is left out because it sacrifices a party member.
	- Portal: Karazhan exists on this client but no class can learn it, so the Portals group leaves it out.
	- The file is self-contained: tune a default by changing a digit here, without touching any other file.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.60.1.70291
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70291
	https://wago.tools/db2/ItemEffect?build=1.60.1.70291
	https://wago.tools/db2/Spell?build=1.60.1.70291
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70291
	https://wago.tools/db2/SpellName?build=1.60.1.70450
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70450
	https://wago.tools/db2/ItemSparse?build=1.60.1.70450
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70450
	https://wago.tools/db2/ItemEffect?build=1.60.1.70450
	https://wago.tools/db2/SpellLevels?build=1.60.1.70450
	https://wago.tools/db2/SkillLine?build=1.60.1.70450
	https://wago.tools/db2/SpellEffect?build=1.60.1.70450
	https://wago.tools/db2/Talent?build=1.60.1.70450

QuestieDB
	None.
]]
