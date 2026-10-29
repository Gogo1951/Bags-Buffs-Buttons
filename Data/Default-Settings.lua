local _, ns = ...
local Data = ns.Data

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    The single AceDB-3.0 defaults table. Features/Core.lua passes this to
    AceDB:New, which applies the defaults itself -- there is no hand-rolled
    merge. Scalar and table defaults are physically copied into the saved
    table (copyDefaults via rawset) when a scope is first accessed; only
    */** wildcard defaults resolve through a metatable. An explicit user
    value, including false, is never overridden either way.

    The consumable settings live under `profile`, so they are per-character:
    each character gets a profile of its own, named as AceDB names the
    character (its first name and surname on WoW Forever, "Name - Realm" on
    Era and TBC), and can run a different set of consumables. That is the
    point -- a level-15 alt and a raiding 60 want different buff food, scrolls
    differ by class, and two Rogues want their own poison pairs. The stock
    Profiles panel (Options/Options-Profiles.lua) is therefore meaningful:
    switching, copying, or resetting a profile moves real settings, and two
    characters share a setup only when the player puts both on one profile.

    What stays under `global` (account-wide), each for a concrete reason rather
    than convenience:
      * showWelcome    -- one login greeting per account, not per character,
                          shared by every feature.
      * showMacroNames -- a client-wide action-bar appearance tweak.
      * macrosEnabled  -- the Macros master switch, account-wide for the same
                          reason as enabledMacros: the macros it freezes are
                          shared by every character.
      * restockerEnabled -- the Restocker master switch, kept with the Restock
                          Lists it governs, which are account-wide too.
      * readinessReportEnabled -- a behaviour preference (does Connoisseur speak
                          up on a ready check?) rather than a consumable choice.
      * enabledMacros  -- the macros themselves are account-wide: they live in
                          the shared General macro tab, so which ones exist has
                          to be one choice for the whole account. Keeping the
                          setting here means the two agree -- a character switch
                          never adds or removes a macro, it only rewrites the
                          shared bodies to that character's best items.
      * minimap        -- LibDBIcon reads this subtable directly and owns its
                          contents (position etc.), so keeping it off the
                          profile means switching, resetting, or deleting a
                          profile never moves the minimap button.
      * ignoreList     -- the Global half of the Ignore List, hiding an
                          item from every character's macros at once; the
                          character's half keeps the same key on the profile,
                          and Features/Macros-for-Consumables/Ignore-List.lua reads both.
      * readiness*     -- the per-category switches under
                          readinessReportEnabled, each answered once for the
                          account like the master toggle above it. Their own
                          reasons are on the keys.
      * restocker      -- the Restock Lists and the Restocker's settings,
                          shared by the account; a profile only picks which
                          list it uses. Its reason is on the key itself.
      * inventoryReport, inventory -- the item-tooltip counts and the
                          per-character snapshots behind them. Their reasons
                          are on the keys.

    The derived item cache (itemCache, with its itemCacheVersion and
    itemCacheFolder stamps) is deliberately NOT declared here:
    ns.EnsureItemCache (Features/Macros-for-Consumables/Item-Cache.lua) creates it on the profile at
    login and after every profile change, and owns its stamp invalidation, so
    it never needs a default.

    No profile names a Restock List: which list a character uses is kept by
    character, in restocker.listChoices below, and
    ns.InitializeCharacterRestockList
    (Features/Inventory-Restocker/Restocker-Saved-Lists.lua) gives a character without
    one a list named for its class.
]]
ns.DATABASE_DEFAULTS = {
	profile = {
		--[[
		    The character's own half of the Ignore List, itemID to true: the
		    items hidden from the macros of whoever is on this profile. The
		    Global half keeps the same key on `global`, and
		    Features/Macros-for-Consumables/Ignore-List.lua reads both.
		]]
		ignoreList = {},
		--[[
		    Use Conjured Food & Water First: the Food and Water macros rank
		    conjured items above anything that restores more (buff food still
		    comes first). Off by default like every opt-in here, and while on
		    it applies only while leveling ("leveling", below max level) unless
		    the player picks another mode from the shared list: leveling is when
		    free conjured food matters, solo or in a dungeon with a Mage friend,
		    while at max level a raider wants the best. Per-character like the
		    other consumable choices.
		]]
		useConjuredFirst = false,
		conjuredFirstMode = "leveling",
		--[[
		    Use Restock List Food & Water Last: between two items that restore
		    the same amount, the Food and Water macros pick the one not on the
		    current Restock List, whatever its Keep amount. Off by default.
		]]
		useRestockLast = false,
		--[[
		    Use Food & Water in Potion Macros Out of Combat: the Health Potion
		    macro eats the Food macro's pick and the Mana Potion macro drinks
		    the Water macro's pick while the player is out of combat, the way
		    an older add-on's single button did. Off by default.
		]]
		potionsUseFoodAndWater = false,
		combineHealthstones = false,
		includeManaRunes = false,
		--[[
		    Early re-application: with earlyReapply on, a food/scroll/pet buff
		    whose remaining time is under earlyReapplyThreshold (seconds)
		    counts as already expired, so the macros offer a fresh application
		    before a pull. See BuffCountsAsActive in Scanner-Auras.lua.
		]]
		earlyReapply = false,
		earlyReapplyThreshold = 120,
		useBuffFood = false,
		buffFoodMode = "always",
		useScrolls = false,
		scrollsMode = "always",
		scrollTypes = {
			Agility = true,
			Intellect = true,
			Protection = true,
			Spirit = true,
			Stamina = true,
			Strength = true,
		},
		--[[
		    Off by default, like every other opt-in feature here. Pet buff food
		    is a min-maxer's tool -- it needs level 55+, a live pet, and a
		    steady supply of Kibler's Bits or Sporeling Snacks -- so a new user
		    should never meet it uninvited. Leave this false.
		]]
		usePetBuffFood = false,
		petBuffFoodMode = "always",
		petBuffTypes = {
			KiblersBits = true,
			SporelingSnacks = true,
		},
		--[[
		    Explosive macro click layout: "atplayer" fires [@player] on
		    left-click and the standard toss on right-click; "toss" swaps
		    the buttons. See BuildExplosiveUseLine in Features/Macros-for-Consumables/Macros/Explosive.lua.
		]]
		explosivesClickMode = "atplayer",
		enableDruidMacroHelper = false,
		druidReturnForm = "bear",
		enableShadowmeldDrinking = false,
		--[[
		    Stealth Eating appends the character's stealth ability to the Food
		    macro -- Stealth for Rogues, Shadowmeld for other Night Elves. One
		    key serves both; the class/race gate lives in Food.lua's appendBlock.
		    Per-character, so a Night Elf Druid enabling it never switches it
		    on for the account's Rogues.
		]]
		enableStealthEating = false,
		--[[
		    Forsaken: the Food and Water macros try Cannibalize first while the
		    target is a Humanoid or Undead and the spell is off cooldown, and
		    eat or drink when it cannot cast (Features/Macros-for-Consumables/Macros/Tools-Forsaken.lua). Drinking only takes effect
		    where Cannibalize restores mana (ns.CANNIBALIZE_RESTORES_MANA).
		]]
		enableCannibalizeEating = false,
		enableCannibalizeDrinking = false,
		--[[
		    Rogue poison groups per weapon slot, keyed by ns.POISON_GROUP_BASE_ITEMS
		    group IDs (4 = Instant Poison). See ns.POISON_GROUPS in Data/Data.lua.
		]]
		mainHandPoisonGroup = 4,
		offHandPoisonGroup = 4,
	},
	global = {
		showWelcome = true,
		--[[
		    The features' master switches, atop each add-on's heading page and
		    each feature's own panel, all account-wide. Off, macrosEnabled
		    leaves every macro as it last was: nothing is created, rewritten or
		    deleted until it is back on. Off, restockerEnabled stops every part
		    of the Restocker, its window, /restock and the mini-map click
		    included; the lists stay saved. Off, spellbookEnabled hides the
		    Spellbook and its tab in the game's spellbook and stops keeping its
		    macros current; the macros it made stay as they last were.
		]]
		macrosEnabled = true,
		restockerEnabled = true,
		spellbookEnabled = true,
		--[[
		    The Restock List subsystem. `lists` are the player's own named
		    shopping lists, shared by every character, and the stock Reset
		    Profile control must never reach them. Putting them on global is
		    what guarantees that -- a profile switch or reset cannot empty a
		    hand-built list or re-offer the Starter List to a character that
		    already answered it. `listChoices` is which list each character
		    uses, keyed by the character's name as profileKeys holds it. It is
		    kept here and not on a profile, so two characters sharing a profile
		    still shop from lists of their own, and switching one never moves
		    the other.

		    The two reminder modes differ on purpose: in town you are away from
		    your bags and the detail is the whole point, while at a merchant or
		    a bank you are already looking at the window that fixes it.

		    The Gold Reserve ships on at 1 gold, a floor low enough that nobody
		    notices it until a merchant run would otherwise leave them broke. It
		    sits here with the lists, outside every profile: one floor for every
		    character, so a reserve set on one also holds back an alt with less.
		    goldReserveAmount is whole gold, one of ns.GOLD_RESERVE_AMOUNTS.
		]]
		restocker = {
			lists = {},
			listChoices = {},
			framePosition = {},
			restockReminderChat = true,
			restockReminderSound = true,
			restockReminderMode = "verbose",
			merchantReminder = true,
			merchantReminderMode = "simple",
			bankReminder = true,
			bankReminderMode = "simple",
			autoOpenAtBank = false,
			autoOpenAtMerchant = false,
			goldReserve = true,
			goldReserveAmount = 1,
		},
		--[[
		    The Inventory Report in item tooltips (Features/Inventory-Restocker/Inventory-Report-Tooltip.lua).
		    Ships ON, unlike the opt-ins above: it only ever adds lines to a
		    tooltip the player asked for, and never acts. The switch exists
		    because most auction add-ons print their own counts under the same
		    items, and a player running one wants a single set. A display
		    preference for the account, like showMacroNames.
		]]
		inventoryReport = true,
		--[[
		    Every character's last-known bags and bank, keyed by character (the
		    Restocker's "Name-Realm" key), each place packed into one line of
		    "itemID:count" pairs by Features/Inventory-Restocker/Inventory-Report-Recording.lua. Account-wide
		    because its whole point is showing one character what the others
		    hold, and never a profile: switching or resetting one must not wipe
		    what an alt was carrying. Each record also holds the character's
		    name, realm and class, and the Restock List reads the class to color
		    the characters on a list.
		]]
		inventory = {},
		--[[
		    The Global half of the Ignore List, itemID to true: items hidden
		    from every character's macros, whatever profile the character is on.
		    Outside the profiles so that it reaches all of them, and so that
		    resetting one character's profile never empties it.
		]]
		ignoreList = {},
		--[[
		    Macro-name text on the default action bars. Off by default so the
		    add-on hides the names Blizzard recently began showing again; the
		    "Enable Macro Names on Buttons" toggle reads it directly, so checked
		    means the names show (see Features/Macros-for-Consumables/Action-Button-Text.lua).
		]]
		showMacroNames = false,
		--[[
		    The Readiness Report: on a ready check, a private report naming what
		    still needs fixing. A behaviour preference -- whether you want
		    Connoisseur speaking up at all -- rather than a consumable choice, so
		    it is answered once for the account rather than per character, and so
		    is every category switch under it.

		    Silence is the report's normal output: a category with nothing wrong
		    prints nothing, and a clean character prints nothing at all. That is
		    what lets it cover this much without becoming noise, so a switch here
		    should only ever be able to ADD a line about something broken.

		    Beta soft launch: the report ships OFF and every player opts in. The
		    key is deliberately a NEW one rather than the retired readinessReport,
		    whose saved values belong to its old meaning.
		]]
		readinessReportEnabled = false,
		--[[
		    Which categories the report covers. Each is answered once for the
		    account, like the master toggle above, and every one of them is dead
		    while readinessReportEnabled is off.

		    Three ship ON, and they share a reason: each is something another
		    player standing next to you can fix inside the few seconds a ready
		    check gives you. A Warlock can hand you a stone, a Warlock can put a
		    soulstone up, and a Mage conjures their own gem. Each also gates on
		    who can fix it, so none of the three can nag someone who cannot
		    answer it: the Healthstone on a Warlock being in the group, the
		    soulstone and the gem on the player being that class.

		    Everything else ships OFF. A report that fires on a fresh install for
		    things the player never asked about is one they switch off entirely
		    rather than tune, and the switches are cheap to find once they go
		    looking. The two potions especially: mid-pull an empty potion slot is
		    not something anyone can act on.
		]]
		-- Missing Buffs
		readinessFlask = false,
		readinessWellFed = false,
		readinessPetWellFed = false,
		readinessScrolls = false,
		readinessSoulstone = true,
		readinessMainHandBuff = false,
		readinessOffHandBuff = false,
		--[[
		    Buffs about to lapse, in seconds. Distinct from the Macros panel's
		    Buff Re-Application threshold, which decides when the MACROS treat a
		    buff as spent: this one only decides when the report mentions one,
		    covers every aura on the character rather than the tracked ones, and
		    reaches further out because a raid leader's pull timer is longer than
		    a macro press.
		]]
		readinessExpiring = false,
		readinessExpiringThreshold = 150,

		-- Missing Items
		readinessHealthstone = true,
		readinessManaGem = true,
		readinessHealingPotion = false,
		readinessManaPotion = false,
		readinessBandages = false,
		--[[
		    Percent, compared against the LOWEST equipped item rather than an
		    average: one weapon at 5% is the thing that breaks mid-pull, and an
		    average hides it behind seventeen healthy pieces.
		]]
		readinessDurability = false,
		readinessDurabilityThreshold = 20,

		-- Character
		readinessSpec = false,
		readinessPvP = false,
		readinessQuestionableGear = false,
		--[[
		    Which macros Connoisseur maintains. Account-wide because the macros
		    are: they live in the shared General macro tab, so unchecking one
		    removes the shared macro for every character. Feed Pet and Poisons
		    are class-gated on top of this toggle and build only for Hunters and
		    Rogues; the conjure-capable macros (Healthstone, Mana Gem,
		    Soulstone) are built for every class, with only their conjure clicks
		    class-gated.
		]]
		enabledMacros = {
			["Bandage"] = true,
			["Explosive"] = true,
			["Feed Pet"] = true,
			["Food"] = true,
			["Health Potion"] = true,
			["Healthstone"] = true,
			["Mana Gem"] = true,
			["Mana Potion"] = true,
			["Poisons"] = true,
			["Soulstone"] = true,
			["Water"] = true,
		},
		--[[
		    The main mini-map button's visibility. LibDBIcon reads `hide` from this subtable,
		    so it stays the single source of truth -- the "Enable Mini-map Button"
		    toggle is its inverse (hide = false means shown). LibDBIcon owns the
		    rest of the subtable (position, etc.); living under `global`, it is
		    untouched by profile switches and resets.
		]]
		minimap = {
			hide = false,
		},
	},
}

--------------------------------------------------------------------------------
-- Feature Defaults
--------------------------------------------------------------------------------

--[[
    Each feature below adds its own keys to the table above. Two features
    declaring one key would share a setting without meaning to, so it stops the
    load instead.
]]
local function AddDefaults(scope, defaults)
	ns.DATABASE_DEFAULTS[scope] = ns.DATABASE_DEFAULTS[scope] or {}
	local target = ns.DATABASE_DEFAULTS[scope]
	for key, value in pairs(defaults) do
		assert(target[key] == nil, "Duplicate default: " .. scope .. "." .. key)
		target[key] = value
	end
end

--------------------------------------------------------------------------------
-- Spellbook Defaults
--------------------------------------------------------------------------------

--[[
	Per-Character model: the recorded trainer spells differ from character to character, and the macro options
	ride the profile with them, since which spells a page lists is per class. Which macros the add-on made is a
	fact about the account's and the character's macro lists, not a setting, so it lives in global and char,
	where no profile change or reset can lose it.
]]
local SPELLBOOK_DEFAULTS = {
	global = {
		ownedMacros = {}, -- general (account-wide) macros the add-on created, by WoW macro name: the creating character's key
		-- each WoW macro's tag line ID (see ns.MacroTag), by what the macro is for, and how many were handed out
		macroTags = {},
		macroTagCount = 0,
	},
	profile = {
		showAllRanks = false,
		showGroupedSpells = false,
		showUnlearned = false,
		countSpellsOnBars = true,
		pageSort = "category", -- "category" (by kind of macro) or "school" (by spellbook tab); see ns.PageSort
		markedPlaced = {}, -- macros marked placed from the page's settings menu, by WoW macro name
		--[[
			the options each kind of macro starts with (see ns.MACRO_KINDS), as kind -> option -> true or
			false. Buffs start on Dynamic Rank, since a buff's rank can't land on a player too far below its level,
			and on Right-Click For the group (or single) version.
		]]
		kindDefaults = {
			enemy = {},
			friendly = {},
			buff = { targetRank = true, groupVersion = true },
			resurrect = {},
			anyone = {},
			ground = {},
			form = {},
			self = {},
		},
		cursor = {},
		focus = {},
		pet = {},
		stance = {},
		petAttack = {},
		stopCast = {},
		startAttack = {},
		noToggle = {},
		targetRank = {},
		fixedRank = {},
		targetEnemy = {},
		targetFriend = {},
		combatOnly = {},
		noCombat = {},
		oncePerCombat = {},
		oncePerTarget = {},
		stopAttack = {},
		stopIfChanneling = {},
		stopIfStealthed = {},
		hideErrors = {},
		muteErrors = {},
		cancelForm = {},
		autoShot = {},
		groupVersion = {},
		groupedSpells = {},
		targetPriority = {}, -- each spell's own target priority, as a list of units (see ns.TargetPriority)
		useItems = {},
		macroCopies = {}, -- the Duplicate copies of each spell's macro, by spell name, as a list of copy numbers
		trainerSpells = {}, -- by class token, then spell id -> required level (see Features/Spellbook/Trainer-Recording.lua)
	},
	char = {
		ownedMacros = {}, -- character macros the add-on created, by WoW macro name
	},
}

AddDefaults("global", SPELLBOOK_DEFAULTS.global)
AddDefaults("profile", SPELLBOOK_DEFAULTS.profile)
AddDefaults("char", SPELLBOOK_DEFAULTS.char)

--------------------------------------------------------------------------------
-- Thanks for the Buff Defaults
--------------------------------------------------------------------------------

--[[
    `enabled` is explicit at every call site rather than defaulted, because the
    two answers are both real: the praise panels seed every emote on, the extra
    Thank You buttons seed every emote off.
]]
local function GetDefaultEmoteSettings(enabled)
	local emotes = {}
	for _, data in ipairs(Data.EMOTES) do
		emotes[data.token] = enabled and true or false
	end
	return emotes
end

--[[
    Thanks for the Buff's settings, account-wide: none of them is about one
    character, so every character thanks, praises and buffs the same way. The
    welcome toggle is the shared one above.
]]
local THANKS_FOR_THE_BUFF_DEFAULTS = {
	--[[
            Praise (the outgoing whisper and emote) carries its own throttles here:
            `praiseCooldown` is the gap between any two praises whoever buffed you,
            `cooldown` the gap between two praises of the SAME player. The overall
            one ships at 0 (off), so out of the box only the per-source limit
            applies. `praiseDelay` is only read while `praiseDelayEnabled` is set,
            and its values are the ones the dropdown offers (Data.PRAISE_DELAY_CHOICES).
        ]]
	strangers = {
		--[[
			    Master switch for the whole panel. On by default: turning the add-on
			    on and getting nothing would read as broken.
			]]
		enabled = true,
		printEnabled = false,
		whisperEnabled = false,
		praiseDelayEnabled = false,
		praiseDelay = 2,
		praiseCooldown = 0,
		cooldown = 3,
		--[[
			    21, not 25: the nearest step on Data.SECONDS_CHOICES. A default that
			    is not on the scale would show up snapped anyway, so storing the
			    snapped value keeps what is saved and what is shown identical.
			]]
		minBuffDuration = 21,
		emotesEnabled = true,
		soundEnabled = false,
		emotes = GetDefaultEmoteSettings(true),
	},
	slash = {
		createMacro = true,
		-- The texture file ID the macro wears: its own icon, or one from ns.THANK_YOU_MACRO_ICONS.
		macroIcon = Data.THANK_YOU_DEFAULT_ICON,
		message = ns.L["DEFAULT_WHISPER"],
		emotes = GetDefaultEmoteSettings(true),
	},
	--[[
		    Teammate Buffs (party/raid buffs & cooldowns cast on you) and Service
		    Alerts (no-aura raid help) each own their messaging settings, like
		    strangers above. The watched-buff list is shared (ids never overlap) and
		    seeds from the `received` defaults in this client's Tracked-Abilities file.
		    Teammates offers the same Praise Delay as strangers, but no cooldowns: a
		    teammate's cooldown is worth acknowledging every single time it lands.
		]]
	teammates = {
		-- Master switch for the whole panel. On by default, like strangers.
		enabled = true,
		printEnabled = false,
		whisperEnabled = true,
		praiseDelayEnabled = false,
		praiseDelay = 2,
		emotesEnabled = false,
		soundEnabled = true,
		emotes = GetDefaultEmoteSettings(true),
	},
	--[[
		    Services carries the same Praise Delay and sound as teammates, and no
		    cooldowns for the same reason. Its sound ships off: a feast or a portal
		    is ambient group help rather than something aimed at you, so it earns a
		    chat line by default and nothing louder.
		]]
	services = {
		-- Master switch for the whole panel. On by default, like teammates.
		enabled = true,
		printEnabled = true,
		whisperEnabled = false,
		praiseDelayEnabled = false,
		praiseDelay = 2,
		emotesEnabled = false,
		soundEnabled = false,
		emotes = GetDefaultEmoteSettings(true),
	},
	--[[
		    Good News: whispers for buffs YOU cast on other players.
		    `watched` is its own list (seeded from the `given` defaults in this
		    client's Tracked-Abilities file) because its ids are the same teammate buff
		    ids -- one shared table couldn't hold independent "thank for it" and
		    "announce it" choices.
		]]
	goodNews = {
		-- The panel's master switch. On by default, like teammates.
		whisperEnabled = true,
		--[[
			    Who gets the whisper: ALWAYS (anyone you buff) or GROUP (your
			    party/raid -- a battleground is a raid). Anything unrecognized
			    fails closed into the group check.
			]]
		scope = "ALWAYS",
		--[[
			    The editable body of the whisper. ONE token, %a, substituted by
			    ns:BuildGoodNewsMessage with the ability link plus -- for a short
			    enough buff -- its duration clause. That call also adds the star
			    marker (left off on WoW Forever) and the " // BBB" sign-off, and
			    trims the body's closing punctuation; neither is editable.
			]]
		message = ns.L["DEFAULT_GOOD_NEWS"],
		watched = {},
	},
	--[[
		    Buff Window: the click-to-cast list of group members missing a buff
		    you can give. On by default: it is self-only, and it
		    only appears when there is something you can fix. `audience` holds who
		    each buff is offered to (Data.BUFF_AUDIENCE), keyed by the row's first
		    single-target id, and seeds from the row defaults in this client's
		    Buff-Window-Spells file. `point` is nil until the window is first
		    dragged, and until then its top-left corner sits a little left of and
		    above the middle of the screen.
		]]
	buffWindow = {
		enabled = true,
		--[[
			    When to Show: whether the window shows solo and in a party or
			    raid, each with where (one of Data.BUFF_WINDOW_WHERE), and
			    which of your classes it shows on, keyed by class token. An
			    unset class reads as ticked. Paladins start off: most of them
			    run Pally Power for their blessings.
			]]
		showSolo = true,
		showSoloWhere = "ALWAYS",
		showGroup = true,
		showGroupWhere = "INSTANCE",
		showClasses = {
			PALADIN = false,
		},
		locked = false,
		hideInCombat = true,
		--[[
			    Minutes left under which a buff counts as missing; one of
			    Data.BUFF_WINDOW_REFRESH_CHOICES.
			]]
		refreshMinutes = 3,
		--[[
			    When each class, and pets (Data.TANK_WHEN_PET), take Tanks buffs
			    (Thorns) without a role of their own: one of Data.TANK_WHEN, keyed
			    by class token. A class with no entry is NEVER; the classes that
			    can fight in melee, and pets, start SOLO.
			]]
		tankWhen = {
			DRUID = "SOLO",
			PALADIN = "SOLO",
			ROGUE = "SOLO",
			SHAMAN = "SOLO",
			WARRIOR = "SOLO",
			PET = "SOLO",
		},
		--[[
			    The Self Buffs row's master switch, and when each self buff shows
			    (one of Data.SELF_REFRESH_CHOICES), keyed by the row's first rank
			    id and seeded from this client's BUFF_WINDOW_SELF_SPELLS defaults.
			]]
		selfEnabled = true,
		selfRefresh = {},
		-- MIGRATION (remove after 2026-11-21): the selfRefresh keys already moved from 5 minutes to 3.
		selfRefreshMigrated = {},
		--[[
			    Whether each poison or imbue is ticked for each hand, keyed
			    "ROGUE_MAIN" and so on, then by the BUFF_WINDOW_WEAPON_ENCHANTS
			    row's first id. Unset reads as ticked.
			]]
		weaponPicks = {},
		--[[
			    The Weapon Buffs switch, its one Reapply timing (one of
			    Data.WEAPON_REFRESH_CHOICES), and whether each oil, stone or
			    lure is ticked for each hand ("MAIN" or "OFF", then the item
			    id; unset reads as ticked).
			]]
		weaponEnabled = true,
		weaponRefresh = 3,
		weaponItems = {},
		favorEnabled = true,
		-- One of Data.BUFF_WINDOW_FAVOR_CHOICES.
		favorSeconds = 40,
		targetEnabled = true,
		audience = {},
	},
	watchedBuffs = {},
}

--[[
    The extra Thank You buttons, generated from Data.THANK_YOU_BUTTONS rather
    than written out, so adding a sixth is a row in that list and nothing here.

    Button 1 is skipped: its `slash` defaults are declared above and are on by
    default. Every later button starts fully switched off -- no macro, no
    whisper text, no emotes -- and only does something once its owner has
    filled it in. An empty message sends no whisper and an all-false emote
    table performs no emote, so "off" needs no guard of its own. Each starts on
    the icon in this client's ns.THANK_YOU_MACRO_ICONS that names its button,
    so the macros tell apart on a bar, or on the default icon where none does.
]]
local startingIcons = {}
for _, icon in ipairs(ns.THANK_YOU_MACRO_ICONS) do
	if icon[2] then
		startingIcons[icon[2]] = icon[1]
	end
end

for index = 2, #Data.THANK_YOU_BUTTONS do
	local button = Data.THANK_YOU_BUTTONS[index]
	local buttonDefaults = {
		createMacro = false,
		message = "",
		macroIcon = startingIcons[index] or Data.THANK_YOU_DEFAULT_ICON,
	}
	if button.singleEmote then
		--[[
		    One chosen token, "" meaning none. A checklist would be the wrong shape:
		    there is nothing to choose randomly between.
		]]
		buttonDefaults.emote = ""
	else
		buttonDefaults.emotes = GetDefaultEmoteSettings(false)
	end
	THANKS_FOR_THE_BUFF_DEFAULTS[button.profileKey] = buttonDefaults
end

AddDefaults("global", THANKS_FOR_THE_BUFF_DEFAULTS)
