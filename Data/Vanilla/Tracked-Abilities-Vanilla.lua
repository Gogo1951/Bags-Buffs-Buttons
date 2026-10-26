local _, ns = ...
local Data = ns.Data
local L = ns.L

if ns.IS_DISCOVERY then
	return
end

local SOLO, SERVICE = Data.BUFF.SOLO, Data.BUFF.SERVICE
local AURA, CAST, RESURRECT = Data.DETECT.AURA, Data.DETECT.CAST, Data.DETECT.RESURRECT

-- { name, labelItem, class, type, detect, opened, noDuration, received, given, triggers = { { spell, item } } }, -- Name
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
		triggers = {
			{ spell = 1008 },
			{ spell = 8455 },
			{ spell = 10169 },
			{ spell = 10170 },
		},
	}, -- Amplify Magic
	{
		class = "MAGE",
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = {
			{ spell = 604 },
			{ spell = 8450 },
			{ spell = 8451 },
			{ spell = 10173 },
			{ spell = 10174 },
		},
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
			{ item = 16895, spell = 20764 },
			{ item = 16892, spell = 20762 },
			{ item = 16896, spell = 20765 },
			{ item = 16893, spell = 20763 },
			{ item = 5232, spell = 20707 },
		},
	}, -- Soulstone
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
		triggers = { { item = 18232, spell = 22700 } },
	}, -- Repair Bots
	{ type = SERVICE, detect = CAST, received = 1, triggers = { { item = 10725, spell = 23133 } } }, -- Gnomish Battle Chicken
	{
		type = SOLO,
		detect = AURA,
		received = 1,
		given = 1,
		triggers = { { spell = 23060 } },
	}, -- Battle Squawk
	{
		labelItem = 7148,
		type = SOLO,
		detect = RESURRECT,
		received = 1,
		given = 1,
		triggers = {
			{ item = 7148, spell = 8342 },
			{ item = 18587, spell = 22999 },
		},
	}, -- Goblin Jumper Cables
}

--[[
How We Got the Data

Last Validated
	2026-10-22, Classic Era 1.15.9.70003

Notes
	- The buffs, cooldowns and services other players spend on you, behind the Buffs from Teammates, Group Services and Good News panels. Buffs from Strangers has no list: any helpful buff from a player outside your group counts.
	- Hand-picked, not queried. One entry is one checkbox. The name after each entry is for people; the panels take names, icons and tooltips from the game. StyLua spreads long entries over several lines, so find one by the name on its closing brace.
	- name is a locale string (L["GROUP_*"]) for a group whose members have different names (Portals, Repair Bots). Without it the toggle shows the first trigger's name in the player's language.
	- labelItem is an item whose game name labels a group named after one of its own items (Soulstone, the stat scrolls), so the label is the game's own in every locale. It takes the place of name.
	- class is the class heading on the Buffs from Teammates panel. Without one the row sits in the generic Items or Group Services list.
	- type is SOLO (cast on you) or SERVICE (set out for the group), from Data.BUFF in Data/Data.lua. No row here is GROUP (cast on your whole party), since every party-wide buff the add-on tracks came later than Classic Era.
	- detect is AURA, CAST or RESURRECT, from Data.DETECT in Data/Data.lua. RESURRECT is for a cast that can fail: Jumper Cables report a successful cast for every jolt, revived or not, so only the resurrection a working jolt produces is worth a message. Tracking the cast instead thanked people for failed jolts.
	- opened makes a service announce as "opened" (portals, summons) instead of "set out" (repair bots, the battle chicken).
	- noDuration marks a buff spent by an event rather than by time, so Good News leaves out its duration: Fear Ward lasts until the next fear, Misdirection until the next few attacks. It matters most on short buffs, which would otherwise slip under the under-a-minute cap and whisper a countdown that means nothing. A long one like Fear Ward is caught by that cap anyway and carries the flag because it's true.
	- received is the default for the shared thank-you list (watchedBuffs) behind the Teammates and Group Services panels: 1 starts the checkbox on, 0 off. A player's own choice is never overwritten.
	- given is the default for the separate Good News list (goodNews.watched), with the same meaning. Services leave it out, since a service has no single recipient and never reaches Good News.
	- triggers lists the ranks or variants one toggle covers: a spell alone, a spell with an aura where the aura's ID differs from the cast's (no row here needs one), or an item with its spell, which shows the item's icon and name and lists every item in the group in the tooltip. Features/Tracked-Lookups.lua builds the lookups from them.
	- Jumper Cables takes its label from item 7148's client name (labelItem), because both cables cast a spell named Defibrillate; only the item names differ.
	- Battle Squawk and Gnomish Battle Chicken are two rows because they're two events for two audiences: using the trinket sets the chicken out, a Group Service, while the squawk is a buff the chicken casts on one person. Battle Squawk carries no item on purpose. Item 10725 would relabel its toggle as a second Gnomish Battle Chicken checkbox and reword the message to "used their Gnomish Battle Chicken on you", which isn't what happened. Its caster is the pet, not the owner: credit reaches the owner through ResolveSource for a received buff, and through the pet branch of OnUnitSpellcastSent for Good News.
	- Portal: Karazhan exists on this client but no class can learn it, so the Portals group leaves it out.
	- Ritual of Doom is left out because it sacrifices a party member rather than serving the group.
	- The file is self-contained: tune a default by changing a digit here, without touching any other file.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellLevels?build=1.15.9.70003
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/SkillLineAbility?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/SkillLine?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/Talent?build=1.15.9.70003

QuestieDB
	None.
]]
