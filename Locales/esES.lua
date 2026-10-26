local L = LibStub("AceLocale-3.0"):NewLocale("Bags-Buffs-Buttons", "esES")
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
	"Versión %s. Los ajustes (incluida la opción de desactivar este mensaje) están en Opciones > Addons > Bags Buffs & Buttons. ¿Te gusta este addon? Cuéntaselo a un amigo, márcalo como favorito en CurseForge o pulsa Star en su página de GitHub. (="
L["OPTIONS_LEVEL_UP_TITLE"] = "Ayuda a Bags Buffs & Buttons a subir de nivel"
L["OPTIONS_LEVEL_UP_THANKS"] = "¡Gracias por elegir Bags Buffs & Buttons!"

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

L["MACRO_BANDAGE"] = "- Venda"
L["MACRO_EXPLOSIVES"] = "- Explosivos"
L["MACRO_FEED_PET"] = "- Alim. mascota"
L["MACRO_FOOD"] = "- Comida"
L["MACRO_HEALTH_POTION"] = "- Poc. Salud"
L["MACRO_HEALTHSTONE"] = "- Piedra"
L["MACRO_MANA_GEM"] = "- Gema de maná"
L["MACRO_MANA_POTION"] = "- Poc. Maná"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Piedra de alma"
L["MACRO_WATER"] = "- Agua"

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

L["DIET_BREAD"] = "Pan"
L["DIET_CHEESE"] = "Queso"
L["DIET_FISH"] = "Pescado"
L["DIET_FRUIT"] = "Fruta"
L["DIET_FUNGUS"] = "Hongo"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"¡Parece que has encontrado un error! %s (%s) no se puede usar en %s > %s (%s). Por favor, avísanos para que podamos corregirlo. ¡Gracias! %s"
L["MESSAGE_NO_ITEM"] = "No hay ningún objeto adecuado de tipo %s en tus bolsas."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"No se pudieron crear algunas macros de Connoisseur & Restocker porque tus espacios para macros están llenos. Libera un espacio borrando macros que ya no uses, o desactiva las macros de Connoisseur & Restocker que no necesites en Opciones > Addons > Connoisseur & Restocker > Macros."
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. %s is "/m", the game's own macro command, colored
    at the call site. "General" is the macro window's tab for account-wide
    macros; use the client's own name for that tab. The macro names are this
    locale's own MACRO_FOOD and MACRO_WATER values, written exactly as this
    locale ships them.
]]
L["MESSAGE_MACROS_READY"] =
	"Tus macros están listas. Escribe %s, abre la pestaña Macros generales y arrastra - Comida, - Agua y las demás a tus barras de acción."
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s ya está en la lista de ignorados de este personaje."
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "Se ha quitado 1 objeto de la lista de ignorados de este personaje."
L["MESSAGE_IGNORE_CLEARED_MANY"] = "Se han quitado %d objetos de la lista de ignorados de este personaje."

L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la interfaz de opciones no se puede abrir durante el combate."

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

L["READINESS_TITLE"] = "Informe de preparación"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Beneficios que faltan:"
L["READINESS_EXPIRING"] = "A punto de expirar:"
L["READINESS_MISSING_ITEMS"] = "Objetos que faltan:"
L["READINESS_DAMAGED_GEAR"] = "Equipo dañado:"
L["READINESS_CHARACTER"] = "Personaje:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate:"

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
L["READINESS_FLASK"] = "Frasco o 2x elixires"
L["READINESS_PET_FORMAT"] = "%s (mascota)"
L["READINESS_SCROLLS"] = "Pergaminos"
L["READINESS_SOULSTONE"] = "Piedra de alma inactiva"
L["READINESS_HEALTHSTONE"] = "Piedra de salud"
L["READINESS_MANA_GEM"] = "Gema de maná"
L["READINESS_HEALING_POTION"] = "Poción de curación"
L["READINESS_MANA_POTION"] = "Poción de maná"
L["READINESS_BANDAGES"] = "Vendas"
L["READINESS_PVP_ON"] = "JcJ activado"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s menos de 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto de talento sin gastar"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d puntos de talento sin gastar"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf, and TIP_EMPTY_* via ConnoisseurNoItem. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Actualmente no tienes ninguna comida útil para tu mascota."
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "Actualmente no conoces %s, %s, %s o %s."
L["TIP_PET_NO_MEND"] = "Actualmente no conoces Sanar mascota."
L["TIP_NO_HAND_POISON"] = "Te has quedado sin el veneno elegido para esta arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Actualmente no conoces %s."

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "No tienes %s en las bolsas. Haz clic derecho en %s para conjurar más."
L["TIP_EMPTY_CREATE"] = "No tienes %s en las bolsas. Haz clic derecho en %s para crear una."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "Comida con beneficio"
L["FEATURE_SCROLL_BUFFS"] = "Beneficios de pergaminos"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. The Readiness Report's block takes its title from
    READINESS_TITLE.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "Comida con beneficio y pergaminos"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'Usa comida que otorga "%s" y aplica los beneficios de pergaminos que te faltan antes de comer.'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "Comida actual"
L["MINIMAP_BEST_PET_FOOD"] = "Comida de mascota actual"
L["MINIMAP_MAIN_HAND_POISON"] = "Veneno de mano principal"
L["MINIMAP_OFF_HAND_POISON"] = "Veneno de mano secundaria"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista de ignorados"
L["MINIMAP_IGNORE_COUNT"] = "%d objetos"
L["MENU_IGNORE"] = "Ignorar"
L["MENU_CLEAR_IGNORE"] = "Borrar lista de ignorados"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Informe de Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d pedidos pendientes"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "¡Felicidades, lo tienes todo abastecido!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Tu lista está vacía."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista de Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra y guarda en el banco los objetos de tu lista."
L["MENU_RESTOCKER_KEYBIND"] = "Mayús + Clic derecho"
L["MENU_OPTIONS"] = "Opciones de BBB"
L["MENU_OPTIONS_KEYBIND"] = "Mayús + Clic central"

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
L["NOTE_MACRO_FEED_PET"] = "Macro de Alim. mascota"
L["NOTE_MACRO_FOOD_WATER"] = "Macros de Comida y Agua"
L["NOTE_MACRO_MANA_GEM"] = "Macro de Gema de maná"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro de Piedra"
L["NOTE_MACRO_SOULSTONE"] = "Macro de Piedra de alma"
L["NOTE_MACRO_POISONS"] = "Macro de Venenos"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Llamar, alimentar o revivir"
L["NOTE_PET_MEND_CLICK"] = "Clic derecho o en combate"
L["NOTE_HOLD_SHIFT"] = "Mantén Mayús"
L["NOTE_PET_FORCE_REVIVE"] = "Forzar revivir"
L["NOTE_HOLD_CONTROL"] = "Mantén Ctrl"
L["NOTE_PET_DISMISS"] = "Retirar"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Conjurar"
L["NOTE_CREATE"] = "Crear"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Otro clic derecho"
L["NOTE_LOWER_RANK_BACKUP"] = "Respaldo de rango inferior"
L["NOTE_MAGE_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para conjurar lo adecuado a su nivel."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para crear una adecuada a su nivel."

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "Ventana de Venenos"
L["NOTE_POISONS_REPLACED"] = "Reemplaza automáticamente los venenos anteriores."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Venda"
L["LABEL_EXPLOSIVE"] = "Explosivo"
L["LABEL_FOOD"] = "Comida"
L["LABEL_HEALTH_POTION"] = "Poción de salud"
L["LABEL_HEALTHSTONE"] = "Piedra de salud"
L["LABEL_MANA_GEM"] = "Gema de maná"
L["LABEL_MANA_POTION"] = "Poción de maná"
L["LABEL_PET_FOOD"] = "Comida de mascota"
L["LABEL_POISON"] = "Veneno"
L["LABEL_SOULSTONE"] = "Piedra de alma"
L["LABEL_WATER"] = "Agua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Activado"
L["MINIMAP_DISABLED"] = "Desactivado"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPEN"] = "Abrir"
L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_MIDDLE_CLICK"] = "Clic central"
L["MINIMAP_SHIFT_LEFT"] = "Mayús + Clic izquierdo"

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
	'Elige cuándo tu macro de Comida ofrece "%s": siempre, o únicamente en solitario, en grupo o banda, en banda, mientras subes de nivel o al nivel máximo.'
L["MODE_ALWAYS"] = "Siempre"
L["MODE_SOLO"] = "En solitario"
L["MODE_PARTY"] = "En grupo o banda"
L["MODE_RAID"] = "En banda"
L["MODE_LEVELING"] = "Subiendo de nivel"
L["MODE_MAX_LEVEL"] = "Al nivel máximo"

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
L["INVENTORY_REPORT_TITLE"] = "Informe de inventario"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "Bolsas %s, Banco %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "Bolsas %s"
L["INVENTORY_REPORT_BANK"] = "Banco %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "Total %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Muestra un mensaje de bienvenida en el chat al iniciar sesión."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Muestra el botón del minimapa."

-- Features: each feature's master switch, also on the panel that configures it.
-- Options: each add-on's heading page
L["OPTIONS_TFTB_DESCRIPTION"] =
	"Agradece automáticamente con un susurro o una emoción a cada jugador que te dé un beneficio, y que a tu banda, a ti y a tus armas nunca les falte un beneficio, con un recordatorio de los beneficios que faltan, que se lanzan con un clic. Además, avisos de festines, portales, invocaciones y pozos de almas. Buenos modales, en automático."
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"Macros al pasar el ratón, en el cursor y sobre ti para cada hechizo de clase, creadas con un clic desde una nueva pestaña del libro de hechizos, sin sintaxis de macros. Se actualizan al subir de nivel, entrenar o cambiar de especialización. Con clic derecho añades foco, detener lanzamiento, ataque automático, ataque de mascota o abalorios."

L["OPTIONS_MACROS_ENABLE"] = "Activar actualización de macros"
L["OPTIONS_MACROS_ENABLE_DESCRIPTION"] =
	"Mantiene tus macros de Connoisseur & Restocker apuntando a tus mejores objetos conforme cambian tus bolsas. Desactivado, cada macro se queda como estaba la última vez."
L["OPTIONS_RESTOCKER_ENABLE"] = "Activar Restocker"
L["OPTIONS_RESTOCKER_ENABLE_DESCRIPTION"] =
	"Compra y guarda en el banco según tu lista de reabastecimiento, y te avisa cuando te quedas corto. Desactivado, lo apaga todo, incluida la ventana de la lista de reabastecimiento."

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "Ejemplo: %s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/bbb"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este addon."
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre tu lista de reabastecimiento."

L["OPTIONS_LEVEL_UP_INTRO"] =
	"Este addon lo han creado jugadores que aman este juego y quieren que sea lo más divertido posible para todos. Nunca pediremos donaciones. La verdadera satisfacción es saber que nuestro trabajo hace que el juego sea un poco mejor para ti. Si es así, ¡nos encantaría saberlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Estas son algunas formas en que puedes ayudarnos a llegar a más jugadores."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Comparte tu opinión: ¿Has encontrado un error o tienes una idea? Dínoslo en Discord. Tus comentarios nos ayudan a mejorar el addon, y las pull requests siempre son bienvenidas."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Cuéntaselo a un amigo: ¿Conoces a alguien a quien le podría gustar este addon? Háblale de él. El boca a boca ayuda a que más jugadores descubran grandes addons."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Favorito en CurseForge: Abre el enlace de CurseForge de abajo, inicia sesión y haz clic en la estrella bajo el botón Download. Los favoritos ayudan a que más jugadores descubran el addon."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star en GitHub: Abre el enlace de GitHub de abajo, inicia sesión y haz clic en Star, arriba a la derecha. Las estrellas ayudan al proyecto a optar a más herramientas gratuitas para desarrolladores."

L["OPTIONS_FEEDBACK"] = "Comentarios y soporte"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Enlaces de comentarios y soporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Para copiar un enlace, haz clic en su casilla y pulsa Ctrl+A y Ctrl+C."
L["OPTIONS_VERSION"] = "Versión %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Macro Updates and
    Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur & Restocker crea una macro por consumible y la mantiene al día conforme cambian tus bolsas, de modo que el botón de tu barra siempre busca el mejor objeto que llevas encima. Elige abajo qué macros crear y luego ajusta cómo elige su objeto cada una."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Activar nombres de macro en los botones"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Muestra el nombre de la macro en los botones de tu barra de acción, un texto que Connoisseur & Restocker oculta por defecto."

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "Qué macros crear"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Elige qué macros crea y mantiene Connoisseur & Restocker. Al desactivar una, también se elimina. Están en la pestaña Macros generales de la ventana de macros, listas para arrastrarlas a tus barras de acción."
L["OPTIONS_OPEN_MACRO_WINDOW"] = "Abrir ventana de macros"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	"Abre la ventana de macros del juego en su pestaña Macros generales, donde están estas macros."
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea y mantiene esta macro, y la elimina al desmarcar la casilla."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Comida y agua"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Tus macros de Comida y Agua usan la mejor comida y bebida de tus bolsas. Estas opciones pueden poner primero la comida con beneficio, los pergaminos o la comida y el agua mágicas, y al final la comida y el agua de la lista de reabastecimiento."

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Priorizar comida con beneficio"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'Prioriza la comida que otorga el beneficio "%s" cuando te falta, excepto en las Arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Activar beneficios de pergaminos"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Tu macro de Comida aplica los pergaminos que faltan con la primera pulsación y come con la siguiente; omite los pergaminos si seleccionas a un jugador amistoso o estás en una Arena."
L["OPTIONS_SCROLL_TYPES"] = "Incluir tipos de pergaminos en la comprobación"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "Protección"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Incluye %s al comprobar los beneficios que faltan."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usar primero la comida y el agua mágicas"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Tus macros de Comida y Agua usan la comida y el agua mágicas antes que cualquier otra cosa, aunque algo de tus bolsas restaure más, ya que no cuestan nada y desaparecen poco después de cerrar sesión. La comida con beneficio sigue yendo primero mientras "Priorizar comida con beneficio" esté activado.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Elige cuándo la comida y el agua mágicas van primero: siempre, o únicamente en solitario, en grupo o banda, en banda, mientras subes de nivel o al nivel máximo."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Usar al final la comida y el agua de la lista de reabastecimiento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Entre dos comidas o bebidas que restauran la misma cantidad, tus macros de Comida y Agua usan la que no está en tu lista de reabastecimiento, y guardan para más tarde lo que tu lista compra."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Pociones y Piedras de salud"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Las macros no pueden cambiar durante el combate (es una restricción de Blizzard), por lo que cada macro de Poción y Piedra de salud se crea previamente con tu mejor objeto más hasta dos alternativas. En combates largos, el icono y la descripción pueden quedar obsoletos y mostrar un objeto equivocado, pero al hacer clic en la macro siempre se usará el mejor objeto que realmente tengas en tus bolsas."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usar comida y agua en las macros de Poción fuera de combate"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuera de combate, tu macro de Poción de salud come tu mejor comida y tu macro de Poción de maná bebe tu mejor agua. En combate, usan tus pociones como siempre. Los pergaminos, la comida de mascota y los hechizos de conjuración siguen en las macros de Comida y Agua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combinar Piedras de salud en la macro de Poción de salud"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Añade tu mejor Piedra de salud al final de la macro de Poción de salud, para que al presionar una vez se use una poción y una Piedra de salud."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemas de maná y runas"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s, %s y algunos otros objetos de maná comparten tiempo de reutilización con las Gemas de maná. Las runas cuestan salud al usarlas, así que la macro de Gema de maná los deja fuera a todos a menos que los añadas."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Añadir runas y otros objetos de maná a la macro de Gema de maná"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"Clasifica %s, %s y cualquier otro objeto de maná que comparta tiempo de reutilización con las Gemas de maná, junto a tus gemas, para que la macro de Gema de maná use uno de ellos cuando sea tu mejor opción o cuando te quedes sin gemas."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Renovación de beneficios"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Las macros no pueden cambiar durante el combate, así que si un beneficio expira en pleno combate, seguirás sin él hasta que el combate termine."
L["OPTIONS_REAPPLY"] = "Renovar beneficios a punto de expirar"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera expirados Comida con beneficio, Beneficios de pergaminos y Beneficios de comida de mascota cuando les quede menos tiempo que tu umbral, para que tus macros ofrezcan uno nuevo antes del combate."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto puede acercarse un beneficio a expirar antes de que tus macros ofrezcan uno nuevo."
L["REAPPLY_THRESHOLD_ONE"] = "Cuando quede < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Cuando queden < %d minutos"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Beneficios de comida de mascota"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = 'Algunas comidas dan a tu mascota su propio beneficio "%s".'
L["OPTIONS_USE_PET_BUFFS"] = "Usar beneficios de comida de mascota"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'Añade comida de mascota a tu macro de Comida cuando a tu mascota le falta el beneficio "%s", excepto en las Arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Incluir tipos de comida de mascota en la comprobación"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosivos"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"La opción @player omite la retícula de selección y detona el explosivo justo a tus pies. Ideal cuando tu objetivo está a distancia cuerpo a cuerpo. Tu otro clic lanza el explosivo como siempre."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Asignación de clics"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] = "Elige qué clic lanza el explosivo y cuál lo detona a tus pies."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic izquierdo @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic izquierdo Lanzar"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "Clase y raza"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"Estas opciones ajustan tus macros para una clase o raza concreta. Todas las secciones se muestran en todos los personajes."

-- The class and race sections' headers; %s is the client's name for the class or race, or OPTIONS_FORSAKEN_HEADER.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "Opciones de clase: %s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "Opciones raciales: %s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"Necesita el addon DruidMacroHelper. Si está activado, tus macros de Poción de salud, Poción de maná y Piedra de salud te sacan de la forma, usan el objeto y te devuelven a Forma de oso o Forma felina, la que elijas junto a la casilla."
L["OPTIONS_DRUID_MACRO_HELPER"] = "Activar integración con DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macros de cambio de forma para pociones de salud, pociones de maná y piedras de salud usando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Elige la forma a la que te devuelven tus macros de cambio de forma después de usar el objeto."
L["DRUID_FORM_BEAR"] = "Volver a Oso"
L["DRUID_FORM_CAT"] = "Volver a Gato"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro de Venenos cargada con el mejor rango utilizable de cada tipo de veneno: clic izquierdo aplica a tu mano secundaria, clic derecho a tu mano principal, y los venenos existentes se reemplazan automáticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo de veneno de mano principal"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo de veneno de mano secundaria"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano principal con clic derecho."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano secundaria con clic izquierdo."
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "Activar sigilo al comer"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "Añade %s a tu macro de Comida para entrar en sigilo mientras comes."

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "Activar sigilo al beber"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "Añade %s a tu macro de Agua para entrar en sigilo mientras bebes."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Consejo experto: Elige uno. Puedes comer y beber a la vez, pero comer o beber después de entrar en sigilo lo romperá."

--[[
    Forsaken. Headed with our own word, the race's lore name, since the client
    names it Undead; in the five texts after the header, %s is the client's
    name for Cannibalize. Drinking shows only where Cannibalize restores mana.
]]
L["OPTIONS_FORSAKEN_HEADER"] = "Renegados"
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"Selecciona como objetivo a un humanoide o no-muerto que hayas matado y tu macro lanzará %s mientras el hechizo esté listo, ahorrando tu comida y bebida. Si no puede (el cadáver está fuera de alcance o el hechizo está en reutilización), come o bebe como siempre."
L["OPTIONS_CANNIBALIZE_EATING"] = "Usar %s en lugar de comer"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"Mientras tu objetivo sea un cadáver en el que funcione %s y el hechizo esté listo, tu macro de Comida lo lanza en lugar de comer. Si no, come como siempre. Los pergaminos y la comida con beneficio siguen teniendo prioridad."
L["OPTIONS_CANNIBALIZE_DRINKING"] = "Usar %s en lugar de beber"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"Mientras tu objetivo sea un cadáver en el que funcione %s y el hechizo esté listo, tu macro de Agua lo lanza en lugar de beber. Si no, bebe como siempre. Las bebidas con beneficio siguen teniendo prioridad."

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
L["TAB_IGNORE_LIST"] = "Lista de ignorados"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ninguna macro elige nunca los objetos ignorados. Comida, agua, pociones, lo que sea. La lista Global se aplica a todos los personajes; la de un personaje, solo a ese. Haz clic derecho en el botón del minimapa para ignorar tu mejor comida actual."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Mueve este objeto a la lista Global, para que se ignore en todos los personajes."
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "Añadir desde las bolsas"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"Elige cualquier cosa que lleves. Las bolsas se cierran al abrir la interfaz de opciones, así que esto sustituye a arrastrar un objeto hasta aquí."
L["OPTIONS_IGNORE_ADD_ID"] = "Añadir por ID de objeto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat mientras este campo está activo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat."
L["OPTIONS_IGNORE_REMOVE"] = "Quitar"
L["OPTIONS_IGNORE_EMPTY"] = "Esta lista está vacía."
L["OPTIONS_IGNORE_CLEAR"] = "Vaciar lista"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"Quita todos los objetos de esta lista. Un personaje con la lista vacía desaparece de la lista de la izquierda, salvo que sea el que estás jugando."
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "¿Quitar todos los objetos de esta lista? No se puede deshacer."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Cargando ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene tus bolsas abastecidas según tu lista de reabastecimiento, comprando a los mercaderes y moviendo objetos desde y hacia el banco automáticamente. Escribe %s para abrir la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Abrir en el banco"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar el banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir con el mercader"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar a un mercader."
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Recordatorios"
L["OPTIONS_RESTOCKER_REMIND"] = "Activar recordatorios de reabastecimiento en la ciudad"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Muestra un recordatorio en el chat cuando a tu lista de reabastecimiento le falta algo y llegas a una posada o una ciudad, o ya estás en una al iniciar sesión."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activar recordatorios de reabastecimiento en el mercader"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar la ventana de un mercader."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activar recordatorios de reabastecimiento en el banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar el banco."

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Activar reserva de oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "El reabastecimiento nunca gasta el oro que apartes aquí."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Establece cuánto oro te deja siempre el reabastecimiento."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Elige si el recordatorio es una sola línea o añade una línea por cada objeto que te falta."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Detallado"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Reproducir sonido"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Reproduce un aviso junto al recordatorio, para cuando el chat está muy movido."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Haz clic para oír el aviso."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Ventana de la lista de reabastecimiento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Elige cuándo se abre sola tu lista de reabastecimiento."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Muestra en la descripción de un objeto cuántas unidades tienes entre todos tus personajes de este reino."
L["OPTIONS_INVENTORY_REPORT"] = "Activar el informe de inventario en las descripciones de objetos"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Añade a la descripción de un objeto cuántas unidades tienes en tus bolsas, en tu banco y en tus otros personajes. Desactívalo si otro addon ya muestra estos recuentos."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Agradecimientos"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Siempre me ha encantado Restocker, y agradezco la oportunidad de que siga vivo dentro de Connoisseur & Restocker. Muchísimas gracias a ChiliFajita, que escribió el Auto Restocker original, y a kvakvs y guardycmw, que lo mantuvieron con vida a lo largo de Classic y Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Informe de preparación"
L["OPTIONS_READINESS_ENABLE"] = "Activar el informe de preparación al comprobar quiénes están listos"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] =
	"Activa el informe de preparación para todos los personajes de esta cuenta."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Cuando empieza una comprobación de quiénes están listos, muestra una lista privada de lo que aún falta por arreglar, y no dice nada en absoluto si estás preparado."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Restablecer ajustes del informe de preparación"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Restablece a sus valores por defecto todas las casillas y ambos umbrales de esta página."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"¿Restablecer todos los ajustes del informe de preparación a sus valores por defecto? Esto también vuelve a desactivar el propio informe."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Beneficios que faltan"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Objetos que faltan"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaje"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Avisa si te falta un frasco. Un frasco, o un elixir de batalla y un elixir guardián, cuenta como cubierto."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] =
	'Avisa si te falta el beneficio "%s". Requiere activar Comida con beneficio en Macros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION_FORMAT"] =
	'Avisa si a tu mascota le falta el beneficio "%s". Requiere activar Beneficios de comida de mascota en Macros, y tener una mascota invocada.'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Avisa si te faltan beneficios de pergaminos. Requiere activar Beneficios de pergaminos en Macros, y solo comprueba los tipos de pergamino seleccionados allí."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Avisa cuando nadie de tu grupo tiene una Piedra de alma activa; una guardada en una bolsa no cuenta. Solo avisa a los brujos que pueden crearla."
L["OPTIONS_READINESS_MAIN_HAND"] = "Beneficio de arma (mano principal)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano principal no tiene un encantamiento temporal. Cuenta cualquier encantamiento, y guarda silencio cuando hay un chamán en tu grupo."
L["OPTIONS_READINESS_OFF_HAND"] = "Beneficio de arma (mano secundaria)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano secundaria no tiene un encantamiento temporal. Cuenta cualquier encantamiento: una piedra, un aceite, un veneno o un beneficio de arma de chamán."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Beneficios que expiran en menos de"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Nombra todos los beneficios que tienes a punto de expirar, no solo los que aplica Connoisseur & Restocker, y es independiente de Renovación de beneficios en Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutos"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe acercarse un beneficio a expirar para que el informe lo nombre."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Piedra de salud. Solo avisa cuando hay un brujo en tu grupo al que pedirla, o cuando el brujo eres tú."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Gema de maná. Solo avisa a los magos que pueden conjurarla."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de curación, ya que nadie puede darte una en plena pelea."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de maná. Solo avisa cuando juegas con una clase que usa maná."
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna venda que tu habilidad de %s te permita usar."
L["OPTIONS_READINESS_DURABILITY"] = "Equipo dañado por debajo de"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Enlaza cada objeto equipado por debajo de esta durabilidad, medida por objeto para que un arma rota siga apareciendo."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe bajar la durabilidad de un objeto para que el informe lo enlace."

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "Especialización actual"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "Muestra tu reparto de talentos y los puntos que no hayas gastado."
L["OPTIONS_READINESS_PVP"] = "Marca JcJ activada"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avisa cuando tu marca JcJ está activa."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"Enlaza los objetos equipados que no tienen cabida en un combate, como el equipo de montar o de pesca."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Ya existe una lista llamada "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "El ID %d no existe."
L["RESTOCKER_BANK_NOT_OPEN"] = "El banco no está abierto."
L["RESTOCKER_DISABLED"] = "El Restocker está desactivado. Actívalo en Opciones > Addons > Connoisseur & Restocker."
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Reabastecimiento completado. Mantén Mayús al abrir el banco para omitir el reabastecimiento. Escribe %s para editar tu lista de reabastecimiento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Reabastecimiento detenido. Tus bolsas y tu banco están llenos."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Reabastecimiento detenido. Tu banco está lleno; libera un espacio y vuelve a abrirlo."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Reabastecimiento detenido. Tus bolsas están llenas; libera un espacio y vuelve a abrir el banco."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Reabastecimiento detenido. No se pudo avanzar."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Reabastecimiento detenido. No se pudo mover: %s."
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (sobrante)"
L["RESTOCKER_STOPPED_ERROR"] = "Reabastecimiento detenido por un error: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Este mercader no tiene todos los ingredientes que necesitan tus venenos. No se comprará ninguno."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "¡No olvides reabastecerte ahora que estás en la ciudad!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 pedido de reabastecimiento pendiente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d pedidos de reabastecimiento pendientes."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Tu lista de reabastecimiento se ha mejorado."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d pasa a %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 pedido de reabastecimiento completado."
L["RESTOCKER_RESTOCKED_MANY"] = "%d pedidos de reabastecimiento completados."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 pedido de reabastecimiento completado en parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d pedidos de reabastecimiento completados en parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Tus bolsas se han llenado antes de poder comprarlo todo."
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "No tienes oro suficiente para terminar el reabastecimiento."
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Se ha dejado de comprar al llegar a tu reserva de oro (%s). Lo que falta se comprará en tu próxima visita, cuando te sobre oro."

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nombre]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Añade una lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renombra la lista actual a ese nombre."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Reemplaza la lista actual por una copia de la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_USE"] = "Hace que este personaje use la lista con ese nombre."

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
L["STARTER_POPUP_TITLE"] = "Básicos"
L["STARTER_POPUP_INTRO_LOGIN"] = "Hemos marcado algunos básicos de tu clase para que empieces."
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Tu lista de reabastecimiento está vacía, así que vamos a añadir algunos objetos para empezar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Elige los básicos que quieres mantener abastecidos."
L["STARTER_POPUP_INTRO_HOW"] =
	"Todo lo que marques se reabastece automáticamente cada vez que visitas a un mercader o tu banco. La mayoría de los básicos se mejoran solos según subes de nivel, así que siempre tendrás lo mejor disponible."
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Siempre puedes ajustar esta lista, o añadir más objetos más adelante, escribiendo %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Comida y agua"
L["STARTER_POPUP_FOOD_HEADER"] = "Comida"
L["STARTER_POPUP_AMMO_HEADER"] = "Munición"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Balas"
L["STARTER_POPUP_ARROWS"] = "Flechas"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Componentes y herramientas"
L["STARTER_POPUP_POISONS_HEADER"] = "Venenos"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Añade el veneno terminado a tu lista y Connoisseur & Restocker comprará los ingredientes automáticamente en cualquier mercader que los venda todos."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Añade %s a tu lista de reabastecimiento, manteniendo %d en tus bolsas y mejorándolos según subes de nivel."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Añade %s a tu lista de reabastecimiento y mantiene %d en tus bolsas."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 montón"
L["STARTER_POPUP_STACK_MANY"] = "%d montones"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Cuántos montones mantener abastecidos, a razón de %d por montón."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Cuántos mantener abastecidos, cada uno en su propio espacio de la bolsa, ya que no se apilan."

--[[
    Restock List window UI. The title names what the window holds, after the
    add-on's full name (ADDON_TITLE // RESTOCKER_WINDOW_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "Lista de reabastecimiento"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Borrar"
L["RESTOCKER_ADD_BUTTON"] = "Añadir"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "Elegir básicos"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"Elige entre los básicos de tu clase y nivel: comida, agua, munición, venenos y componentes. Al marcar uno se añade a esta lista, y al desmarcarlo se quita."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Añadir un objeto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Suelta un objeto de tus bolsas aquí o en cualquier parte de esta ventana, o escribe un ID de objeto y pulsa Intro."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Suelta objeto o escribe ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Escribe el ID del objeto."
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "Ya está en esta lista."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Añadir desde tus bolsas"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Todos los objetos de tus bolsas que aún no están en esta lista. Haz clic en uno para añadirlo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nada en tus bolsas que añadir"

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
	"Haz clic para que este personaje use otra lista de reabastecimiento, o para empezar una nueva."
L["RESTOCKER_USED_BY"] = "Usada por %s"
L["RESTOCKER_MANAGE"] = "Gestionar listas"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Empieza una lista nueva, o copia, renombra o elimina esta."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "Lista nueva"
L["RESTOCKER_MANAGE_COPY"] = "Copiar esta lista en una nueva"
L["RESTOCKER_RENAME_PROFILE"] = "Renombrar esta lista"
L["RESTOCKER_MANAGE_DELETE"] = "Eliminar esta lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - copia"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renombrar"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renombra esta lista para todos los personajes que la usan."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "¿Seguro que quieres eliminar esta lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s también la usa y, al iniciar sesión, encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s también la usan y, al iniciar sesión, cada uno encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Pasarás a usar %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es la única lista que queda, así que empezarás con una nueva y vacía."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Esto no se puede deshacer."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mejorar al subir de nivel"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permite que Connoisseur & Restocker mejore la comida, el agua, la munición, los venenos, las pociones y los componentes de clase a objetos mejores según subes de nivel."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banco"
L["RESTOCKER_ROW_MERCHANT"] = "Mercader"
L["RESTOCKER_ROW_UPGRADE"] = "Mejora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Objeto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Sacar"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Guardar"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Mantener"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Haz clic en el encabezado para ajustarlo en todos los objetos mostrados."
L["RESTOCKER_BULK_ON"] = "Activar en los mostrados (%d)"
L["RESTOCKER_BULK_OFF"] = "Desactivar en los mostrados (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Otros"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuevos"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Todos los objetos"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Aún no hay nada en esta lista"
L["RESTOCKER_EMPTY_BODY"] =
	"Elige básicos como comida, agua o componentes de clase, o añade cualquier cosa de tus bolsas con el menú de arriba. Los objetos de esta lista se mantienen abastecidos o se guardan en tu banco automáticamente, para que tus bolsas queden despejadas."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Soltar un objeto en cualquier parte de esta ventana también lo añade."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nada de esta lista coincide con tu filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "No queda nada en esta categoría."

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
L["RESTOCKER_NO_ORDERS"] = "No hay pedidos de reabastecimiento pendientes."
L["RESTOCKER_REPORT_MORE"] = "y %d más"
L["RESTOCKER_REMOVED_ITEM"] = "Se ha quitado %s."
L["RESTOCKER_UNDO"] = "Deshacer"
L["RESTOCKER_UNDO_TOOLTIP"] = "Devolver este objeto a la lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Quitar este objeto de la lista de reabastecimiento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puedes deshacerlo desde la parte inferior de la ventana."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Mantener en tus bolsas"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Cuántos mantener en tus bolsas. El número se muestra en amarillo mientras tus bolsas tengan menos, y 0 con Guardar activado lo envía todo al banco."
L["RESTOCKER_BUY_LABEL"] = "Comprar"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Comprar al mercader"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra al mercader la cantidad necesaria cuando la ventana del mercader está abierta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Comprar de más"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra todas las existencias limitadas que un mercader tenga de este objeto, esos pocos artículos que repone lentamente, incluso por encima de tu cifra de Mantener."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar en el banco"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda en el banco los objetos sobrantes cuando el banco está abierto, o todos ellos si pones 0 en la columna Mantener."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Sacar del banco"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Saca del banco los objetos necesarios cuando el banco está abierto."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputación requerida"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de descuento)"
L["RESTOCKER_REPUTATION_ANY"] = "Cualquiera"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputación requerida con el mercader"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"Haz clic para elegir la reputación necesaria con un mercader antes de que Connoisseur & Restocker le compre, lo que además rebaja el precio: %s 5%%, %s 10%%, %s 15%%, %s 20%%. Con un guion, compra a cualquier mercader."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no hay nada extra que comprar."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no se aplica ninguna reputación."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Este objeto no tiene ninguna versión superior a la que mejorar."

--------------------------------------------------------------------------------
-- Thanks for the Buff
--------------------------------------------------------------------------------

-- Every string from here to Spellbook is Thanks for the Buff's.

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "¡%s te ha beneficiado con %s!"
L["MESSAGE_GAVE_YOU"] = "¡%s te ha dado %s!"
L["MESSAGE_GAVE_GROUP"] = "¡%s le ha dado %s a tu grupo!"
L["MESSAGE_USED_ITEM"] = "¡%s ha usado %s en ti!"
L["MESSAGE_USED_SPELL"] = "¡%s ha lanzado %s sobre ti!"
L["MESSAGE_SET_OUT"] = "¡%s ha colocado %s!"
L["MESSAGE_OPENED"] = "¡%s ha abierto %s!"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "Gracias por %s"
L["MESSAGE_SELECT_PLAYER"] = "Primero selecciona a un jugador como objetivo."
L["MESSAGE_CANT_THANK_SELF"] = "¡No puedes agradecerte a ti mismo!"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "Hechizo desconocido"

--------------------------------------------------------------------------------
-- Options: Main Panel
--------------------------------------------------------------------------------

L["OPTIONS_EXAMPLE"] = "Ejemplo: %s"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "Beneficios de desconocidos"
L["STRANGERS_ENABLE"] = "Habilitar agradecimientos por beneficios de desconocidos"
L["STRANGERS_ENABLE_DESCRIPTION"] = "Activa los agradecimientos por beneficios de jugadores de fuera de tu grupo."
L["STRANGERS_DESCRIPTION"] = "Agradece a los jugadores de fuera de tu grupo cuando te benefician en el mundo abierto."
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "Reutilización de elogios"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"Establece el tiempo de espera entre una ronda de elogios y la siguiente, sin importar quién te haya dado el beneficio. Ponlo a cero para elogiar todos los beneficios."
L["STRANGERS_SOURCE_COOLDOWN"] = "Reutilización de elogios al mismo jugador"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"Establece el tiempo de espera entre elogios dirigidos al mismo jugador. Ponlo a cero para elogiar todos los beneficios."
L["STRANGERS_MIN_DURATION"] = "Duración mínima del beneficio"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"Ignora los beneficios que duran menos que este valor. Ponlo a cero para reaccionar a todos los beneficios."

-- Teammate Buffs
L["TAB_TEAMMATES"] = "Beneficios de compañeros"
L["TEAMMATES_ENABLE"] = "Habilitar agradecimientos por beneficios de compañeros"
L["TEAMMATES_ENABLE_DESCRIPTION"] =
	"Activa los agradecimientos por los beneficios y habilidades con reutilización que los miembros de tu grupo o banda lanzan sobre ti."
L["TEAMMATES_DESCRIPTION"] =
	"Agradece a los miembros de tu grupo o banda los beneficios y habilidades con reutilización que lanzan sobre ti."

-- Service Alerts
L["TAB_SERVICES"] = "Avisos de servicios"
L["SERVICES_ENABLE"] = "Habilitar avisos de servicios"
L["SERVICES_ENABLE_DESCRIPTION"] =
	"Activa los avisos de festines, pozos de almas, portales y otras ayudas que se colocan para tu grupo."
L["SERVICES_DESCRIPTION"] =
	"Reacciona cuando alguien pone ayuda a disposición de tu grupo: festines, pozos de almas, portales y robots de reparación."

-- Send Good News
L["TAB_GOOD_NEWS"] = "Enviar buenas noticias"
L["GOOD_NEWS_DESCRIPTION"] =
	"Informa a los jugadores que beneficias de lo que les has lanzado y, en los beneficios cortos, de cuánto dura."
L["GOOD_NEWS_ENABLE"] = "Habilitar buenas noticias"
L["GOOD_NEWS_ENABLE_DESCRIPTION"] =
	"Activa un susurro que indica a los jugadores que beneficias lo que les has lanzado."
L["GOOD_NEWS_SCOPE"] = "Destinatarios"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "Cualquiera al que beneficies"
L["GOOD_NEWS_SCOPE_GROUP"] = "Solo miembros del grupo"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"Establece quién recibe un susurro de buenas noticias: cualquiera al que beneficies o solo los miembros de tu grupo."
L["GOOD_NEWS_MESSAGES_HEADER"] = "Mensaje de buenas noticias"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "El susurro que reciben los jugadores a los que beneficias."
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] =
	"Establece lo que dice el susurro. Déjalo vacío para usar el texto predeterminado."
L["GOOD_NEWS_MESSAGE_LIMIT"] = "Longitud máxima: %d."
L["GOOD_NEWS_MESSAGE_TOKENS"] =
	"%a se convierte en el enlace de la habilidad, junto con su duración si es inferior a un minuto."
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "durante %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "Habilidades rastreadas"
L["TRACKED_GROUP_ITEMS"] = "Objetos"
L["TRACKED_ITEM_PENDING"] = "Objeto #%d"
L["TRACKED_SPELL_PENDING"] = "Hechizo #%d"

-- Shared by Send Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "Mensaje de susurro"
L["WHISPER_MESSAGE_RESET"] = "Restablecer"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "Restablece el mensaje de susurro al texto predeterminado."

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "Susurros de agradecimiento y emociones"
L["NOTIFICATIONS_HEADER"] = "Notificaciones"
L["PRAISE_DESCRIPTION"] = "Lo que ve el otro jugador: un susurro de agradecimiento, una emoción o ambos."
L["NOTIFICATIONS_DESCRIPTION"] = "Lo que solo recibes tú: un aviso de texto, un sonido o ambos."

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "Seleccionar emociones"

L["PRAISE_WHISPER_ENABLE"] = "Habilitar susurros de agradecimiento"
L["PRAISE_WHISPER_DESCRIPTION"] = "Susurra un agradecimiento al jugador que te ha dado el beneficio."
L["PRAISE_EMOTES_ENABLE"] = "Habilitar emociones"
L["PRAISE_EMOTES_DESCRIPTION"] =
	"Muestra tu agradecimiento con una emoción. Las emociones se retienen mientras estás en combate."
L["PRAISE_DELAY_ENABLE"] = "Habilitar retraso del elogio"
L["PRAISE_DELAY_DESCRIPTION"] =
	"Espera un momento antes del susurro y la emoción, para que tu agradecimiento no llegue en el mismo instante que el beneficio. Las notificaciones no se ven afectadas."
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "Establece cuánto se espera antes de enviar el susurro y la emoción."

L["NOTIFICATIONS_PRINT_ENABLE"] = "Habilitar avisos de texto"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "Muestra un mensaje que solo tú puedes ver cuando recibes un beneficio."
L["NOTIFICATIONS_SOUND_ENABLE"] = "Habilitar efectos de sonido"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "Reproduce un sonido cuando recibes un beneficio. Solo tú lo oyes."
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "Reproduce el sonido para que puedas oírlo antes de activarlo."

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "Portales"
L["GROUP_RESISTANCE_CAULDRONS"] = "Calderos de resistencia"
L["GROUP_REPAIR_BOTS"] = "Robots de reparación"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_WINDOW"] = "Turno de beneficios"
L["BUFF_WINDOW_DESCRIPTION"] = "Muestra a quién le faltan tus beneficios. Haz clic en un icono para lanzarlo."
L["BUFF_WINDOW_ENABLE"] = "Habilitar turno de beneficios"
L["BUFF_WINDOW_ENABLE_DESCRIPTION"] =
	"Activa el turno de beneficios, la ventana de miembros del grupo a los que les falta un beneficio que puedes dar."
L["BUFF_WINDOW_NO_BUFFS"] =
	"Tu clase no tiene beneficios en esta lista, así que la ventana nunca aparece con este personaje."
-- When to Show: Solo and In Group, each with Always or In Instance, then the classes.
L["BUFF_WINDOW_WHEN_HEADER"] = "Cuándo mostrar"
L["BUFF_WINDOW_WHEN_DESCRIPTION"] = "Elige cuándo puede aparecer la ventana."
L["BUFF_WINDOW_WHEN_SOLO"] = "En solitario"
L["BUFF_WINDOW_WHEN_SOLO_DESCRIPTION"] = "Muestra la ventana cuando no estás en un grupo o banda."
L["BUFF_WINDOW_WHEN_GROUP"] = "En grupo"
L["BUFF_WINDOW_WHEN_GROUP_DESCRIPTION"] = "Muestra la ventana cuando estás en un grupo o banda."
L["BUFF_WINDOW_WHERE_DESCRIPTION"] =
	"Define dónde se muestra la ventana: en todas partes, o solo en mazmorras, bandas, campos de batalla y arenas."
L["BUFF_WINDOW_WHERE_ALWAYS"] = "Siempre"
L["BUFF_WINDOW_WHERE_INSTANCE"] = "En instancia"
L["BUFF_WINDOW_CLASSES_DESCRIPTION"] = "Muestra la ventana cuando juegas estas clases."
L["BUFF_WINDOW_CLASS_DESCRIPTION"] = "Muestra la ventana cuando juegas esta clase."
L["BUFF_WINDOW_HEADER"] = "Ventana"
L["BUFF_WINDOW_WINDOW_DESCRIPTION"] = "Mantén la ventana donde la dejaste, o apártala durante el combate."
L["BUFF_WINDOW_LOCK"] = "Bloquear ventana"
L["BUFF_WINDOW_LOCK_DESCRIPTION"] = "Impide que la ventana se mueva. Desbloqueada, arrástrala desde el fondo."
L["BUFF_WINDOW_HIDE_IN_COMBAT"] = "Ocultar en combate"
L["BUFF_WINDOW_HIDE_IN_COMBAT_DESCRIPTION"] =
	"Oculta la ventana durante el combate. La lista no se puede actualizar en combate, así que si dejas la ventana visible, conserva su último estado hasta que termine el combate."
L["BUFF_WINDOW_SHOW_HEADER"] = "Mostrar en la ventana"
L["BUFF_WINDOW_SHOW_DESCRIPTION"] =
	"Añade a la ventana tus propios beneficios, los desconocidos que te han beneficiado y tu objetivo."
L["BUFF_WINDOW_FAVOR_ENABLE"] = "Devolver el favor"
L["BUFF_WINDOW_FAVOR_ENABLE_DESCRIPTION"] =
	"Muestra a los desconocidos que te han beneficiado hace poco, con los beneficios que puedes devolverles. Haz clic derecho en un icono para quitar a alguien de la lista."
L["BUFF_WINDOW_FAVOR_SECONDS_DESCRIPTION"] =
	"Establece cuánto tiempo permanece un desconocido en la lista tras su último beneficio."
L["BUFF_WINDOW_TARGET_ENABLE"] = "Tu objetivo"
L["BUFF_WINDOW_TARGET_ENABLE_DESCRIPTION"] =
	"Muestra a tu objetivo cuando es un jugador de fuera de tu grupo al que le falta un beneficio que puedes dar."
L["BUFF_WINDOW_REFRESH"] = "Renovar con menos de"
L["BUFF_WINDOW_REFRESH_DESCRIPTION"] =
	"Establece con cuánto tiempo restante un beneficio pasa a contar como ausente, para que puedas renovarlo antes de que expire. Un beneficio que no dura más que esto solo cuenta cuando ya ha desaparecido."
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_WINDOW_TANKS_HEADER"] = "Contar como tanques"
L["BUFF_WINDOW_TANKS_DESCRIPTION"] =
	"Quién recibe los beneficios que ofreces a Tanques, como Espinas, cuando no tiene un rol propio."
L["BUFF_WINDOW_TANKS_CLASS_DESCRIPTION"] =
	"Establece cuándo los jugadores de esta clase cuentan como tanques. Un rol de tanque o sanador que tengan siempre tiene prioridad."
L["BUFF_WINDOW_TANKS_PETS"] = "Mascotas"
L["BUFF_WINDOW_TANKS_PETS_DESCRIPTION"] =
	"Establece cuándo las mascotas cuentan como tanques. Las mascotas también reciben los beneficios que ofreces a Todos."
L["BUFF_WINDOW_TANKS_NEVER"] = "Nunca"
L["BUFF_WINDOW_TANKS_SOLO"] = "Cuando no estás en un grupo"
L["BUFF_WINDOW_TANKS_ALWAYS"] = "Siempre"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_WINDOW_AUDIENCE_OFF"] = "Desactivado"
L["BUFF_WINDOW_AUDIENCE_TANK"] = "Tanques"
L["BUFF_WINDOW_AUDIENCE_HEALER"] = "Sanadores"
L["BUFF_WINDOW_AUDIENCE_ALL"] = "Todos"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_WINDOW_AUDIENCE_DESCRIPTION"] = "Establece a quién se le ofrece %s."
L["BUFF_WINDOW_BUFFS_DESCRIPTION"] =
	"Elige a quién se ofrece cada beneficio. Tanques y Sanadores se asignan por rol de grupo; quien no tenga ninguno cuenta como Daño, salvo que Contar como tanques, más abajo, indique otra cosa."

L["BUFF_WINDOW_SELF_DESCRIPTION"] = "Tus propios beneficios, fijados en la parte superior de la ventana."
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_WINDOW_SELF_NOTE_ASPECT"] = "cualquier aspecto cuenta"
L["BUFF_WINDOW_SELF_NOTE_MAGE_ARMOR"] = "cualquier armadura cuenta"
L["BUFF_WINDOW_SELF_NOTE_PALADIN_AURA"] = "cualquier aura cuenta"
L["BUFF_WINDOW_SELF_NOTE_SHAMAN_SHIELD"] = "cualquier escudo cuenta"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_ARMOR"] = "cualquier armadura cuenta"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_DEMON"] = "cualquiera de los dos beneficios de demonio cuenta"
L["BUFF_WINDOW_SELF_REFRESH_OFF"] = "Desactivado"
L["BUFF_WINDOW_SELF_REFRESH_MISSING"] = "Si falta"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_WINDOW_SELF_REFRESH_UNDER"] = "Menos de %s"
L["BUFF_WINDOW_SELF_REFRESH_DESCRIPTION"] =
	"Establece cuándo aparece %s: nunca, cuando ya no está activo o cuando le queda menos de este tiempo."
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_WINDOW_WEAPON_PANEL_HEADER"] = "Beneficios de arma"
L["BUFF_WINDOW_WEAPON_DESCRIPTION"] =
	"Marca lo que debe llevar cada arma. La ventana lo ofrece cuando falta o está por agotarse, si lo tienes en las bolsas y es apto para el arma."
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_WINDOW_WEAPON_REFRESH"] = "Reaplicar"
L["BUFF_WINDOW_WEAPON_REFRESH_DESCRIPTION"] =
	"Establece cuándo se vuelve a ofrecer un beneficio de arma: cuando ya no está activo o cuando le queda menos de este tiempo."
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_WINDOW_WEAPON_KIND_OIL"] = "Aceites"
L["BUFF_WINDOW_WEAPON_KIND_STONE"] = "Piedras"
L["BUFF_WINDOW_WEAPON_KIND_LURE"] = "Cebos"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_WINDOW_WEAPON_PICK_DESCRIPTION"] =
	"Ofrece %s para tu arma (%s). Mientras el arma no lleve ninguna de las opciones marcadas, se ofrece cada una que tengas."
L["BUFF_WINDOW_SELF_ENABLE"] = "Tus beneficios propios"
L["BUFF_WINDOW_SELF_ENABLE_DESCRIPTION"] =
	"Muestra en la parte superior de la ventana los beneficios que solo puedes lanzarte a ti mismo, como una armadura o Fuego interno, cuando faltan o están por agotarse. Elige cuáles en Beneficios propios."
L["BUFF_WINDOW_WEAPON_ENABLE"] = "Tus beneficios de arma"
L["BUFF_WINDOW_WEAPON_ENABLE_DESCRIPTION"] =
	"Muestra los venenos, imbuiciones, aceites, piedras y cebos que faltan o están por agotarse en tus armas, junto con tus beneficios propios en la parte superior de la ventana. Haz clic en uno para aplicarlo. Elige cuáles en Beneficios de arma."

-- The window itself
L["BUFF_WINDOW_SELF_HEADER"] = "Beneficios propios"
L["BUFF_WINDOW_FAVOR_HEADER"] = "Devolver el favor"
L["BUFF_WINDOW_TARGET_HEADER"] = "Objetivo"
L["BUFF_WINDOW_TOOLTIP_CAST"] = "Haz clic para lanzarlo sobre %s."
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_WINDOW_TOOLTIP_WEAPON"] = "Haz clic para aplicarlo a tu arma (%s)."
L["BUFF_WINDOW_TOOLTIP_USE"] = "Nadie en tu grupo tiene una piedra de alma. Haz clic para usar una sobre %s."
L["BUFF_WINDOW_TOOLTIP_CREATE"] = "Nadie en tu grupo tiene una piedra de alma. Haz clic para crear una."
L["BUFF_WINDOW_TOOLTIP_GROUP"] = "Haz clic para lanzarlo sobre %s y su grupo."
L["BUFF_WINDOW_TOOLTIP_FAVOR"] = "Haz clic para seleccionar a %s como objetivo y lanzarlo."
L["BUFF_WINDOW_TOOLTIP_DISMISS"] = "Haz clic derecho para quitar a %s de la lista."
-- The window's close button: the class name in its color, then the options command.
L["BUFF_WINDOW_CLOSED"] =
	"Turno de beneficios está desactivado para la clase %s. Para volver a activarlo, usa Mayús + Clic derecho en el botón del minimapa o escribe %s."

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEYS_HEADER"] = "Atajos de teclado"
L["BUFF_KEYS_DESCRIPTION"] =
	"Lanza el siguiente beneficio de tu lista con una tecla o una macro, fuera de combate. Los beneficios de arma siguen siendo un clic en la ventana."
L["BUFF_KEY"] = "Botón de beneficio"
L["BUFF_KEY_DESCRIPTION"] =
	"Lanza tu siguiente beneficio pendiente, uno por pulsación: una resurrección sobre tu objetivo muerto, luego sobre los muertos de tu grupo (sacerdotes, paladines y chamanes), luego tus beneficios propios, Devolver el favor, tu objetivo y tu grupo. Un grupo recibe el beneficio de grupo cuando cuesta menos maná que lanzarlo uno a uno a todos los que están a tu alcance."
L["BUFF_KEY_SKIP_COOLDOWNS"] = "Omitir beneficios con reutilización"
L["BUFF_KEY_SKIP_COOLDOWNS_DESCRIPTION"] =
	"Pasa por alto los beneficios con tiempo de reutilización, como Custodia de miedo, y sigue con el siguiente."
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "Esperando a que %s esté a tu alcance."
L["BUFF_KEY_DONE"] = "No queda nada por lanzar."
-- The caption beside the read-only box that holds a Buff Key's macro line.
L["BUFF_KEY_MACRO_CAPTION"] = "Macro"

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "Botón de agradecimiento"
L["BUTTON_DESCRIPTION"] = "Susurra a tu objetivo y dedícale una emoción con una sola tecla. Cortesía, automatizada."
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "Botón de agradecimiento %d"
L["BUTTON_EMOTE"] = "Emoción"
L["BUTTON_EMOTE_DESCRIPTION"] =
	"Establece la emoción que este botón realiza hacia tu objetivo, o Ninguna para no realizar ninguna."
L["BUTTON_EMOTE_NONE"] = "Ninguna"
L["BUTTON_ICON"] = "Icono"
L["BUTTON_ICON_DESCRIPTION"] =
	"Establece el icono que muestra la macro de este botón en tu lista de macros y en tus barras de acción."
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "Predeterminado"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = 'Habilitar macro "%s"'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] = "Crea una macro llamada %s y la elimina al desactivar esta opción."
L["BUTTON_WHISPER_DESCRIPTION"] =
	"Establece lo que este botón susurra a tu objetivo. Déjalo vacío para no enviar ningún susurro."

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "¡Gracias, eres lo máximo! (="
--[[
    The star marker (left off on WoW Forever) and " // TFTB" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "Tienes %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "Animas a <Target>."
L["EMOTE_DRINK_DESCRIPTION"] = "Levantas una copa por <Target>."
L["EMOTE_FLEX_DESCRIPTION"] = "Haces alarde de tus músculos ante <Target>."
L["EMOTE_GRIN_DESCRIPTION"] = "Le sonríes con malicia a <Target>."
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "Chocas los cinco con <Target>."
L["EMOTE_PRAISE_DESCRIPTION"] = "Alabas a <Target>."
L["EMOTE_SALUTE_DESCRIPTION"] = "Saludas a <Target> con respeto."
L["EMOTE_SMILE_DESCRIPTION"] = "Le sonríes a <Target>."
L["EMOTE_THANK_DESCRIPTION"] = "Le das las gracias a <Target>."
L["EMOTE_WHOA_DESCRIPTION"] = "Exclamas '¡Hala!' a <Target>."
L["EMOTE_WINK_DESCRIPTION"] = "Le guiñas un ojo a <Target>."
L["EMOTE_YES_DESCRIPTION"] = "Asientes a <Target>."

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- Every string from here to the end is the Spellbook's.

-- Page: Sections
L["SECTION_UNLEARNED"] = "Sin aprender"

-- Page: Macro Menu
L["MENU_GROUP_COMBAT_CHECK"] = "Condición de combate"
L["MENU_GROUP_SPELL_RANK"] = "Rango del hechizo"
L["MENU_GROUP_BEFORE_CAST"] = "Antes de lanzar"
L["MENU_GROUP_ADD_ATTACK"] = "Añadir ataque"
L["MENU_GROUP_CASTING_RULES"] = "Reglas de lanzamiento"
L["MENU_GROUP_ERRORS"] = "Mensajes de error"
L["MENU_GROUP_USE_ITEMS_FIRST"] = "Usar objetos primero"
L["MACRO_TEXT"] = "Texto de la macro"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_OPTIONS_COUNT"] = "%d opciones"
L["MENU_RANK_LEARN_LEVEL"] = "%s (Nivel %d)"
L["MENU_MAX_RANK"] = "Rango máximo"
L["MENU_DYNAMIC_RANK"] = "Rango dinámico"
L["MENU_DYNAMIC_RANK_NOTE"] =
	"El rango dinámico, basado en el nivel de un jugador amistoso, solo se actualiza fuera de combate."
L["MENU_CAST_AT_CURSOR"] = "Lanzar en el cursor"
L["MENU_TARGET_NEAREST_ENEMY"] = "Seleccionar el enemigo más cercano"
L["MENU_TARGET_NEAREST_FRIEND"] = "Seleccionar el aliado más cercano"
L["MENU_CAST_IF_SUMMONED"] = "Lanzar %s si está invocado"
L["MENU_NEVER_TURN_OFF"] = "No desactivar nunca"
L["MENU_LEAVE_FORM_BEFORE"] = "Salir de la forma antes de lanzar"
L["MENU_RIGHT_CLICK_FOR"] = "Clic derecho para %s"
L["MENU_ONLY_IN_COMBAT"] = "Solo en combate"
L["MENU_NEVER_IN_COMBAT"] = "Nunca en combate"
L["MENU_COMBAT_CHECK_NONE"] = "Ninguna"
L["MENU_ONCE_PER_COMBAT"] = "Lanzar una vez por combate"
L["MENU_ONCE_PER_TARGET"] = "Lanzar una vez por objetivo"
L["MENU_HIDE_ERRORS"] = "Ocultar mensajes de error"
L["MENU_MUTE_ERRORS"] = "Silenciar sonidos de error"
L["MENU_SWITCH_TO"] = "Cambiar a %s"
L["MENU_CAST_ON_FOCUS"] = "Lanzar sobre el foco"
L["MENU_START_AUTO_ATTACK"] = "Iniciar ataque automático"
L["MENU_STOP_ATTACK"] = "Detener ataque"
L["MENU_START_AUTO_SHOT"] = "Iniciar disparo automático"
L["MENU_START_PET_ATTACK"] = "Iniciar ataque de mascota"
L["MENU_START_WAND"] = "Iniciar varita"
L["MENU_STOP_CASTING"] = "Detener lanzamiento"
L["MENU_STOP_CASTING_NOTE"] =
	"Usa Detener lanzamiento en hechizos que no pueden esperar, como interrupciones y disipaciones."
L["MENU_STOP_IF_CHANNELING"] = "Detener macro si canalizas"
L["MENU_STOP_IF_STEALTHED"] = "Detener macro si estás en sigilo"
L["MENU_SAFE_TO_SPAM_NOTE"] =
	"Para poder pulsar una macro repetidamente sin riesgo, activa Detener macro si canalizas para un hechizo canalizado, o Detener macro si estás en sigilo para Sigilo o Acechar. Así, volver a pulsarla no romperá la canalización ni tu sigilo."
L["MENU_USE_FOR_KIND"] = "Usar estas opciones en la categoría %s"
L["MENU_DUPLICATE"] = "Duplicar"
L["MENU_USE_FOR_KIND_DESCRIPTION"] =
	"Cada macro de la categoría %s que no hayas ajustado tú empieza con las opciones de esta macro. Abre Valores predeterminados de macros para mostrártelo."

-- Page: Settings Menu
L["SETTINGS_SHOW_UNLEARNED"] = "Mostrar hechizos sin aprender"
L["SETTINGS_MARK_ALL_PLACED"] = "Marcar todos los hechizos como colocados"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"Ninguna macro de esta página vuelve a brillar, esté o no en tus barras. Un hechizo que aprendas después seguirá brillando hasta que lo coloques."

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "Foco"
L["SUBTEXT_PET"] = "Mascota"
L["SUBTEXT_CURSOR"] = "En cursor"
L["SUBTEXT_STANCE"] = "Actitud"
L["SUBTEXT_USE_ITEMS"] = "Usar objetos"
L["SUBTEXT_PET_ATTACK"] = "Ataque mascota"
L["SUBTEXT_DYNAMIC_RANK"] = "Rango dinám."
L["SUBTEXT_MAX_RANK"] = "Rango máximo"
L["SUBTEXT_TARGET_ENEMY"] = "Enemigo cercano"
L["SUBTEXT_TARGET_FRIEND"] = "Aliado cercano"
L["SUBTEXT_ONCE_PER_COMBAT"] = "1 por combate"
L["SUBTEXT_ONCE_PER_TARGET"] = "1 por objetivo"
L["SUBTEXT_COMBAT_ONLY"] = "Solo combate"
L["SUBTEXT_NO_COMBAT"] = "Fuera de combate"
L["SUBTEXT_LEAVE_FORM"] = "Salir de forma"
L["SUBTEXT_NO_TOGGLE"] = "Siempre activo"
L["SUBTEXT_WAND"] = "Varita"
L["SUBTEXT_START_ATTACK"] = "Ataque auto."
L["SUBTEXT_STOP_ATTACK"] = "Detener ataque"
L["SUBTEXT_STOP_CASTING"] = "Detener lanz."
L["SUBTEXT_STOP_IF_CHANNELING"] = "No al canalizar"
L["SUBTEXT_STOP_IF_STEALTHED"] = "No en sigilo"
L["SUBTEXT_HIDE_ERRORS"] = "Sin errores"
L["SUBTEXT_MUTE_ERRORS"] = "Errores mudos"
L["SUBTEXT_OPTIONS_COUNT"] = "%d opciones"
L["SUBTEXT_TOO_LONG"] = "Muy larga"
L["SUBTEXT_LEARN_LEVEL"] = "Nivel %d"
L["SUBTEXT_TALENT"] = "Talento"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "Aún sin aprender"
L["TOOLTIP_LEARN_LEVEL"] = "Tu instructor de clase lo enseña a nivel %d."
L["TOOLTIP_LEARN_TALENT"] = "Se aprende con tus talentos."
L["TOOLTIP_NOT_ON_BARS"] = "No está en tus barras de acción"
L["TOOLTIP_TOO_LONG"] = "Demasiado larga: %d / %d bytes. Desactiva una opción para acortarla."
L["TOOLTIP_OPTIONS_ON"] = "Opciones activadas: %s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "Clic o arrastrar"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "Colocar en tus barras de acción"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "Clic derecho"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "Opciones de la macro"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "Los hechizos de tu clase como macros de un clic."
L["TOOLTIP_KEY_CLICK"] = "Clic"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "Abrir BBB Spellbook"

-- Page: Layout
L["PAGE_EMPTY"] = "Aún no hay macros. Visita a tu instructor de clase para aprender tus primeros hechizos."
L["PAGE_MACRO_SLOTS"] = "Espacios de macros"
L["TOOLTIP_MACRO_SLOTS"] =
	"Cada macro que colocas ocupa un espacio de macro. Los espacios de personaje son de este personaje y se llenan primero. Los espacios generales los comparten todos los personajes de tu cuenta."
L["PAGE_MACRO_GENERAL"] = "Generales"
L["PAGE_MACRO_CHARACTER"] = "Personaje"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "Asignación de teclas"
L["OPTIONS_KEY_SET"] = "Asignar tecla"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Abre la lista de asignación de teclas del juego, donde Bags Buffs & Buttons tiene su propia sección."
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"Abre y cierra BBB Spellbook. También tiene su propia pestaña en tu libro de hechizos."
L["OPTIONS_DELETE_MACROS_HEADER"] = "Borrar macros"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"Borra las macros que creó BBB Spellbook, lo que también las quita de tus barras de acción. Tus propias macros nunca se tocan, y la página vuelve a crear cualquiera de ellas cuando la pulsas o la arrastras."
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "Borrar macros del personaje"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"Borra las macros de BBB Spellbook de la pestaña de macros de este personaje. Tus otros personajes conservan las suyas hasta que hagas lo mismo con ellos."
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"¿Borrar todas las macros de BBB Spellbook de este personaje? También se quitan de tus barras de acción."
L["OPTIONS_DELETE_GENERAL_MACROS"] = "Borrar macros generales"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"Borra las macros de BBB Spellbook de la pestaña Macros generales, que comparten todos los personajes de tu cuenta, así que tus otros personajes también pierden las suyas ahí."
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"¿Borrar todas las macros generales de BBB Spellbook? Todos los personajes de tu cuenta las pierden, y también se quitan de tus barras de acción."

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"Muestra los hechizos de clase que aún no has aprendido en una sección Sin aprender, para que puedas colocar sus macros antes."

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "Coloca el hechizo donde apunta el cursor, sin círculo de selección."
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "Lanza el rango más alto que admite el nivel del jugador amistoso."
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] =
	"Detiene primero lo que estés lanzando, para que este hechizo salga al instante."
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "Detiene primero tu ataque automático cuerpo a cuerpo."
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"No hace nada mientras canalizas un hechizo, así que pulsarla nunca rompe la canalización."
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"No hace nada mientras estás en sigilo, así que pulsarla nunca rompe Sigilo ni Acechar."
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "Sale primero de tu forma actual, para que se pueda lanzar el hechizo."
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] =
	"Selecciona primero al enemigo más cercano cuando no tienes ningún enemigo vivo como objetivo."
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] =
	"Selecciona primero al aliado más cercano cuando no tienes ningún aliado vivo como objetivo."
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "Envía también a tu mascota a atacar a tu objetivo."
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "Inicia tu ataque automático cuerpo a cuerpo después del lanzamiento."
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "Inicia Disparo automático o tu varita después del lanzamiento."
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "Lanza una vez y no vuelve a hacerlo hasta que cambie tu objetivo."
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"Lanza una vez y no vuelve a hacerlo hasta que termine el combate o cambie tu objetivo."
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"Mantiene activa la forma o el aspecto cuando vuelves a pulsar la macro, en lugar de desactivarlo."
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "Borra el texto de error rojo que la macro deja en pantalla."
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "Silencia el sonido de error mientras se ejecuta la macro."
L["KIND_ENEMY"] = "Hechizos contra enemigos"
L["KIND_ENEMY_DESCRIPTION"] = "Hechizos que lanzas a un enemigo, como ataques y perjuicios."
L["KIND_FRIENDLY"] = "Hechizos amistosos"
L["KIND_FRIENDLY_DESCRIPTION"] = "Hechizos que lanzas a un aliado, como sanaciones."
L["KIND_BUFF"] = "Beneficios"
L["KIND_BUFF_DESCRIPTION"] = "Hechizos que dan a un aliado un beneficio duradero."
L["KIND_ANYONE"] = "Hechizos para aliado o enemigo"
L["KIND_ANYONE_DESCRIPTION"] = "Hechizos que puedes lanzar a un aliado o a un enemigo."
L["KIND_GROUND"] = "Hechizos de área en el suelo"
L["KIND_GROUND_DESCRIPTION"] = "Hechizos que colocas en el suelo."
L["KIND_FORM"] = "Formas, actitudes y aspectos"
L["KIND_FORM_DESCRIPTION"] = "Hechizos que siguen activos hasta que los desactivas o cambias a otro."
L["KIND_SELF"] = "Hechizos propios y de área"
L["KIND_SELF_DESCRIPTION"] = "Hechizos sin objetivo, lanzados sobre ti o a tu alrededor."

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "Mostrar/ocultar BBB Spellbook"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"Como medida de seguridad, la lista de asignación de teclas no se puede abrir durante el combate."
L["KEY_BINDINGS_LOCATION"] = "Abre el menú del juego, luego %s, luego %s, y busca la sección Bags Buffs & Buttons."
L["ERROR_MACRO_SLOTS_FULL"] = "No hay espacios de macros libres. Borra una macro en /macro para hacer sitio."
L["CHAT_MACROS_DELETED"] = "Macros borradas: %d"
L["CHAT_MACRO_TOO_LONG"] =
	'La macro "%s" ocupa %d bytes con sus opciones activadas, más de los %d que admite una macro. Desactiva una opción para acortarla.'
