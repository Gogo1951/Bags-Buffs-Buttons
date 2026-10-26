local L = LibStub("AceLocale-3.0"):NewLocale("Bags-Buffs-Buttons", "zhTW")
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
	"版本 %s。設定（包括停用此訊息的選項）位於 選項 > 插件 > Bags Buffs & Buttons。喜歡這個插件嗎？告訴朋友，在 CurseForge 上收藏它，或在它的 GitHub 頁面上點擊 Star。(="
L["OPTIONS_LEVEL_UP_TITLE"] = "幫助 Bags Buffs & Buttons 升級"
L["OPTIONS_LEVEL_UP_THANKS"] = "感謝你選擇 Bags Buffs & Buttons！"

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

L["MACRO_BANDAGE"] = "- 繃帶"
L["MACRO_EXPLOSIVES"] = "- 爆炸物"
L["MACRO_FEED_PET"] = "- 餵養寵物"
L["MACRO_FOOD"] = "- 食物"
L["MACRO_HEALTH_POTION"] = "- 治療藥水"
L["MACRO_HEALTHSTONE"] = "- 治療石"
L["MACRO_MANA_GEM"] = "- 法力寶石"
L["MACRO_MANA_POTION"] = "- 法力藥水"
L["MACRO_POISONS"] = "- 毒藥"
L["MACRO_SOULSTONE"] = "- 靈魂石"
L["MACRO_WATER"] = "- 水"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a list: a Readiness Report clause, the Restocker's "Couldn't move" list, or the characters on a Restock List.
L["LIST_SEPARATOR"] = "、"
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = "."

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

L["DIET_BREAD"] = "麵包"
L["DIET_CHEESE"] = "乳酪"
L["DIET_FISH"] = "魚"
L["DIET_FRUIT"] = "水果"
L["DIET_FUNGUS"] = "蘑菇"
L["DIET_MEAT"] = "肉"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"看來你發現了一個錯誤！%s (%s) 無法在 %s > %s (%s) 使用。請將此問題回報給我們，以便修正。謝謝！%s"
L["MESSAGE_NO_ITEM"] = "背包中未找到合適的%s。"
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"由於你的巨集欄位已滿，部分 Connoisseur & Restocker 巨集未能建立。請刪除不再使用的巨集以騰出欄位，或在 選項 > 插件 > Connoisseur & Restocker > 巨集 中關閉不需要的 Connoisseur & Restocker 巨集。"
--[[
    Printed once after the add-on creates one or more of its macros, so a new
    player learns they exist. %s is "/m", the game's own macro command, colored
    at the call site. "General" is the macro window's tab for account-wide
    macros; use the client's own name for that tab. The macro names are this
    locale's own MACRO_FOOD and MACRO_WATER values, written exactly as this
    locale ships them.
]]
L["MESSAGE_MACROS_READY"] =
	'你的巨集已準備就緒。輸入 %s，開啟"一般巨集指令"標籤頁，然後把 - 食物、- 水 等巨集拖到你的快捷列上。'
-- The mini-map button's Right-Click and Middle-Click. %s is the item's link.
L["MESSAGE_IGNORE_ADDED"] = "%s 已加入此角色的忽略列表。"
-- %d is how many items the Middle-Click took off the list: exactly one, or two or more.
L["MESSAGE_IGNORE_CLEARED_ONE"] = "已從此角色的忽略列表中清除 1 件物品。"
L["MESSAGE_IGNORE_CLEARED_MANY"] = "已從此角色的忽略列表中清除 %d 件物品。"

L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"

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

L["READINESS_TITLE"] = "就緒報告"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s%s"
L["READINESS_CLAUSE_SEPARATOR"] = "。"

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "缺少增益："
L["READINESS_EXPIRING"] = "即將到期："
L["READINESS_MISSING_ITEMS"] = "缺少物品："
L["READINESS_DAMAGED_GEAR"] = "受損裝備："
L["READINESS_CHARACTER"] = "角色："
L["READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備："

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
L["READINESS_FLASK"] = "精煉藥劑或 2 種藥劑"
L["READINESS_PET_FORMAT"] = "%s（寵物）"
L["READINESS_SCROLLS"] = "卷軸"
L["READINESS_SOULSTONE"] = "靈魂石未啟用"
L["READINESS_HEALTHSTONE"] = "治療石"
L["READINESS_MANA_GEM"] = "法力寶石"
L["READINESS_HEALING_POTION"] = "治療藥水"
L["READINESS_MANA_POTION"] = "法力藥水"
L["READINESS_BANDAGES"] = "繃帶"
L["READINESS_PVP_ON"] = "PvP 已開啟"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d 分鐘"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 不足 1 分鐘"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPECIALIZATION_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 個未使用的天賦點"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d 個未使用的天賦點"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf, and TIP_EMPTY_* via ConnoisseurNoItem. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "你目前沒有任何對寵物有用的食物。"
-- The four %s are the client's names for Call Pet, Dismiss Pet, Feed Pet and Revive Pet, in that order.
L["TIP_PET_NO_SKILLS_FORMAT"] = "你目前還沒有學會%s、%s、%s或%s。"
L["TIP_PET_NO_MEND"] = "你目前還沒有學會治療寵物。"
L["TIP_NO_HAND_POISON"] = "這把武器所選的毒藥已用完。"

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "你目前還沒有學會%s。"

--[[
    A Mage's Food, Water or Mana Gem macro, or a Warlock's Healthstone or
    Soulstone macro, pressed with none in the bags by a character who knows the
    spell that makes it. { LABEL_* name, MACRO_* name }: "No Water in your
    bags. Right-Click - Water to conjure more." Mages conjure, warlocks create,
    the same verbs as NOTE_CONJURE and NOTE_CREATE.
]]
L["TIP_EMPTY_CONJURE"] = "你的背包裡沒有%s了。右鍵點擊 %s 製造更多。"
L["TIP_EMPTY_CREATE"] = "你的背包裡沒有%s了。右鍵點擊 %s 製造一顆。"

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

--[[
    The two Food macro features. Both names fill OPTIONS_MODE_DESCRIPTION's %s,
    and Scroll Buffs labels the Readiness Report's switch. In every *_FORMAT key
    that names the buff, here and below, %s is the client's name for "Well Fed".
]]
L["FEATURE_BUFF_FOOD"] = "增益食物"
L["FEATURE_SCROLL_BUFFS"] = "卷軸增益"

--[[
    The mini-map tooltip's two switches, each a block with a description line.
    Buff Food and Scroll Buffs share one block and one click, which turns both
    on or off together. The Readiness Report's block takes its title from
    READINESS_TITLE.
]]
L["MINIMAP_BUFF_FOOD_SCROLLS"] = "增益食物與卷軸"
L["MINIMAP_BUFF_FOOD_SCROLLS_DESCRIPTION_FORMAT"] =
	'使用提供"%s"的食物，並在進食前補上缺少的卷軸增益。'

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Hunter's class block, and the two poison titles open the
    Rogue's.
]]
L["MINIMAP_BEST_FOOD"] = "當前食物"
L["MINIMAP_BEST_PET_FOOD"] = "當前寵物食物"
L["MINIMAP_MAIN_HAND_POISON"] = "主手毒藥"
L["MINIMAP_OFF_HAND_POISON"] = "副手毒藥"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "忽略列表"
L["MINIMAP_IGNORE_COUNT"] = "%d 件物品"
L["MENU_IGNORE"] = "忽略"
L["MENU_CLEAR_IGNORE"] = "清除忽略列表"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 報告"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d 項未完成訂單"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "恭喜，你的補給已全部備齊！"
L["MINIMAP_RESTOCKER_EMPTY"] = "你的清單是空的。"

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restocker 清單"
L["MENU_RESTOCKER_DESCRIPTION"] = "購買你清單上的物品，並在銀行存取。"
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 右鍵點擊"
L["MENU_OPTIONS"] = "BBB 選項"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

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
L["NOTE_MACRO_FEED_PET"] = "餵養寵物巨集"
L["NOTE_MACRO_FOOD_WATER"] = "食物與水巨集"
L["NOTE_MACRO_MANA_GEM"] = "法力寶石巨集"
L["NOTE_MACRO_HEALTHSTONE"] = "治療石巨集"
L["NOTE_MACRO_SOULSTONE"] = "靈魂石巨集"
L["NOTE_MACRO_POISONS"] = "毒藥巨集"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "召喚、餵養或復活"
L["NOTE_PET_MEND_CLICK"] = "右鍵點擊，或戰鬥中點擊"
L["NOTE_HOLD_SHIFT"] = "按住 Shift"
L["NOTE_PET_FORCE_REVIVE"] = "強制復活"
L["NOTE_HOLD_CONTROL"] = "按住 Ctrl"
L["NOTE_PET_DISMISS"] = "解散"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "製造"
L["NOTE_CREATE"] = "製造"
L["NOTE_RIGHT_CLICK_AGAIN"] = "再次右鍵點擊"
L["NOTE_LOWER_RANK_BACKUP"] = "低等級備用"
L["NOTE_MAGE_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造。"
L["NOTE_WARLOCK_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造一顆治療石。"

-- Rogue. A Left-Click and a Right-Click on the Poisons macro show the client's slot names, MAINHANDSLOT and SECONDARYHANDSLOT.
L["NOTE_POISONS_WINDOW"] = "毒藥視窗"
L["NOTE_POISONS_REPLACED"] = "自動替換舊毒藥。"

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "繃帶"
L["LABEL_EXPLOSIVE"] = "爆炸物"
L["LABEL_FOOD"] = "食物"
L["LABEL_HEALTH_POTION"] = "治療藥水"
L["LABEL_HEALTHSTONE"] = "治療石"
L["LABEL_MANA_GEM"] = "法力寶石"
L["LABEL_MANA_POTION"] = "法力藥水"
L["LABEL_PET_FOOD"] = "寵物食物"
L["LABEL_POISON"] = "毒藥"
L["LABEL_SOULSTONE"] = "靈魂石"
L["LABEL_WATER"] = "水"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "已啟用"
L["MINIMAP_DISABLED"] = "已停用"
L["MINIMAP_TOGGLE"] = "切換"
L["MINIMAP_OPEN"] = "開啟"
L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_MIDDLE_CLICK"] = "中鍵點擊"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 左鍵點擊"

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
	"選擇你的食物巨集何時提供%s：總是提供，或僅在單人時、隊伍或團隊中、團隊中、練等時或滿等時提供。"
L["MODE_ALWAYS"] = "總是"
L["MODE_SOLO"] = "單人時"
L["MODE_PARTY"] = "在隊伍或團隊中時"
L["MODE_RAID"] = "在團隊中時"
L["MODE_LEVELING"] = "練等時"
L["MODE_MAX_LEVEL"] = "滿等時"

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
L["INVENTORY_REPORT_TITLE"] = "庫存報告"
-- A character's bags, then its bank: "Bag 39, Bank 1". The words show gray and each count white.
L["INVENTORY_REPORT_COUNTS"] = "背包 %s，銀行 %s"
-- The same row when only one of the two holds some; a place holding none is left out.
L["INVENTORY_REPORT_BAG"] = "背包 %s"
L["INVENTORY_REPORT_BANK"] = "銀行 %s"
-- On the header's right: every character on the realm added up, the word gray and the count white.
L["INVENTORY_REPORT_TOTAL"] = "總計 %s"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "登入時在聊天視窗中輸出歡迎訊息。"

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "啟用小地圖按鈕"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "顯示小地圖按鈕。"

-- Features: each feature's master switch, also on the panel that configures it.
-- Options: each add-on's heading page
L["OPTIONS_TFTB_DESCRIPTION"] =
	"自動透過密語或表情感謝每一位為你施加增益的玩家，並用一鍵施放的缺失增益提醒，讓你的團隊、你自己和你的武器始終保持增益。還會提醒你大餐、傳送門、召喚和靈魂之井。禮數周到，全自動。"
L["OPTIONS_SPELLBOOK_DESCRIPTION"] =
	"在新的法術書分頁中一鍵把每個職業法術做成滑鼠指向巨集、游標施放巨集和自我施放巨集，不需巨集語法。升級、訓練或切換專精時會自動更新。右鍵即可加入專注目標、停止施法、自動攻擊、寵物攻擊或使用飾品。"

L["OPTIONS_MACROS_ENABLE"] = "啟用巨集更新"
L["OPTIONS_MACROS_ENABLE_DESCRIPTION"] =
	"隨著背包變化，讓你的 Connoisseur & Restocker 巨集始終指向你最好的物品。關閉後，每個巨集都保持最後的狀態。"
L["OPTIONS_RESTOCKER_ENABLE"] = "啟用 Restocker"
L["OPTIONS_RESTOCKER_ENABLE_DESCRIPTION"] =
	"根據你的補貨清單購買物品並存入銀行，並在存貨不足時提醒你。關閉後會停用全部功能，包括補貨清單視窗。"

-- The label before a panel's Example line, which shows a chat print as it will arrive.
L["SAMPLE_EXAMPLE"] = "範例：%s"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/bbb"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"
L["RESTOCKER_COMMAND"] = "/restock"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "開啟你的補貨清單。"

L["OPTIONS_LEVEL_UP_INTRO"] =
	"這個插件由熱愛這款遊戲、希望讓每個人都盡可能玩得開心的玩家打造。我們永遠不會請求捐款。真正讓我們滿足的，是知道我們的努力讓你的遊戲體驗更好了一點。如果確實如此，我們很想聽你說說！"
L["OPTIONS_LEVEL_UP_WAYS"] = "以下是你可以幫助我們接觸更多玩家的幾種方式。"
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 分享回饋：發現了錯誤或有新點子？請在 Discord 上告訴我們。你的回饋能幫助我們改進插件，也隨時歡迎提交拉取請求。"
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 告訴朋友：認識可能會喜歡這個插件的人嗎？告訴他們吧。口耳相傳能幫助更多玩家發現優秀的插件。"
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• 在 CurseForge 上收藏：打開下方的 CurseForge 連結，登入後點擊 Download 按鈕下方的星號。收藏能幫助更多玩家發現這個插件。"
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• 在 GitHub 上點 Star：打開下方的 GitHub 連結，登入後點擊右上角的 Star。星號能幫助專案取得更多免費開發者工具的資格。"

L["OPTIONS_FEEDBACK"] = "回饋與支援"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "回饋與支援連結"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "要複製連結，請點擊其輸入框，然後按 Ctrl+A 和 Ctrl+C。"
L["OPTIONS_VERSION"] = "版本 %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Which Macros to Create header below titles the first
    section, after the page's two headerless toggles, Enable Macro Updates and
    Macro Names on Buttons.
]]
L["TAB_MACROS"] = "巨集"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur & Restocker 會為每種消耗品各建立一個巨集，並隨著背包變化保持更新，讓你快捷列上的按鈕始終取用你身上最好的物品。請在下方選擇要建立哪些巨集，然後設定每個巨集如何挑選物品。"

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "在按鈕上顯示巨集名稱"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"在你的快捷列按鈕上顯示巨集名稱文字，Connoisseur & Restocker 預設會隱藏這些文字。"

--[[
    Which Macros to Create. "General" in the description is the Macros
    window's tab for account-wide macros; use the client's own name for it. The
    button under the checkboxes opens that window.
]]
L["OPTIONS_MACROS_TO_CREATE_HEADER"] = "要建立的巨集"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	'選擇 Connoisseur & Restocker 要建立並維護哪些巨集。關閉某個巨集也會將其移除。它們位於巨集視窗的"一般巨集指令"標籤頁中，可直接拖到你的快捷列上。'
L["OPTIONS_OPEN_MACRO_WINDOW"] = "開啟巨集視窗"
L["OPTIONS_OPEN_MACRO_WINDOW_DESCRIPTION"] =
	'開啟遊戲的巨集視窗並切換到"一般巨集指令"標籤頁，這些巨集就在那裡。'
--[[
    Hover text on each Which Macros to Create toggle, whose own label names
    the macro. It says "this macro" because a LABEL_* is not every macro's
    name: Feed Pet's label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "建立並維護此巨集，取消勾選時會將其移除。"

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, Use Conjured
    Food & Water First, and Use Restock List Food & Water Last, in page
    order. One description serves all four, so each option's hover text says
    what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "食物與水"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"你的食物和水巨集會使用背包中最好的食物和飲料。這些選項可以讓增益食物、卷軸或魔法製造的食物和水優先，並讓補貨清單中的食物和水最後使用。"

--[[
    Buff Food, the first option under Food & Water. Its hover text carries the
    arena exception, which the mini-map tooltip's shared Buff Food & Scrolls
    line has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "優先增益食物"
L["OPTIONS_BUFF_FOOD_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益時，優先使用可提供該增益的食物，競技場中除外。'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "啟用卷軸增益"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"你的食物巨集第一次按下時會使用缺少的卷軸，再按一次則進食；以友方玩家為目標或身處競技場時會跳過卷軸。"
L["OPTIONS_SCROLL_TYPES"] = "在檢查中包含卷軸類型"
-- The other five scroll types are labeled with the client's stat names (SPELL_STAT1_NAME to SPELL_STAT5_NAME); Protection has none.
L["OPTIONS_SCROLL_PROTECTION"] = "保護"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = '檢查缺少的增益時包含"%s"。'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "優先使用魔法製造的食物與水"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'魔法製造的食物和水不花錢，並會在你離線後不久消失，因此你的食物和水巨集會優先使用它們，即使背包裡有恢復量更高的物品。開啟"優先增益食物"時，增益食物仍然最先使用。'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"選擇魔法製造的食物和水何時優先：總是優先，或僅在單人時、隊伍或團隊中、團隊中、練等時或滿等時優先。"

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "最後使用補貨清單中的食物與水"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"當兩種食物或飲料恢復量相同時，你的食物和水巨集會先使用不在補貨清單上的那種，把補貨清單購買的留到以後。"

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "藥水與治療石"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"巨集在戰鬥中無法更改（這是暴雪的限制），因此每個藥水和治療石巨集都預先包含你最好的物品以及最多兩個備用物品。在較長的戰鬥中，圖示和提示可能會過時並顯示錯誤的物品，但點擊該巨集將始終使用你背包中實際擁有的最佳物品。"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "非戰鬥時在藥水巨集中使用食物與水"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"非戰鬥時，你的治療藥水巨集會食用你最好的食物，法力藥水巨集會飲用你最好的水。戰鬥中則照舊使用你的藥水。卷軸、寵物食物和魔法製造仍保留在食物和水巨集中。"
L["OPTIONS_COMBINE_HEALTHSTONES"] = "將治療石合併到治療藥水巨集中"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"將你最好的治療石加入治療藥水巨集的底部，這樣按一次即可同時使用藥水和治療石。"

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "法力寶石與符文"
-- In both Mana Gem texts the two %s are the client's names for Demonic Rune and Dark Rune, in that order, each with its icon.
L["OPTIONS_MANA_GEMS_DESCRIPTION_FORMAT"] =
	"%s、%s以及另外幾種法力物品，都與法力寶石共用冷卻時間。符文使用時會消耗生命力，因此除非你選擇加入，否則法力寶石巨集不會包含其中任何一種。"
L["OPTIONS_INCLUDE_MANA_RUNES"] = "將符文與其他法力物品加入法力寶石巨集"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION_FORMAT"] =
	"將你的%s、%s，以及任何其他與法力寶石共用冷卻時間的法力物品，和你的法力寶石一同排序，這樣當其中某件物品是你的最佳選擇，或你的法力寶石用完時，法力寶石巨集就會使用該物品。"

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "增益重新施放"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"巨集在戰鬥中無法更改，因此戰鬥中途到期的增益會一直缺失，直到戰鬥結束。"
L["OPTIONS_REAPPLY"] = "提前補充即將到期的增益"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"將剩餘時間低於你所設門檻的增益食物、卷軸增益和寵物食物增益視為已到期，讓你的巨集在開怪前提供新的增益。"
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，你的巨集就會提供新的增益。"
L["REAPPLY_THRESHOLD_ONE"] = "當剩餘不足 1 分鐘時"
L["REAPPLY_THRESHOLD_MANY"] = "當剩餘不足 %d 分鐘時"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "寵物食物增益"
L["OPTIONS_PET_SECTION_DESCRIPTION_FORMAT"] = '少數食物會為你的寵物提供專屬的"%s"增益。'
L["OPTIONS_USE_PET_BUFFS"] = "使用寵物食物增益"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION_FORMAT"] =
	'當你的寵物缺少"%s"增益時，將寵物食物加入你的食物巨集，競技場中除外。'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "在檢查中包含寵物食物類型"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "爆炸物"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 選項會跳過目標指示圈，直接將爆炸物在你腳下引爆，非常適合目標處於近戰距離時使用。另一個鍵則照常投擲。"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "點擊方式"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"選擇用哪個鍵投擲爆炸物，用哪個鍵將它在你腳下引爆。"
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "左鍵點擊 @player"
L["EXPLOSIVES_MODE_TOSS"] = "左鍵點擊投擲"

--[[
    Class & Race panel (Options-Class-Race.lua), nested under Macros. TAB_CLASS_RACE
    is its label in the settings tree and the title on the page;
    OPTIONS_CLASS_RACE_DESCRIPTION is the intro beneath it.
]]
L["TAB_CLASS_RACE"] = "職業與種族"
L["OPTIONS_CLASS_RACE_DESCRIPTION"] =
	"這些選項會針對某個職業或種族調整你的巨集。所有區塊在每個角色上都會顯示。"

-- The class and race sections' headers; %s is the client's name for the class or race, or OPTIONS_FORSAKEN_HEADER.
L["OPTIONS_CLASS_HEADER_FORMAT"] = "職業選項：%s"
L["OPTIONS_RACE_HEADER_FORMAT"] = "種族選項：%s"

-- Druids
L["OPTIONS_DRUID_DESCRIPTION"] =
	"需要 DruidMacroHelper 插件。開啟後，你的治療藥水、法力藥水和治療石巨集會讓你脫離形態、使用物品，再讓你回到熊形態或獵豹形態，取決於你在核取方塊旁選擇的那個。"
L["OPTIONS_DRUID_MACRO_HELPER"] = "啟用 DruidMacroHelper 整合"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"使用 DruidMacroHelper (/dmh) 為治療藥水、法力藥水和治療石建立變形巨集。"
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] = "選擇你的變形巨集在使用物品後讓你返回哪種形態。"
L["DRUID_FORM_BEAR"] = "返回熊形態"
L["DRUID_FORM_CAT"] = "返回獵豹形態"

-- Rogues
L["OPTIONS_POISONS_DESCRIPTION"] =
	"讓毒藥巨集始終裝載每種毒藥類型可用的最高等級。左鍵塗抹副手，右鍵塗抹主手，既有毒藥會自動替換。"
L["OPTIONS_POISON_MAIN_HAND"] = "主手毒藥類型"
L["OPTIONS_POISON_OFF_HAND"] = "副手毒藥類型"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在右鍵點擊時塗抹到主手的毒藥。"
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在左鍵點擊時塗抹到副手的毒藥。"
--[[
    Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) eating toggles.
    In both hover texts %s is the client's name for the spell the macro
    appends.
]]
L["OPTIONS_STEALTH_EATING"] = "啟用進食時潛行"
L["OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION"] = "將%s加入你的食物巨集中，以便你在進食時潛行。"

-- Night Elves
L["OPTIONS_STEALTH_DRINKING"] = "啟用喝水時潛行"
L["OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION"] = "將%s加入你的水巨集中，以便你在喝水時潛行。"
L["OPTIONS_STEALTH_PICK_ONE"] =
	"專業提示：只選一個。你可以同時進食和喝水，但潛行後再進食或喝水會解除潛行。"

--[[
    Forsaken. Headed with our own word, the race's lore name, since the client
    names it Undead; in the five texts after the header, %s is the client's
    name for Cannibalize. Drinking shows only where Cannibalize restores mana.
]]
L["OPTIONS_FORSAKEN_HEADER"] = "被遺忘者"
L["OPTIONS_CANNIBALIZE_DESCRIPTION"] =
	"選取一個你殺死的人型生物或不死族，你的巨集會在%s不在冷卻中時施放它，節省你的食物和飲料。如果無法施放（屍體超出距離，或該技能正在冷卻），則照常進食或喝水。"
L["OPTIONS_CANNIBALIZE_EATING"] = "使用%s代替進食"
L["OPTIONS_CANNIBALIZE_EATING_DESCRIPTION"] =
	"當你的目標是%s可用的屍體且該技能不在冷卻中時，你的食物巨集會施放它而不是進食。否則照常進食。卷軸和增益食物仍然優先。"
L["OPTIONS_CANNIBALIZE_DRINKING"] = "使用%s代替喝水"
L["OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION"] =
	"當你的目標是%s可用的屍體且該技能不在冷卻中時，你的水巨集會施放它而不是喝水。否則照常喝水。增益飲料仍然優先。"

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
L["TAB_IGNORE_LIST"] = "忽略列表"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"被忽略的物品永遠不會被任何巨集選用。食物、水、藥水，任何東西都一樣。全域列表對所有角色生效；角色列表只對該角色生效。右鍵點擊小地圖按鈕可忽略你當前的最佳食物。"
L["OPTIONS_IGNORE_GLOBAL"] = "全域"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "將此物品移至全域列表，使其在所有角色上都被忽略。"
L["OPTIONS_IGNORE_ADD_FROM_BAGS"] = "從背包新增"
L["OPTIONS_IGNORE_ADD_FROM_BAGS_DESCRIPTION"] =
	"從你身上的物品中挑選。開啟選項介面時背包會關閉，所以這可以代替把物品拖到這裡。"
L["OPTIONS_IGNORE_ADD_ID"] = "以物品 ID 新增"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"輸入物品 ID，或在此輸入框取得焦點時按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "輸入物品 ID，或按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_REMOVE"] = "移除"
L["OPTIONS_IGNORE_EMPTY"] = "此列表為空。"
L["OPTIONS_IGNORE_CLEAR"] = "清空清單"
L["OPTIONS_IGNORE_CLEAR_DESCRIPTION"] =
	"移除此清單中的所有物品。清單為空的角色會從左側清單中消失，除非是你目前正在玩的角色。"
L["OPTIONS_IGNORE_CLEAR_CONFIRM"] = "移除此清單中的所有物品？此動作無法復原。"
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "正在載入 ID：%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"根據你的補貨清單保持背包物資充足，自動向商人購買，並在背包與銀行之間搬運物品。輸入 %s 開啟清單。"
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "在銀行開啟"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "造訪銀行時開啟你的補貨清單。"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "在商人處開啟"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "造訪商人時開啟你的補貨清單。"
-- The header over the three reminder rows below, which follow the Staples Pop-Up and Gold Reserve rows on the page.
L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "提醒"
L["OPTIONS_RESTOCKER_REMIND"] = "啟用城鎮補貨提醒"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"當補貨清單尚有缺口，且你抵達旅店或城市，或登入時已身處其中，在聊天中輸出提醒。"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "啟用商人補貨提醒"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] = "關閉商人視窗時，回報所有未完成的補貨訂單。"
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "啟用銀行補貨提醒"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "關閉銀行時，回報所有未完成的補貨訂單。"

--[[
    The Gold Reserve: the floor the merchant restock never spends below. The
    dropdown beside it writes each amount as a number and the gold coin, so
    its values have no strings; AMOUNT_DESCRIPTION is its hover text.
]]
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "啟用金幣儲備"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "補貨絕不會花掉你在此預留的金幣。"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "設定補貨始終為你保留的金幣數量。"

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"選擇提醒只有一行，還是為你缺少的每件物品各加一行。"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "簡潔"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "詳細"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "播放音效"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "在提醒的同時播放提示音，適合聊天繁忙的時候。"
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "點擊試聽提示音。"

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "補貨清單視窗"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "選擇你的補貨清單何時自動開啟。"

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"在物品提示中顯示你在本伺服器所有角色上共有多少件該物品。"
L["OPTIONS_INVENTORY_REPORT"] = "在物品提示中啟用庫存報告"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"在物品提示中加入該物品在你的背包、銀行和其他角色身上各有多少件。如果其他插件已經顯示這些數量，請將其關閉。"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "致謝"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"我一直很喜歡 Restocker，很感激能有機會讓它在 Connoisseur & Restocker 中延續下去。非常感謝撰寫最初 Auto Restocker 的 ChiliFajita，以及在經典版與潘達利亞之謎期間一直維護它的 kvakvs 和 guardycmw。"

-- Readiness Report
L["TAB_READINESS_REPORT"] = "就緒報告"
L["OPTIONS_READINESS_ENABLE"] = "在準備確認時啟用就緒報告"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "為此帳號的所有角色開啟就緒報告。"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"準備確認開始時，輸出一份僅你可見的清單，列出仍需處理的事項；如果你已準備就緒，則完全不會輸出任何內容。"

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "重置就緒報告設定"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] = "將本頁的所有核取方塊和兩個門檻恢復為預設值。"
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"將就緒報告的所有設定重置為預設值？這也會重新關閉報告本身。"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "缺少增益"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "缺少物品"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "角色"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"缺少精煉藥劑時提醒。一瓶精煉藥劑，或作戰藥劑與守護藥劑各一瓶，均視為已滿足。"
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION_FORMAT"] =
	'缺少"%s"增益時提醒。需要在巨集頁面中開啟增益食物。'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION_FORMAT"] =
	'你的寵物缺少"%s"增益時提醒。需要在巨集頁面中開啟寵物食物增益，並且已召喚出寵物。'
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"缺少卷軸增益時提醒。需要在巨集頁面中開啟卷軸增益，並且只檢查該處所選的卷軸類型。"
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"當隊伍中沒有人身上有生效的靈魂石時提醒；背包裡的靈魂石不算。僅提醒能製造靈魂石的術士。"
L["OPTIONS_READINESS_MAIN_HAND"] = "主手武器增益"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"主手武器沒有臨時附魔時提醒。任何附魔都算，且隊伍中有薩滿時不會回報此項。"
L["OPTIONS_READINESS_OFF_HAND"] = "副手武器增益"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"副手武器沒有臨時附魔時提醒。任何附魔都算：磨刀石、油劑、毒藥或薩滿的武器增益。"
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "增益到期時間少於"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"列出你身上所有即將到期的增益，而不僅是 Connoisseur & Restocker 施加的那些；此設定與巨集頁面中的增益重新施放相互獨立。"
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s 分鐘"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 分鐘"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，報告才會列出它。"

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"當你身上沒有治療石時提醒。僅當隊伍中有可以索取的術士，或你自己就是術士時才提醒。"
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"當你身上沒有法力寶石時提醒。僅提醒能製造法力寶石的法師。"
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"當你身上沒有治療藥水時提醒，因為戰鬥中沒人能遞給你藥水。"
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"當你身上沒有法力藥水時提醒。僅當你的角色是使用法力的職業時才提醒。"
-- %s is the client's name for the First Aid skill line.
L["OPTIONS_READINESS_BANDAGES_SKILL_DESCRIPTION"] = "當你身上沒有%s技能允許使用的繃帶時提醒。"
L["OPTIONS_READINESS_DURABILITY"] = "受損裝備低於"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"連結耐久度低於該值的每件已裝備物品；按單件計算，因此即使只有一把武器損壞也會顯示。"
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"設定物品耐久度降到多低時，報告才會連結它。"

-- Character
L["OPTIONS_READINESS_SPECIALIZATION"] = "目前天賦"
L["OPTIONS_READINESS_SPECIALIZATION_DESCRIPTION"] = "輸出你的天賦分配，以及尚未使用的點數。"
L["OPTIONS_READINESS_PVP"] = "PvP 標記開啟"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "當你的 PvP 標記開啟時發出警告。"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備"
L["OPTIONS_READINESS_NONCOMBAT_GEAR_DESCRIPTION"] =
	"連結不該出現在戰鬥中的已裝備物品，比如騎乘裝備或釣魚裝備。"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '已存在名為"%s"的清單。'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "沒有 ID 為 %d 的物品。"
L["RESTOCKER_BANK_NOT_OPEN"] = "銀行未開啟。"
L["RESTOCKER_DISABLED"] = "Restocker 已關閉。請在 選項 > 插件 > Connoisseur & Restocker 中開啟。"
--[[
    %s is the /restock slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankFrameOpened), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"補貨完成。開啟銀行時按住 Shift 可跳過補貨。輸入 %s 編輯你的補貨清單。"
L["RESTOCKER_STOPPED_BOTH_FULL"] = "補貨已停止。你的背包和銀行都已滿。"
L["RESTOCKER_STOPPED_BANK_FULL"] = "補貨已停止。你的銀行已滿；請騰出一格後重新開啟。"
L["RESTOCKER_STOPPED_BAG_FULL"] = "補貨已停止。你的背包已滿；請騰出一格後重新開啟銀行。"
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "補貨已停止。無法繼續進行。"
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "補貨已停止。無法移動：%s。"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (多餘)"
L["RESTOCKER_STOPPED_ERROR"] = "補貨因錯誤而停止：%s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"這個商人沒有販售你的毒藥所需的全部材料。跳過購買這些材料。"
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "在城裡的時候別忘了補貨！"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "還有 1 項補貨訂單未完成。"
L["RESTOCKER_STILL_SHORT_MANY"] = "還有 %d 項補貨訂單未完成。"

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "你的補貨清單已升級。"
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d 升級為 %sx%d。"

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
L["RESTOCKER_RESTOCKED_ONE"] = "已完成 1 項補貨訂單。"
L["RESTOCKER_RESTOCKED_MANY"] = "已完成 %d 項補貨訂單。"

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "有 1 項補貨訂單僅部分完成。"
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "有 %d 項補貨訂單僅部分完成。"
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "背包在全部購買完成前就已裝滿。"
-- Printed after the counts above when gold ran out before every order was bought, while the Gold Reserve is off.
L["RESTOCKER_OUT_OF_GOLD"] = "金幣不足，無法完成補貨。"
--[[
    RESTOCKER_OUT_OF_GOLD's line while the Gold Reserve is on, whole so each
    locale joins its sentences its own way. %s is the reserve with the gold
    coin. Nothing waits at this merchant: the next merchant visit buys whatever
    fits above the reserve, which is what the second sentence says.
]]
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"已在你的金幣儲備（%s）處停止購買。剩下的會在你下次來訪、有多餘金幣時購買。"

-- /restock help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.

-- Stands for the list name the player types after a /restock profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[名稱]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "新增一個以該名稱命名的清單。"
L["RESTOCKER_HELP_PROFILE_DELETE"] = "刪除該名稱的清單。"
L["RESTOCKER_HELP_PROFILE_RENAME"] = "將當前清單重新命名為該名稱。"
L["RESTOCKER_HELP_PROFILE_COPY"] = "用該名稱的清單副本取代當前清單。"
L["RESTOCKER_HELP_PROFILE_USE"] = "將此角色切換到該名稱的清單。"

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
L["STARTER_POPUP_TITLE"] = "基礎物資"
L["STARTER_POPUP_INTRO_LOGIN"] = "我們已為你的職業勾選了一些基礎物資，幫你快速上手。"
L["STARTER_POPUP_INTRO_EMPTY"] = "你的補貨清單是空的，我們來新增一些物品好讓你上手。"
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "挑選你想保持備足的基礎物資。"
L["STARTER_POPUP_INTRO_HOW"] =
	"你勾選的一切都會在你開啟商人或銀行時自動補足。大多數基礎物資會隨著等級提升自動升級，所以你手上永遠是目前最好的。"
-- %s is the /restock slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "你隨時可以輸入 %s 來調整這份清單，或稍後新增更多物品。"
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "食物與水"
L["STARTER_POPUP_FOOD_HEADER"] = "食物"
L["STARTER_POPUP_AMMO_HEADER"] = "彈藥"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "子彈"
L["STARTER_POPUP_ARROWS"] = "箭矢"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header opens with the client's name for the class
    (rogue-colored at the call site) to say the ingredients take care of
    themselves. Both sections name their rows with the client's own item
    names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "材料與工具"
L["STARTER_POPUP_POISONS_HEADER"] = "毒藥"
-- %s is the client's name for the Rogue class, rogue-colored; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s ：將成品毒藥加入你的清單，Connoisseur & Restocker 會在任何販售全部所需材料的商人處自動購買這些材料。"
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"將 %s 加入你的補貨清單，在背包中保留 %d 個，並隨著你的等級自動升級。"
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "將 %s 加入補貨清單，並在背包中保留 %d 個。"
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 疊"
L["STARTER_POPUP_STACK_MANY"] = "%d 疊"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "要保持備足多少疊，每疊 %d 個。"
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"要保持備足多少個；這些物品無法堆疊，因此每個都會佔用一個背包格。"

--[[
    Restock List window UI. The title names what the window holds, after the
    add-on's full name (ADDON_TITLE // RESTOCKER_WINDOW_TITLE); the feature
    that acts on it stays "Restocker".
]]
L["RESTOCKER_WINDOW_TITLE"] = "補貨清單"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "篩選物品……"
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "清除"
L["RESTOCKER_ADD_BUTTON"] = "新增"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. "Check" is the pop-up's own
    word (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_PICK_STAPLES_BUTTON"] = "挑選基礎物資"
L["RESTOCKER_PICK_STAPLES_TOOLTIP"] =
	"從適合你職業和等級的基礎物資中選擇：食物、水、彈藥、毒藥和施法材料。勾選一項即可將其加入此清單，取消勾選則會將其移除。"
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "新增物品"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"將背包中的物品拖曳到這裡或此視窗的任意位置，或輸入物品 ID 後按 Enter。"
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "拖曳物品或輸入物品 ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "請改為輸入物品 ID。"
-- Written into the add box the same way, when the item dropped or typed is already on the list.
L["RESTOCKER_ADD_DUPLICATE"] = "已在此清單中。"
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "從背包新增物品"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"你背包中尚未加入此清單的所有物品。點擊其中一件即可新增。"
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "背包中沒有可新增的物品"

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
L["RESTOCKER_PROFILE_LABEL"] = "清單"
L["RESTOCKER_PROFILE_TOOLTIP"] = "點擊為此角色切換到其他補貨清單，或新建一個清單。"
L["RESTOCKER_USED_BY"] = "使用者：%s"
L["RESTOCKER_MANAGE"] = "管理清單"
L["RESTOCKER_MANAGE_TOOLTIP"] = "新建一個清單，或複製、重新命名、刪除此清單。"
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu.
]]
L["RESTOCKER_NEW_PROFILE"] = "新清單"
L["RESTOCKER_MANAGE_COPY"] = "將此清單複製為新清單"
L["RESTOCKER_RENAME_PROFILE"] = "重新命名此清單"
L["RESTOCKER_MANAGE_DELETE"] = "刪除此清單"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 副本"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "重新命名"
L["RESTOCKER_RENAME_TOOLTIP"] = "重新命名此清單，對所有使用它的角色生效。"
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "確定要刪除此清單嗎？"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s 也在使用此清單，下次登入時將進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s 也在使用此清單，下次登入時將各自進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SWITCH"] = "你將切換到 %s。"
L["RESTOCKER_DELETE_LIST_LAST"] = "這是僅剩的一個清單，因此你將從一個新的空清單開始。"
L["RESTOCKER_DELETE_LIST_FINAL"] = "此操作無法復原。"
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "隨等級升級"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"允許 Connoisseur & Restocker 在你升級時，將食物、水、彈藥、毒藥、藥水和職業施法材料升級為更好的物品。"

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "銀行"
L["RESTOCKER_ROW_MERCHANT"] = "商人"
L["RESTOCKER_ROW_UPGRADE"] = "升級"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "物品"
L["RESTOCKER_COLUMN_WITHDRAW"] = "取出"
L["RESTOCKER_COLUMN_DEPOSIT"] = "存入"
L["RESTOCKER_COLUMN_REPUTATION"] = "聲望"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "保留"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "點擊此標題，可為目前顯示的所有物品設定此項。"
L["RESTOCKER_BULK_ON"] = "為顯示的 %d 件物品開啟"
L["RESTOCKER_BULK_OFF"] = "為顯示的 %d 件物品關閉"

L["RESTOCKER_GROUP_OTHER"] = "未分類"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "新增"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "全部物品"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_PICK_STAPLES_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "此清單中還沒有物品"
L["RESTOCKER_EMPTY_BODY"] =
	"挑選食物、水或職業施法材料等基礎物資，或透過上方的選單新增背包中的任何物品。此清單中的物品會自動補足或存入你的銀行，讓你的背包保持整潔。"
L["RESTOCKER_EMPTY_DROP_HINT"] = "將物品拖曳到此視窗的任意位置也能新增。"
L["RESTOCKER_NO_MATCH_FILTER"] = "此清單中沒有符合篩選條件的物品。"
L["RESTOCKER_NO_MATCH_GROUP"] = "此分類中已沒有物品。"

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
L["RESTOCKER_NO_ORDERS"] = "沒有未完成的補貨訂單。"
L["RESTOCKER_REPORT_MORE"] = "還有 %d 項"
L["RESTOCKER_REMOVED_ITEM"] = "已移除 %s。"
L["RESTOCKER_UNDO"] = "復原"
L["RESTOCKER_UNDO_TOOLTIP"] = "將此物品放回清單"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "將此物品從補貨清單中移除"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "你可以在視窗底部復原此操作。"
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "在背包中保留"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'要在背包中保留多少個。背包中的數量少於此數時，該數字會顯示為黃色；若設為 0 並開啟"存入"，則會將其全部存入銀行。'
L["RESTOCKER_BUY_LABEL"] = "購買"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "向商人購買"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "商人視窗開啟時，向商人購買所需數量。"

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "額外"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "額外購買"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"買下商人此物品的全部限量存貨（即每次只有少量、會慢慢刷新的商品），即使超出你的保留數量。"
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "存入銀行"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"銀行開啟時，將多餘的物品存入銀行；若保留欄填寫 0，則全部存入。"
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "從銀行取出"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "銀行開啟時，從銀行取出所需物品。"

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "所需聲望"
--[[
    { standing label, discount percent }. The standings are the client's own
    labels (FACTION_STANDING_LABEL5 to 8), so only "Any" has a key here.

    Run through string.format, so its literal percent sign is escaped as %%,
    as is RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS' below.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (優惠 %d%%)"
L["RESTOCKER_REPUTATION_ANY"] = "任意"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "所需商人聲望"
--[[
    The four %s are the client's labels for Friendly, Honored, Revered and
    Exalted, in that order, each followed by its discount; the percent signs are
    escaped as %% because the line goes through string.format. With no standing
    required the cell draws a dash rather than the word "Any", which is why the
    last sentence names the dash; "Any" is still the menu's first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_DISCOUNTS"] =
	"點擊設定 Connoisseur & Restocker 向商人購買前所需的聲望等級；聲望還會降低價格：%s 5%%，%s 10%%，%s 15%%，%s 20%%。短橫線表示向任何商人購買。"

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此無法額外購買。'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此聲望要求不適用。'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "此物品沒有可升級的更好版本。"

--------------------------------------------------------------------------------
-- Thanks for the Buff
--------------------------------------------------------------------------------

-- Every string from here to Spellbook is Thanks for the Buff's.

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

-- Buff & gift announcements
L["MESSAGE_BUFFED"] = "%s 給你施放了 %s！"
L["MESSAGE_GAVE_YOU"] = "%s 給了你 %s！"
L["MESSAGE_GAVE_GROUP"] = "%s 給你的隊伍提供了 %s！"
L["MESSAGE_USED_ITEM"] = "%s 對你使用了 %s！"
L["MESSAGE_USED_SPELL"] = "%s 對你施放了 %s！"
L["MESSAGE_SET_OUT"] = "%s 擺放了 %s！"
L["MESSAGE_OPENED"] = "%s 開啟了 %s！"

-- Thank-you
L["MESSAGE_WHISPER_THANKS"] = "感謝你的 %s"
L["MESSAGE_SELECT_PLAYER"] = "請先以一名玩家為目標。"
L["MESSAGE_CANT_THANK_SELF"] = "你不能感謝自己！"

--------------------------------------------------------------------------------
-- Text Fragments
--------------------------------------------------------------------------------

L["UNKNOWN_SPELL"] = "未知法術"

--------------------------------------------------------------------------------
-- Options: Main Panel
--------------------------------------------------------------------------------

L["OPTIONS_EXAMPLE"] = "範例：%s"

--------------------------------------------------------------------------------
-- Options: Buff Panels
--------------------------------------------------------------------------------

-- Stranger Buffs
L["TAB_STRANGERS"] = "來自陌生人的增益"
L["STRANGERS_ENABLE"] = "啟用對陌生人增益的感謝"
L["STRANGERS_ENABLE_DESCRIPTION"] = "開啟對隊伍外玩家所施增益的感謝。"
L["STRANGERS_DESCRIPTION"] = "在開放世界中，感謝隊伍外的玩家為你施放的增益。"
-- The dropdown values carry the unit, so these labels do not repeat it.
L["STRANGERS_OVERALL_COOLDOWN"] = "感謝冷卻時間"
L["STRANGERS_OVERALL_COOLDOWN_DESCRIPTION"] =
	"設定兩輪感謝之間的間隔，無論增益來自誰。設為零則對每個增益都表示感謝。"
L["STRANGERS_SOURCE_COOLDOWN"] = "同一玩家感謝冷卻時間"
L["STRANGERS_SOURCE_COOLDOWN_DESCRIPTION"] =
	"設定對同一名玩家兩次感謝之間的間隔。設為零則對每個增益都表示感謝。"
L["STRANGERS_MIN_DURATION"] = "最短增益持續時間"
L["STRANGERS_MIN_DURATION_DESCRIPTION"] =
	"忽略持續時間短於此值的增益。設為零則對每個增益都作出反應。"

-- Teammate Buffs
L["TAB_TEAMMATES"] = "來自隊友的增益"
L["TEAMMATES_ENABLE"] = "啟用對隊友增益的感謝"
L["TEAMMATES_ENABLE_DESCRIPTION"] = "開啟對隊伍或團隊成員為你施放的增益和冷卻技能的感謝。"
L["TEAMMATES_DESCRIPTION"] = "感謝隊伍和團隊成員對你施放的增益與冷卻技能。"

-- Service Alerts
L["TAB_SERVICES"] = "服務提醒"
L["SERVICES_ENABLE"] = "啟用服務提醒"
L["SERVICES_ENABLE_DESCRIPTION"] =
	"開啟對大餐、靈魂之井、傳送門以及其他為你的隊伍擺放的幫助的提醒。"
L["SERVICES_DESCRIPTION"] =
	"有人為你的隊伍擺出幫助時作出反應：大餐、靈魂之井、傳送門和修理機器人。"

-- Send Good News
L["TAB_GOOD_NEWS"] = "發送好消息"
L["GOOD_NEWS_DESCRIPTION"] =
	"讓被你施加增益的玩家知道你為他們施放了什麼；對於短時增益，還會告知能持續多久。"
L["GOOD_NEWS_ENABLE"] = "啟用好消息"
L["GOOD_NEWS_ENABLE_DESCRIPTION"] =
	"開啟一則密語，告訴被你施加增益的玩家你為他們施放了什麼。"
L["GOOD_NEWS_SCOPE"] = "接收者"
L["GOOD_NEWS_SCOPE_ALWAYS"] = "任何被你增益的人"
L["GOOD_NEWS_SCOPE_GROUP"] = "僅隊伍或團隊成員"
L["GOOD_NEWS_SCOPE_DESCRIPTION"] =
	"設定誰會收到好消息密語：任何被你增益的人，或僅限你的隊伍成員。"
L["GOOD_NEWS_MESSAGES_HEADER"] = "好消息訊息"
L["GOOD_NEWS_MESSAGES_DESCRIPTION"] = "被你增益的玩家會收到的密語。"
--[[
    The message box's tooltip, in three parts. LIMIT's %d is a real placeholder
    and gets formatted; TOKENS carries a literal %a for the reader to copy and so
    must never reach string.format. Joined into one line at the point of use.
]]
L["GOOD_NEWS_MESSAGE_INPUT_DESCRIPTION"] = "設定密語的內容。留空則使用預設文字。"
L["GOOD_NEWS_MESSAGE_LIMIT"] = "最大長度：%d。"
L["GOOD_NEWS_MESSAGE_TOKENS"] = "%a 會變成技能連結，持續時間不足一分鐘時還會附上持續時間。"
--[[
    Appended to the ability link inside %a when the buff has a readable duration
    under a minute. A whole clause rather than a bare number so it can be reworded
    per language.
]]
L["GOOD_NEWS_DURATION_CLAUSE"] = "持續 %s"

-- Shared across the buff panels
L["TRACKED_HEADER"] = "追蹤的技能"
L["TRACKED_GROUP_ITEMS"] = "物品"
L["TRACKED_ITEM_PENDING"] = "物品 #%d"
L["TRACKED_SPELL_PENDING"] = "法術 #%d"

-- Shared by Send Good News and the Thank You Button
L["WHISPER_MESSAGE"] = "密語訊息"
L["WHISPER_MESSAGE_RESET"] = "重設"
L["WHISPER_MESSAGE_RESET_DESCRIPTION"] = "將密語訊息恢復為預設文字。"

--------------------------------------------------------------------------------
-- Shared: Praise and Notifications
--------------------------------------------------------------------------------

--[[
    The two section headers every buff panel is built from: what the other player
    sees, then what only you get. Key prefixes match the header the control
    appears under.
]]
L["PRAISE_HEADER"] = "感謝密語與表情"
L["NOTIFICATIONS_HEADER"] = "通知"
L["PRAISE_DESCRIPTION"] = "對方玩家看到的內容：一則感謝密語、一個表情，或兩者兼有。"
L["NOTIFICATIONS_DESCRIPTION"] = "只有你會收到的內容：一則文字提示、一段音效，或兩者兼有。"

-- Also titles the Thank You Button's emote grid, so it carries no PRAISE_ prefix.
L["EMOTES_SELECT"] = "選擇表情"

L["PRAISE_WHISPER_ENABLE"] = "啟用感謝密語"
L["PRAISE_WHISPER_DESCRIPTION"] = "向為你施加增益的玩家密語致謝。"
L["PRAISE_EMOTES_ENABLE"] = "啟用表情"
L["PRAISE_EMOTES_DESCRIPTION"] = "用表情表達你的謝意。戰鬥中會暫緩發送表情。"
L["PRAISE_DELAY_ENABLE"] = "啟用感謝延遲"
L["PRAISE_DELAY_DESCRIPTION"] =
	"在發送密語和表情前稍作等待，避免你的感謝與增益在同一瞬間出現。通知不受影響。"
L["PRAISE_DELAY_LENGTH_DESCRIPTION"] = "設定發送密語和表情前的等待時間。"

L["NOTIFICATIONS_PRINT_ENABLE"] = "啟用文字提示"
L["NOTIFICATIONS_PRINT_DESCRIPTION"] = "獲得增益時，顯示一則只有你能看到的訊息。"
L["NOTIFICATIONS_SOUND_ENABLE"] = "啟用音效"
L["NOTIFICATIONS_SOUND_DESCRIPTION"] = "獲得增益時播放音效。只有你能聽到。"
L["NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION"] = "播放該音效，讓你在開啟前先試聽。"

--------------------------------------------------------------------------------
-- Tracked Ability Groups
--------------------------------------------------------------------------------

--[[
    Labels for multi-member tracked groups that no single game record names
    (Data/{Game}/Tracked-Abilities-{Game}.lua). Single spells and items, and a
    group named after one of its own items, take their names from the client.
]]
L["GROUP_PORTALS"] = "傳送門"
L["GROUP_RESISTANCE_CAULDRONS"] = "抗性大鍋"
L["GROUP_REPAIR_BOTS"] = "修理機器人"

--------------------------------------------------------------------------------
-- Options: Buff Duty
--------------------------------------------------------------------------------

L["TAB_BUFF_WINDOW"] = "增益值班"
L["BUFF_WINDOW_DESCRIPTION"] = "顯示誰缺少你的增益。點擊圖示即可施放。"
L["BUFF_WINDOW_ENABLE"] = "啟用增益值班"
L["BUFF_WINDOW_ENABLE_DESCRIPTION"] =
	"開啟增益值班，即列出缺少你可施放增益的隊伍成員的視窗。"
L["BUFF_WINDOW_NO_BUFFS"] =
	"你的職業沒有此列表中的增益，因此該視窗在這個角色上永遠不會出現。"
-- When to Show: Solo and In Group, each with Always or In Instance, then the classes.
L["BUFF_WINDOW_WHEN_HEADER"] = "顯示時機"
L["BUFF_WINDOW_WHEN_DESCRIPTION"] = "選擇視窗何時可以出現。"
L["BUFF_WINDOW_WHEN_SOLO"] = "單人"
L["BUFF_WINDOW_WHEN_SOLO_DESCRIPTION"] = "不在隊伍或團隊中時顯示視窗。"
L["BUFF_WINDOW_WHEN_GROUP"] = "在隊伍中"
L["BUFF_WINDOW_WHEN_GROUP_DESCRIPTION"] = "在隊伍或團隊中時顯示視窗。"
L["BUFF_WINDOW_WHERE_DESCRIPTION"] =
	"設定視窗在哪裡顯示：任何地方，或僅在地城、團隊副本、戰場和競技場內。"
L["BUFF_WINDOW_WHERE_ALWAYS"] = "總是"
L["BUFF_WINDOW_WHERE_INSTANCE"] = "在副本中"
L["BUFF_WINDOW_CLASSES_DESCRIPTION"] = "在玩這些職業時顯示視窗。"
L["BUFF_WINDOW_CLASS_DESCRIPTION"] = "在玩此職業時顯示視窗。"
L["BUFF_WINDOW_HEADER"] = "視窗"
L["BUFF_WINDOW_WINDOW_DESCRIPTION"] = "讓視窗留在你放置的位置，或在戰鬥中不擋視線。"
L["BUFF_WINDOW_LOCK"] = "鎖定視窗"
L["BUFF_WINDOW_LOCK_DESCRIPTION"] = "使視窗無法移動。解鎖後，可拖曳其背景來移動視窗。"
L["BUFF_WINDOW_HIDE_IN_COMBAT"] = "戰鬥中隱藏"
L["BUFF_WINDOW_HIDE_IN_COMBAT_DESCRIPTION"] =
	"在戰鬥中隱藏視窗。戰鬥中列表無法更新，因此保持顯示的視窗會停留在最後的狀態，直到戰鬥結束。"
L["BUFF_WINDOW_SHOW_HEADER"] = "在視窗中顯示"
L["BUFF_WINDOW_SHOW_DESCRIPTION"] =
	"將你自己的增益、為你施放增益的陌生人以及你的目標加入視窗。"
L["BUFF_WINDOW_FAVOR_ENABLE"] = "禮尚往來"
L["BUFF_WINDOW_FAVOR_ENABLE_DESCRIPTION"] =
	"列出最近為你施放增益的陌生人，以及你可以回贈他們的增益。右鍵點擊圖示可將某人從列表中移除。"
L["BUFF_WINDOW_FAVOR_SECONDS_DESCRIPTION"] =
	"設定陌生人在最後一次施放增益後保留在列表中的時間。"
L["BUFF_WINDOW_TARGET_ENABLE"] = "你的目標"
L["BUFF_WINDOW_TARGET_ENABLE_DESCRIPTION"] =
	"當你的目標是缺少你可施放增益的隊伍外玩家時，將其列出。"
L["BUFF_WINDOW_REFRESH"] = "剩餘低於此值時補充"
L["BUFF_WINDOW_REFRESH_DESCRIPTION"] =
	"設定增益剩餘時間低於多少時視為缺失，方便你在增益消失前及時補上。持續時間不超過此值的增益，只有在消失後才會視為缺失。"
-- Count as Tanks: one dropdown per class, then Pets, each with these three choices.
L["BUFF_WINDOW_TANKS_HEADER"] = "視為坦克"
L["BUFF_WINDOW_TANKS_DESCRIPTION"] =
	"沒有自身職責時，誰能獲得你提供給坦克的增益，例如荊棘術。"
L["BUFF_WINDOW_TANKS_CLASS_DESCRIPTION"] =
	"設定此職業的玩家何時視為坦克。他們自己的坦克或治療者職責始終優先。"
L["BUFF_WINDOW_TANKS_PETS"] = "寵物"
L["BUFF_WINDOW_TANKS_PETS_DESCRIPTION"] =
	"設定寵物何時視為坦克。寵物也會獲得你提供給所有人的增益。"
L["BUFF_WINDOW_TANKS_NEVER"] = "從不"
L["BUFF_WINDOW_TANKS_SOLO"] = "不在隊伍中時"
L["BUFF_WINDOW_TANKS_ALWAYS"] = "總是"
-- Who each buff is offered to: one dropdown per buff, these four choices.
L["BUFF_WINDOW_AUDIENCE_OFF"] = "關閉"
L["BUFF_WINDOW_AUDIENCE_TANK"] = "坦克"
L["BUFF_WINDOW_AUDIENCE_HEALER"] = "治療者"
L["BUFF_WINDOW_AUDIENCE_ALL"] = "所有人"
-- Each buff's dropdown tooltip; hovering the buff's name shows the spell itself.
L["BUFF_WINDOW_AUDIENCE_DESCRIPTION"] = "設定 %s 提供給誰。"
L["BUFF_WINDOW_BUFFS_DESCRIPTION"] =
	"選擇每個增益提供給誰。坦克和治療者依隊伍職責判定；沒有職責的人視為傷害輸出，除非下方的視為坦克另有設定。"

L["BUFF_WINDOW_SELF_DESCRIPTION"] = "你自己的增益，固定在視窗頂部。"
--[[
    Muted note after a class name on the Self-Buffs panel, for a family of self
    buffs only one of which can be up at a time. Keyed by the family.
]]
L["BUFF_WINDOW_SELF_NOTE_ASPECT"] = "任意一種守護即可"
L["BUFF_WINDOW_SELF_NOTE_MAGE_ARMOR"] = "任意一種護甲即可"
L["BUFF_WINDOW_SELF_NOTE_PALADIN_AURA"] = "任意一種光環即可"
L["BUFF_WINDOW_SELF_NOTE_SHAMAN_SHIELD"] = "任意一種護盾即可"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_ARMOR"] = "任意一種護甲即可"
L["BUFF_WINDOW_SELF_NOTE_WARLOCK_DEMON"] = "兩種惡魔增益任意一種即可"
L["BUFF_WINDOW_SELF_REFRESH_OFF"] = "關閉"
L["BUFF_WINDOW_SELF_REFRESH_MISSING"] = "缺失時"
-- %s is a duration from the client, like "5 Minutes".
L["BUFF_WINDOW_SELF_REFRESH_UNDER"] = "剩餘不足%s"
L["BUFF_WINDOW_SELF_REFRESH_DESCRIPTION"] =
	"設定 %s 何時顯示：從不、消失後，或剩餘時間少於此值時。"
-- The Weapon Buffs panel, under Buff Duty after Self-Buffs.
L["BUFF_WINDOW_WEAPON_PANEL_HEADER"] = "武器增益"
L["BUFF_WINDOW_WEAPON_DESCRIPTION"] =
	"勾選每把武器應保持的效果。當效果缺失或即將結束，且物品在你的背包中並適用於該武器時，視窗會提供它。"
-- The one timing for every weapon buff, at the top of the panel.
L["BUFF_WINDOW_WEAPON_REFRESH"] = "重新施加"
L["BUFF_WINDOW_WEAPON_REFRESH_DESCRIPTION"] =
	"設定武器增益何時再次提供：消失後，或剩餘時間少於此值時。"
-- The boxes for the weapon items any class can use, after the rogue and shaman boxes.
L["BUFF_WINDOW_WEAPON_KIND_OIL"] = "油"
L["BUFF_WINDOW_WEAPON_KIND_STONE"] = "磨刀石"
L["BUFF_WINDOW_WEAPON_KIND_LURE"] = "魚餌"
--[[
    One choice's checkbox under one hand. The first %s is the poison, imbue,
    oil, stone or lure, the second the client's "Main Hand" or "Off Hand".
]]
L["BUFF_WINDOW_WEAPON_PICK_DESCRIPTION"] =
	"提供%s，用於你的%s武器。當武器上沒有任何已勾選的選項時，會提供你擁有的每一種。"
L["BUFF_WINDOW_SELF_ENABLE"] = "你的自身增益"
L["BUFF_WINDOW_SELF_ENABLE_DESCRIPTION"] =
	"當只能對自己施放的增益（例如護甲類法術或心靈之火）缺失或即將結束時，將其顯示在視窗頂部。可在自身增益中選擇要顯示哪些。"
L["BUFF_WINDOW_WEAPON_ENABLE"] = "你的武器增益"
L["BUFF_WINDOW_WEAPON_ENABLE_DESCRIPTION"] =
	"將武器上缺失或即將結束的毒藥、武器強化、油、磨刀石和魚餌，與你的自身增益一起顯示在視窗頂部。點擊即可施加。可在武器增益中選擇要顯示哪些。"

-- The window itself
L["BUFF_WINDOW_SELF_HEADER"] = "自身增益"
L["BUFF_WINDOW_FAVOR_HEADER"] = "禮尚往來"
L["BUFF_WINDOW_TARGET_HEADER"] = "目標"
L["BUFF_WINDOW_TOOLTIP_CAST"] = "點擊對 %s 施放。"
-- %s is the client's "Main Hand" or "Off Hand".
L["BUFF_WINDOW_TOOLTIP_WEAPON"] = "點擊施加到你的%s武器。"
L["BUFF_WINDOW_TOOLTIP_USE"] = "你的隊伍中沒有人有靈魂石。點擊對 %s 使用一顆。"
L["BUFF_WINDOW_TOOLTIP_CREATE"] = "你的隊伍中沒有人有靈魂石。點擊製造一顆。"
L["BUFF_WINDOW_TOOLTIP_GROUP"] = "點擊對 %s 及其隊伍施放。"
L["BUFF_WINDOW_TOOLTIP_FAVOR"] = "點擊選取 %s 為目標並施放。"
L["BUFF_WINDOW_TOOLTIP_DISMISS"] = "右鍵點擊將 %s 從列表中移除。"
-- The window's close button: the class name in its color, then the options command.
L["BUFF_WINDOW_CLOSED"] =
	"已為%s職業關閉增益值班。要重新開啟，請 Shift + 右鍵點擊小地圖按鈕，或輸入 %s。"

-- The Buff Key (Key Bindings, and the Keybinds section of Buff Duty)
L["BUFF_KEYS_HEADER"] = "按鍵綁定"
L["BUFF_KEYS_DESCRIPTION"] =
	"脫離戰鬥時，用一個按鍵或巨集施放清單中的下一個增益。武器增益仍需在視窗中點擊施加。"
L["BUFF_KEY"] = "增益按鈕"
L["BUFF_KEY_DESCRIPTION"] =
	"每按一次施放下一個缺少的增益：先復活死亡的目標，再復活隊伍中死亡的成員（牧師、聖騎士和薩滿），然後是自身增益、禮尚往來、你的目標和你的隊伍。當隊伍增益比逐一為範圍內所有人施放單體增益消耗更少法力時，就施放隊伍增益。"
L["BUFF_KEY_SKIP_COOLDOWNS"] = "跳過有冷卻時間的增益"
L["BUFF_KEY_SKIP_COOLDOWNS_DESCRIPTION"] =
	"跳過有冷卻時間的增益（例如防護恐懼結界），繼續施放下一個。"
-- %s is a player's name.
L["BUFF_KEY_WAITING"] = "正在等待 %s 進入範圍。"
L["BUFF_KEY_DONE"] = "沒有需要施放的增益了。"
-- The caption beside the read-only box that holds a Buff Key's macro line.
L["BUFF_KEY_MACRO_CAPTION"] = "巨集"

--------------------------------------------------------------------------------
-- Options: Thank You Button
--------------------------------------------------------------------------------

L["TAB_THANK_YOU_BUTTON"] = "感謝按鈕"
L["BUTTON_DESCRIPTION"] = "一次按鍵即可對目標發送密語和表情。讓禮貌自動完成。"
-- One heading per button, numbered; %d is the button's position in the list.
L["BUTTON_SECTION"] = "感謝按鈕 %d"
L["BUTTON_EMOTE"] = "表情"
L["BUTTON_EMOTE_DESCRIPTION"] = "設定此按鈕對你的目標使用的表情，選擇'無'則不使用表情。"
L["BUTTON_EMOTE_NONE"] = "無"
L["BUTTON_ICON"] = "圖示"
L["BUTTON_ICON_DESCRIPTION"] = "設定此按鈕的巨集在巨集清單和快捷列上顯示的圖示。"
-- The Icon dropdown's first choice, the macros' own icon; every other choice is a picture alone.
L["BUTTON_ICON_DEFAULT"] = "預設"
--[[
    The toggle owns the macro in both directions, so the label is ENABLE rather
    than CREATE. Both strings carry the macro's name: with five buttons stacked,
    "which macro is this one?" should not need a hover.
]]
L["BUTTON_MACRO_ENABLE"] = '啟用巨集 "%s"'
L["BUTTON_MACRO_ENABLE_DESCRIPTION"] = "建立一個名為 %s 的巨集，關閉此項時會將其刪除。"
L["BUTTON_WHISPER_DESCRIPTION"] = "設定此按鈕向你的目標發送的密語。留空則不發送密語。"

--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

L["DEFAULT_WHISPER"] = "謝謝，你最棒了！(="
--[[
    The star marker (left off on WoW Forever) and " // TFTB" sign-off are added
    by the builder, which also drops the closing punctuation; neither is part of
    the editable text.
]]
L["DEFAULT_GOOD_NEWS"] = "你獲得了 %a"

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

L["EMOTE_CHEER_DESCRIPTION"] = "你向<Target>歡呼。"
L["EMOTE_DRINK_DESCRIPTION"] = "你向<Target>舉杯致意。"
L["EMOTE_FLEX_DESCRIPTION"] = "你向<Target>展示肌肉。"
L["EMOTE_GRIN_DESCRIPTION"] = "你對著<Target>壞笑。"
L["EMOTE_HIGHFIVE_DESCRIPTION"] = "你與<Target>擊掌。"
L["EMOTE_PRAISE_DESCRIPTION"] = "你讚美了<Target>。"
L["EMOTE_SALUTE_DESCRIPTION"] = "你恭敬地向<Target>致敬。"
L["EMOTE_SMILE_DESCRIPTION"] = "你對<Target>微笑。"
L["EMOTE_THANK_DESCRIPTION"] = "你向<Target>表示感謝。"
L["EMOTE_WHOA_DESCRIPTION"] = "你對<Target>驚嘆道'哇！'。"
L["EMOTE_WINK_DESCRIPTION"] = "你向<Target>眨眼。"
L["EMOTE_YES_DESCRIPTION"] = "你向<Target>點頭。"

--------------------------------------------------------------------------------
-- Spellbook
--------------------------------------------------------------------------------

-- Every string from here to the end is the Spellbook's.

-- Page: Sections
L["SECTION_UNLEARNED"] = "未學會"

-- Page: Macro Menu
L["MENU_GROUP_COMBAT_CHECK"] = "戰鬥條件"
L["MENU_GROUP_SPELL_RANK"] = "法術等級"
L["MENU_GROUP_BEFORE_CAST"] = "施法前"
L["MENU_GROUP_ADD_ATTACK"] = "加入攻擊"
L["MENU_GROUP_CASTING_RULES"] = "施法規則"
L["MENU_GROUP_ERRORS"] = "錯誤訊息"
L["MENU_GROUP_USE_ITEMS_FIRST"] = "先使用物品"
L["MACRO_TEXT"] = "巨集內容"
L["MENU_MACRO_LENGTH"] = "%d / %d"
L["MENU_OPTIONS_COUNT"] = "%d 個選項"
L["MENU_RANK_LEARN_LEVEL"] = "%s (%d級可學)"
L["MENU_MAX_RANK"] = "最高等級"
L["MENU_DYNAMIC_RANK"] = "動態等級"
L["MENU_DYNAMIC_RANK_NOTE"] = "動態等級依友方玩家的等級決定，只在非戰鬥狀態下更新。"
L["MENU_CAST_AT_CURSOR"] = "在游標處施放"
L["MENU_TARGET_NEAREST_ENEMY"] = "選取最近的敵人"
L["MENU_TARGET_NEAREST_FRIEND"] = "選取最近的友方"
L["MENU_CAST_IF_SUMMONED"] = "寵物已召喚時施放%s"
L["MENU_NEVER_TURN_OFF"] = "永不關閉"
L["MENU_LEAVE_FORM_BEFORE"] = "施法前取消形態"
L["MENU_RIGHT_CLICK_FOR"] = "右鍵點擊：%s"
L["MENU_ONLY_IN_COMBAT"] = "僅在戰鬥中"
L["MENU_NEVER_IN_COMBAT"] = "從不在戰鬥中"
L["MENU_COMBAT_CHECK_NONE"] = "無"
L["MENU_ONCE_PER_COMBAT"] = "每場戰鬥施放一次"
L["MENU_ONCE_PER_TARGET"] = "每個目標施放一次"
L["MENU_HIDE_ERRORS"] = "隱藏錯誤訊息"
L["MENU_MUTE_ERRORS"] = "關閉錯誤音效"
L["MENU_SWITCH_TO"] = "切換為%s"
L["MENU_CAST_ON_FOCUS"] = "對專注目標施放"
L["MENU_START_AUTO_ATTACK"] = "開始自動攻擊"
L["MENU_STOP_ATTACK"] = "停止攻擊"
L["MENU_START_AUTO_SHOT"] = "開始自動射擊"
L["MENU_START_PET_ATTACK"] = "開始寵物攻擊"
L["MENU_START_WAND"] = "開始魔杖射擊"
L["MENU_STOP_CASTING"] = "停止施法"
L["MENU_STOP_CASTING_NOTE"] = "對斷法、驅散這類不能等待的法術使用停止施法。"
L["MENU_STOP_IF_CHANNELING"] = "引導時停止巨集"
L["MENU_STOP_IF_STEALTHED"] = "潛行時停止巨集"
L["MENU_SAFE_TO_SPAM_NOTE"] =
	"想讓巨集可以放心連按，引導法術請開啟引導時停止巨集，潛行請開啟潛行時停止巨集。這樣再次按下就不會打斷引導，也不會讓你脫離潛行。"
L["MENU_USE_FOR_KIND"] = "對所有%s使用這些選項"
L["MENU_DUPLICATE"] = "複製"
L["MENU_USE_FOR_KIND_DESCRIPTION"] =
	"%s中你沒有親自設定過的每個巨集，都會以這個巨集的選項為初始選項。會開啟巨集預設設定給你查看。"

-- Page: Settings Menu
L["SETTINGS_SHOW_UNLEARNED"] = "顯示未學會的法術"
L["SETTINGS_MARK_ALL_PLACED"] = "將所有法術標記為已放置"
L["SETTINGS_MARK_ALL_PLACED_DESCRIPTION"] =
	"本頁的所有巨集不再發光，無論是否在你的快捷列上。之後學會的法術在放置前仍會發光。"

-- Page: Macro Buttons
-- TRANSLATORS: each note fills the small slot under a macro button, so keep it short.
L["SUBTEXT_FOCUS"] = "專注目標"
L["SUBTEXT_PET"] = "寵物"
L["SUBTEXT_CURSOR"] = "游標"
L["SUBTEXT_STANCE"] = "姿態"
L["SUBTEXT_USE_ITEMS"] = "使用物品"
L["SUBTEXT_PET_ATTACK"] = "寵物攻擊"
L["SUBTEXT_DYNAMIC_RANK"] = "動態等級"
L["SUBTEXT_MAX_RANK"] = "最高等級"
L["SUBTEXT_TARGET_ENEMY"] = "最近敵人"
L["SUBTEXT_TARGET_FRIEND"] = "最近友方"
L["SUBTEXT_ONCE_PER_COMBAT"] = "每戰一次"
L["SUBTEXT_ONCE_PER_TARGET"] = "每目標一次"
L["SUBTEXT_COMBAT_ONLY"] = "僅戰鬥中"
L["SUBTEXT_NO_COMBAT"] = "非戰鬥"
L["SUBTEXT_LEAVE_FORM"] = "取消形態"
L["SUBTEXT_NO_TOGGLE"] = "保持開啟"
L["SUBTEXT_WAND"] = "魔杖"
L["SUBTEXT_START_ATTACK"] = "自動攻擊"
L["SUBTEXT_STOP_ATTACK"] = "停止攻擊"
L["SUBTEXT_STOP_CASTING"] = "停止施法"
L["SUBTEXT_STOP_IF_CHANNELING"] = "引導時不施放"
L["SUBTEXT_STOP_IF_STEALTHED"] = "潛行時不施放"
L["SUBTEXT_HIDE_ERRORS"] = "隱藏錯誤"
L["SUBTEXT_MUTE_ERRORS"] = "錯誤靜音"
L["SUBTEXT_OPTIONS_COUNT"] = "%d 個選項"
L["SUBTEXT_TOO_LONG"] = "過長"
L["SUBTEXT_LEARN_LEVEL"] = "%d級"
L["SUBTEXT_TALENT"] = "天賦"

-- Page: Macro Tooltip
L["TOOLTIP_NOT_LEARNED"] = "尚未學會"
L["TOOLTIP_LEARN_LEVEL"] = "你的職業訓練師在%d級時傳授。"
L["TOOLTIP_LEARN_TALENT"] = "透過天賦學會。"
L["TOOLTIP_NOT_ON_BARS"] = "不在你的快捷列上"
L["TOOLTIP_TOO_LONG"] = "過長：%d / %d 位元組。關閉一個選項來縮短它。"
L["TOOLTIP_OPTIONS_ON"] = "已開啟選項：%s"
L["TOOLTIP_KEY_CLICK_DRAG"] = "點擊或拖曳"
L["TOOLTIP_ACTION_PLACE_ON_BAR"] = "放到你的快捷列上"
L["TOOLTIP_KEY_RIGHT_CLICK"] = "右鍵點擊"
L["TOOLTIP_ACTION_MACRO_OPTIONS"] = "巨集選項"

-- Spellbook Tab Tooltip
L["SPELLBOOK_TAB_DESCRIPTION"] = "把你的職業法術做成一鍵巨集。"
L["TOOLTIP_KEY_CLICK"] = "點擊"
L["TOOLTIP_ACTION_OPEN_PAGE"] = "開啟 BBB Spellbook"

-- Page: Layout
L["PAGE_EMPTY"] = "還沒有巨集。去找你的職業訓練師學習第一批法術。"
L["PAGE_MACRO_SLOTS"] = "巨集欄位"
L["TOOLTIP_MACRO_SLOTS"] =
	"你放置的每個巨集都會佔用一個巨集欄位。角色欄位專屬於這個角色，並優先佔用。一般欄位由你帳號中的所有角色共用。"
L["PAGE_MACRO_GENERAL"] = "一般"
L["PAGE_MACRO_CHARACTER"] = "角色"

L["OPTIONS_KEY_BINDINGS_HEADER"] = "按鍵設定"
L["OPTIONS_KEY_SET"] = "設定按鍵"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"開啟遊戲的按鍵設定清單，Bags Buffs & Buttons 在其中有自己的分類。"
L["OPTIONS_KEY_BINDING_TOGGLE_DESCRIPTION"] =
	"開啟或關閉 BBB Spellbook。它在你的法術書中也有自己的分頁。"
L["OPTIONS_DELETE_MACROS_HEADER"] = "刪除巨集"
L["OPTIONS_DELETE_MACROS_DESCRIPTION"] =
	"刪除 BBB Spellbook 建立的巨集，同時會將它們從快捷列上移除。你自己的巨集絕不會被改動，在頁面上點擊或拖曳任一個巨集即可重新建立。"
L["OPTIONS_DELETE_CHARACTER_MACROS"] = "刪除角色巨集"
L["OPTIONS_DELETE_CHARACTER_MACROS_DESCRIPTION"] =
	"從此角色的巨集分頁中刪除 BBB Spellbook 的巨集。你的其他角色會保留各自的巨集，直到你在那些角色上也這樣做。"
L["OPTIONS_DELETE_CHARACTER_MACROS_CONFIRM"] =
	"刪除此角色上所有 BBB Spellbook 的巨集？它們也會從你的快捷列上移除。"
L["OPTIONS_DELETE_GENERAL_MACROS"] = "刪除通用巨集"
L["OPTIONS_DELETE_GENERAL_MACROS_DESCRIPTION"] =
	"從通用巨集分頁中刪除 BBB Spellbook 的巨集。該分頁由帳號內所有角色共用，因此你的其他角色也會失去那裡的巨集。"
L["OPTIONS_DELETE_GENERAL_MACROS_CONFIRM"] =
	"刪除 BBB Spellbook 的所有通用巨集？帳號內所有角色都會失去它們，並且它們也會從你的快捷列上移除。"

-- Options: Spellbook Page Panel
L["OPTIONS_SHOW_UNLEARNED_DESCRIPTION"] =
	"在未學會分類中列出你尚未學會的職業法術，方便提前放置它們的巨集。"

-- Macro Option Descriptions
L["OPTIONS_DEFAULT_CURSOR_DESCRIPTION"] = "把法術放在游標所指的位置，不出現瞄準圈。"
L["OPTIONS_DEFAULT_DYNAMIC_RANK_DESCRIPTION"] = "施放友方玩家等級所能接受的最高等級。"
L["OPTIONS_DEFAULT_STOP_CASTING_DESCRIPTION"] = "先停止你正在施放的法術，讓這個法術立刻施放。"
L["OPTIONS_DEFAULT_STOP_ATTACK_DESCRIPTION"] = "先停止你的近戰自動攻擊。"
L["OPTIONS_DEFAULT_STOP_IF_CHANNELING_DESCRIPTION"] =
	"你在引導法術時不做任何事，因此按下也絕不會打斷引導。"
L["OPTIONS_DEFAULT_STOP_IF_STEALTHED_DESCRIPTION"] =
	"你在潛行時不做任何事，因此按下也絕不會打破潛行。"
L["OPTIONS_DEFAULT_LEAVE_FORM_DESCRIPTION"] = "先取消你目前的形態，以便施放法術。"
L["OPTIONS_DEFAULT_TARGET_ENEMY_DESCRIPTION"] = "當你沒有選取活著的敵人時，先選取最近的敵人。"
L["OPTIONS_DEFAULT_TARGET_FRIEND_DESCRIPTION"] = "當你沒有選取活著的友方時，先選取最近的友方。"
L["OPTIONS_DEFAULT_PET_ATTACK_DESCRIPTION"] = "同時讓你的寵物攻擊你的目標。"
L["OPTIONS_DEFAULT_START_ATTACK_DESCRIPTION"] = "施法後開始你的近戰自動攻擊。"
L["OPTIONS_DEFAULT_AUTO_SHOT_DESCRIPTION"] = "施法後開始自動射擊或魔杖射擊。"
L["OPTIONS_DEFAULT_ONCE_PER_TARGET_DESCRIPTION"] = "施放一次，直到你的目標改變前不再施放。"
L["OPTIONS_DEFAULT_ONCE_PER_COMBAT_DESCRIPTION"] =
	"施放一次，直到戰鬥結束或你的目標改變前不再施放。"
L["OPTIONS_DEFAULT_NEVER_TURN_OFF_DESCRIPTION"] =
	"再次按下巨集時保持形態或守護開啟，而不是將其關閉。"
L["OPTIONS_DEFAULT_HIDE_ERRORS_DESCRIPTION"] = "清除巨集在畫面上留下的紅色錯誤文字。"
L["OPTIONS_DEFAULT_MUTE_ERRORS_DESCRIPTION"] = "巨集執行期間關閉錯誤音效。"
L["KIND_ENEMY"] = "敵對法術"
L["KIND_ENEMY_DESCRIPTION"] = "對敵人施放的法術，例如攻擊和減益效果。"
L["KIND_FRIENDLY"] = "友方法術"
L["KIND_FRIENDLY_DESCRIPTION"] = "對友方施放的法術，例如治療。"
L["KIND_BUFF"] = "增益法術"
L["KIND_BUFF_DESCRIPTION"] = "為友方施加持久增益效果的法術。"
L["KIND_ANYONE"] = "友方或敵方法術"
L["KIND_ANYONE_DESCRIPTION"] = "既可以對友方也可以對敵人施放的法術。"
L["KIND_GROUND"] = "地面目標法術"
L["KIND_GROUND_DESCRIPTION"] = "放置在地面上的法術。"
L["KIND_FORM"] = "形態、姿態和守護"
L["KIND_FORM_DESCRIPTION"] = "在你關閉或切換之前一直保持的法術。"
L["KIND_SELF"] = "自身和範圍法術"
L["KIND_SELF_DESCRIPTION"] = "沒有目標，對自己或周圍施放的法術。"

-- Key Bindings
L["BINDING_TOGGLE_PAGE"] = "開啟/關閉 BBB Spellbook"

L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟按鍵設定清單。"
L["KEY_BINDINGS_LOCATION"] = "開啟遊戲選單，依序進入 %s 和 %s，找到 Bags Buffs & Buttons 分類。"
L["ERROR_MACRO_SLOTS_FULL"] = "沒有空的巨集欄位。請在 /macro 中刪除一個巨集來騰出位置。"
L["CHAT_MACROS_DELETED"] = "已刪除巨集：%d"
L["CHAT_MACRO_TOO_LONG"] =
	'"%s"巨集在開啟選項後為 %d 位元組，超過了巨集能容納的 %d 位元組。關閉一個選項來縮短它。'
