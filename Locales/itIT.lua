local L = LibStub("AceLocale-3.0"):NewLocale("Bags-Buffs-Buttons", "itIT")
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
	"Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > Add-on > Bags Buffs & Buttons. Ti piace questo add-on? Parlane a un amico, aggiungilo ai preferiti su CurseForge o clicca su Star nella sua pagina GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Aiuta Bags Buffs & Buttons a salire di livello"
L["OPTIONS_LEVEL_UP_THANKS"] = "Grazie per aver scelto Bags Buffs & Buttons!"

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

L["MACRO_BANDAGE"] = "- Benda"
L["MACRO_EXPLOSIVES"] = "- Esplosivi"
L["MACRO_FEED_PET"] = "- Nutri Famiglio"
L["MACRO_FOOD"] = "- Cibo"
L["MACRO_HEALTH_POTION"] = "- Poz. Salute"
L["MACRO_HEALTHSTONE"] = "- Pietra Salute"
L["MACRO_MANA_GEM"] = "- Gemma di Mana"
L["MACRO_MANA_POTION"] = "- Poz. Mana"
L["MACRO_POISONS"] = "- Veleni"
L["MACRO_SOULSTONE"] = "- Pietra Anima"
L["MACRO_WATER"] = "- Acqua"

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

L["DIET_BREAD"] = "Pane"
L["DIET_CHEESE"] = "Formaggio"
L["DIET_FISH"] = "Pesce"
L["DIET_FRUIT"] = "Frutta"
L["DIET_FUNGUS"] = "Funghi"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sembra che tu abbia trovato un bug! Non è possibile usare %s (%s) in %s > %s (%s). Segnalacelo, così potremo risolverlo. Grazie! %s"
L["MESSAGE_NO_ITEM"] = "%s: nessun oggetto adatto trovato nelle tue borse."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Non è stato possibile creare alcune macro di Connoisseur & Restocker perché gli slot delle macro sono pieni. Libera uno slot eliminando le macro che non usi più, oppure disattiva le macro di Connoisseur & Restocker che non ti servono in Opzioni > Add-on > Connoisseur & Restocker > Macro."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. %s is "/m", the game's own macro command, colored
    at the call site. "General" is the macro window's tab for account-wide
    macros; use the client's own name for that tab. The macro names are this
    locale's own MACRO_FOOD and MACRO_WATER values, written exactly as this
    locale ships them.
]]
L["MESSAGE_MACROS_READY"] =
	"Le tue macro sono pronte. Digita %s, apri la scheda Macro generali e trascina - Cibo, - Acqua e le altre sulle tue barre delle azioni."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s ora è nella lista ignorati di questo personaggio."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "Rimosso 1 oggetto dalla lista ignorati di questo personaggio."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "Rimossi %d oggetti dalla lista ignorati di questo personaggio."

L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per sicurezza, l'interfaccia delle opzioni non può essere aperta durante il combattimento."

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

L["READINESS_TITLE"] = "Rapporto di preparazione"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Buff mancanti:"
L["READINESS_EXPIRING"] = "In scadenza:"
L["READINESS_MISSING_ITEMS"] = "Oggetti mancanti:"
L["READINESS_DAMAGED_GEAR"] = "Equipaggiamento danneggiato:"
L["READINESS_CHARACTER"] = "Personaggio:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento:"

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
L["READINESS_FLASK"] = "Tonico o 2x elisir"
L["READINESS_PET_FORMAT"] = "%s (famiglio)"
L["READINESS_SCROLLS"] = "Pergamene"
L["READINESS_SOULSTONE"] = "Pietra dell'Anima inattiva"
L["READINESS_HEALTHSTONE"] = "Pietra della Salute"
L["READINESS_MANA_GEM"] = "Gemma di Mana"
L["READINESS_HEALING_POTION"] = "Pozione di Cura"
L["READINESS_MANA_POTION"] = "Pozione di Mana"
L["READINESS_BANDAGES"] = "Bende"
L["READINESS_PVP_ON"] = "PvP attivo"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s meno di 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto talento non speso"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d punti talento non spesi"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf, and TIP_EMPTY_* via ConnoisseurNoItem. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Al momento non hai alcun cibo utile per il tuo famiglio."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Al momento non conosci %s, %s, %s o %s."
L["TIP_PET_NO_MEND"] = "Al momento non conosci Cura Famiglio."
L["TIP_NO_HAND_POISON"] = "Hai esaurito il veleno scelto per quest'arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Al momento non conosci %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "%s: non ne hai più nelle borse. Fai clic destro su %s per evocarne ancora."
L["TIP_EMPTY_CREATE"] = "%s: non ne hai più nelle borse. Fai clic destro su %s per crearne una."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Cibo con buff"
L["FEATURE_SCROLL_BUFFS"] = "Buff delle pergamene"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. The Readiness Report's block takes its title from
    READINESS_TITLE.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Cibo con buff e pergamene"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Usa cibo che fornisce "%s" e applica i buff delle pergamene mancanti prima di mangiare.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Cibo attuale"
L["MINIMAP_BEST_PET_FOOD"] = "Cibo attuale del famiglio"
L["MINIMAP_MAIN_HAND_POISON"] = "Veleno mano primaria"
L["MINIMAP_OFF_HAND_POISON"] = "Veleno mano secondaria"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista ignorati"
L["MINIMAP_IGNORE_COUNT"] = "%d oggetti"
L["MENU_IGNORE"] = "Ignora"
L["MENU_CLEAR_IGNORE"] = "Svuota lista ignorati"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Rapporto di Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d ordini in sospeso"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Complimenti, hai le scorte al completo!"
L["MINIMAP_RESTOCKER_EMPTY"] = "La tua lista è vuota."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista di Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra e deposita in banca gli oggetti della tua lista."
L["MENU_RESTOCKER_KEYBIND"] = "Maiusc + clic destro"
L["MENU_OPTIONS"] = "Opzioni di BBB"
L["MENU_OPTIONS_KEYBIND"] = "Maiusc + clic centrale"

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
L["NOTE_MACRO_FEED_PET"] = "Macro Nutri Famiglio"
L["NOTE_MACRO_FOOD_WATER"] = "Macro Cibo e Acqua"
L["NOTE_MACRO_MANA_GEM"] = "Macro Gemma di Mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro Pietra Salute"
L["NOTE_MACRO_SOULSTONE"] = "Macro Pietra Anima"
L["NOTE_MACRO_POISONS"] = "Macro Veleni"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Richiama, nutri o rianima"
L["NOTE_PET_MEND_CLICK"] = "Clic destro, o in combattimento"
L["NOTE_HOLD_SHIFT"] = "Tieni premuto Maiusc"
L["NOTE_PET_FORCE_REVIVE"] = "Forza la rianimazione"
L["NOTE_HOLD_CONTROL"] = "Tieni premuto Ctrl"
L["NOTE_PET_DISMISS"] = "Congeda"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Evoca"
L["NOTE_CREATE"] = "Crea"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Clic destro di nuovo"
L["NOTE_LOWER_RANK_BACKUP"] = "Scorta di grado inferiore"
L["NOTE_MAGE_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per evocare in base al suo livello."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per crearne una in base al suo livello."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Finestra dei Veleni"
L["NOTE_POISONS_REPLACED"] = "Sostituisce automaticamente i vecchi veleni."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Benda"
L["LABEL_EXPLOSIVE"] = "Esplosivo"
L["LABEL_FOOD"] = "Cibo"
L["LABEL_HEALTH_POTION"] = "Pozione di Salute"
L["LABEL_HEALTHSTONE"] = "Pietra della Salute"
L["LABEL_MANA_GEM"] = "Gemma di Mana"
L["LABEL_MANA_POTION"] = "Pozione di Mana"
L["LABEL_PET_FOOD"] = "Cibo per famigli"
L["LABEL_POISON"] = "Veleno"
L["LABEL_SOULSTONE"] = "Pietra dell'Anima"
L["LABEL_WATER"] = "Acqua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Attivato"
L["MINIMAP_DISABLED"] = "Disattivato"
L["MINIMAP_TOGGLE"] = "Attiva/disattiva"
L["MINIMAP_OPEN"] = "Apri"
L["MINIMAP_LEFT_CLICK"] = "Clic sinistro"
L["MINIMAP_RIGHT_CLICK"] = "Clic destro"
L["MINIMAP_MIDDLE_CLICK"] = "Clic centrale"
L["MINIMAP_SHIFT_LEFT"] = "Maiusc + clic sinistro"

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
	'Determina quando la tua macro Cibo propone "%s": sempre, oppure soltanto quando giochi da solo, sei in gruppo o incursione, sei in incursione, stai salendo di livello o sei al livello massimo.'
L["MODE_ALWAYS"] = "Sempre"
L["MODE_SOLO"] = "Da solo"
L["MODE_PARTY"] = "In gruppo o incursione"
L["MODE_RAID"] = "In incursione"
L["MODE_LEVELING"] = "Mentre sali di livello"
L["MODE_MAX_LEVEL"] = "Al livello massimo"

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
L["INVENTORY_REPORT_TITLE"] = "Rapporto di inventario"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Borse %s, Banca %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Borse %s"
L["INVENTORY_REPORT_BANK"] = "Banca %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Totale %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Attiva il messaggio di benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Mostra un messaggio di benvenuto in chat all'accesso."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Attiva il pulsante della minimappa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Mostra il pulsante della minimappa."

-- Features: each feature's master switch, also on the panel that configures it.
-- Options: each add-on's heading page
L["OPTIONS_TFTB_DESCRIPTION"] =
	"Ringrazia automaticamente con un sussurro o un'emote ogni giocatore che ti potenzia e non lasciare mai senza potenziamenti la tua incursione, te e le tue armi, grazie a un promemoria dei potenziamenti mancanti dove basta un clic per lanciarli. In più, avvisi per banchetti, portali, evocazioni e pozzi delle anime. Buone maniere, in automatico."
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Macro al passaggio del mouse, sul cursore e su te stesso per ogni incantesimo di classe, create con un clic da una nuova scheda del libro degli incantesimi, senza sintassi delle macro. Si aggiornano quando sali di livello, ti addestri o cambi specializzazione. Con il clic destro aggiungi focus, interruzione del lancio, attacco automatico, attacco del famiglio o monili."

L["OPTIONS_MACROS_ENABLE"] = "Attiva l'aggiornamento delle macro"
L["OPTIONS_MACROS_ENABLE_DESCRIPTION"] =
	"Mantiene le tue macro di Connoisseur & Restocker puntate sui tuoi oggetti migliori mentre le borse cambiano. Disattivato, ogni macro resta com'era l'ultima volta."
L["OPTIONS_RESTOCKER_ENABLE"] = "Attiva il Restocker"
L["OPTIONS_RESTOCKER_ENABLE_DESCRIPTION"] =
	"Acquista e deposita in banca secondo la tua lista di rifornimento e ti avvisa quando stai finendo le scorte. Disattivato, spegne tutto, compresa la finestra della lista di rifornimento."

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Esempio: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/bbb"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Apre la tua lista di rifornimento."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Questo add-on è stato creato da giocatori che amano questo gioco e vogliono renderlo il più divertente possibile per tutti. Non chiederemo mai donazioni. La vera soddisfazione è sapere che il nostro lavoro rende il gioco un po' migliore per te. Se è così, ci piacerebbe saperlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Ecco alcuni modi in cui puoi aiutarci a raggiungere più giocatori."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Condividi il tuo feedback: Hai trovato un bug o hai un'idea? Faccelo sapere su Discord. Il tuo feedback ci aiuta a migliorare l'add-on, e le pull request sono sempre benvenute."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Dillo a un amico: Conosci qualcuno a cui potrebbe piacere questo add-on? Parlagliene. Il passaparola aiuta più giocatori a scoprire ottimi add-on."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Preferito su CurseForge: Apri il link di CurseForge qui sotto, accedi e clicca sulla stella sotto il pulsante Download. I preferiti aiutano più giocatori a scoprire l'add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star su GitHub: Apri il link di GitHub qui sotto, accedi e clicca su Star in alto a destra. Le stelle aiutano il progetto ad accedere a più strumenti gratuiti per sviluppatori."

L["OPTIONS_FEEDBACK"] = "Feedback e supporto"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Link di feedback e supporto"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Per copiare un link, clicca sulla sua casella, poi premi Ctrl+A e Ctrl+C."
L["OPTIONS_VERSION"] = "Versione %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Macro Updates and
    Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macro"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur & Restocker crea una macro per ogni consumabile e la tiene aggiornata mentre le tue borse cambiano, così il pulsante sulla barra punta sempre al miglior oggetto che stai portando. Scegli qui sotto quali macro creare, poi imposta come ciascuna sceglie il suo oggetto."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Attiva i nomi delle macro sui pulsanti"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Mostra sui pulsanti della barra delle azioni il nome delle macro, che Connoisseur & Restocker nasconde per impostazione predefinita."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Macro da creare"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Scegli quali macro Connoisseur & Restocker crea e mantiene. Disattivarne una la rimuove anche. Si trovano nella scheda Macro generali della finestra delle macro, pronte da trascinare sulle tue barre delle azioni."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Apri la finestra delle macro"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Apre la finestra delle macro del gioco sulla scheda Macro generali, dove si trovano queste macro."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea e mantiene questa macro e la rimuove quando togli la spunta."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Cibo e acqua"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Le tue macro Cibo e Acqua usano il miglior cibo e la miglior bevanda nelle tue borse. Queste opzioni possono mettere al primo posto il cibo con buff, le pergamene o il cibo e l'acqua evocati, e all'ultimo posto il cibo e l'acqua della lista di rifornimento."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Dai priorità al cibo con buff"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Dà priorità al cibo che fornisce il buff "%s" quando il buff è assente, tranne nelle arene.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Attiva i buff delle pergamene"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"La tua macro Cibo applica le pergamene mancanti alla prima pressione e mangia a quella successiva, saltando le pergamene quando selezioni un giocatore amico o sei in un'arena."
L["OPTIONS_SCROLL_TYPES"] = "Includi i tipi di pergamena nel controllo"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Difesa"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Include "%s" nel controllo dei buff mancanti.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usa prima cibo e acqua evocati"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Le tue macro Cibo e Acqua usano cibo e acqua evocati prima di qualsiasi altra cosa, anche se qualcosa nelle tue borse ripristina di più, perché non costano nulla e svaniscono poco dopo la disconnessione. Il cibo con buff resta comunque al primo posto finché "Dai priorità al cibo con buff" è attivo.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Determina quando cibo e acqua evocati hanno la precedenza: sempre, oppure soltanto quando giochi da solo, sei in gruppo o incursione, sei in incursione, stai salendo di livello o sei al livello massimo."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Usa per ultimi cibo e acqua della lista di rifornimento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Tra due cibi o bevande che ripristinano la stessa quantità, le tue macro Cibo e Acqua usano quello che non è nella tua lista di rifornimento, conservando per dopo ciò che la lista acquista."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Pozioni e Pietre della Salute"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Le macro non possono cambiare durante il combattimento (questa è una restrizione della Blizzard), quindi ogni macro per Pozioni e Pietre della Salute è pre-costruita con il tuo miglior oggetto più fino a due alternative. Nei combattimenti più lunghi, l'icona e il tooltip possono diventare obsoleti e mostrare l'oggetto sbagliato, ma cliccando sulla macro verrà sempre utilizzato il miglior oggetto che hai effettivamente nelle borse."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usa cibo e acqua nelle macro delle pozioni fuori dal combattimento"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuori dal combattimento, la tua macro Pozione di Salute mangia il tuo miglior cibo e la tua macro Pozione di Mana beve la tua miglior acqua. In combattimento, usano le tue pozioni come prima. Le pergamene, il cibo per famigli e l'evocazione restano nelle macro Cibo e Acqua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combina le Pietre della Salute nella macro Pozione di Salute"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Aggiunge la tua migliore Pietra della Salute in fondo alla macro Pozione di Salute, così una singola pressione usa una pozione e una Pietra della Salute."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemme di Mana e rune"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s e alcuni altri oggetti per il mana condividono il tempo di recupero con le Gemme di Mana. Usare le rune costa salute, quindi la macro Gemma di Mana esclude tutti questi oggetti, a meno che tu non li aggiunga."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Aggiungi le rune e gli altri oggetti per il mana alla macro Gemma di Mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Inserisce nella stessa classifica delle tue Gemme di Mana %s, %s e ogni altro oggetto per il mana che ne condivide il tempo di recupero, così la macro Gemma di Mana ne usa uno quando è la tua opzione migliore o quando hai finito le gemme."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Rinnovo dei buff"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Le macro non possono cambiare durante il combattimento, quindi un buff che scade a metà scontro resta assente fino alla fine del combattimento."
L["OPTIONS_REAPPLY"] = "Rinnova i buff in scadenza"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	'Considera scaduti "Cibo con buff", "Buff delle pergamene" e "Buff del cibo per famigli" quando resta meno tempo della tua soglia, così le tue macro te ne propongono uno nuovo prima dello scontro.'
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza può arrivare un buff prima che le tue macro te ne propongano uno nuovo."
L["REAPPLY_THRESHOLD_ONE"] = "Quando rimane < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Quando rimangono < %d minuti"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Buff del cibo per famigli"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'Alcuni cibi danno al tuo famiglio un buff "%s" tutto suo.'
L["OPTIONS_USE_PET_BUFFS"] = "Usa i buff del cibo per famigli"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Aggiunge il cibo per famigli alla tua macro Cibo quando al tuo famiglio manca il buff "%s", tranne nelle arene.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Includi i tipi di cibo per famigli nel controllo"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Esplosivi"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"L'opzione @player salta il reticolo di puntamento e fa detonare l'esplosivo ai tuoi piedi. Ideale quando il bersaglio è in mischia. L'altro clic lancia l'esplosivo come al solito."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Assegnazione dei clic"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Determina quale clic lancia l'esplosivo e quale lo fa detonare ai tuoi piedi."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic sinistro @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic sinistro lancio"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Classe e razza"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Queste opzioni adattano le tue macro a una classe o a una razza. Ogni sezione è visibile su tutti i personaggi."

-- The class and race sections' headers; %s is the client's name for the class or race, or OPTIONS_FORSAKEN_HEADER.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Opzioni di classe: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Opzioni razziali: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Richiede l'add-on DruidMacroHelper. Se attivo, le tue macro Pozione di Salute, Pozione di Mana e Pietra della Salute ti fanno uscire dalla forma, usano l'oggetto e ti riportano in Forma d'Orso o Forma Felina, quella che scegli accanto alla casella."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Attiva l'integrazione con DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macro di mutaforma per Pozioni di Salute, Pozioni di Mana e Pietre della Salute utilizzando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Determina la forma in cui le tue macro di mutaforma ti riportano dopo l'uso dell'oggetto."
L["DRUID_FORM_BEAR"] = "Torna in Forma d'Orso"
L["DRUID_FORM_CAT"] = "Torna in Forma Felina"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro Veleni carica con il miglior grado utilizzabile di ogni tipo di veleno: clic sinistro applica alla mano secondaria, clic destro alla mano primaria, e i veleni esistenti vengono sostituiti automaticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo di veleno mano primaria"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo di veleno mano secondaria"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano primaria con il clic destro."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano secondaria con il clic sinistro."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Attiva la furtività mentre mangi"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "Aggiunge %s alla tua macro Cibo per renderti furtivo mentre mangi."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Attiva la furtività mentre bevi"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "Aggiunge %s alla tua macro Acqua per renderti furtivo mentre bevi."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Suggerimento pro: scegline uno. Puoi mangiare e bere allo stesso tempo, ma mangiare o bere dopo esserti reso furtivo interromperà la furtività."

--[[
    Forsaken. Headed with our own word, the race's lore name, since the client
    names it Undead; in the five texts after the header, %s is the client's
    name for Cannibalize. Drinking shows only where Cannibalize restores mana.
]]
L["OPTIONS_FORSAKEN_HEADER"] = "Reietti"
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Prendi come bersaglio un umanoide o un non morto che hai ucciso e la tua macro usa %s finché l'abilità è pronta, risparmiando cibo e bevande. Se non può (il cadavere è fuori portata o l'abilità è in ricarica), mangia o beve come al solito."
L["OPTIONS_CANNIBALIZE_EATING"] = "Usa %s invece di mangiare"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Finché il tuo bersaglio è un cadavere su cui funziona %s e l'abilità è pronta, la tua macro Cibo la usa invece di mangiare. Altrimenti mangia come al solito. Le pergamene e il cibo con buff hanno ancora la precedenza."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Usa %s invece di bere"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Finché il tuo bersaglio è un cadavere su cui funziona %s e l'abilità è pronta, la tua macro Acqua la usa invece di bere. Altrimenti beve come al solito. Le bevande con buff hanno ancora la precedenza."

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
L["TAB_IGNORE_LIST"] = "Lista ignorati"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Gli oggetti ignorati non vengono mai scelti da nessuna macro. Cibo, acqua, pozioni, qualsiasi cosa. La lista Globale vale per tutti i personaggi; quella di un personaggio vale solo per lui. Fai clic destro sul pulsante della minimappa per ignorare il tuo miglior cibo attuale."
L["OPTIONS_IGNORE_GLOBAL"] = "Globale"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Sposta questo oggetto nella lista Globale, così viene ignorato su tutti i personaggi."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Aggiungi dalle borse"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Scegli qualsiasi cosa tu abbia con te. Le borse si chiudono quando si apre l'interfaccia delle opzioni, quindi questo sostituisce il trascinamento di un oggetto qui."
L["OPTIONS_IGNORE_ADD_ID"] = "Aggiungi tramite ID oggetto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat mentre questo campo è attivo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat."
L["OPTIONS_IGNORE_REMOVE"] = "Rimuovi"
L["OPTIONS_IGNORE_EMPTY"] = "Questa lista è vuota."
L["OPTIONS_IGNORE_CLEAR"] = "Svuota lista"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Rimuove tutti gli oggetti da questa lista. Un personaggio con la lista vuota sparisce dall'elenco a sinistra, a meno che non sia quello che stai giocando."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] =
	"Rimuovere tutti gli oggetti da questa lista? L'operazione non può essere annullata."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Caricamento ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene rifornite le tue borse in base alla tua lista di rifornimento, comprando dai mercanti e spostando automaticamente gli oggetti da e verso la banca. Digita %s per aprire la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Apri in banca"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti la banca."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Apri dal mercante"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti un mercante."
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Promemoria"
L["OPTIONS_RESTOCKER_REMIND"] = "Attiva i promemoria di rifornimento in città"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Mostra un promemoria in chat quando ti manca qualcosa della tua lista di rifornimento e raggiungi una locanda o una città, o ti trovi già in una all'accesso."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Attiva i promemoria di rifornimento dal mercante"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Segnala gli eventuali ordini di rifornimento in sospeso quando chiudi la finestra di un mercante."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Attiva i promemoria di rifornimento in banca"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Segnala gli eventuali ordini di rifornimento in sospeso quando chiudi la banca."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Attiva la riserva d'oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "Il rifornimento non spende mai l'oro che metti da parte qui."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Imposta quanto oro il rifornimento ti lascia sempre."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Determina se il promemoria sia una sola riga o ne aggiunga una per ogni oggetto da rifornire."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Semplice"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Dettagliato"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Riproduci suono"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Riproduce un avviso insieme al promemoria, per quando la chat è affollata."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Clicca per ascoltare l'avviso."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Finestra della lista di rifornimento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Scegli quando la tua lista di rifornimento si apre da sola."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Mostra nel tooltip di un oggetto quanti ne possiedi, contando tutti i tuoi personaggi di questo reame."
L["OPTIONS_INVENTORY_REPORT"] = "Attiva il rapporto di inventario nei tooltip degli oggetti"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Aggiunge al tooltip di un oggetto quanti ne hai nelle tue borse, nella tua banca e sugli altri tuoi personaggi. Disattivalo se un altro add-on mostra già questi conteggi."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Ringraziamenti"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Ho sempre amato Restocker, e sono felice che continui a vivere dentro Connoisseur & Restocker. Un grazie enorme a ChiliFajita, che ha scritto l'Auto Restocker originale, e a kvakvs e guardycmw, che lo hanno tenuto in vita attraverso Classic e Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Rapporto di preparazione"
L["OPTIONS_READINESS_ENABLE"] = "Attiva il rapporto di preparazione all'appello"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] =
	"Attiva il rapporto di preparazione per tutti i personaggi di questo account."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quando parte un appello, mostra in chat una lista privata di ciò che va ancora sistemato e, se sei pronto, non dice proprio nulla."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Ripristina le impostazioni del rapporto di preparazione"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Riporta ai valori predefiniti ogni casella ed entrambe le soglie di questa pagina."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Ripristinare tutte le impostazioni del rapporto di preparazione ai valori predefiniti? Questo disattiva di nuovo anche il rapporto stesso."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Buff mancanti"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Oggetti mancanti"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaggio"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Segnala se manca un tonico. Basta un tonico, oppure un elisir di combattimento e un elisir di protezione."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] =
	'Segnala se manca il buff "%s". Richiede che "Cibo con buff" sia attivo nel pannello Macro.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION_FORMAT"] =
	'Segnala se al tuo famiglio manca il buff "%s". Richiede che "Buff del cibo per famigli" sia attivo nel pannello Macro e che tu abbia un famiglio evocato.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	'Segnala se ti mancano i buff delle pergamene. Richiede che "Buff delle pergamene" sia attivo nel pannello Macro e controlla solo i tipi di pergamena selezionati lì.'
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Segnala quando nessuno nel tuo gruppo ha una Pietra dell'Anima attiva; una rimasta in una borsa non conta. Segnalato solo a uno Stregone che può crearne una."
L["OPTIONS_READINESS_MAIN_HAND"] = "Buff arma (mano primaria)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano primaria senza incantamento temporaneo. Conta qualsiasi incantamento, e resta in silenzio quando nel tuo gruppo c'è uno Sciamano."
L["OPTIONS_READINESS_OFF_HAND"] = "Buff arma (mano secondaria)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano secondaria senza incantamento temporaneo. Conta qualsiasi incantamento: una pietra, un olio, un veleno o un buff arma da Sciamano."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buff in scadenza entro"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	'Elenca ogni buff su di te che sta per scadere, non solo quelli applicati da Connoisseur & Restocker, ed è indipendente da "Rinnovo dei buff" nel pannello Macro.'
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minuti"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza deve essere un buff perché il rapporto lo elenchi."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Pietra della Salute. Segnalato solo quando c'è uno Stregone nel gruppo a cui chiederla, o quando lo Stregone sei tu."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Gemma di Mana. Segnalato solo a un Mago che può evocarne una."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di cura, perché nessuno può passartene una in pieno combattimento."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di mana. Segnalato solo quando giochi con una classe che usa il mana."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna benda che la tua abilità in %s ti permetta di usare."
L["OPTIONS_READINESS_DURABILITY"] = "Equipaggiamento danneggiato sotto"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Mostra il collegamento di ogni oggetto equipaggiato con integrità inferiore a questa soglia, calcolata oggetto per oggetto, così compare anche una sola arma rotta."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto deve scendere l'integrità di un oggetto perché il rapporto ne mostri il collegamento."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Specializzazione attuale"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] =
	"Mostra la distribuzione dei talenti e gli eventuali punti che non hai speso."
L["OPTIONS_READINESS_PVP"] = "PvP attivo"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avvisa quando la tua modalità PvP è attiva."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Mostra il collegamento degli oggetti equipaggiati che non c'entrano con un combattimento, come l'attrezzatura da equitazione o da pesca."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Esiste già una lista chiamata "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "L'ID %d non esiste."
L["RESTOCKER_BANK_NOT_OPEN"] = "La banca non è aperta."
L["RESTOCKER_DISABLED"] = "Il Restocker è disattivato. Attivalo in Opzioni > Add-on > Connoisseur & Restocker."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Rifornimento completato. Tieni premuto Maiusc mentre apri la banca per saltare il rifornimento. Digita %s per modificare la tua lista di rifornimento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Rifornimento interrotto. Le tue borse e la tua banca sono piene."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Rifornimento interrotto. La tua banca è piena; libera uno spazio e riaprila."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Rifornimento interrotto. Le tue borse sono piene; libera uno spazio e riapri la banca."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Rifornimento interrotto. Nessun progresso possibile."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Rifornimento interrotto. Impossibile spostare: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (in eccesso)"
L["RESTOCKER_STOPPED_ERROR"] = "Rifornimento interrotto a causa di un errore: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Questo mercante non vende tutti gli ingredienti necessari ai tuoi veleni. Non ne verrà comprato nessuno."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Non dimenticare di fare rifornimento mentre sei in città!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 ordine di rifornimento in sospeso."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d ordini di rifornimento in sospeso."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "La tua lista di rifornimento è stata migliorata."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d diventa %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 ordine di rifornimento evaso."
L["RESTOCKER_RESTOCKED_MANY"] = "%d ordini di rifornimento evasi."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 ordine di rifornimento evaso in parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d ordini di rifornimento evasi in parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Le tue borse si sono riempite prima che fosse comprato tutto."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "Oro insufficiente per completare il rifornimento."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Acquisti interrotti alla tua riserva d'oro (%s). Il resto verrà comprato alla tua prossima visita, se avrai oro in più."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nome]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Aggiunge una lista con quel nome."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con quel nome."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Rinomina la lista attuale con quel nome."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Sostituisce la lista attuale con una copia della lista con quel nome."
L["RESTOCKER_HELP_PROFILE_USE"] = "Assegna a questo personaggio la lista con quel nome."

--[[
    Starter List pop-up, the staples window: offers staples at login when the
    Restock List is empty, and on demand from the Restock List window's Pick
    Staples button. The staples logic is in
    Features/Restocker/Restocker-Starter-List.lua, the window in
    Options/Options-Starter-List-Popup.lua. The six
    food staples reuse the DIET_ keys above, so each food row carries the
    client's own pet diet name.

    The title is its own, and the call site puts the add-on's full name in
    front of it (ADDON_TITLE // STARTER_POPUP_TITLE): at login this window
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
L["STARTER_POPUP_TITLE"] = "Beni essenziali"
L["STARTER_POPUP_INTRO_LOGIN"] = "Abbiamo spuntato alcuni beni essenziali della tua classe per aiutarti a iniziare."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"La tua lista di rifornimento è vuota, quindi aggiungiamo qualche oggetto per iniziare."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Scegli i beni essenziali che vuoi tenere di scorta."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tutto ciò che spunti viene rifornito automaticamente ogni volta che apri un mercante o la tua banca. La maggior parte dei beni essenziali migliora da sola man mano che sali di livello, così avrai sempre il meglio disponibile."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Puoi sempre modificare questa lista, o aggiungere altri oggetti in seguito, digitando %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Cibo e acqua"
L["STARTER_POPUP_FOOD_HEADER"] = "Cibo"
L["STARTER_POPUP_AMMO_HEADER"] = "Munizioni"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Proiettili"
L["STARTER_POPUP_ARROWS"] = "Frecce"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenti e strumenti"
L["STARTER_POPUP_POISONS_HEADER"] = "Veleni"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : aggiungi il veleno finito alla tua lista e Connoisseur & Restocker comprerà automaticamente gli ingredienti da qualsiasi mercante che li venda tutti."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse e migliorandoli man mano che sali di livello."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pila"
L["STARTER_POPUP_STACK_MANY"] = "%d pile"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Quante pile tenere di scorta, dove una pila equivale a %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Quanti tenerne di scorta, ognuno in uno spazio a sé nelle borse, perché non si impilano."

--[[
    Restock List window UI. The title names what the window holds, after the
    add-on's full name (ADDON_TITLE // RESTOCKER_WINDOW_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Lista di rifornimento"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtra oggetti..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Cancella"
L["RESTOCKER_ADD_BUTTON"] = "Aggiungi"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Beni essenziali"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Scegli tra i beni essenziali per la tua classe e il tuo livello: cibo, acqua, munizioni, veleni e reagenti. Spuntarne uno lo aggiunge a questa lista e togliere la spunta lo rimuove."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Aggiungi un oggetto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Trascina un oggetto dalle tue borse qui o in qualsiasi punto di questa finestra, oppure digita un ID oggetto e premi Invio."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Trascina o digita l'ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Digita invece un ID."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Già in questa lista."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Aggiungi dalle borse"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Ogni oggetto nelle tue borse che non è ancora in questa lista. Cliccane uno per aggiungerlo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nulla da aggiungere dalle tue borse"

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
L["RESTOCKER_PROFILE_LABEL"] = "Lista"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Clicca per assegnare a questo personaggio un'altra lista di rifornimento o per iniziarne una nuova."
L["RESTOCKER_USED_BY"] = "Usata da %s"
L["RESTOCKER_MANAGE"] = "Gestisci liste"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Inizia una nuova lista, oppure copia, rinomina o elimina questa."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nuova lista"
L["RESTOCKER_MANAGE_COPY"] = "Copia questa lista in una nuova"
L["RESTOCKER_RENAME_PROFILE"] = "Rinomina questa lista"
L["RESTOCKER_MANAGE_DELETE"] = "Elimina questa lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Copia"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Rinomina"
L["RESTOCKER_RENAME_TOOLTIP"] = "Rinomina questa lista per tutti i personaggi che la usano."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Vuoi davvero eliminare questa lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "Anche %s la usa e, all'accesso, troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"Anche %s la usano e, all'accesso, ognuno troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Passerai alla lista %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "È l'unica lista rimasta, quindi ripartirai da una nuova lista vuota."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Questa azione non può essere annullata."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Migliora salendo di livello"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permette a Connoisseur & Restocker di migliorare cibo, acqua, munizioni, veleni, pozioni e reagenti di classe, passando a oggetti migliori man mano che sali di livello."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banca"
L["RESTOCKER_ROW_MERCHANT"] = "Mercante"
L["RESTOCKER_ROW_UPGRADE"] = "Migliora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Oggetto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Preleva"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Deposita"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Tieni"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Clicca sull'intestazione per impostare questa opzione su tutti gli oggetti mostrati."
L["RESTOCKER_BULK_ON"] = "Attiva (mostrati: %d)"
L["RESTOCKER_BULK_OFF"] = "Disattiva (mostrati: %d)"

L["RESTOCKER_GROUP_OTHER"] = "Altro"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuovi"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Tutti gli oggetti"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Questa lista è ancora vuota"
L["RESTOCKER_EMPTY_BODY"] =
	"Scegli beni essenziali come cibo, acqua o reagenti di classe, oppure aggiungi qualsiasi cosa dalle tue borse con il menu qui sopra. Gli oggetti in questa lista vengono tenuti di scorta o depositati in banca automaticamente, così le tue borse restano in ordine."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Puoi anche aggiungere un oggetto trascinandolo ovunque in questa finestra."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nessun oggetto in questa lista corrisponde al tuo filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "Non è rimasto nulla in questa categoria."

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
L["RESTOCKER_NO_ORDERS"] = "Nessun ordine di rifornimento in sospeso."
L["RESTOCKER_REPORT_MORE"] = "e %d in più"
L["RESTOCKER_REMOVED_ITEM"] = "Hai rimosso %s."
L["RESTOCKER_UNDO"] = "Annulla"
L["RESTOCKER_UNDO_TOOLTIP"] = "Rimetti questo oggetto nella lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Rimuovi questo oggetto dalla lista di rifornimento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puoi annullare questa azione in fondo alla finestra."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Tieni nelle borse"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'Quanti tenerne nelle borse. Il numero diventa giallo finché le tue borse ne contengono di meno, e 0 con "Deposita" attivo manda tutto in banca.'
L["RESTOCKER_BUY_LABEL"] = "Compra"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Compra dal mercante"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra dal mercante la quantità necessaria quando la finestra del mercante è aperta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Compra extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra da un mercante tutta la scorta limitata di questo oggetto, cioè la merce che vende pochi pezzi alla volta e rifornisce lentamente, anche oltre il numero della colonna Tieni."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Deposita in banca"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Deposita in banca gli oggetti in eccesso quando la banca è aperta, oppure tutti se nella colonna Tieni imposti 0."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Preleva dalla banca"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Preleva dalla banca gli oggetti necessari quando la banca è aperta."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputazione richiesta"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% di sconto)"
L["RESTOCKER_REPUTATION_ANY"] = "Qualsiasi"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputazione richiesta con il mercante"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Clicca per impostare la reputazione che un mercante richiede prima che Connoisseur & Restocker compri da lui, il che riduce anche il prezzo: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Con un trattino, Connoisseur & Restocker compra da qualsiasi mercante."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi non c\'è nulla di extra da comprare.'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi la reputazione non si applica.'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Questo oggetto non ha una versione migliore a cui passare."

--------------------------------------------------------------------------------
-- Thanks for the Buff
--------------------------------------------------------------------------------

-- Every string from here to Spellbook is Thanks for the Buff's.

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "%s ti ha potenziato con %s!"
L["MESSAGE_GAVE_YOU"] = "%s ti ha dato %s!"
L["MESSAGE_GAVE_GROUP"] = "%s ha dato %s al tuo gruppo!"
L["MESSAGE_USED_ITEM"] = "%s ha usato %s su di te!"
L["MESSAGE_USED_SPELL"] = "%s ha lanciato %s su di te!"
L["MESSAGE_SET_OUT"] = "%s ha posizionato %s!"
L["MESSAGE_OPENED"] = "%s ha aperto %s!"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "Grazie per %s"
L["MESSAGE_SELECT_PLAYER"] = "Prima prendi un giocatore come bersaglio."
L["MESSAGE_CANT_THANK_SELF"] = "Non puoi ringraziare te stesso!"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "Incantesimo sconosciuto"

--------------------------------------------------------------------------------
-- Options: Main Panel
--------------------------------------------------------------------------------

L["OPTIONS_EXAMPLE"] = "Esempio: %s"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "Potenziamenti da sconosciuti"
L["STRANGERS_ENABLE"] = "Abilita i ringraziamenti per i potenziamenti da sconosciuti"
L["STRANGERS_ENABLE_DESCRIPTION"] =
	"Attiva i ringraziamenti per i potenziamenti ricevuti da giocatori fuori dal tuo gruppo."
L["STRANGERS_DESCRIPTION"] = "Ringrazia i giocatori fuori dal tuo gruppo quando ti potenziano nel mondo aperto."
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "Recupero dei ringraziamenti"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"Imposta il ritardo tra un giro di ringraziamenti e il successivo, chiunque ti abbia potenziato. Con zero si ringrazia per ogni potenziamento."
L["STRANGERS_SOURCE_COOLDOWN"] = "Recupero dei ringraziamenti allo stesso giocatore"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"Imposta il ritardo tra i ringraziamenti rivolti allo stesso giocatore. Con zero si ringrazia per ogni potenziamento."
L["STRANGERS_MIN_DURATION"] = "Durata minima del potenziamento"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"Ignora i potenziamenti più brevi di questo valore. Con zero si reagisce a ogni potenziamento."

-- Teammate Buffs
L["TAB_TEAMMATES"] = "Potenziamenti dai compagni"
L["TEAMMATES_ENABLE"] = "Abilita i ringraziamenti per i potenziamenti dai compagni"
L["TEAMMATES_ENABLE_DESCRIPTION"] =
	"Attiva i ringraziamenti per i potenziamenti e le capacità con tempo di recupero che i membri del tuo gruppo o della tua incursione lanciano su di te."
L["TEAMMATES_DESCRIPTION"] =
	"Ringrazia i membri del gruppo e dell'incursione per i potenziamenti e le capacità con tempo di recupero che lanciano su di te."

-- Service Alerts
L["TAB_SERVICES"] = "Avvisi sui servizi"
L["SERVICES_ENABLE"] = "Abilita gli avvisi sui servizi"
L["SERVICES_ENABLE_DESCRIPTION"] =
	"Attiva gli avvisi per banchetti, pozzi delle anime, portali e altri aiuti messi a disposizione del tuo gruppo."
L["SERVICES_DESCRIPTION"] =
	"Reagisci quando qualcuno mette a disposizione un aiuto per il tuo gruppo: banchetti, pozzi delle anime, portali e robot di riparazione."

-- Send Good News
L["TAB_GOOD_NEWS"] = "Invia buone notizie"
L["GOOD_NEWS_DESCRIPTION"] =
	"Informa i giocatori che potenzi di ciò che hai lanciato su di loro e, per i potenziamenti brevi, di quanto dura."
L["GOOD_NEWS_ENABLE"] = "Abilita buone notizie"
L["GOOD_NEWS_ENABLE_DESCRIPTION"] =
	"Attiva un sussurro che comunica ai giocatori che potenzi ciò che hai lanciato su di loro."
L["GOOD_NEWS_SCOPE"] = "Destinatari"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "Chiunque potenzi"
L["GOOD_NEWS_SCOPE_GROUP"] = "Solo membri del gruppo"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"Imposta chi riceve il sussurro delle buone notizie: chiunque potenzi, oppure solo i membri del tuo gruppo."
L["GOOD_NEWS_MESSAGES_HEADER"] = "Messaggio delle buone notizie"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "Il sussurro che ricevono i giocatori che potenzi."
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] =
	"Imposta cosa dice il sussurro. Lascialo vuoto per usare il testo predefinito."
L["GOOD_NEWS_MESSAGE_LIMIT"] = "Lunghezza massima: %d."
L["GOOD_NEWS_MESSAGE_TOKENS"] =
	"%a diventa il collegamento all'abilità, con la sua durata quando è inferiore a un minuto."
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "per %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "Abilità tracciate"
L["TRACKED_GROUP_ITEMS"] = "Oggetti"
L["TRACKED_ITEM_PENDING"] = "Oggetto #%d"
L["TRACKED_SPELL_PENDING"] = "Incantesimo #%d"

-- Shared by Send Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "Messaggio sussurrato"
L["WHISPER_MESSAGE_RESET"] = "Ripristina"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "Ripristina il testo predefinito del messaggio sussurrato."

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "Sussurri di ringraziamento ed emote"
L["NOTIFICATIONS_HEADER"] = "Notifiche"
L["PRAISE_DESCRIPTION"] = "Ciò che vede l'altro giocatore: un sussurro di ringraziamento, un'emote o entrambi."
L["NOTIFICATIONS_DESCRIPTION"] = "Ciò che ricevi solo tu: un messaggio di testo, un suono o entrambi."

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "Seleziona le emote"

L["PRAISE_WHISPER_ENABLE"] = "Abilita sussurri di ringraziamento"
L["PRAISE_WHISPER_DESCRIPTION"] = "Sussurra un ringraziamento al giocatore che ti ha potenziato."
L["PRAISE_EMOTES_ENABLE"] = "Abilita emote"
L["PRAISE_EMOTES_DESCRIPTION"] =
	"Mostra il tuo apprezzamento con un'emote. Le emote vengono trattenute mentre sei in combattimento."
L["PRAISE_DELAY_ENABLE"] = "Abilita ritardo del ringraziamento"
L["PRAISE_DELAY_DESCRIPTION"] =
	"Attende un momento prima del sussurro e dell'emote, così il tuo ringraziamento non arriva nello stesso istante del potenziamento. Le notifiche non vengono influenzate."
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "Imposta quanto attendere prima di inviare il sussurro e l'emote."

L["NOTIFICATIONS_PRINT_ENABLE"] = "Abilita messaggi di testo"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "Mostra un messaggio visibile solo a te quando ricevi un potenziamento."
L["NOTIFICATIONS_SOUND_ENABLE"] = "Abilita effetti sonori"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "Riproduce un suono quando ricevi un potenziamento. Lo senti solo tu."
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Riproduce il suono così puoi ascoltarlo prima di attivarlo."

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "Portali"
L["GROUP_RESISTANCE_CAULDRONS"] = "Calderoni di resistenza"
L["GROUP_REPAIR_BOTS"] = "Robot di riparazione"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_WINDOW"] = "Turno dei potenziamenti"
L["BUFF_WINDOW_DESCRIPTION"] = "Mostra a chi mancano i tuoi potenziamenti. Clicca su un'icona per lanciarlo."
L["BUFF_WINDOW_ENABLE"] = "Abilita turno dei potenziamenti"
L["BUFF_WINDOW_ENABLE_DESCRIPTION"] =
	"Attiva il turno dei potenziamenti, la finestra dei membri del gruppo a cui manca un potenziamento che puoi lanciare."
L["BUFF_WINDOW_NO_BUFFS"] =
	"La tua classe non ha potenziamenti in questa lista, quindi la finestra non compare mai con questo personaggio."
-- When to Show: Solo and In Group, each with Always or In Instance, then the classes.
L["BUFF_WINDOW_WHEN_HEADER"] = "Quando mostrare"
L["BUFF_WINDOW_WHEN_DESCRIPTION"] = "Scegli quando la finestra può apparire."
L["BUFF_WINDOW_WHEN_SOLO"] = "Da solo"
L["BUFF_WINDOW_WHEN_SOLO_DESCRIPTION"] = "Mostra la finestra quando non sei in un gruppo o in un'incursione."
L["BUFF_WINDOW_WHEN_GROUP"] = "In gruppo"
L["BUFF_WINDOW_WHEN_GROUP_DESCRIPTION"] = "Mostra la finestra quando sei in un gruppo o in un'incursione."
L["BUFF_WINDOW_WHERE_DESCRIPTION"] =
	"Imposta dove appare la finestra: ovunque, o solo in spedizioni, incursioni, campi di battaglia e arene."
L["BUFF_WINDOW_WHERE_ALWAYS"] = "Sempre"
L["BUFF_WINDOW_WHERE_INSTANCE"] = "In istanza"
L["BUFF_WINDOW_CLASSES_DESCRIPTION"] = "Mostra la finestra quando giochi queste classi."
L["BUFF_WINDOW_CLASS_DESCRIPTION"] = "Mostra la finestra quando giochi questa classe."
L["BUFF_WINDOW_HEADER"] = "Finestra"
L["BUFF_WINDOW_WINDOW_DESCRIPTION"] = "Tieni la finestra dove l'hai messa, o toglila di mezzo in combattimento."
L["BUFF_WINDOW_LOCK"] = "Blocca la finestra"
L["BUFF_WINDOW_LOCK_DESCRIPTION"] = "Impedisce di spostare la finestra. Quando è sbloccata, trascinala dallo sfondo."
L["BUFF_WINDOW_HIDE_IN_COMBAT"] = "Nascondi in combattimento"
L["BUFF_WINDOW_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Nasconde la finestra durante il combattimento. In combattimento la lista non può aggiornarsi, quindi una finestra lasciata visibile mantiene il suo ultimo stato fino alla fine del combattimento."
L["BUFF_WINDOW_SHOW_HEADER"] = "Mostra nella finestra"
L["BUFF_WINDOW_SHOW_DESCRIPTION"] =
	"Aggiungi alla finestra i tuoi potenziamenti, gli sconosciuti che ti hanno potenziato e il tuo bersaglio."
L["BUFF_WINDOW_FAVOR_ENABLE"] = "Ricambia il favore"
L["BUFF_WINDOW_FAVOR_ENABLE_DESCRIPTION"] =
	"Elenca gli sconosciuti che ti hanno potenziato di recente, con i potenziamenti che puoi restituire loro. Clic destro su un'icona per togliere qualcuno dalla lista."
L["BUFF_WINDOW_FAVOR_SECONDS_DESCRIPTION"] =
	"Imposta per quanto tempo uno sconosciuto resta nella lista dopo il suo ultimo potenziamento."
L["BUFF_WINDOW_TARGET_ENABLE"] = "Il tuo bersaglio"
L["BUFF_WINDOW_TARGET_ENABLE_DESCRIPTION"] =
	"Elenca il tuo bersaglio quando è un giocatore fuori dal tuo gruppo a cui manca un potenziamento che puoi lanciare."
L["BUFF_WINDOW_REFRESH"] = "Rinnova sotto"
L["BUFF_WINDOW_REFRESH_DESCRIPTION"] =
	"Imposta sotto quale tempo residuo un potenziamento viene considerato mancante, così puoi rinnovarlo prima che svanisca. Un potenziamento che non dura più di questo tempo conta solo quando è svanito."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_WINDOW_TANKS_HEADER"] = "Considera come difensori"
L["BUFF_WINDOW_TANKS_DESCRIPTION"] =
	"Chi riceve i potenziamenti che offri ai Difensori, come Thorns, quando non ha un ruolo proprio."
L["BUFF_WINDOW_TANKS_CLASS_DESCRIPTION"] =
	"Imposta quando i giocatori di questa classe contano come difensori. Un ruolo da difensore o guaritore che abbiano ha sempre la precedenza."
L["BUFF_WINDOW_TANKS_PETS"] = "Famigli"
L["BUFF_WINDOW_TANKS_PETS_DESCRIPTION"] =
	"Imposta quando i famigli contano come difensori. I famigli ricevono anche i potenziamenti che offri a Tutti."
L["BUFF_WINDOW_TANKS_NEVER"] = "Mai"
L["BUFF_WINDOW_TANKS_SOLO"] = "Quando non sei in gruppo"
L["BUFF_WINDOW_TANKS_ALWAYS"] = "Sempre"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_WINDOW_AUDIENCE_OFF"] = "Disattivato"
L["BUFF_WINDOW_AUDIENCE_TANK"] = "Difensori"
L["BUFF_WINDOW_AUDIENCE_HEALER"] = "Guaritori"
L["BUFF_WINDOW_AUDIENCE_ALL"] = "Tutti"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_WINDOW_AUDIENCE_DESCRIPTION"] = "Imposta a chi offrire %s."
L["BUFF_WINDOW_BUFFS_DESCRIPTION"] =
	"Scegli a chi offrire ogni potenziamento. Difensori e Guaritori si basano sul ruolo nel gruppo; chi non ne ha uno conta come Danno, a meno che Considera come difensori qui sotto non indichi altrimenti."

L["BUFF_WINDOW_SELF_DESCRIPTION"] = "I tuoi potenziamenti, fissati in cima alla finestra."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_WINDOW_SELF_NOTE_ASPECT"] = "vale un aspetto qualsiasi"
L["BUFF_WINDOW_SELF_NOTE_MAGE_ARMOR"] = "vale un'armatura qualsiasi"
L["BUFF_WINDOW_SELF_NOTE_PALADIN_AURA"] = "vale un'aura qualsiasi"
L["BUFF_WINDOW_SELF_NOTE_SHAMAN_SHIELD"] = "vale uno scudo qualsiasi"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_ARMOR"] = "vale un'armatura qualsiasi"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_DEMON"] = "vale uno qualsiasi dei due potenziamenti demoniaci"
L["BUFF_WINDOW_SELF_REFRESH_OFF"] = "Disattivato"
L["BUFF_WINDOW_SELF_REFRESH_MISSING"] = "Se manca"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_WINDOW_SELF_REFRESH_UNDER"] = "Meno di %s"
L["BUFF_WINDOW_SELF_REFRESH_DESCRIPTION"] =
	"Imposta quando compare %s: mai, quando l'effetto è finito, o quando ne resta meno di questo tempo."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_WINDOW_WEAPON_PANEL_HEADER"] = "Potenziamenti delle armi"
L["BUFF_WINDOW_WEAPON_DESCRIPTION"] =
	"Spunta cosa deve avere ogni arma. La finestra lo propone quando manca o sta per scadere, se è nelle tue borse ed è adatto all'arma."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_WINDOW_WEAPON_REFRESH"] = "Riapplica"
L["BUFF_WINDOW_WEAPON_REFRESH_DESCRIPTION"] =
	"Imposta quando un potenziamento dell'arma viene proposto di nuovo: quando l'effetto è finito, o quando ne resta meno di questo tempo."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_WINDOW_WEAPON_KIND_OIL"] = "Oli"
L["BUFF_WINDOW_WEAPON_KIND_STONE"] = "Pietre"
L["BUFF_WINDOW_WEAPON_KIND_LURE"] = "Esche"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_WINDOW_WEAPON_PICK_DESCRIPTION"] =
	"Offre %s per la tua arma (%s). Finché l'arma non ha nessuna delle scelte spuntate, viene offerta ognuna di quelle che possiedi."
L["BUFF_WINDOW_SELF_ENABLE"] = "I tuoi potenziamenti personali"
L["BUFF_WINDOW_SELF_ENABLE_DESCRIPTION"] =
	"Mostra in cima alla finestra i potenziamenti che solo tu puoi lanciare su te stesso, come un'armatura o Inner Fire, quando mancano o stanno per scadere. Scegli quali in Potenziamenti personali."
L["BUFF_WINDOW_WEAPON_ENABLE"] = "I tuoi potenziamenti delle armi"
L["BUFF_WINDOW_WEAPON_ENABLE_DESCRIPTION"] =
	"Mostra i veleni, le infusioni, gli oli, le pietre e le esche che mancano alle tue armi o stanno per scadere, insieme ai tuoi potenziamenti personali in cima alla finestra. Cliccane uno per applicarlo. Scegli quali in Potenziamenti delle armi."

-- The window itself
L["BUFF_WINDOW_SELF_HEADER"] = "Potenziamenti personali"
L["BUFF_WINDOW_FAVOR_HEADER"] = "Ricambia il favore"
L["BUFF_WINDOW_TARGET_HEADER"] = "Bersaglio"
L["BUFF_WINDOW_TOOLTIP_CAST"] = "Clicca per lanciarlo su %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_WINDOW_TOOLTIP_WEAPON"] = "Clicca per applicarlo alla tua arma (%s)."
L["BUFF_WINDOW_TOOLTIP_USE"] = "Nessuno nel tuo gruppo ha una Pietra dell'Anima. Clicca per usarne una su %s."
L["BUFF_WINDOW_TOOLTIP_CREATE"] = "Nessuno nel tuo gruppo ha una Pietra dell'Anima. Clicca per crearne una."
L["BUFF_WINDOW_TOOLTIP_GROUP"] = "Clicca per lanciarlo su %s e sul suo gruppo."
L["BUFF_WINDOW_TOOLTIP_FAVOR"] = "Clicca per selezionare %s come bersaglio e lanciarlo."
L["BUFF_WINDOW_TOOLTIP_DISMISS"] = "Clic destro per togliere %s dalla lista."
-- The window's close button: the class name in its color, then the options command.
L["BUFF_WINDOW_CLOSED"] =
	"Turno dei potenziamenti è disattivato per la classe %s. Per riattivarlo, usa Maiusc + Clic destro sul pulsante della minimappa o digita %s."

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEYS_HEADER"] = "Tasti rapidi"
L["BUFF_KEYS_DESCRIPTION"] =
	"Lancia il prossimo potenziamento della tua lista con un tasto o una macro, fuori dal combattimento. I potenziamenti delle armi restano un clic sulla finestra."
L["BUFF_KEY"] = "Pulsante potenziamento"
L["BUFF_KEY_DESCRIPTION"] =
	"Lancia il tuo prossimo potenziamento mancante, uno per pressione: una resurrezione sul tuo bersaglio morto, poi sui morti del tuo gruppo (sacerdoti, paladini e sciamani), poi i tuoi potenziamenti personali, Ricambia il favore, il tuo bersaglio e il tuo gruppo. Un gruppo riceve il potenziamento di gruppo quando costa meno mana che potenziare uno alla volta tutti quelli a portata."
L["BUFF_KEY_SKIP_COOLDOWNS"] = "Salta i potenziamenti con tempo di recupero"
L["BUFF_KEY_SKIP_COOLDOWNS_DESCRIPTION"] =
	"Salta i potenziamenti con un tempo di recupero, come Fear Ward, e passa al successivo."
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "In attesa che %s sia a portata."
L["BUFF_KEY_DONE"] = "Niente più da potenziare."
-- The caption beside the read-only box that holds a Buff Key's macro line.
L["BUFF_KEY_MACRO_CAPTION"] = "Macro"

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "Pulsante di ringraziamento"
L["BUTTON_DESCRIPTION"] =
	"Sussurra al tuo bersaglio e rivolgigli un'emote con un solo tasto. Buone maniere, automatizzate."
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "Pulsante di ringraziamento %d"
L["BUTTON_EMOTE"] = "Emote"
L["BUTTON_EMOTE_DESCRIPTION"] =
	"Imposta l'emote che questo pulsante esegue sul tuo bersaglio, oppure Nessuna per non usare alcuna emote."
L["BUTTON_EMOTE_NONE"] = "Nessuna"
L["BUTTON_ICON"] = "Icona"
L["BUTTON_ICON_DESCRIPTION"] =
	"Imposta l'icona che la macro di questo pulsante mostra nell'elenco delle macro e sulle barre delle azioni."
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "Predefinita"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = 'Abilita la macro "%s"'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] =
	"Crea una macro chiamata %s e la elimina di nuovo quando disattivi questa opzione."
L["BUTTON_WHISPER_DESCRIPTION"] =
	"Imposta cosa sussurra questo pulsante al tuo bersaglio. Se il campo resta vuoto, non viene inviato alcun sussurro."

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "Grazie, sei un mito! (="
--[[
    The star marker (left off on WoW Forever) and " // TFTB" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "Hai %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "Fai il tifo per <Target>."
L["EMOTE_DRINK_DESCRIPTION"] = "Brindi a <Target>."
L["EMOTE_FLEX_DESCRIPTION"] = "Mostri i muscoli a <Target>."
L["EMOTE_GRIN_DESCRIPTION"] = "Sorridi maliziosamente a <Target>."
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "Dai il cinque a <Target>."
L["EMOTE_PRAISE_DESCRIPTION"] = "Lodi <Target>."
L["EMOTE_SALUTE_DESCRIPTION"] = "Saluti <Target> con rispetto."
L["EMOTE_SMILE_DESCRIPTION"] = "Sorridi a <Target>."
L["EMOTE_THANK_DESCRIPTION"] = "Ringrazi <Target>."
L["EMOTE_WHOA_DESCRIPTION"] = "Esclami 'Wow!' verso <Target>."
L["EMOTE_WINK_DESCRIPTION"] = "Fai l'occhiolino a <Target>."
L["EMOTE_YES_DESCRIPTION"] = "Annuisci a <Target>."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- Every string from here to the end is the Spellbook's.

-- Page: Sections
L["SECTION_UNLEARNED"] = "Non appresi"

-- Page: Macro Menu
L["MENU_GROUP_COMBAT_CHECK"] = "Condizione di combattimento"
L["MENU_GROUP_SPELL_RANK"] = "Grado dell'incantesimo"
L["MENU_GROUP_BEFORE_CAST"] = "Prima del lancio"
L["MENU_GROUP_ADD_ATTACK"] = "Aggiungi attacco"
L["MENU_GROUP_CASTING_RULES"] = "Regole di lancio"
L["MENU_GROUP_ERRORS"] = "Messaggi di errore"
L["MENU_GROUP_USE_ITEMS_FIRST"] = "Usa prima gli oggetti"
L["MACRO_TEXT"] = "Testo della macro"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_OPTIONS_COUNT"] = "%d opzioni"
L["MENU_RANK_LEARN_LEVEL"] = "%s (Livello %d)"
L["MENU_MAX_RANK"] = "Grado massimo"
L["MENU_DYNAMIC_RANK"] = "Grado dinamico"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"Il grado dinamico, basato sul livello di un giocatore amico, si aggiorna solo fuori dal combattimento."
L["MENU_CAST_AT_CURSOR"] = "Lancia sul cursore"
L["MENU_TARGET_NEAREST_ENEMY"] = "Seleziona il nemico più vicino"
L["MENU_TARGET_NEAREST_FRIEND"] = "Seleziona l'alleato più vicino"
L["MENU_CAST_IF_SUMMONED"] = "Lancia %s se evocato"
L["MENU_NEVER_TURN_OFF"] = "Non disattivare mai"
L["MENU_LEAVE_FORM_BEFORE"] = "Esci dalla forma prima del lancio"
L["MENU_RIGHT_CLICK_FOR"] = "Clic destro per %s"
L["MENU_ONLY_IN_COMBAT"] = "Solo in combattimento"
L["MENU_NEVER_IN_COMBAT"] = "Mai in combattimento"
L["MENU_COMBAT_CHECK_NONE"] = "Nessuna"
L["MENU_ONCE_PER_COMBAT"] = "Lancia una volta per combattimento"
L["MENU_ONCE_PER_TARGET"] = "Lancia una volta per bersaglio"
L["MENU_HIDE_ERRORS"] = "Nascondi i messaggi di errore"
L["MENU_MUTE_ERRORS"] = "Silenzia i suoni di errore"
L["MENU_SWITCH_TO"] = "Passa a %s"
L["MENU_CAST_ON_FOCUS"] = "Lancia sul focus"
L["MENU_START_AUTO_ATTACK"] = "Avvia l'attacco automatico"
L["MENU_STOP_ATTACK"] = "Ferma l'attacco"
L["MENU_START_AUTO_SHOT"] = "Avvia il tiro automatico"
L["MENU_START_PET_ATTACK"] = "Avvia l'attacco del famiglio"
L["MENU_START_WAND"] = "Avvia la bacchetta"
L["MENU_STOP_CASTING"] = "Interrompi il lancio"
L["MENU_STOP_CASTING_NOTE"] =
	"Usa Interrompi il lancio per gli incantesimi che non possono aspettare, come interruzioni e dissoluzioni."
L["MENU_STOP_IF_CHANNELING"] = "Ferma la macro se canalizzi"
L["MENU_STOP_IF_STEALTHED"] = "Ferma la macro se sei furtivo"
L["MENU_SAFE_TO_SPAM_NOTE"] =
	"Per premere una macro a ripetizione senza rischi, attiva Ferma la macro se canalizzi per un incantesimo canalizzato, o Ferma la macro se sei furtivo per Furtività o Aggirarsi. Premerla di nuovo non interromperà più la canalizzazione o la tua furtività."
L["MENU_USE_FOR_KIND"] = "Usa queste opzioni per la categoria %s"
L["MENU_DUPLICATE"] = "Duplica"
L["MENU_USE_FOR_KIND_DESCRIPTION"] =
	"Ogni macro della categoria %s che non hai impostato tu parte con le opzioni di questa macro. Apre Predefiniti delle macro per mostrartelo."

-- Page: Settings Menu
L["SETTINGS_SHOW_UNLEARNED"] = "Mostra gli incantesimi non appresi"
L["SETTINGS_MARK_ALL_PLACED"] = "Segna tutti gli incantesimi come piazzati"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Nessuna macro di questa pagina si illumina più, che sia sulle tue barre o no. Un incantesimo che impari in seguito resta illuminato finché non lo piazzi."

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Sul focus"
L["SUBTEXT_PET"] = "Famiglio"
L["SUBTEXT_CURSOR"] = "Cursore"
L["SUBTEXT_STANCE"] = "Postura"
L["SUBTEXT_USE_ITEMS"] = "Usa oggetti"
L["SUBTEXT_PET_ATTACK"] = "Attacco famiglio"
L["SUBTEXT_DYNAMIC_RANK"] = "Grado din."
L["SUBTEXT_MAX_RANK"] = "Grado massimo"
L["SUBTEXT_TARGET_ENEMY"] = "Nemico vicino"
L["SUBTEXT_TARGET_FRIEND"] = "Alleato vicino"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1 per combatt."
L["SUBTEXT_ONCE_PER_TARGET"] = "1 per bersaglio"
L["SUBTEXT_COMBAT_ONLY"] = "Solo in combatt."
L["SUBTEXT_NO_COMBAT"] = "Fuori combatt."
L["SUBTEXT_LEAVE_FORM"] = "Esce da forma"
L["SUBTEXT_NO_TOGGLE"] = "Resta attivo"
L["SUBTEXT_WAND"] = "Bacchetta"
L["SUBTEXT_START_ATTACK"] = "Attacco auto"
L["SUBTEXT_STOP_ATTACK"] = "Ferma attacco"
L["SUBTEXT_STOP_CASTING"] = "Interrompe"
L["SUBTEXT_STOP_IF_CHANNELING"] = "Non se canalizzi"
L["SUBTEXT_STOP_IF_STEALTHED"] = "Non se furtivo"
L["SUBTEXT_HIDE_ERRORS"] = "Senza errori"
L["SUBTEXT_MUTE_ERRORS"] = "Errori muti"
L["SUBTEXT_OPTIONS_COUNT"] = "%d opzioni"
L["SUBTEXT_TOO_LONG"] = "Troppo lunga"
L["SUBTEXT_LEARN_LEVEL"] = "Livello %d"
L["SUBTEXT_TALENT"] = "Talento"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Non ancora appreso"
L["TOOLTIP_LEARN_LEVEL"] = "Il tuo istruttore di classe lo insegna al livello %d."
L["TOOLTIP_LEARN_TALENT"] = "Si impara dai tuoi talenti."
L["TOOLTIP_NOT_ON_BARS"] = "Non è sulle tue barre delle azioni"
L["TOOLTIP_TOO_LONG"] = "Troppo lunga: %d / %d byte. Disattiva un'opzione per accorciarla."
L["TOOLTIP_OPTIONS_ON"] = "Opzioni attive: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clic o trascina"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Piazza sulle tue barre delle azioni"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clic destro"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Opzioni della macro"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Gli incantesimi della tua classe come macro a un clic."
L["TOOLTIP_KEY_CLICK"] = "Clic"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Apri BBB Spellbook"

-- Page: Layout
L["PAGE_EMPTY"] = "Ancora nessuna macro. Visita il tuo istruttore di classe per imparare i tuoi primi incantesimi."
L["PAGE_MACRO_SLOTS"] = "Spazi per le macro"
L["TOOLTIP_MACRO_SLOTS"] =
	"Ogni macro che piazzi occupa uno spazio per le macro. Gli spazi del personaggio appartengono a questo personaggio e si riempiono per primi. Gli spazi generali sono condivisi da tutti i personaggi del tuo account."
L["PAGE_MACRO_GENERAL"] = "Generali"
L["PAGE_MACRO_CHARACTER"] = "Personaggio"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Assegnazione tasti"
L["OPTIONS_KEY_SET"] = "Assegna tasto"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Apre l'elenco di assegnazione tasti del gioco, dove Bags Buffs & Buttons ha una sezione tutta sua."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Apre e chiude BBB Spellbook. Ha anche una scheda tutta sua nel tuo libro degli incantesimi."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Elimina macro"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Elimina le macro create da BBB Spellbook, togliendole anche dalle tue barre delle azioni. Le tue macro non vengono mai toccate, e la pagina ricrea ognuna di esse quando la clicchi o la trascini."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Elimina macro del personaggio"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Elimina le macro di BBB Spellbook dalla scheda macro di questo personaggio. Gli altri tuoi personaggi tengono le loro finché non fai lo stesso su di loro."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"Eliminare tutte le macro di BBB Spellbook di questo personaggio? Vengono tolte anche dalle tue barre delle azioni."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Elimina macro generali"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Elimina le macro di BBB Spellbook dalla scheda Macro generali, condivisa da tutti i personaggi del tuo account, quindi anche gli altri tuoi personaggi perdono lì le loro."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"Eliminare tutte le macro generali di BBB Spellbook? Tutti i personaggi del tuo account le perdono, e vengono tolte anche dalle tue barre delle azioni."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Elenca gli incantesimi di classe che non hai ancora appreso in una sezione Non appresi, così puoi piazzare le loro macro in anticipo."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Piazza l'incantesimo dove punta il cursore, senza cerchio di selezione."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lancia il grado più alto che il livello del giocatore amico consente."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Interrompe prima ciò che stai lanciando, così questo incantesimo parte subito."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Ferma prima il tuo attacco automatico in mischia."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"Non fa nulla mentre canalizzi un incantesimo, così una pressione non interrompe mai la canalizzazione."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"Non fa nulla mentre sei furtivo, così una pressione non interrompe mai Furtività o Aggirarsi."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] =
	"Esce prima dalla tua forma attuale, così l'incantesimo può essere lanciato."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Seleziona prima il nemico più vicino quando non hai un nemico vivo come bersaglio."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Seleziona prima l'alleato più vicino quando non hai un alleato vivo come bersaglio."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Manda anche il tuo famiglio ad attaccare il tuo bersaglio."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Avvia il tuo attacco automatico in mischia dopo il lancio."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Avvia Tiro automatico o la tua bacchetta dopo il lancio."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lancia una volta, poi non più finché non cambia il tuo bersaglio."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lancia una volta, poi non più finché il combattimento non finisce o il tuo bersaglio non cambia."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Mantiene attivi la forma o l'aspetto quando premi di nuovo la macro, invece di disattivarli."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Cancella il testo di errore rosso che la macro lascia sullo schermo."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Silenzia il suono di errore mentre la macro è in esecuzione."
L["KIND_ENEMY"] = "Incantesimi sui nemici"
L["KIND_ENEMY_DESCRIPTION"] = "Incantesimi lanciati su un nemico, come attacchi e penalità."
L["KIND_FRIENDLY"] = "Incantesimi amichevoli"
L["KIND_FRIENDLY_DESCRIPTION"] = "Incantesimi lanciati su un alleato, come le cure."
L["KIND_BUFF"] = "Benefici"
L["KIND_BUFF_DESCRIPTION"] = "Incantesimi che danno a un alleato un beneficio duraturo."
L["KIND_ANYONE"] = "Incantesimi su alleati o nemici"
L["KIND_ANYONE_DESCRIPTION"] = "Incantesimi che puoi lanciare su un alleato o su un nemico."
L["KIND_GROUND"] = "Incantesimi a terra"
L["KIND_GROUND_DESCRIPTION"] = "Incantesimi che posizioni sul terreno."
L["KIND_FORM"] = "Forme, posture e aspetti"
L["KIND_FORM_DESCRIPTION"] = "Incantesimi che restano attivi finché non li spegni o ne scegli un altro."
L["KIND_SELF"] = "Incantesimi personali e ad area"
L["KIND_SELF_DESCRIPTION"] = "Incantesimi senza bersaglio, lanciati su di te o intorno a te."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Mostra/nascondi BBB Spellbook"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Per sicurezza, l'elenco di assegnazione tasti non può essere aperto durante il combattimento."
L["KEY_BINDINGS_LOCATION"] = "Apri il menu di gioco, poi %s, poi %s, e cerca la sezione Bags Buffs & Buttons."
L["ERROR_MACRO_SLOTS_FULL"] = "Nessuno spazio libero per le macro. Elimina una macro in /macro per fare spazio."
L["CHAT_MACROS_DELETED"] = "Macro eliminate: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'La macro "%s" è di %d byte con le sue opzioni attive, oltre i %d che una macro può contenere. Disattiva un\'opzione per accorciarla.'
