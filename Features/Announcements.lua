local _, ns = ...
local L = ns.L
local Data = ns.Data

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Print Outs (Player Only)
--------------------------------------------------------------------------------

--[[
    The "BBB // " brand that opens every print: the Short Name, never the Full
    Name. Exposed so options panels can render pipeline-true sample messages
    that always match the real thing.
]]
function ns.GetPrintPrefix()
	return GetColor("INFO") .. L["ADDON_SHORT_NAME"] .. "|r " .. GetColor("SEPARATOR") .. "//" .. "|r "
end

--[[
    A player-only print as chat will show it, without printing it, so the
    options panels' Example lines draw exactly what chat shows. The body is
    white; colors a message embeds (links, class-colored names) sit inside it.
]]
function ns.BuildPrintLine(text)
	return ns.GetPrintPrefix() .. GetColor("TEXT") .. text .. "|r"
end

-- Format: |cff[INFO]BBB|r |cff[SEPARATOR]//|r |cff[TEXT]Message|r
function ns:PrintMessage(message)
	print(ns.BuildPrintLine(message))
end

local warned = {}

-- Prints a config problem once per session.
function ns.WarnOnce(message)
	if warned[message] then
		return
	end
	warned[message] = true
	ns:PrintMessage(message)
end

--------------------------------------------------------------------------------
-- Sent Messages (Other Players)
--------------------------------------------------------------------------------

--[[
    Branded sent messages for the automated buff/service thank-yous:
    {rt1} Message // BBB. BuildAnnounceMessage assembles the decorated string and
    Announce sends it. The body carries a spell/item link and the leading raid-
    target marker; the chat system renders both on send (the marker becomes the
    Star icon), so the pipes and braces pass through unchanged. WoW Forever blocks
    raid-marker tokens in chat, so there the marker is left off.
]]
local function MarkerPrefix()
	if ns.FLAVOR == "Camelot" then
		return ""
	end
	return ns.TARGET_MARKER .. " "
end

--[[
    The name signs off a sent message, so the body gives up its closing
    punctuation: "Thanks for the [Arcane Intellect] // BBB", never "...! //
    BBB". Translations and player-written Good News templates still carry their
    own (Spanish opens with an inverted mark, CJK closes with a full-width one),
    so the trim covers those too. Marks are matched as whole UTF-8 sequences,
    never as a byte class, so a multi-byte character is never cut in half.
]]
local CLOSING_MARKS = { "!", ".", "?", "\239\188\129", "\227\128\130", "\239\188\159" } -- ! . ? and full-width ！ 。 ？
local OPENING_MARKS = { "\194\161", "\194\191" } -- ¡ ¿

local function TrimSentBody(body)
	local trimmed = true
	while trimmed do
		trimmed = false
		body = body:gsub("%s+$", "")
		for _, mark in ipairs(CLOSING_MARKS) do
			if body:sub(-#mark) == mark then
				body = body:sub(1, -#mark - 1)
				trimmed = true
			end
		end
	end
	for _, mark in ipairs(OPENING_MARKS) do
		if body:sub(1, #mark) == mark then
			body = body:sub(#mark + 1)
		end
	end
	return body
end

local function SignOff(body)
	return MarkerPrefix() .. TrimSentBody(body) .. " // " .. L["ADDON_SHORT_NAME"]
end

function ns:BuildAnnounceMessage(formatKey, ...)
	local template = L[formatKey]
	if not template then
		return nil
	end
	return SignOff(string.format(template, ...))
end

function ns:Announce(channel, target, formatKey, ...)
	if not channel then
		return
	end
	local message = ns:BuildAnnounceMessage(formatKey, ...)
	if not message then
		return
	end
	C_ChatInfo.SendChatMessage(message, channel, nil, target)
end

--[[
    Unbranded, natural-language whisper for the manual Thank You Button only: a
    human-sounding message to your target, deliberately without the marker or
    add-on name. Links are legal in whispers, so pipes are not stripped.
]]
function ns:Whisper(target, message)
	if not target or not message or message == "" then
		return
	end
	C_ChatInfo.SendChatMessage(message, "WHISPER", nil, target)
end

--------------------------------------------------------------------------------
-- Emotes
--------------------------------------------------------------------------------

--[[
    The one place an emote reaches the client, through the namespaced call every
    target client ships. Returns its success flag, or nil when that comes back secret.
]]
local function PerformEmote(token, target)
	local success = C_ChatInfo.PerformEmote(token, target)
	if ns.IsPlain(success) then
		return success
	end
end

--[[
    Perform a random enabled emote from the given selection. `target` is what to
    direct the emote at: a live unit token ("target", "party3") when the caller
    holds one, else a bare character name the client may resolve to a visible
    player (never the combat log's "Name-Realm" form -- callers strip the realm).

    No target means NO emote. The undirected flavor ("You thank everyone around
    you.") is never what a caller wants here: it fires precisely when the buffer
    could not be resolved, and failing to resolve them is itself the evidence
    they are gone -- so it thanks an empty room and reads as a bug. Refusing it
    at the chokepoint instead of at each call site keeps the promise in one
    place: this add-on does not emote into the void.

    Trap for anyone tempted to pass a target straight through:
    C_ChatInfo.PerformEmote(token, nil) is NOT undirected -- it falls back to
    your CURRENT TARGET, thanking whatever bystander you happen to be pointing
    at. "none" is what actually forces the undirected flavor, and a name the
    client can't resolve degrades to it the same way; no API pre-tests a name,
    so that case still reaches here (see ResolveEmoteTarget in Praise.lua).
]]
function ns:DoRandomEmote(emotes, target)
	if not emotes or not target then
		return
	end
	--[[
        Driven by Data.EMOTES rather than by the saved table's own keys: a saved
        profile can hold keys that are not real emote tokens (a "YES" key, say),
        and picking one would be a silent no-op.
    ]]
	local available = {}
	for _, data in ipairs(Data.EMOTES) do
		if emotes[data.token] then
			available[#available + 1] = data.token
		end
	end
	if #available > 0 then
		PerformEmote(available[math.random(#available)], target)
	end
end

--[[
    Perform ONE specific emote, for the buttons that choose from a dropdown
    instead of randomising over a checklist.

    Validated against the CLIENT catalog rather than Data.EMOTES: that dropdown
    offers every emote this build has, which is far more than the twelve the
    praise panels curate. An unknown token is dropped rather than handed on,
    because C_ChatInfo.PerformEmote given a bad token is a silent no-op --
    indistinguishable, to whoever pressed the button, from the button being
    broken.
]]
function ns:DoEmoteToken(token, target)
	if not token or token == "" or not target then
		return
	end
	if not ns.IsClientEmote(token) then
		return
	end
	PerformEmote(token, target)
end

--------------------------------------------------------------------------------
-- Buff Announcements
--------------------------------------------------------------------------------

-- Tint a player's name with their class color; an unknown class leaves it plain.
local function ColorNameByClass(class, name)
	if class and Data.CLASS_COLORS[class] then
		return "|cff" .. Data.CLASS_COLORS[class] .. name .. "|r"
	end
	return name
end

local function ClassOf(guid)
	if guid then
		return (select(2, GetPlayerInfoByGUID(guid)))
	end
	return nil
end

--[[
    Item-driven buffs link the source item; everything else links the spell. A
    stranger buff carries no tracked entry, so a nil entry is simply the spell
    case. Resolved once by the caller and passed to whichever of the print and
    the whisper actually fire, since each has its own toggle and timing (see
    ns:WhisperThanks).
]]
function ns.GetBuffLink(entry, spellID)
	if entry and entry.itemId then
		local link = select(2, C_Item.GetItemInfo(entry.itemId))
		if link then
			return link
		end
	end
	return ns.GetSpellLink(spellID) or L["UNKNOWN_SPELL"]
end

--[[
    The print out for a tracked teammate buff or group service. The verb comes
    from the entry's type/detect: a solo buff "gave you", a group buff "gave your
    group", a service "set out" or "opened", an item used on you "used X on
    you", a cast "cast X on you".
]]
function ns:BuildTrackedMessage(entry, class, creditName, link)
	local name = ColorNameByClass(class, creditName)
	local message
	if entry.type == Data.BUFF.SERVICE then
		message = (entry.opened and L["MESSAGE_OPENED"] or L["MESSAGE_SET_OUT"]):format(name, link)
	elseif entry.type == Data.BUFF.GROUP then
		message = L["MESSAGE_GAVE_GROUP"]:format(name, link)
	elseif entry.itemId then
		message = L["MESSAGE_USED_ITEM"]:format(name, link)
	elseif entry.detect == Data.DETECT.CAST then
		message = L["MESSAGE_USED_SPELL"]:format(name, link)
	else
		message = L["MESSAGE_GAVE_YOU"]:format(name, link)
	end
	return message
end

function ns:AnnounceTracked(entry, creditGUID, creditName, link)
	ns:PrintMessage(ns:BuildTrackedMessage(entry, ClassOf(creditGUID), creditName, link))
end

--[[
    The thank-you whisper behind both the Strangers and the Teammates reactions.
    Separate from the prints above: the whisper is praise the other player sees
    and can be held back by the Praise Delay, while the print is your own
    heads-up and always fires immediately.
]]
function ns:WhisperThanks(target, link)
	ns:Announce("WHISPER", target, "MESSAGE_WHISPER_THANKS", link)
end

--[[
    The print out for any helpful buff from a non-grouped friendly player. Its
    thank-you whisper goes out through ns:WhisperThanks.
]]
function ns:BuildStrangerMessage(class, sourceName, link)
	return L["MESSAGE_BUFFED"]:format(ColorNameByClass(class, sourceName), link)
end

function ns:AnnounceStranger(sourceGUID, sourceName, link)
	ns:PrintMessage(ns:BuildStrangerMessage(ClassOf(sourceGUID), sourceName, link))
end

--------------------------------------------------------------------------------
-- Good News
--------------------------------------------------------------------------------

--[[
    Good News whispers are queued with a small gap instead of sent inline: a
    raid-wide buff (Prayer of Fortitude) lands on every recipient in the same
    instant, and a burst of same-frame whispers risks the server-side chat
    squelch. An empty queue still sends immediately, so the common
    one-recipient case feels instant.
]]
local WHISPER_GAP = 0.35
local nextWhisperAt = 0
local function QueueWhisper(target, message)
	local now = GetTime()
	local delay = nextWhisperAt - now
	if delay < 0 then
		delay = 0
	end
	nextWhisperAt = now + delay + WHISPER_GAP
	if delay == 0 then
		C_ChatInfo.SendChatMessage(message, "WHISPER", nil, target)
	else
		C_Timer.After(delay, function()
			C_ChatInfo.SendChatMessage(message, "WHISPER", nil, target)
		end)
	end
end

--[[
    Resolve the client's plural escape to plain text.

    Trap: WoW's own duration strings (D_MINUTES == "%d |4minute:minutes;") carry
    a |4 escape that the UI expands only at render time. It looks right in a
    print, but SendChatMessage rejects any message still holding one -- "Invalid
    escape code in chat message" -- and silently drops the whole line. Resolving
    it here is what lets the units come from the client's own localization in
    every language it ships, instead of TFTB carrying its own copies.

    Slavic locales list a third form (one/few/many) and get their rule; two-form
    languages take a simple count check; languages that don't inflect (zhCN,
    koKR) carry no escape at all, so the gsub finds nothing to do.
]]
local function ResolvePlurals(text)
	return (
		text:gsub("(%d+)(%s*)|4([^;]*);", function(count, gap, body)
			local forms = {}
			for form in body:gmatch("[^:]+") do
				forms[#forms + 1] = form
			end
			if #forms == 0 then
				return count .. gap
			end

			local number = tonumber(count) or 0
			local pick
			if #forms >= 3 then
				local mod10, mod100 = number % 10, number % 100
				if mod10 == 1 and mod100 ~= 11 then
					pick = forms[1] -- 1, 21, 31...
				elseif mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then
					pick = forms[2] -- 2-4, 22-24...
				else
					pick = forms[3]
				end
			else
				pick = (number == 1) and forms[1] or (forms[2] or forms[1])
			end
			return count .. gap .. pick
		end)
	)
end

--[[
    Durations run to round numbers, so the largest whole unit states one exactly.
    Exposed on ns so the Good News options panel can render its sample message
    through the real pipeline. `forceSeconds` keeps the seconds wording whatever
    the size: the rounding is right for a duration read as a length ("1 Minute"
    for 89s) but wrong for a fixed menu choice, where 89 would print as "1
    Minute" directly beneath "55 Seconds".

    Good News caps its clause below a minute (GOOD_NEWS_MAX_SECONDS) and the
    seconds dropdowns pass forceSeconds, but Return the Favor's 60-second choice
    reads as a minute. The hour rung stays because this formats whatever
    duration it is handed, and a later caller re-deriving the ladder would walk
    back into the plural-escape trap that ResolvePlurals exists to solve.
]]
local function FormatDuration(seconds, forceSeconds)
	seconds = math.floor((seconds or 0) + 0.5)
	local template, count
	if not forceSeconds and seconds >= 3600 then
		template, count = D_HOURS, math.floor(seconds / 3600 + 0.5)
	elseif not forceSeconds and seconds >= 60 then
		template, count = D_MINUTES, math.floor(seconds / 60 + 0.5)
	else
		template, count = D_SECONDS, seconds
	end
	return ResolvePlurals(template:format(count))
end
ns.FormatDuration = FormatDuration

--[[
    Only a SHORT duration is worth stating. "for 15 Seconds" tells the recipient
    to spend it now; "for 10 Minutes" is a number nobody acts on, and it pushes
    the ability name further from the front of a whisper that has one job. So the
    clause is capped: under a minute it prints, a minute or longer it is dropped
    and the whisper is just the ability.

    This cap is the LAST of the three ways a message ends up clause-less, and the
    only one that a real ticking timer can fail. The other two are settled before
    the duration ever reaches here, in Tracked-Lookups' givenLookup: a cast that
    leaves no aura (Rebirth, Lay on Hands, jumper cables) and a `noDuration`
    entry spent by an event rather than by time (Fear Ward, Misdirection) both
    carry no auraId at all, so nothing is ever read for them.
]]
local GOOD_NEWS_MAX_SECONDS = 60

--[[
    Build the Good News whisper from the player's own template.

    ONE token, %a, carrying the whole ability phrase: "[Power Infusion] for 15
    Seconds" when the buff has a short readable timer, plain "[Rebirth]" when it
    does not. Folding the duration in rather than exposing it as a second token
    is what lets a single template cover both cases -- there is no clause left
    dangling when a one-shot cast has no duration to report, so the template
    needs no conditional and the player needs no second variable.

    Substitution is gsub with a replacement FUNCTION, never string.format. The
    template is user-editable, so a stray % in it would make format raise an
    error mid-whisper; a replacement function also stops a % inside a spell link
    from being read back as a capture reference.
]]
local function BuildGoodNewsLine(template, link, duration)
	local ability = link or ""
	if duration and duration > 0 then
		--[[
		    Rounded up front, the same way FormatDuration would round it, so a 59.7s
		    aura is tested as the "60 Seconds" it would print as instead of slipping
		    under the cap and printing a full minute in seconds.
		]]
		local whole = math.floor(duration + 0.5)
		if whole < GOOD_NEWS_MAX_SECONDS then
			ability = ability .. " " .. string.format(L["GOOD_NEWS_DURATION_CLAUSE"], FormatDuration(whole))
		end
	end

	local body = template:gsub("%%a", function()
		return ability
	end)

	return SignOff(body)
end

function ns:BuildGoodNewsMessage(link, duration)
	local db = ns.db and ns.db.global.goodNews
	local template = db and db.message
	if type(template) ~= "string" or template:match("^%s*$") then
		template = L["DEFAULT_GOOD_NEWS"]
	end

	--[[
	    SendChatMessage rejects a line over 255 bytes, and %a can repeat, so a long
	    line falls back to the default template, then drops the duration; cutting it could break the link.
	]]
	local message = BuildGoodNewsLine(template, link, duration)
	if #message > ns.CHAT_MESSAGE_MAX_LENGTH then
		message = BuildGoodNewsLine(L["DEFAULT_GOOD_NEWS"], link, duration)
	end
	if #message > ns.CHAT_MESSAGE_MAX_LENGTH then
		message = BuildGoodNewsLine(L["DEFAULT_GOOD_NEWS"], link, nil)
	end
	return message
end

function ns:AnnounceGoodNews(entry, destName, spellID, duration)
	local link = ns.GetBuffLink(entry, spellID)
	local message = ns:BuildGoodNewsMessage(link, duration)
	if message then
		QueueWhisper(destName, message)
	end
end
