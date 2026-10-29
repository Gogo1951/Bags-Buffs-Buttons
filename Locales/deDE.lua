local L = LibStub("AceLocale-3.0"):NewLocale("Bags-Buffs-Buttons", "deDE")
if not L then
	return
end

--------------------------------------------------------------------------------
-- Brand
--------------------------------------------------------------------------------

--[[
    The add-on has two names. ADDON_TITLE, the full name, is for window
    titles and anywhere the add-on is talked about; ADDON_SHORT_NAME is for
    tooltips and the chat prints ("BBB // ..."). Both are proper nouns and
    stay as written in every locale, as does the full name inside any
    sentence below.
]]
L["ADDON_TITLE"] = "Bags Buffs & Buttons"
L["ADDON_SHORT_NAME"] = "BBB"

L["CHAT_LOADED"] =
	"Version %s. Die Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findest du unter Optionen > Addons > Bags Buffs & Buttons. Gefällt dir dieses Add-on? Erzähle einem Freund davon, markiere es auf CurseForge als Favorit oder klicke auf seiner GitHub-Seite auf Star. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Hilf Bags Buffs & Buttons beim Leveln"
L["OPTIONS_LEVEL_UP_THANKS"] = "Danke, dass du dich für Bags Buffs & Buttons entschieden hast!"

--------------------------------------------------------------------------------
-- Connoisseur & Restocker
--------------------------------------------------------------------------------

-- Every string from here to Thanks for the Buff is Connoisseur & Restocker's.

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Verband"
L["MACRO_EXPLOSIVES"] = "- Sprengstoff"
L["MACRO_FEED_PET"] = "- Tier füttern"
L["MACRO_FOOD"] = "- Essen"
L["MACRO_HEALTH_POTION"] = "- Heiltrank"
L["MACRO_HEALTHSTONE"] = "- GS"
L["MACRO_MANA_GEM"] = "- Manastein"
L["MACRO_MANA_POTION"] = "- Manatrank"
L["MACRO_POISONS"] = "- Gifte"
L["MACRO_SOULSTONE"] = "- Seelenstein"
L["MACRO_WATER"] = "- Wasser"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a list: a Readiness Report clause, the Restocker's "Couldn't move" list, or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = ","

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    Diet names as returned by the pet diet reader, which is localized. These
    values MUST match the client's strings exactly (verify in-game with a pet
    out: /dump GetPetFoodTypes() on Era and TBC,
    /dump C_PetInfo.GetPetFoodTypes() on Forever). Used to build
    ns.PET_DIET_MAP in Data/Data.lua.

    They are ALSO the food checkbox labels in the staples pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Brot"
L["DIET_CHEESE"] = "Käse"
L["DIET_FISH"] = "Fisch"
L["DIET_FRUIT"] = "Obst"
L["DIET_FUNGUS"] = "Fungus"
L["DIET_MEAT"] = "Fleisch"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sieht aus, als hättest du einen Bug gefunden! %s (%s) kann in %s > %s (%s) nicht verwendet werden. Bitte melde das, damit wir es beheben können. Danke! %s"
L["MESSAGE_NO_ITEM"] = "Kein geeigneter Gegenstand vom Typ %s in deinen Taschen gefunden."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Einige Makros von Connoisseur & Restocker konnten nicht erstellt werden, weil deine Makroplätze voll sind. Mache einen Platz frei, indem du Makros löschst, die du nicht mehr verwendest, oder deaktiviere nicht benötigte Makros von Connoisseur & Restocker unter Optionen > Addons > Connoisseur & Restocker > Makros."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. %s is "/m", the game's own macro command, colored
    at the call site. "General" is the macro window's tab for account-wide
    macros; use the client's own name for that tab. The macro names are this
    locale's own MACRO_FOOD and MACRO_WATER values, written exactly as this
    locale ships them.
]]
L["MESSAGE_MACROS_READY"] =
	"Deine Makros sind bereit. Gib %s ein, öffne den Reiter Allgemeine Makros und ziehe - Essen, - Wasser und die anderen auf deine Aktionsleisten."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s steht jetzt auf der Ignorierliste dieses Charakters."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "1 Gegenstand von der Ignorierliste dieses Charakters entfernt."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "%d Gegenstände von der Ignorierliste dieses Charakters entfernt."

L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann das Optionsmenü im Kampf nicht geöffnet werden."

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    Printed when a ready check starts, as a header plus up to three lines. Each
    line is a set of "Label : a, b, c" clauses joined by ". ", and every part of
    it is dropped when it has nothing to say -- a clean character prints nothing
    at all, so there is no all-clear string here and must not be one.

    The joins are keys of their own so a locale can use its own punctuation:
    READINESS_CLAUSE_FORMAT puts a clause's label before its items, the items
    are joined with LIST_SEPARATOR, and the clauses with
    READINESS_CLAUSE_SEPARATOR.
]]

L["READINESS_TITLE"] = "Bereitschaftsbericht"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Fehlende Buffs:"
L["READINESS_EXPIRING"] = "Läuft bald ab:"
L["READINESS_MISSING_ITEMS"] = "Fehlende Gegenstände:"
L["READINESS_DAMAGED_GEAR"] = "Beschädigte Ausrüstung:"
L["READINESS_CHARACTER"] = "Charakter:"
L["READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt:"

--[[
    What the report calls each thing. The Readiness Report panel labels its
    switches with these same keys, so a switch names exactly the line it
    controls; a switch that needs other words than its line (Main Hand Weapon
    Buff, PvP Flag On) keeps an OPTIONS_READINESS_* label of its own, and
    Scroll Buffs borrows FEATURE_SCROLL_BUFFS, the Macros feature it needs.
    Well Fed, Main Hand and Off Hand are the client's own names (the buff,
    MAINHANDSLOT and SECONDARYHANDSLOT), so they have no keys here, and
    READINESS_PET_FORMAT puts Well Fed in the pet's line (%s is that name).

    Deliberately its own set rather than the shared LABEL_* keys the macro
    messages use: those name an item you are being offered ("Health Potion"),
    these name a gap in your preparation ("Healing Potion"), and the two want
    to be reworded independently.
]]
L["READINESS_FLASK"] = "Fläschchen oder 2x Elixiere"
L["READINESS_PET_FORMAT"] = "%s (Tier)"
L["READINESS_SCROLLS"] = "Schriftrollen"
L["READINESS_SOULSTONE"] = "Seelenstein inaktiv"
L["READINESS_HEALTHSTONE"] = "Gesundheitsstein"
L["READINESS_MANA_GEM"] = "Manastein"
L["READINESS_HEALING_POTION"] = "Heiltrank"
L["READINESS_MANA_POTION"] = "Manatrank"
L["READINESS_BANDAGES"] = "Verbände"
L["READINESS_PVP_ON"] = "PvP aktiv"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d Min."
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s unter 1 Min."
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 nicht verteilter Talentpunkt"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d nicht verteilte Talentpunkte"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf, and TIP_EMPTY_* via ConnoisseurNoItem. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Du hast derzeit kein nützliches Futter für dein Tier."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Du kennst derzeit keinen der Zauber %s, %s, %s oder %s."
L["TIP_PET_NO_MEND"] = "Du kennst Tier heilen derzeit nicht."
L["TIP_NO_HAND_POISON"] = "Für diese Waffe ist das gewählte Gift aufgebraucht."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Du kennst %s derzeit nicht."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "Kein %s in deinen Taschen. Rechtsklicke auf %s, um mehr herbeizuzaubern."
L["TIP_EMPTY_CREATE"] = "Kein %s in deinen Taschen. Rechtsklicke auf %s, um einen herzustellen."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Buff-Essen"
L["FEATURE_SCROLL_BUFFS"] = "Schriftrollen-Buffs"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. The Readiness Report's block takes its title from
    READINESS_TITLE.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Buff-Essen und Schriftrollen"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Verwendet Essen mit "%s" und wendet fehlende Schriftrollen-Buffs an, bevor du isst.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Aktuelles Essen"
L["MINIMAP_BEST_PET_FOOD"] = "Aktuelles Tierfutter"
L["MINIMAP_MAIN_HAND_POISON"] = "Waffenhand-Gift"
L["MINIMAP_OFF_HAND_POISON"] = "Schildhand-Gift"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Ignorierliste"
L["MINIMAP_IGNORE_COUNT"] = "%d Gegenstände"
L["MENU_IGNORE"] = "Ignorieren"
L["MENU_CLEAR_IGNORE"] = "Ignorierliste leeren"

--[[
    Restocker Report block in the mini-map tooltip. While the outstanding
    restocking orders are few enough to fit, it lists them under the header,
    one item per row; past that it shows only how many there are, beside the
    header. An order is one Restock List row with Buy switched on that is still
    short in your bags, so the count is of rows and not of missing units -- nine
    outstanding orders can be nine single juices or nine full stacks. The header
    beside it supplies the "restocking", so the count only needs the noun.

    The count only ever stands in for a list too long to show, so it is never
    one and needs no singular.

    The count sits in the tooltip's right column, beside the header, so it has
    to stay short enough to read as a value rather than a sentence. The
    all-stocked case has no header and no count: STOCKED replaces the whole
    row, on a wrapping line of its own, so it can be a full sentence. EMPTY is
    the line under the header when the list holds nothing at all, which is not
    the same as being stocked.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.
]]
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker-Bericht"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d offene Posten"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Glückwunsch, deine Vorräte sind vollständig aufgefüllt!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Deine Liste ist leer."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restocker-Liste"
L["MENU_RESTOCKER_DESCRIPTION"] = "Kauft die Gegenstände auf deiner Liste und lagert sie in der Bank."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + Rechtsklick"
L["MENU_OPTIONS"] = "BBB-Optionen"
L["MENU_OPTIONS_KEYBIND"] = "Shift + Mittelklick"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, which is
    the client's name for the player's class and has no key here, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "Tier-füttern-Makro"
L["NOTE_MACRO_FOOD_WATER"] = "Essen- und Wasser-Makros"
L["NOTE_MACRO_MANA_GEM"] = "Manastein-Makro"
L["NOTE_MACRO_HEALTHSTONE"] = "GS-Makro"
L["NOTE_MACRO_SOULSTONE"] = "Seelenstein-Makro"
L["NOTE_MACRO_POISONS"] = "Gifte-Makro"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Rufen, füttern oder wiederbeleben"
L["NOTE_PET_MEND_CLICK"] = "Rechtsklick oder im Kampf"
L["NOTE_HOLD_SHIFT"] = "Shift halten"
L["NOTE_PET_FORCE_REVIVE"] = "Wiederbeleben erzwingen"
L["NOTE_HOLD_CONTROL"] = "Strg halten"
L["NOTE_PET_DISMISS"] = "Freigeben"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Herbeizaubern"
L["NOTE_CREATE"] = "Herstellen"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Erneuter Rechtsklick"
L["NOTE_LOWER_RANK_BACKUP"] = "Ersatz niedrigeren Ranges"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um Essen oder Wasser für dessen Stufe herbeizuzaubern."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um einen Gesundheitsstein für dessen Stufe herzustellen."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Gifte-Fenster"
L["NOTE_POISONS_REPLACED"] = "Ersetzt alte Gifte automatisch."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Verband"
L["LABEL_EXPLOSIVE"] = "Sprengstoff"
L["LABEL_FOOD"] = "Essen"
L["LABEL_HEALTH_POTION"] = "Heiltrank"
L["LABEL_HEALTHSTONE"] = "Gesundheitsstein"
L["LABEL_MANA_GEM"] = "Manastein"
L["LABEL_MANA_POTION"] = "Manatrank"
L["LABEL_PET_FOOD"] = "Tierfutter"
L["LABEL_POISON"] = "Gift"
L["LABEL_SOULSTONE"] = "Seelenstein"
L["LABEL_WATER"] = "Wasser"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Aktiviert"
L["MINIMAP_DISABLED"] = "Deaktiviert"
L["MINIMAP_TOGGLE"] = "Umschalten"
L["MINIMAP_OPEN"] = "Öffnen"
L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_MIDDLE_CLICK"] = "Mittelklick"
L["MINIMAP_SHIFT_LEFT"] = "Shift + Linksklick"

--------------------------------------------------------------------------------
-- Mode Values
--------------------------------------------------------------------------------

--[[
    The one when-to-use list, offered by every mode dropdown: Prioritize Buff
    Food, Enable Scroll Buffs, Use Pet Food Buffs, and Use Conjured Food &
    Water First. %s in OPTIONS_MODE_DESCRIPTION is the feature's name,
    FEATURE_BUFF_FOOD, FEATURE_SCROLL_BUFFS or OPTIONS_PET_HEADER; the
    conjured dropdown has hover text of its own. The dropdowns have no
    caption, so each value carries its own "when". Leveling means below the
    client's max level.

    In the mini-map tooltip, the Buff Food & Scrolls block, while a switch is
    on but no choice applies, shows that choice's label in place of
    MINIMAP_ENABLED, so every label has to read as a state too.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	'Legt fest, wann dein Essen-Makro "%s" anbietet: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe.'
L["MODE_ALWAYS"] = "Immer"
L["MODE_SOLO"] = "Beim Solospiel"
L["MODE_PARTY"] = "In Gruppe oder Schlachtzug"
L["MODE_RAID"] = "Im Schlachtzug"
L["MODE_LEVELING"] = "Beim Leveln"
L["MODE_MAX_LEVEL"] = "Auf Höchststufe"

--------------------------------------------------------------------------------
-- Inventory Report
--------------------------------------------------------------------------------

--[[
    The block Features/Inventory-Report.lua adds under an item's own tooltip
    lines. Its header is "C & R // Inventory Report": ADDON_SHORT_NAME, then the
    title, in the chat prints' branded colors, with the total at its right
    edge. Under it, one line per character, this one first: the name on the
    left (the client's own character names, so no keys here), its counts at
    the right edge.

    Keep the counts short: they share a line with a name, and the tooltip is
    as wide as its longest line.
]]
L["INVENTORY_REPORT_TITLE"] = "Inventarbericht"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Taschen %s, Bank %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Taschen %s"
L["INVENTORY_REPORT_BANK"] = "Bank %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Gesamt %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Gibt beim Anmelden eine Willkommensnachricht im Chat aus."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Minikarten-Button aktivieren"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Zeigt den Minikarten-Button an."

-- Features: each feature's master switch, also on the panel that configures it.
-- Options: each add-on's heading page
L["OPTIONS_TFTB_DESCRIPTION"] =
	"Bedankt Euch automatisch per Flüstern oder Emote bei jedem Spieler, der Euch bufft, und haltet Euren Schlachtzug, Euch selbst und Eure Waffen gebufft, mit einer Erinnerung an fehlende Buffs, die per Klick wirkt. Dazu Benachrichtigungen für Festmähler, Portale, Beschwörungen und Seelenbrunnen. Gute Manieren, automatisiert."
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Mouseover-, Cursor- und Selbstzauber-Makros für jeden Klassenzauber, mit einem Klick in einem neuen Zauberbuch-Reiter erstellt, ganz ohne Makrosyntax. Sie bleiben aktuell, wenn du aufsteigst, trainierst oder die Spezialisierung wechselst. Per Rechtsklick kommen Fokus, Zaubern abbrechen, automatischer Angriff, Begleiterangriff oder Schmuckstücke dazu."

L["OPTIONS_MACROS_ENABLE"] = "Makro-Aktualisierungen aktivieren"
L["OPTIONS_MACROS_ENABLE_DESCRIPTION"] =
	"Hält deine Makros von Connoisseur & Restocker auf deine besten Gegenstände ausgerichtet, während sich deine Taschen ändern. Aus lässt jedes Makro so, wie es zuletzt war."
L["OPTIONS_RESTOCKER_ENABLE"] = "Restocker aktivieren"
L["OPTIONS_RESTOCKER_ENABLE_DESCRIPTION"] =
	"Kauft und lagert nach deiner Nachschubliste ein und erinnert dich, wenn dir etwas ausgeht. Aus schaltet all das ab, auch das Fenster der Nachschubliste."

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Beispiel: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/bbb"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsmenü dieses Add-ons."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Öffnet deine Nachschubliste."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Dieses Add-on wurde von Spielern entwickelt, die dieses Spiel lieben und es für alle so unterhaltsam wie möglich machen wollen. Wir werden nie um Spenden bitten. Die wahre Genugtuung liegt darin, zu wissen, dass unsere Arbeit das Spiel für dich ein kleines bisschen besser macht. Wenn das so ist, würden wir uns freuen, davon zu hören!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Hier sind ein paar Möglichkeiten, wie du uns helfen kannst, mehr Spieler zu erreichen."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Feedback geben: Einen Fehler gefunden oder eine Idee? Sag es uns auf Discord. Dein Feedback hilft uns, das Add-on zu verbessern, und Pull-Requests sind jederzeit willkommen."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Einem Freund erzählen: Kennst du jemanden, dem dieses Add-on gefallen könnte? Erzähl ihm davon. Mundpropaganda hilft mehr Spielern, großartige Add-ons zu entdecken."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorit auf CurseForge: Öffne unten den CurseForge-Link, melde dich an und klicke auf den Stern unter der Schaltfläche Download. Favoriten helfen mehr Spielern, das Add-on zu entdecken."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star auf GitHub: Öffne unten den GitHub-Link, melde dich an und klicke oben rechts auf Star. Sterne helfen dem Projekt, sich für weitere kostenlose Entwicklerwerkzeuge zu qualifizieren."

L["OPTIONS_FEEDBACK"] = "Feedback & Unterstützung"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Links für Feedback & Unterstützung"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Um einen Link zu kopieren, klicke in sein Feld und drücke dann Strg+A und Strg+C."
L["OPTIONS_VERSION"] = "Version %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Macro Updates and
    Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Makros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur & Restocker erstellt ein Makro pro Verbrauchsgegenstand und hält es aktuell, während sich deine Taschen ändern, damit der Button auf deiner Leiste immer zum besten Gegenstand greift, den du dabeihast. Wähle unten, welche Makros erstellt werden, und lege dann fest, wie jedes seinen Gegenstand auswählt."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Makronamen auf Buttons aktivieren"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Zeigt den Makronamen-Text auf den Buttons deiner Aktionsleisten an, den Connoisseur & Restocker standardmäßig ausblendet."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Zu erstellende Makros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Wähle, welche Makros Connoisseur & Restocker erstellt und pflegt. Wenn du eines deaktivierst, wird es auch entfernt. Du findest sie im Reiter Allgemeine Makros des Makrofensters, bereit zum Ziehen auf deine Aktionsleisten."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Makrofenster öffnen"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Öffnet das Makrofenster des Spiels im Reiter Allgemeine Makros, wo diese Makros liegen."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"Erstellt und pflegt dieses Makro und entfernt es, wenn du das Kästchen abwählst."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Essen und Wasser"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Deine Essen- und Wasser-Makros verwenden das beste Essen und die besten Getränke in deinen Taschen. Diese Optionen können Buff-Essen, Schriftrollen oder herbeigezaubertes Essen und Wasser an die erste Stelle und Essen und Wasser der Nachschubliste an die letzte Stelle setzen."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Buff-Essen bevorzugen"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Bevorzugt Essen, das den "%s"-Buff gewährt, wenn der Buff fehlt, außer in Arenen.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Schriftrollen-Buffs aktivieren"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Dein Essen-Makro wendet beim ersten Drücken fehlende Schriftrollen an und lässt dich beim nächsten essen, überspringt die Schriftrollen aber, wenn du einen befreundeten Spieler anvisierst oder in einer Arena bist."
L["OPTIONS_SCROLL_TYPES"] = "Schriftrollentypen in Prüfung einschließen"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Schutz"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Schließt "%s" in die Prüfung auf fehlende Buffs ein.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Herbeigezaubertes Essen und Wasser zuerst verwenden"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Deine Essen- und Wasser-Makros verwenden herbeigezaubertes Essen und Wasser vor allem anderen, auch wenn etwas in deinen Taschen mehr wiederherstellt, denn es kostet nichts und verschwindet kurz nach dem Ausloggen. Buff-Essen hat weiterhin Vorrang, solange "Buff-Essen bevorzugen" aktiviert ist.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Legt fest, wann herbeigezaubertes Essen und Wasser Vorrang haben: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Essen und Wasser der Nachschubliste zuletzt verwenden"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Von zwei Speisen oder Getränken, die gleich viel wiederherstellen, verwenden deine Essen- und Wasser-Makros das, was nicht auf deiner Nachschubliste steht. So bleibt, was der Nachschub kauft, für später."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Tränke und Gesundheitssteine"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden (dies ist eine Blizzard-Einschränkung). Daher wird jedes Trank- und Gesundheitsstein-Makro im Voraus mit deinem besten Gegenstand und bis zu zwei Ersatzgegenständen erstellt. Bei längeren Kämpfen können das Symbol und der Tooltip veralten und den falschen Gegenstand anzeigen, aber ein Klick auf das Makro verwendet immer den besten Gegenstand, den du tatsächlich in deinen Taschen hast."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Essen und Wasser außerhalb des Kampfes in Trank-Makros verwenden"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Außerhalb des Kampfes isst du mit deinem Heiltrank-Makro dein bestes Essen und trinkst mit deinem Manatrank-Makro dein bestes Wasser. Im Kampf verwenden die Makros wie bisher deine Tränke. Schriftrollen, Tierfutter und das Herbeizaubern bleiben bei den Essen- und Wasser-Makros."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Gesundheitssteine mit Heiltrank-Makro kombinieren"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Fügt deinen besten Gesundheitsstein unten an das Heiltrank-Makro an, sodass ein Tastendruck einen Trank und einen Gesundheitsstein verwendet."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Manasteine und Runen"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s und einige andere Mana-Gegenstände teilen sich die Abklingzeit mit Manasteinen. Die Runen kosten bei der Verwendung Gesundheit, daher lässt das Manastein-Makro all diese Gegenstände weg, solange du sie nicht hinzufügst."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Runen und andere Mana-Gegenstände zum Manastein-Makro hinzufügen"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Nimmt %s, %s sowie jeden anderen Mana-Gegenstand, der sich die Abklingzeit mit Manasteinen teilt, in die Rangfolge deiner Manasteine auf, sodass das Manastein-Makro einen davon verwendet, wenn das deine beste Wahl ist oder du keine Manasteine mehr hast."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Buff-Erneuerung"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden, daher bleibt ein Buff, der mitten im Kampf abläuft, bis zum Ende des Kampfes weg."
L["OPTIONS_REAPPLY"] = "Ablaufende Buffs erneuern"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Behandelt Buff-Essen, Schriftrollen-Buffs und Tierfutter-Buffs mit weniger Restzeit als deinem Schwellenwert als abgelaufen, sodass deine Makros vor dem Pull einen frischen anbieten."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen darf, bevor deine Makros einen frischen anbieten."
L["REAPPLY_THRESHOLD_ONE"] = "Wenn < 1 Minute übrig"
L["REAPPLY_THRESHOLD_MANY"] = "Wenn < %d Minuten übrig"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Tierfutter-Buffs"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'Ein paar Futtersorten verleihen deinem Tier einen eigenen "%s"-Buff.'
L["OPTIONS_USE_PET_BUFFS"] = "Tierfutter-Buffs verwenden"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Fügt deinem Essen-Makro Tierfutter hinzu, wenn deinem Tier der "%s"-Buff fehlt, außer in Arenen.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Tierfutter-Arten in Prüfung einschließen"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Sprengstoff"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"Die @player-Option überspringt den Zielkreis und zündet den Sprengstoff direkt zu deinen Füßen. Ideal, wenn dein Ziel in Nahkampfreichweite ist. Der andere Klick wirft ihn wie gewohnt."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Klickbelegung"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Legt fest, welcher Klick den Sprengstoff wirft und welcher ihn zu deinen Füßen zündet."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Linksklick @player"
L["EXPLOSIVES_MODE_TOSS"] = "Linksklick Werfen"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Klasse und Volk"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Diese Optionen passen deine Makros für eine Klasse oder ein Volk an. Jeder Abschnitt wird bei jedem Charakter angezeigt."

-- The class and race sections' headers; %s is the client's name for the class or race, or OPTIONS_FORSAKEN_HEADER.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Klassenoptionen: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Volksoptionen: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Benötigt das Add-on DruidMacroHelper. Eingeschaltet holen dich deine Heiltrank-, Manatrank- und Gesundheitsstein-Makros per Powershifting aus der Gestalt, verwenden den Gegenstand und versetzen dich zurück in Bärengestalt oder Katzengestalt, je nachdem, was du neben dem Kontrollkästchen wählst."
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper-Integration aktivieren"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Erstellt Powershifting-Makros für Heiltränke, Manatränke und Gesundheitssteine mithilfe von DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Legt fest, in welche Gestalt dich deine Powershifting-Makros nach dem Verwenden des Gegenstands zurückverwandeln."
L["DRUID_FORM_BEAR"] = "Zurück in Bärengestalt"
L["DRUID_FORM_CAT"] = "Zurück in Katzengestalt"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Hält das Gifte-Makro mit dem besten nutzbaren Rang jedes Gifttyps bestückt. Linksklick trägt auf die Schildhand auf, Rechtsklick auf die Waffenhand; vorhandene Gifte werden automatisch ersetzt."
L["OPTIONS_POISON_MAIN_HAND"] = "Gifttyp Waffenhand"
L["OPTIONS_POISON_OFF_HAND"] = "Gifttyp Schildhand"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Rechtsklick auf deine Waffenhand aufträgt."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Linksklick auf deine Schildhand aufträgt."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Verstohlenes Essen aktivieren"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Essen-Makro hinzu, damit du beim Essen verborgen bist."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Verstohlenes Trinken aktivieren"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] =
	"Fügt %s zu deinem Wasser-Makro hinzu, damit du beim Trinken verborgen bist."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Profi-Tipp: Wähle eines. Du kannst gleichzeitig essen und trinken, aber Essen oder Trinken nach dem Verstecken beendet deine Tarnung."

--[[
    Forsaken. Headed with our own word, the race's lore name, since the client
    names it Undead; in the five texts after the header, %s is the client's
    name for Cannibalize. Drinking shows only where Cannibalize restores mana.
]]
L["OPTIONS_FORSAKEN_HEADER"] = "Verlassene"
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Nimm einen getöteten Humanoiden oder Untoten ins Ziel, und dein Makro wirkt %s, solange der Zauber bereit ist, und spart so dein Essen und Trinken. Geht das nicht (die Leiche ist außer Reichweite oder der Zauber hat Abklingzeit), isst oder trinkt es wie gewohnt."
L["OPTIONS_CANNIBALIZE_EATING"] = "%s statt Essen verwenden"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Essen-Makro ihn, statt zu essen. Sonst isst es wie gewohnt. Schriftrollen und Buff-Essen haben weiterhin Vorrang."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "%s statt Trinken verwenden"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Solange dein Ziel eine Leiche ist, an der %s wirkt, und der Zauber bereit ist, wirkt dein Wasser-Makro ihn, statt zu trinken. Sonst trinkt es wie gewohnt. Buff-Getränke haben weiterhin Vorrang."

--[[
    Ignore List panel (Options-Ignore-List.lua). One tree scope per list: the
    Global list, then the character playing and every other character with
    something ignored, each under its profile's name, which is never
    translated and has no key here. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map tooltip, the Macros
    panel, and the staples pop-up use it too). The mini-map tooltip's section
    keeps its own MINIMAP_IGNORE_LIST and MENU_CLEAR_IGNORE keys.
]]
L["TAB_IGNORE_LIST"] = "Ignorierliste"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ignorierte Gegenstände werden von keinem Makro ausgewählt. Essen, Wasser, Tränke, alles. Die Global-Liste gilt für jeden Charakter; die Liste eines Charakters gilt nur für diesen einen. Rechtsklicke auf den Minikarten-Button, um dein aktuell bestes Essen zu ignorieren."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Verschiebt diesen Gegenstand auf die Global-Liste, sodass er auf jedem Charakter ignoriert wird."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Wähle etwas aus, das du bei dir trägst. Die Taschen schließen sich, wenn das Optionsmenü geöffnet wird, daher ersetzt dies das Hineinziehen eines Gegenstands."
L["OPTIONS_IGNORE_ADD_ID"] = "Per Gegenstands-ID hinzufügen"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat, während dieses Feld ausgewählt ist."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat."
L["OPTIONS_IGNORE_REMOVE"] = "Entfernen"
L["OPTIONS_IGNORE_EMPTY"] = "Diese Liste ist leer."
L["OPTIONS_IGNORE_CLEAR"] = "Liste leeren"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Entfernt alle Gegenstände aus dieser Liste. Ein Charakter mit leerer Liste verschwindet aus der Liste links, außer es ist der, den du gerade spielst."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] =
	"Alle Gegenstände aus dieser Liste entfernen? Das lässt sich nicht rückgängig machen."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Lade ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Hält deine Taschen anhand deiner Nachschubliste gefüllt, indem automatisch bei Händlern eingekauft und Gegenstände zwischen Taschen und Bank verschoben werden. Gib %s ein, um die Liste zu öffnen."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Bei der Bank öffnen"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du die Bank besuchst."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Beim Händler öffnen"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du einen Händler besuchst."
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Erinnerungen"
L["OPTIONS_RESTOCKER_REMIND"] = "Nachschub-Erinnerungen in der Stadt aktivieren"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Gibt eine Chat-Erinnerung aus, wenn deiner Nachschubliste etwas fehlt und du ein Gasthaus oder eine Stadt erreichst oder dich beim Anmelden bereits dort befindest."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Nachschub-Erinnerungen beim Händler aktivieren"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Meldet alle offenen Nachschubposten, wenn du ein Händlerfenster schließt."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Nachschub-Erinnerungen bei der Bank aktivieren"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "Meldet alle offenen Nachschubposten, wenn du die Bank schließt."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Goldreserve aktivieren"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "Der Nachschub gibt das Gold, das du hier zurücklegst, nie aus."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] =
	"Legt fest, wie viel Gold dir der Nachschub immer übrig lässt."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Legt fest, ob die Erinnerung nur eine Zeile umfasst oder für jeden fehlenden Gegenstand eine Zeile hinzufügt."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Einfach"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Ausführlich"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Ton abspielen"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Spielt zusätzlich zur Erinnerung einen Hinweiston ab, falls im Chat gerade viel los ist."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Klicke, um den Hinweiston zu hören."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenster der Nachschubliste"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Wähle, wann sich deine Nachschubliste von selbst öffnet."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Zeigt im Tooltip eines Gegenstands an, wie viele davon du auf all deinen Charakteren dieses Realms besitzt."
L["OPTIONS_INVENTORY_REPORT"] = "Inventarbericht in Gegenstands-Tooltips aktivieren"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Fügt dem Tooltip eines Gegenstands hinzu, wie viele davon du in deinen Taschen, in deiner Bank und auf deinen anderen Charakteren hast. Deaktiviere den Bericht, wenn bereits ein anderes Add-on diese Zahlen anzeigt."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Danksagung"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Ich habe Restocker schon immer geliebt und bin dankbar für die Gelegenheit, ihn in Connoisseur & Restocker weiterleben zu lassen. Ein riesiges Dankeschön an ChiliFajita für den ursprünglichen Auto Restocker und an kvakvs und guardycmw, die ihn durch Classic und Mists of Pandaria am Leben gehalten haben."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Bereitschaftsbericht"
L["OPTIONS_READINESS_ENABLE"] = "Bereitschaftsbericht beim Bereitschaftscheck aktivieren"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "Aktiviert den Bereitschaftsbericht für alle Charaktere dieses Accounts."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Gibt beim Start eines Bereitschaftschecks eine private Liste dessen aus, was noch behoben werden muss, und bleibt komplett still, wenn du bereit bist."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Bereitschaftsbericht-Einstellungen zurücksetzen"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Setzt jedes Kontrollkästchen und beide Schwellenwerte auf dieser Seite auf ihre Standardwerte zurück."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Alle Einstellungen des Bereitschaftsberichts auf ihre Standardwerte zurücksetzen? Das schaltet auch den Bericht selbst wieder aus."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Fehlende Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Fehlende Gegenstände"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Charakter"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Meldet ein fehlendes Fläschchen. Ein Fläschchen oder je ein Kampf- und ein Wächterelixier gelten als abgedeckt."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] =
	'Meldet einen fehlenden "%s"-Buff. Erfordert aktiviertes Buff-Essen unter Makros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION_FORMAT"] =
	'Meldet den fehlenden "%s"-Buff deines Tiers. Erfordert aktivierte Tierfutter-Buffs unter Makros und ein herbeigerufenes Tier.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Meldet fehlende Schriftrollen-Buffs. Erfordert aktivierte Schriftrollen-Buffs unter Makros und prüft nur die dort ausgewählten Schriftrollentypen."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Meldet sich, wenn auf niemandem in deiner Gruppe ein Seelenstein aktiv ist; einer in einer Tasche zählt nicht. Wird nur einem Hexenmeister gemeldet, der einen herstellen kann."
L["OPTIONS_READINESS_MAIN_HAND"] = "Waffenbuff (Waffenhand)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Waffenhand ohne temporäre Verzauberung. Jede Verzauberung zählt, und der Bericht schweigt dazu, wenn ein Schamane in deiner Gruppe ist."
L["OPTIONS_READINESS_OFF_HAND"] = "Waffenbuff (Schildhand)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Schildhand ohne temporäre Verzauberung. Jede Verzauberung zählt: ein Stein, ein Öl, ein Gift oder ein Schamanen-Waffenbuff."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Ablaufende Buffs innerhalb von"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Nennt jeden Buff auf dir, der bald abläuft, nicht nur die von Connoisseur & Restocker angewendeten, und ist unabhängig von der Buff-Erneuerung unter Makros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s Minuten"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 Minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen muss, damit der Bericht ihn nennt."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Gesundheitsstein dabeihast. Wird nur gemeldet, wenn ein Hexenmeister in deiner Gruppe ist, den man fragen kann, oder wenn du selbst der Hexenmeister bist."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manastein dabeihast. Wird nur einem Magier gemeldet, der einen herbeizaubern kann."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Heiltrank dabeihast, denn mitten im Kampf kann dir niemand einen reichen."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manatrank dabeihast. Wird nur gemeldet, wenn du eine Klasse spielst, die Mana verwendet."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Verband dabeihast, den du mit deiner Fertigkeit %s verwenden kannst."
L["OPTIONS_READINESS_DURABILITY"] = "Beschädigte Ausrüstung unter"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Verlinkt jeden angelegten Gegenstand unter dieser Haltbarkeit, pro Gegenstand gemessen, damit auch eine einzelne kaputte Waffe auftaucht."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie tief die Haltbarkeit eines Gegenstands sinken muss, damit der Bericht ihn verlinkt."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Aktuelle Skillung"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Gibt deine Talentverteilung aus sowie alle Punkte, die du noch nicht verteilt hast."
L["OPTIONS_READINESS_PVP"] = "PvP-Status aktiv"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Warnt, wenn dein PvP-Status aktiv ist."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Verlinkt angelegte Gegenstände, die nicht in einen Kampf gehören, etwa Reit- oder Angelausrüstung."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Inventory-Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Eine Liste namens "%s" existiert bereits.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Es gibt keine ID %d."
L["RESTOCKER_BANK_NOT_OPEN"] = "Die Bank ist nicht geöffnet."
L["RESTOCKER_DISABLED"] = "Der Restocker ist aus. Schalte ihn unter Optionen > Addons > Connoisseur & Restocker ein."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Auffüllen abgeschlossen. Halte Shift beim Öffnen der Bank, um das Auffüllen zu überspringen. Gib %s ein, um deine Nachschubliste zu bearbeiten."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Auffüllen gestoppt. Deine Taschen und deine Bank sind voll."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Auffüllen gestoppt. Deine Bank ist voll; mache einen Platz frei und öffne sie erneut."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Auffüllen gestoppt. Deine Taschen sind voll; mache einen Platz frei und öffne die Bank erneut."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Auffüllen gestoppt. Es konnte kein Fortschritt erzielt werden."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Auffüllen gestoppt. Konnte nicht verschieben: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (überschüssig)"
L["RESTOCKER_STOPPED_ERROR"] = "Auffüllen wegen eines Fehlers gestoppt: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Inventory-Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Dieser Händler führt nicht alle Zutaten, die deine Gifte benötigen. Es wird keine davon gekauft."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Vergiss nicht, deine Vorräte aufzufüllen, solange du in der Stadt bist!"

--[[
    Headline for the merchant and bank reminders, which report on the way out
    rather than nudging on arrival, so the count is the message. The in-town
    reminder keeps its own line above.

    The count is of restocking orders -- Restock List rows with Buy switched on
    that are still short in your bags -- so it never says "items", and never
    puts a bare count after "short": "short 9 apples" reads as nine apples
    missing, while the number here is nine ROWS, each short by anything from one
    juice to a full stack. "Order" can only mean a line on a list, and it is the
    word the code uses (BuildPurchaseOrder, purchaseOrders).

    "Outstanding" is load-bearing, not decoration. "Restocking order" alone can
    be read as the sequence restocking happens in, and the list UI is sortable,
    so the word forcing the purchase-order sense has to stay beside the noun.
    Same job as "filled" on RESTOCKER_RESTOCKED_ONE -- never print the bare
    noun without one of them.
]]
L["RESTOCKER_STILL_SHORT_ONE"] = "1 Nachschubposten offen."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d Nachschubposten offen."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Deine Nachschubliste wurde aufgewertet."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d wird zu %sx%d."

--[[
    Verbose follow-up line, one per short item: { have, wanted, item link }.
    Shared by all three reminders. Wordless on purpose -- the headline above it
    supplies the context, so there is nothing here to translate. It stays a
    locale key anyway so a locale that needs a different order can reorder it
    (same as RESTOCKER_STUCK_ITEM_FORMAT).
]]
L["RESTOCKER_REMINDER_ITEM"] = "%d/%d %s"

--[[
    Printed after buying at a vendor. Counts restocking orders FILLED -- Restock
    List rows and poison ingredients whose whole requested amount was ordered --
    not BuyMerchantItem calls. Forty juice bought in two stacks of twenty is one
    order filled; six of a requested twenty is not one at all, and belongs to
    the partial line below.

    The claim has to be earned: PurchaseMerchantItem returns nothing, and the
    caller decides filled or partly filled once per order, after the last slot,
    from the units that order bought. What the vendor did not stock is
    deliberately not mentioned here: the mini-map's Restocker Report owns the
    outstanding state, this line owns the event, and neither repeats the other.
]]
L["RESTOCKER_RESTOCKED_ONE"] = "1 Nachschubposten erfüllt."
L["RESTOCKER_RESTOCKED_MANY"] = "%d Nachschubposten erfüllt."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 Nachschubposten teilweise erfüllt."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d Nachschubposten teilweise erfüllt."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Deine Taschen waren voll, bevor alles gekauft war."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "Nicht genug Gold, um den Nachschub abzuschließen."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Einkauf bei deiner Goldreserve (%s) gestoppt. Der Rest wird bei deinem nächsten Besuch gekauft, wenn du genug Gold übrig hast."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[Name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Legt eine Liste mit diesem Namen an."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Löscht die Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Benennt die aktuelle Liste auf diesen Namen um."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Ersetzt die aktuelle Liste durch eine Kopie der Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_USE"] = "Weist diesem Charakter die Liste mit diesem Namen zu."

--[[
    Starter List pop-up, the staples window: offers staples at login when the
    Restock List is empty, and on demand from the Restock List window's Pick
    Staples button. The staples logic is in
    Features/Inventory-Restocker/Restocker-Starter-List.lua, the window in
    Options/Options-Starter-List-Popup.lua. The six
    food staples reuse the DIET_ keys above, so each food row carries the
    client's own pet diet name.

    The title is its own, and the call site puts the add-on's full name
    after it (STARTER_POPUP_TITLE // ADDON_TITLE): at login this window
    opens with nothing else of the add-on's on screen, so its title bar is
    all that says whose it is.

    The intro is one paragraph: an opening sentence that answers to how the
    window was reached (LOGIN when it opened by itself at login, which checks
    a few staples before it opens; otherwise EMPTY over an empty list and
    STOCKED over one that has items), then HOW, which says what a check
    does. The two are run together with a space at the call site, so each
    has to stand as whole sentences.
    The way back in (COMMAND_HINT) is a second paragraph, shown only when the
    window opened by itself at login; from the Pick Staples button the list it
    names is open right behind it.
]]
L["STARTER_POPUP_TITLE"] = "Grundvorräte"
L["STARTER_POPUP_INTRO_LOGIN"] =
	"Wir haben schon ein paar Grundvorräte für deine Klasse angehakt, damit du loslegen kannst."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Deine Nachschubliste ist leer, also lass uns ein paar Gegenstände hinzufügen, damit du loslegen kannst."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Wähle die Grundvorräte, die aufgefüllt bleiben sollen."
L["STARTER_POPUP_INTRO_HOW"] =
	"Alles, was du anhakst, wird automatisch aufgefüllt, sobald du einen Händler oder deine Bank öffnest. Die meisten Grundvorräte werten sich mit deiner Stufe von selbst auf, sodass du immer das Beste dabeihast."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Du kannst diese Liste jederzeit anpassen oder später weitere Gegenstände hinzufügen, indem du %s eingibst."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Essen und Wasser"
L["STARTER_POPUP_FOOD_HEADER"] = "Essen"
L["STARTER_POPUP_AMMO_HEADER"] = "Munition"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Kugeln"
L["STARTER_POPUP_ARROWS"] = "Pfeile"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenzien und Werkzeuge"
L["STARTER_POPUP_POISONS_HEADER"] = "Gifte"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Setze das fertige Gift auf deine Liste, und Connoisseur & Restocker kauft die Zutaten automatisch bei jedem Händler, der sie alle führt."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Fügt %s zu deiner Nachschubliste hinzu, hält %d davon in deinen Taschen und wertet sie mit deiner Stufe auf."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Fügt %s zu deiner Nachschubliste hinzu und hält %d in deinen Taschen bereit."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 Stapel"
L["STARTER_POPUP_STACK_MANY"] = "%d Stapel"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Wie viele Stapel vorrätig bleiben sollen, wobei ein Stapel %d Stück umfasst."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Wie viele vorrätig bleiben sollen, jeweils auf einem eigenen Taschenplatz, da sie sich nicht stapeln lassen."

--[[
    Restock List window UI. The title names what the window holds, before the
    add-on's full name (RESTOCKER_WINDOW_TITLE // ADDON_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Nachschubliste"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Gegenstände filtern..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Leeren"
L["RESTOCKER_ADD_BUTTON"] = "Hinzufügen"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Grundvorräte wählen"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Wähle aus den Grundvorräten für deine Klasse und Stufe: Essen, Wasser, Munition, Gifte und Reagenzien. Was du anhakst, wird dieser Liste hinzugefügt, und was du abwählst, wird entfernt."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Gegenstand hinzufügen"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Ziehe einen Gegenstand aus deinen Taschen hierher oder irgendwo auf dieses Fenster, oder gib eine Gegenstands-ID ein und drücke Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Ziehen oder ID eingeben"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Stattdessen ID eingeben."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Schon auf dieser Liste."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Alle Gegenstände in deinen Taschen, die noch nicht auf dieser Liste stehen. Klicke auf einen, um ihn hinzuzufügen."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nichts in deinen Taschen zum Hinzufügen"

--[[
    The list bar across the top of the window: the selector, the characters on
    the list, and Manage Lists.

    USED_BY's %s is those characters, the client's own names joined with
    LIST_SEPARATOR, which also joins them on the selector's menu and in the
    delete confirmation. Each name is colored by its class at the call site.
    Keep USED_BY short: the line shares its row with the selector and the
    Manage Lists button, and truncates when it outgrows the space. MANAGE is
    that button's caption and the title of its tooltip.
]]
L["RESTOCKER_PROFILE_LABEL"] = "Liste"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Klicke, um diesem Charakter eine andere Nachschubliste zuzuweisen oder eine neue anzulegen."
L["RESTOCKER_USED_BY"] = "Genutzt von %s"
L["RESTOCKER_MANAGE"] = "Listen verwalten"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Lege eine neue Liste an oder kopiere diese, benenne sie um oder lösche sie."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Neue Liste"
L["RESTOCKER_MANAGE_COPY"] = "Diese Liste in eine neue kopieren"
L["RESTOCKER_RENAME_PROFILE"] = "Diese Liste umbenennen"
L["RESTOCKER_MANAGE_DELETE"] = "Diese Liste löschen"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Kopie"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Umbenennen"
L["RESTOCKER_RENAME_TOOLTIP"] = "Benennt diese Liste für jeden Charakter um, der sie verwendet."
--[[
    The delete confirmation, a paragraph per fact, joined with blank lines in
    code: QUESTION, the list's name (colored at the call site), what happens
    next, and FINAL.

    "What happens next" is SHARED followed by SWITCH or LAST, run together as
    one paragraph, so each has to stand as a full sentence. SHARED appears only
    when other characters are on the list; its %s is their names, joined with
    LIST_SEPARATOR, and ONE or MANY follows how many there are.

    SWITCH says where this character lands: %s is the top list in the List
    selector, colored at the call site. LAST stands in for it when the list
    being deleted is the only one, which is the one delete that makes a list.
]]
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Möchtest du diese Liste wirklich löschen?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s nutzt sie ebenfalls und findet beim nächsten Anmelden eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s nutzen sie ebenfalls und finden beim nächsten Anmelden jeweils eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Du wechselst dann zu %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es ist die einzige verbliebene Liste, daher beginnst du mit einer neuen, leeren."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Das kann nicht rückgängig gemacht werden."
--[[
    The Upgrade toggle. One string serves both the column heading and every
    row's checkbox, so it has to read for a single item and for the whole
    column at once -- which is why it names categories rather than "this item".

    The categories are exactly the ladder kinds in each flavor folder's
    Consumable-Upgrade-Paths-{Game}.lua: food, water, arrow and bullet, poison,
    healing and mana potion, and the class reagents. Naming anything else here
    promises an upgrade that never arrives, since the toggle is disabled on any
    item that is not on a ladder -- which on a real list is most of them.
]]
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mit steigender Stufe aufwerten"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Erlaubt Connoisseur & Restocker, Essen, Wasser, Munition, Gifte, Tränke und Klassenreagenzien mit steigender Stufe auf bessere Gegenstände aufzuwerten."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Bank"
L["RESTOCKER_ROW_MERCHANT"] = "Händler"
L["RESTOCKER_ROW_UPGRADE"] = "Aufwertung"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Gegenstand"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Holen"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Lagern"
L["RESTOCKER_COLUMN_REPUTATION"] = "Ruf"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Behalten"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Klicke auf die Überschrift, um dies für alle angezeigten Gegenstände festzulegen."
L["RESTOCKER_BULK_ON"] = "%d angezeigte aktivieren"
L["RESTOCKER_BULK_OFF"] = "%d angezeigte deaktivieren"

L["RESTOCKER_GROUP_OTHER"] = "Sonstiges"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Neu"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Alle Gegenstände"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Noch nichts auf dieser Liste"
L["RESTOCKER_EMPTY_BODY"] =
	"Wähle Grundvorräte wie Essen, Wasser oder Klassenreagenzien, oder füge über das Menü oben beliebige Gegenstände aus deinen Taschen hinzu. Gegenstände auf dieser Liste werden automatisch aufgefüllt oder in deiner Bank eingelagert, damit deine Taschen aufgeräumt bleiben."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Gegenstände, die du irgendwo auf dieses Fenster ziehst, werden auch hinzugefügt."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nichts auf dieser Liste passt zu deinem Filter."
L["RESTOCKER_NO_MATCH_GROUP"] = "In dieser Kategorie ist nichts mehr übrig."

--[[
    The status line under the list. The orders count itself is
    RESTOCKER_STILL_SHORT_ONE / _MANY above, and the all-stocked line is
    MINIMAP_RESTOCKER_STOCKED, so the window, the reminders and the mini-map
    tooltip say the same thing in the same words.

    NO_ORDERS is the in-between: nothing for a merchant to fill, but a row with
    Buy off is still short in the bags (its Keep number is yellow), so the
    congratulation would be untrue. "Outstanding" stays beside the noun, as in
    the counts.

    REPORT_MORE closes the orders tooltip when the list is longer than it shows:
    %d is how many were left out. REMOVED_ITEM's %s is the item's icon and name,
    and UNDO is the button beside it that puts the item back; UNDO_TOOLTIP
    renders in the title slot.
]]
L["RESTOCKER_NO_ORDERS"] = "Keine Nachschubposten offen."
L["RESTOCKER_REPORT_MORE"] = "und %d weitere"
L["RESTOCKER_REMOVED_ITEM"] = "%s entfernt."
L["RESTOCKER_UNDO"] = "Rückgängig"
L["RESTOCKER_UNDO_TOOLTIP"] = "Diesen Gegenstand wieder auf die Liste setzen"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Diesen Gegenstand von der Nachschubliste entfernen"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Du kannst das unten im Fenster rückgängig machen."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "In deinen Taschen behalten"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Wie viele du in deinen Taschen behalten willst. Die Zahl wird gelb, solange deine Taschen weniger enthalten, und eine 0 schickt bei aktiviertem Lagern alles in die Bank."
L["RESTOCKER_BUY_LABEL"] = "Kaufen"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Beim Händler kaufen"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Kauft die benötigte Menge beim Händler, wenn das Händlerfenster geöffnet ist."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Extra kaufen"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Kauft den gesamten begrenzten Vorrat eines Händlers an diesem Gegenstand, also Ware, die er nur nach und nach wieder auffüllt, auch über deinen Behalten-Wert hinaus."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "In der Bank lagern"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Lagert überschüssige Gegenstände in der Bank, wenn die Bank geöffnet ist, oder alle, wenn in der Behalten-Spalte 0 steht."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Aus der Bank holen"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Holt benötigte Gegenstände aus der Bank, wenn die Bank geöffnet ist."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Benötigter Ruf"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% Rabatt)"
L["RESTOCKER_REPUTATION_ANY"] = "Beliebig"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Benötigter Ruf beim Händler"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Klicke, um festzulegen, welchen Ruf ein Händler voraussetzt, bevor Connoisseur & Restocker bei ihm kauft, was auch den Preis senkt: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Mit einem Strich wird bei jedem Händler gekauft."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also gibt es nichts extra zu kaufen."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also spielt der Ruf keine Rolle."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Für diesen Gegenstand gibt es keine bessere Version zum Aufwerten."

--------------------------------------------------------------------------------
-- Thanks for the Buff
--------------------------------------------------------------------------------

-- Every string from here to Spellbook is Thanks for the Buff's.

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "%s hat Euch mit %s gebufft!"
L["MESSAGE_GAVE_YOU"] = "%s hat Euch %s gegeben!"
L["MESSAGE_GAVE_GROUP"] = "%s hat Eurer Gruppe %s gegeben!"
L["MESSAGE_USED_ITEM"] = "%s hat %s bei Euch benutzt!"
L["MESSAGE_USED_SPELL"] = "%s hat %s auf Euch gewirkt!"
L["MESSAGE_SET_OUT"] = "%s hat %s aufgestellt!"
L["MESSAGE_OPENED"] = "%s hat %s geöffnet!"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "Danke für %s"
L["MESSAGE_SELECT_PLAYER"] = "Nehmt zuerst einen Spieler ins Ziel."
L["MESSAGE_CANT_THANK_SELF"] = "Ihr könnt Euch nicht selbst danken!"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "Unbekannter Zauber"

--------------------------------------------------------------------------------
-- Options: Main Panel
--------------------------------------------------------------------------------

L["OPTIONS_EXAMPLE"] = "Beispiel: %s"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "Buffs von Fremden"
L["STRANGERS_ENABLE"] = "Dank für Buffs von Fremden aktivieren"
L["STRANGERS_ENABLE_DESCRIPTION"] = "Aktiviert den Dank für Buffs von Spielern außerhalb Eurer Gruppe."
L["STRANGERS_DESCRIPTION"] = "Dankt Spielern außerhalb Eurer Gruppe, wenn sie Euch in der offenen Welt buffen."
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "Lob-Abklingzeit"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"Legt die Verzögerung zwischen einer Lobrunde und der nächsten fest, ganz gleich, wer Euch gebufft hat. Bei null wird jeder Buff gelobt."
L["STRANGERS_SOURCE_COOLDOWN"] = "Lob-Abklingzeit für denselben Spieler"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"Legt die Verzögerung fest, bevor derselbe Spieler erneut gelobt wird. Bei null wird jeder Buff gelobt."
L["STRANGERS_MIN_DURATION"] = "Minimale Buff-Dauer"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"Ignoriert Buffs, die kürzer als dieser Wert sind. Bei null wird auf jeden Buff reagiert."

-- Teammate Buffs
L["TAB_TEAMMATES"] = "Buffs von Teammitgliedern"
L["TEAMMATES_ENABLE"] = "Dank für Buffs von Teammitgliedern aktivieren"
L["TEAMMATES_ENABLE_DESCRIPTION"] =
	"Aktiviert den Dank für Buffs und Abklingzeiten, die Eure Gruppen- oder Schlachtzugsmitglieder auf Euch wirken."
L["TEAMMATES_DESCRIPTION"] =
	"Dankt Gruppen- und Schlachtzugsmitgliedern für Buffs und Abklingzeiten, die sie auf Euch wirken."

-- Service Alerts
L["TAB_SERVICES"] = "Dienst-Hinweise"
L["SERVICES_ENABLE"] = "Dienst-Hinweise aktivieren"
L["SERVICES_ENABLE_DESCRIPTION"] =
	"Aktiviert Hinweise zu Festmählern, Seelenbrunnen, Portalen und anderer Hilfe, die für Eure Gruppe aufgestellt wird."
L["SERVICES_DESCRIPTION"] =
	"Reagiert, wenn jemand Hilfe für Eure Gruppe aufstellt: Festmähler, Seelenbrunnen, Portale und Reparaturbots."

-- Send Good News
L["TAB_GOOD_NEWS"] = "Gute Neuigkeiten senden"
L["GOOD_NEWS_DESCRIPTION"] =
	"Lasst die Spieler, die Ihr bufft, wissen, was Ihr auf sie gewirkt habt und, bei kurzen Buffs, wie lange es anhält."
L["GOOD_NEWS_ENABLE"] = "Gute Neuigkeiten aktivieren"
L["GOOD_NEWS_ENABLE_DESCRIPTION"] =
	"Aktiviert ein Flüstern, das den Spielern, die Ihr bufft, mitteilt, was Ihr auf sie gewirkt habt."
L["GOOD_NEWS_SCOPE"] = "Empfänger"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "Jeder, den Ihr bufft"
L["GOOD_NEWS_SCOPE_GROUP"] = "Nur Gruppenmitglieder"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"Legt fest, wer die Guten Neuigkeiten zugeflüstert bekommt: jeder, den Ihr bufft, oder nur Eure Gruppenmitglieder."
L["GOOD_NEWS_MESSAGES_HEADER"] = "Nachricht für Gute Neuigkeiten"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "Das Flüstern, das die Spieler erhalten, die Ihr bufft."
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] =
	"Legt fest, was das Flüstern sagt. Lasst das Feld leer, um den Standardtext zu verwenden."
L["GOOD_NEWS_MESSAGE_LIMIT"] = "Maximale Länge: %d."
L["GOOD_NEWS_MESSAGE_TOKENS"] = "%a wird zum Fähigkeitslink, samt Dauer, wenn sie unter einer Minute liegt."
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "für %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "Verfolgte Fähigkeiten"
L["TRACKED_GROUP_ITEMS"] = "Gegenstände"
L["TRACKED_ITEM_PENDING"] = "Gegenstand #%d"
L["TRACKED_SPELL_PENDING"] = "Zauber #%d"

-- Shared by Send Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "Flüsternachricht"
L["WHISPER_MESSAGE_RESET"] = "Zurücksetzen"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "Setzt die Flüsternachricht auf den Standardtext zurück."

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "Dankesflüstern & Emotes"
L["NOTIFICATIONS_HEADER"] = "Benachrichtigungen"
L["PRAISE_DESCRIPTION"] = "Was der andere Spieler sieht: ein Dankesflüstern, ein Emote oder beides."
L["NOTIFICATIONS_DESCRIPTION"] = "Was nur Ihr bekommt: eine Textmeldung, einen Ton oder beides."

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "Emotes auswählen"

L["PRAISE_WHISPER_ENABLE"] = "Dankesflüstern aktivieren"
L["PRAISE_WHISPER_DESCRIPTION"] = "Flüstert dem Spieler, der Euch gebufft hat, ein Dankeschön zu."
L["PRAISE_EMOTES_ENABLE"] = "Emotes aktivieren"
L["PRAISE_EMOTES_DESCRIPTION"] =
	"Zeigt Eure Wertschätzung mit einem Emote. Emotes werden zurückgehalten, solange Ihr im Kampf seid."
L["PRAISE_DELAY_ENABLE"] = "Lob-Verzögerung aktivieren"
L["PRAISE_DELAY_DESCRIPTION"] =
	"Wartet einen Moment vor dem Flüstern und dem Emote, damit Euer Dank nicht im selben Augenblick wie der Buff eintrifft. Benachrichtigungen bleiben unberührt."
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "Legt fest, wie lange gewartet wird, bevor Flüstern und Emote gesendet werden."

L["NOTIFICATIONS_PRINT_ENABLE"] = "Textmeldungen aktivieren"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "Gibt eine Nachricht aus, die nur Ihr seht, wenn Ihr einen Buff erhaltet."
L["NOTIFICATIONS_SOUND_ENABLE"] = "Soundeffekte aktivieren"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "Spielt einen Ton ab, wenn Ihr einen Buff erhaltet. Nur Ihr hört ihn."
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] =
	"Spielt den Ton ab, damit Ihr ihn hören könnt, bevor Ihr ihn aktiviert."

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "Portale"
L["GROUP_RESISTANCE_CAULDRONS"] = "Widerstandskessel"
L["GROUP_REPAIR_BOTS"] = "Reparaturbots"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_WINDOW"] = "Buff-Dienst"
L["BUFF_WINDOW_DESCRIPTION"] = "Zeigt, wem Eure Buffs fehlen. Klickt auf ein Symbol, um zu wirken."
L["BUFF_WINDOW_ENABLE"] = "Buff-Dienst aktivieren"
L["BUFF_WINDOW_ENABLE_DESCRIPTION"] =
	"Aktiviert den Buff-Dienst, das Fenster mit den Gruppenmitgliedern, denen ein Buff fehlt, den Ihr geben könnt."
L["BUFF_WINDOW_NO_BUFFS"] =
	"Eure Klasse hat keine Buffs auf dieser Liste, daher erscheint das Fenster bei diesem Charakter nie."
-- When to Show: Solo and In Group, each with Always or In Instance, then the classes.
L["BUFF_WINDOW_WHEN_HEADER"] = "Wann anzeigen"
L["BUFF_WINDOW_WHEN_DESCRIPTION"] = "Legt fest, wann das Fenster erscheinen kann."
L["BUFF_WINDOW_WHEN_SOLO"] = "Solo"
L["BUFF_WINDOW_WHEN_SOLO_DESCRIPTION"] =
	"Zeigt das Fenster, während Ihr nicht in einer Gruppe oder einem Schlachtzug seid."
L["BUFF_WINDOW_WHEN_GROUP"] = "In Gruppe"
L["BUFF_WINDOW_WHEN_GROUP_DESCRIPTION"] = "Zeigt das Fenster, während Ihr in einer Gruppe oder einem Schlachtzug seid."
L["BUFF_WINDOW_WHERE_DESCRIPTION"] =
	"Legt fest, wo das Fenster erscheint: überall oder nur in Dungeons, Schlachtzügen, Schlachtfeldern und Arenen."
L["BUFF_WINDOW_WHERE_ALWAYS"] = "Immer"
L["BUFF_WINDOW_WHERE_INSTANCE"] = "In Instanz"
L["BUFF_WINDOW_CLASSES_DESCRIPTION"] = "Zeigt das Fenster, wenn Ihr eine dieser Klassen spielt."
L["BUFF_WINDOW_CLASS_DESCRIPTION"] = "Zeigt das Fenster, während Ihr diese Klasse spielt."
L["BUFF_WINDOW_HEADER"] = "Fenster"
L["BUFF_WINDOW_WINDOW_DESCRIPTION"] =
	"Lasst das Fenster dort, wo Ihr es abgelegt habt, oder haltet es im Kampf aus dem Weg."
L["BUFF_WINDOW_LOCK"] = "Fenster sperren"
L["BUFF_WINDOW_LOCK_DESCRIPTION"] =
	"Verhindert, dass das Fenster verschoben wird. Entsperrt lässt es sich an seinem Hintergrund ziehen."
L["BUFF_WINDOW_HIDE_IN_COMBAT"] = "Im Kampf ausblenden"
L["BUFF_WINDOW_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Blendet das Fenster während des Kampfes aus. Im Kampf kann die Liste nicht aktualisiert werden, daher behält ein sichtbar gelassenes Fenster seinen letzten Stand, bis der Kampf endet."
L["BUFF_WINDOW_SHOW_HEADER"] = "Im Fenster anzeigen"
L["BUFF_WINDOW_SHOW_DESCRIPTION"] =
	"Fügt dem Fenster Eure eigenen Buffs, die Fremden, die Euch gebufft haben, und Euer Ziel hinzu."
L["BUFF_WINDOW_FAVOR_ENABLE"] = "Gefallen erwidern"
L["BUFF_WINDOW_FAVOR_ENABLE_DESCRIPTION"] =
	"Listet die Fremden auf, die Euch kürzlich gebufft haben, samt den Buffs, die Ihr ihnen zurückgeben könnt. Rechtsklickt auf ein Symbol, um jemanden von der Liste zu nehmen."
L["BUFF_WINDOW_FAVOR_SECONDS_DESCRIPTION"] =
	"Legt fest, wie lange ein Fremder nach seinem letzten Buff auf der Liste bleibt."
L["BUFF_WINDOW_TARGET_ENABLE"] = "Euer Ziel"
L["BUFF_WINDOW_TARGET_ENABLE_DESCRIPTION"] =
	"Listet Euer Ziel auf, wenn es ein Spieler außerhalb Eurer Gruppe ist, dem ein Buff fehlt, den Ihr geben könnt."
L["BUFF_WINDOW_REFRESH"] = "Auffrischen unter"
L["BUFF_WINDOW_REFRESH_DESCRIPTION"] =
	"Legt fest, wie wenig Restzeit ein Buff haben darf, bevor er als fehlend gilt, damit Ihr ihn auffrischen könnt, bevor er ausläuft. Ein Buff, der nicht länger als diese Zeit hält, zählt erst, wenn er abgelaufen ist."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_WINDOW_TANKS_HEADER"] = "Als Tanks zählen"
L["BUFF_WINDOW_TANKS_DESCRIPTION"] =
	"Wer die Buffs erhält, die Ihr für Tanks anbietet, etwa Dornen, wenn er keine eigene Rolle hat."
L["BUFF_WINDOW_TANKS_CLASS_DESCRIPTION"] =
	"Legt fest, wann Spieler dieser Klasse als Tanks zählen. Eine Tank- oder Heilerrolle, die sie haben, geht immer vor."
L["BUFF_WINDOW_TANKS_PETS"] = "Begleiter"
L["BUFF_WINDOW_TANKS_PETS_DESCRIPTION"] =
	"Legt fest, wann Begleiter als Tanks zählen. Begleiter erhalten außerdem die Buffs, die Ihr für Alle anbietet."
L["BUFF_WINDOW_TANKS_NEVER"] = "Nie"
L["BUFF_WINDOW_TANKS_SOLO"] = "Wenn nicht in einer Gruppe"
L["BUFF_WINDOW_TANKS_ALWAYS"] = "Immer"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_WINDOW_AUDIENCE_OFF"] = "Aus"
L["BUFF_WINDOW_AUDIENCE_TANK"] = "Tanks"
L["BUFF_WINDOW_AUDIENCE_HEALER"] = "Heiler"
L["BUFF_WINDOW_AUDIENCE_ALL"] = "Alle"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_WINDOW_AUDIENCE_DESCRIPTION"] = "Legt fest, wem %s angeboten wird."
-- %s is the game's own Main Tank label.
L["BUFF_WINDOW_BUFFS_DESCRIPTION"] =
	"Wählt für jeden Buff, wem er angeboten wird. Tanks und Heiler richten sich nach der Gruppenrolle, im Schlachtzug zählen aber nur Spieler, die als %s eingeteilt sind, als Tanks. Wer keine Rolle hat, zählt als Schaden, sofern Als Tanks zählen weiter unten nichts anderes festlegt."

L["BUFF_WINDOW_SELF_DESCRIPTION"] = "Eure eigenen Buffs, oben im Fenster angeheftet."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_WINDOW_SELF_NOTE_ASPECT"] = "ein beliebiger Aspekt genügt"
L["BUFF_WINDOW_SELF_NOTE_MAGE_ARMOR"] = "eine beliebige Rüstung genügt"
L["BUFF_WINDOW_SELF_NOTE_PALADIN_AURA"] = "eine beliebige Aura genügt"
L["BUFF_WINDOW_SELF_NOTE_SHAMAN_SHIELD"] = "ein beliebiger Schild genügt"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_ARMOR"] = "eine beliebige Rüstung genügt"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_DEMON"] = "einer der beiden Dämonenbuffs genügt"
L["BUFF_WINDOW_SELF_REFRESH_OFF"] = "Aus"
L["BUFF_WINDOW_SELF_REFRESH_MISSING"] = "Bei Fehlen"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_WINDOW_SELF_REFRESH_UNDER"] = "Unter %s"
L["BUFF_WINDOW_SELF_REFRESH_DESCRIPTION"] =
	"Legt fest, wann %s angezeigt wird: nie, nach dem Ablaufen oder wenn weniger als diese Zeit übrig ist."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_WINDOW_WEAPON_PANEL_HEADER"] = "Waffenbuffs"
L["BUFF_WINDOW_WEAPON_DESCRIPTION"] =
	"Hakt an, was jede Waffe tragen soll. Das Fenster bietet es an, wenn es fehlt oder bald abläuft, sofern es in Euren Taschen ist und zur Waffe passt."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_WINDOW_WEAPON_REFRESH"] = "Erneuern"
L["BUFF_WINDOW_WEAPON_REFRESH_DESCRIPTION"] =
	"Legt fest, wann ein Waffenbuff erneut angeboten wird: nach dem Ablaufen oder wenn weniger als diese Zeit übrig ist."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_WINDOW_WEAPON_KIND_OIL"] = "Öle"
L["BUFF_WINDOW_WEAPON_KIND_STONE"] = "Steine"
L["BUFF_WINDOW_WEAPON_KIND_LURE"] = "Köder"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_WINDOW_WEAPON_PICK_DESCRIPTION"] =
	"Bietet %s für die Waffe in Eurer %s an. Solange die Waffe keine Eurer angehakten Optionen trägt, wird jede angeboten, die Ihr habt."
L["BUFF_WINDOW_SELF_ENABLE"] = "Eure Selbstbuffs"
L["BUFF_WINDOW_SELF_ENABLE_DESCRIPTION"] =
	"Zeigt oben im Fenster die Buffs, die nur Ihr Euch selbst geben könnt, etwa eine Rüstung oder Inneres Feuer, wenn sie fehlen oder bald ablaufen. Welche, legt Ihr unter Selbstbuffs fest."
L["BUFF_WINDOW_WEAPON_ENABLE"] = "Eure Waffenbuffs"
L["BUFF_WINDOW_WEAPON_ENABLE_DESCRIPTION"] =
	"Zeigt die Gifte, Waffenverzauberungen, Öle, Steine und Köder, die Euren Waffen fehlen oder bald ablaufen, zusammen mit Euren Selbstbuffs oben im Fenster. Klickt auf einen Eintrag, um ihn aufzutragen. Welche, legt Ihr unter Waffenbuffs fest."

-- The window itself
L["BUFF_WINDOW_SELF_HEADER"] = "Selbstbuffs"
L["BUFF_WINDOW_FAVOR_HEADER"] = "Gefallen erwidern"
L["BUFF_WINDOW_TARGET_HEADER"] = "Ziel"
L["BUFF_WINDOW_TOOLTIP_CAST"] = "Klicken, um auf %s zu wirken."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_WINDOW_TOOLTIP_WEAPON"] = "Klicken, um es auf die Waffe in Eurer %s aufzutragen."
L["BUFF_WINDOW_TOOLTIP_USE"] = "Niemand in Eurer Gruppe hat einen Seelenstein. Klicken, um einen auf %s anzuwenden."
L["BUFF_WINDOW_TOOLTIP_CREATE"] = "Niemand in Eurer Gruppe hat einen Seelenstein. Klicken, um einen herzustellen."
L["BUFF_WINDOW_TOOLTIP_GROUP"] = "Klicken, um auf %s samt Gruppe zu wirken."
L["BUFF_WINDOW_TOOLTIP_FAVOR"] = "Klicken, um %s ins Ziel zu nehmen und zu wirken."
L["BUFF_WINDOW_TOOLTIP_DISMISS"] = "Rechtsklick, um %s von der Liste zu nehmen."
-- The window's close button: the class name in its color, then the options command.
L["BUFF_WINDOW_CLOSED"] =
	"Buff-Dienst ist für die Klasse %s aus. Um ihn wieder einzuschalten, macht Umschalt + Rechtsklick auf die Minikarten-Schaltfläche oder gebt %s ein."

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEYS_HEADER"] = "Tastenbelegungen"
L["BUFF_KEYS_DESCRIPTION"] =
	"Wirkt den nächsten Buff Eurer Liste mit einer Taste oder einem Makro, außerhalb des Kampfes. Waffenbuffs bleiben ein Klick im Fenster."
L["BUFF_KEY"] = "Buff-Knopf"
L["BUFF_KEY_DESCRIPTION"] =
	"Wirkt Euren nächsten fehlenden Buff, einen pro Tastendruck: eine Wiederbelebung auf Euer totes Ziel, dann auf die Toten Eurer Gruppe (Priester, Paladine und Schamanen), dann Gefallen erwidern, Euer Ziel, Eure Selbstbuffs und Eure Gruppe. Eine Gruppe erhält den Gruppenbuff, wenn er weniger Mana kostet, als ihre Mitglieder einzeln zu buffen, sobald alle in der Nähe sind. Übergeht Buffs mit Abklingzeit, etwa Furchtzauberschutz, und macht mit dem nächsten Buff weiter."
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Warte darauf, dass %s in Reichweite kommt."
L["BUFF_KEY_DONE"] = "Nichts mehr zu buffen."
-- The caption beside the read-only box that holds a Buff Key's macro line.
L["BUFF_KEY_MACRO_CAPTION"] = "Makro"

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "Dankeschön-Knopf"
L["BUTTON_DESCRIPTION"] =
	"Flüstert Eurem Ziel zu und bedenkt es mit einem Emote, alles mit einem einzigen Tastendruck. Höflichkeit, automatisiert."
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "Dankeschön-Knopf %d"
L["BUTTON_EMOTE"] = "Emote"
L["BUTTON_EMOTE_DESCRIPTION"] =
	"Legt das Emote fest, das dieser Knopf bei Eurem Ziel ausführt, oder Keine für kein Emote."
L["BUTTON_EMOTE_NONE"] = "Keine"
L["BUTTON_ICON"] = "Symbol"
L["BUTTON_ICON_DESCRIPTION"] =
	"Legt das Symbol fest, das das Makro dieses Knopfes in Eurer Makroliste und auf Euren Aktionsleisten zeigt."
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "Standard"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = 'Makro "%s" aktivieren'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] =
	"Erstellt ein Makro namens %s und löscht es wieder, sobald Ihr dies ausschaltet."
L["BUTTON_WHISPER_DESCRIPTION"] =
	"Legt fest, was dieser Knopf Eurem Ziel zuflüstert. Bleibt das Feld leer, wird nichts geflüstert."

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "Danke, du bist spitze! (="
--[[
    The star marker (left off on WoW Forever) and " // TFTB" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "Du hast %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "Ihr jubelt <Target> zu."
L["EMOTE_DRINK_DESCRIPTION"] = "Ihr erhebt Euer Glas auf <Target>."
L["EMOTE_FLEX_DESCRIPTION"] = "Ihr lasst vor <Target> Eure Muskeln spielen."
L["EMOTE_GRIN_DESCRIPTION"] = "Ihr grinst <Target> schelmisch an."
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "Ihr gebt <Target> ein High-Five."
L["EMOTE_PRAISE_DESCRIPTION"] = "Ihr lobt <Target>."
L["EMOTE_SALUTE_DESCRIPTION"] = "Ihr grüßt <Target> voller Respekt."
L["EMOTE_SMILE_DESCRIPTION"] = "Ihr lächelt <Target> an."
L["EMOTE_THANK_DESCRIPTION"] = "Ihr dankt <Target>."
L["EMOTE_WHOA_DESCRIPTION"] = "Ihr ruft <Target> 'Boah!' zu."
L["EMOTE_WINK_DESCRIPTION"] = "Ihr zwinkert <Target> zu."
L["EMOTE_YES_DESCRIPTION"] = "Ihr nickt <Target> zu."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- Every string from here to the end is the Spellbook's.

-- Page: Sections
L["SECTION_UNLEARNED"] = "Nicht erlernt"

-- Page: Macro Menu
L["MENU_GROUP_COMBAT_CHECK"] = "Kampfbedingung"
L["MENU_GROUP_SPELL_RANK"] = "Zauberrang"
L["MENU_GROUP_BEFORE_CAST"] = "Vor dem Wirken"
L["MENU_GROUP_ADD_ATTACK"] = "Angriff hinzufügen"
L["MENU_GROUP_CASTING_RULES"] = "Wirkregeln"
L["MENU_GROUP_ERRORS"] = "Fehlermeldungen"
L["MENU_GROUP_USE_ITEMS_FIRST"] = "Erst Gegenstände benutzen"
L["MACRO_TEXT"] = "Makrotext"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_OPTIONS_COUNT"] = "%d Optionen"
L["MENU_RANK_LEARN_LEVEL"] = "%s (Stufe %d)"
L["MENU_MAX_RANK"] = "Höchster Rang"
L["MENU_DYNAMIC_RANK"] = "Dynamischer Rang"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Der dynamische Rang richtet sich nach der Stufe eines freundlichen Spielers und wird nur außerhalb des Kampfes aktualisiert."
L["MENU_CAST_AT_CURSOR"] = "Am Cursor wirken"
L["MENU_TARGET_NEAREST_ENEMY"] = "Nächsten Feind anvisieren"
L["MENU_TARGET_NEAREST_FRIEND"] = "Nächsten Verbündeten anvisieren"
L["MENU_CAST_IF_SUMMONED"] = "%s wirken, wenn beschworen"
L["MENU_NEVER_TURN_OFF"] = "Nie ausschalten"
L["MENU_LEAVE_FORM_BEFORE"] = "Vor dem Wirken Gestalt verlassen"
L["MENU_RIGHT_CLICK_FOR"] = "Rechtsklick für %s"
L["MENU_ONLY_IN_COMBAT"] = "Nur im Kampf"
L["MENU_NEVER_IN_COMBAT"] = "Nie im Kampf"
L["MENU_COMBAT_CHECK_NONE"] = "Keine"
L["MENU_ONCE_PER_COMBAT"] = "Einmal pro Kampf wirken"
L["MENU_ONCE_PER_TARGET"] = "Einmal pro Ziel wirken"
L["MENU_HIDE_ERRORS"] = "Fehlermeldungen ausblenden"
L["MENU_MUTE_ERRORS"] = "Fehlergeräusche stummschalten"
L["MENU_SWITCH_TO"] = "Zu %s wechseln"
L["MENU_CAST_ON_FOCUS"] = "Auf den Fokus wirken"
L["MENU_START_AUTO_ATTACK"] = "Automatischen Angriff starten"
L["MENU_STOP_ATTACK"] = "Angriff beenden"
L["MENU_START_AUTO_SHOT"] = "Automatischen Schuss starten"
L["MENU_START_PET_ATTACK"] = "Begleiterangriff starten"
L["MENU_START_WAND"] = "Zauberstab starten"
L["MENU_STOP_CASTING"] = "Zaubern abbrechen"
L["MENU_STOP_CASTING_NOTE"] =
	"Nutze Zaubern abbrechen für Zauber, die nicht warten können, etwa Unterbrechungen und Bannzauber."
L["MENU_STOP_IF_CHANNELING"] = "Makro beim Kanalisieren stoppen"
L["MENU_STOP_IF_STEALTHED"] = "Makro in Verstohlenheit stoppen"
L["MENU_SAFE_TO_SPAM_NOTE"] =
	"Damit du ein Makro gefahrlos spammen kannst, schalte bei einem kanalisierten Zauber Makro beim Kanalisieren stoppen ein, bei Verstohlenheit oder Schleichen Makro in Verstohlenheit stoppen. Erneutes Drücken unterbricht dann weder das Kanalisieren noch deine Verstohlenheit."
L["MENU_USE_FOR_KIND"] = "Diese Optionen für die Kategorie %s verwenden"
L["MENU_DUPLICATE"] = "Duplizieren"
L["MENU_USE_FOR_KIND_DESCRIPTION"] =
	"Jedes Makro in der Kategorie %s, das du nicht selbst eingestellt hast, beginnt mit den Optionen dieses Makros. Öffnet Makro-Standards, um es dir zu zeigen."

-- Page: Settings Menu
L["SETTINGS_SHOW_UNLEARNED"] = "Nicht erlernte Zauber anzeigen"
L["SETTINGS_MARK_ALL_PLACED"] = "Alle Zauber als platziert markieren"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Kein Makro auf dieser Seite leuchtet mehr, ob es auf deinen Leisten liegt oder nicht. Ein Zauber, den du später erlernst, leuchtet weiter, bis du ihn platzierst."

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Fokus"
L["SUBTEXT_PET"] = "Begleiter"
L["SUBTEXT_CURSOR"] = "Am Cursor"
L["SUBTEXT_STANCE"] = "Haltung"
L["SUBTEXT_USE_ITEMS"] = "Gegenstände"
L["SUBTEXT_PET_ATTACK"] = "Begleiterangriff"
L["SUBTEXT_DYNAMIC_RANK"] = "Dyn. Rang"
L["SUBTEXT_DYNAMIC_ITEM"] = "Dyn. Gegenstand"
L["SUBTEXT_DYNAMIC_RANK_ITEM"] = "Dyn. Rang, Dyn. Gegenstand"
L["SUBTEXT_MAX_RANK"] = "Höchster Rang"
L["SUBTEXT_TARGET_ENEMY"] = "Nächster Feind"
L["SUBTEXT_TARGET_FRIEND"] = "Nächster Verbündeter"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1x pro Kampf"
L["SUBTEXT_ONCE_PER_TARGET"] = "1x pro Ziel"
L["SUBTEXT_COMBAT_ONLY"] = "Nur im Kampf"
L["SUBTEXT_NO_COMBAT"] = "Außer Kampf"
L["SUBTEXT_LEAVE_FORM"] = "Gestalt verlassen"
L["SUBTEXT_NO_TOGGLE"] = "Bleibt an"
L["SUBTEXT_WAND"] = "Zauberstab"
L["SUBTEXT_START_ATTACK"] = "Auto-Angriff"
L["SUBTEXT_STOP_ATTACK"] = "Angriff aus"
L["SUBTEXT_STOP_CASTING"] = "Zauber abbr."
L["SUBTEXT_STOP_IF_CHANNELING"] = "Nicht beim Kanalisieren"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Nicht in Verstohlenheit"
L["SUBTEXT_HIDE_ERRORS"] = "Fehler aus"
L["SUBTEXT_MUTE_ERRORS"] = "Fehler stumm"
L["SUBTEXT_OPTIONS_COUNT"] = "%d Optionen"
L["SUBTEXT_TOO_LONG"] = "Zu lang"
L["SUBTEXT_LEARN_LEVEL"] = "Stufe %d"
L["SUBTEXT_TALENT"] = "Talent"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Noch nicht erlernt"
L["TOOLTIP_LEARN_LEVEL"] = "Dein Klassenlehrer bringt ihn dir auf Stufe %d bei."
L["TOOLTIP_LEARN_TALENT"] = "Wird über deine Talente erlernt."
L["TOOLTIP_NOT_ON_BARS"] = "Nicht auf deinen Aktionsleisten"
L["TOOLTIP_TOO_LONG"] = "Zu lang: %d / %d Bytes. Schalte eine Option ab, um es zu kürzen."
L["TOOLTIP_OPTIONS_ON"] = "Aktive Optionen: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Klicken oder ziehen"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Auf deine Aktionsleisten legen"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Rechtsklick"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Makrooptionen"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Die Zauber deiner Klasse als Ein-Klick-Makros."
L["TOOLTIP_KEY_CLICK"] = "Klicken"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "BBB Spellbook öffnen"

-- Page: Layout
L["PAGE_EMPTY"] = "Noch keine Makros. Besuche deinen Klassenlehrer, um deine ersten Zauber zu erlernen."
L["PAGE_MACRO_SLOTS"] = "Makroplätze"
L["TOOLTIP_MACRO_SLOTS"] =
	"Jedes Makro, das du platzierst, belegt einen Makroplatz. Charakterplätze gehören diesem Charakter und werden zuerst belegt. Allgemeine Plätze teilen sich alle Charaktere deines Accounts."
L["PAGE_MACRO_GENERAL"] = "Allgemein"
L["PAGE_MACRO_CHARACTER"] = "Charakter"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Tastenbelegung"
L["OPTIONS_KEY_SET"] = "Taste festlegen"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Öffnet die Tastenbelegung des Spiels, in der Bags Buffs & Buttons einen eigenen Abschnitt hat."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Öffnet und schließt BBB Spellbook. Es hat außerdem einen eigenen Reiter in deinem Zauberbuch."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Makros löschen"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Löscht die Makros, die BBB Spellbook erstellt hat, und nimmt sie damit auch von deinen Aktionsleisten. Deine eigenen Makros bleiben unberührt, und die Seite erstellt jedes davon neu, wenn du es anklickst oder ziehst."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Charaktermakros löschen"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Löscht die Makros von BBB Spellbook aus dem Makro-Reiter dieses Charakters. Deine anderen Charaktere behalten ihre, bis du dort dasselbe tust."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Alle Makros von BBB Spellbook auf diesem Charakter löschen? Sie verschwinden auch von deinen Aktionsleisten."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Allgemeine Makros löschen"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Löscht die Makros von BBB Spellbook aus dem Reiter Allgemeine Makros, den alle Charaktere deines Accounts teilen, sodass auch deine anderen Charaktere ihre dort verlieren."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Alle allgemeinen Makros von BBB Spellbook löschen? Alle Charaktere deines Accounts verlieren sie, und sie verschwinden auch von deinen Aktionsleisten."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Listet die Klassenzauber, die du noch nicht erlernt hast, im Abschnitt Nicht erlernt auf, damit du ihre Makros schon vorher platzieren kannst."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Setzt den Zauber dorthin, wo dein Cursor hinzeigt, ohne Zielkreis."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] =
	"Wirkt den höchsten Rang, den die Stufe des freundlichen Spielers zulässt."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Bricht zuerst ab, was du gerade wirkst, damit dieser Zauber sofort losgeht."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Beendet zuerst deinen automatischen Nahkampfangriff."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Tut nichts, während du einen Zauber kanalisierst, damit ein Tastendruck das Kanalisieren nie unterbricht."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Tut nichts, während du verstohlen bist, damit ein Tastendruck Verstohlenheit oder Schleichen nie beendet."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Verlässt zuerst deine aktuelle Gestalt, damit der Zauber gewirkt werden kann."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Visiert zuerst den nächsten Feind an, wenn du keinen lebenden Feind im Ziel hast."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Visiert zuerst den nächsten Verbündeten an, wenn du keinen lebenden Verbündeten im Ziel hast."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Schickt auch deinen Begleiter los, um dein Ziel anzugreifen."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Startet nach dem Wirken deinen automatischen Nahkampfangriff."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Startet nach dem Wirken den Automatischen Schuss oder deinen Zauberstab."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Wirkt einmal und dann erst wieder, wenn dein Ziel wechselt."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Wirkt einmal und dann erst wieder, wenn der Kampf endet oder dein Ziel wechselt."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Lässt Gestalt oder Aspekt an, wenn du das Makro erneut drückst, statt sie auszuschalten."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] =
	"Entfernt den roten Fehlertext, den das Makro auf dem Bildschirm hinterlässt."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Schaltet das Fehlergeräusch stumm, während das Makro läuft."
L["KIND_ENEMY"] = "Zauber gegen Feinde"
L["KIND_ENEMY_DESCRIPTION"] = "Zauber, die du auf einen Feind wirkst, etwa Angriffe und Schwächungen."
L["KIND_FRIENDLY"] = "Freundliche Zauber"
L["KIND_FRIENDLY_DESCRIPTION"] = "Zauber, die du auf einen Verbündeten wirkst, etwa Heilungen."
L["KIND_BUFF"] = "Stärkungszauber"
L["KIND_BUFF_DESCRIPTION"] = "Zauber, die einem Verbündeten eine anhaltende Stärkung geben."
L["KIND_ANYONE"] = "Zauber für Freund oder Feind"
L["KIND_ANYONE_DESCRIPTION"] = "Zauber, die du auf einen Verbündeten oder einen Feind wirken kannst."
L["KIND_GROUND"] = "Bodenzauber"
L["KIND_GROUND_DESCRIPTION"] = "Zauber, die du auf dem Boden platzierst."
L["KIND_FORM"] = "Gestalten, Haltungen und Aspekte"
L["KIND_FORM_DESCRIPTION"] = "Zauber, die aktiv bleiben, bis du sie ausschaltest oder wechselst."
L["KIND_SELF"] = "Selbst- und Flächenzauber"
L["KIND_SELF_DESCRIPTION"] = "Zauber ohne Ziel, die auf dich oder um dich herum wirken."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "BBB Spellbook ein-/ausblenden"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "Aus Sicherheitsgründen kann die Tastenbelegung im Kampf nicht geöffnet werden."
L["KEY_BINDINGS_LOCATION"] = "Öffne das Spielmenü, dann %s, dann %s, und suche den Abschnitt Bags Buffs & Buttons."
L["ERROR_MACRO_SLOTS_FULL"] = "Keine freien Makroplätze. Lösche ein Makro in /macro, um Platz zu schaffen."
L["CHAT_MACROS_DELETED"] = "Gelöschte Makros: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'Das Makro "%s" ist mit seinen Optionen %d Bytes lang, mehr als die %d, die ein Makro fasst. Schalte eine Option ab, um es zu kürzen.'
