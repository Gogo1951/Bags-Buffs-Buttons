local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Client Emote Catalog
--------------------------------------------------------------------------------

--[[
    Every emote the RUNNING client can perform, read from its own EMOTE<n>_TOKEN
    and EMOTE<n>_CMD<n> globals rather than from a list kept in this add-on.

    Deliberately not a data file. The set differs per expansion, so a
    hand-maintained copy would be correct on exactly one client and quietly wrong
    on the others -- and it is a long list to get wrong. Reading the client means
    a dropdown built from this offers precisely what this build can perform, and
    Diagnostics can export the same list from any flavour without a code change.

    Two traps the scan has to respect. Indices are SPARSE (Era jumps 171 -> 304),
    so it cannot stop at the first gap. And a few tokens appear twice under
    different indices (INCOMING, FLEE), so tokens are deduped -- the dropdown
    should not offer the same emote twice.

    Sorted by the slash command players recognise, not by token or index. Built
    once on demand; these globals do not change during a session.
]]
local EMOTE_SCAN_CEILING = 1000 -- backstop only, for a client without MAXEMOTEINDEX

local emoteCatalog, emoteTokens

local function BuildEmoteCatalog()
	emoteCatalog, emoteTokens = {}, {}

	--[[
	    The client's own list of emotes that play a voice line. Absent on some
	    builds, in which case the voice column simply reads unknown.
	]]
	local voice = {}
	if type(TextEmoteSpeechList) == "table" then
		for _, entry in pairs(TextEmoteSpeechList) do
			voice[tostring(entry)] = true
		end
	end

	for index = 1, (MAXEMOTEINDEX or EMOTE_SCAN_CEILING) do
		local token = _G["EMOTE" .. index .. "_TOKEN"]
		if token and not emoteTokens[token] then
			--[[
			    CMD1 is the primary; the rest are aliases, and the client repeats the
			    whole set once per locale, so exact repeats are dropped.
			]]
			local aliases, seen = {}, {}
			for c = 1, 8 do
				local command = _G["EMOTE" .. index .. "_CMD" .. c]
				if command and command ~= "" and not seen[command] then
					seen[command] = true
					aliases[#aliases + 1] = command
				end
			end
			local entry = {
				index = index,
				token = token,
				command = aliases[1] or ("/" .. token:lower()),
				aliases = table.concat(aliases, " "),
				voice = voice[token] == true,
			}
			emoteTokens[token] = entry
			emoteCatalog[#emoteCatalog + 1] = entry
		end
	end

	table.sort(emoteCatalog, function(a, b)
		return a.command < b.command
	end)
end

-- Every client emote, sorted by slash command.
function ns.GetEmoteCatalog()
	if not emoteCatalog then
		BuildEmoteCatalog()
	end
	return emoteCatalog
end

-- Is this token something the running client can actually perform?
function ns.IsClientEmote(token)
	if not emoteTokens then
		BuildEmoteCatalog()
	end
	return token ~= nil and emoteTokens[token] ~= nil
end

-- The slash command this client gives an emote token, in its own language.
function ns.GetEmoteCommand(token)
	if not emoteTokens then
		BuildEmoteCatalog()
	end
	local entry = emoteTokens[token]
	return entry and entry.command or ("/" .. token:lower())
end

--------------------------------------------------------------------------------
-- Spell Links
--------------------------------------------------------------------------------

--[[
    Chat-safe spell link, built by hand the way Control Freak does. We deliberately
    do NOT prefer the native GetSpellLink: on Classic it returns a link WITHOUT the
    trailing ":0" glyph field, which renders fine in a local tooltip or print, but
    SendChatMessage's hyperlink validator strips a link without it and leaves only
    the bare spell name. Building "Hspell:<id>:0"
    ourselves passes that validator and works in both chat and local prints.

    Native is only a last resort, for the rare spell whose name won't resolve (so we
    can't build the link text ourselves) -- at least it gives something on screen.

    The link's color is ns.SPELL_LINK_COLOR (Data/Data.lua), lowercased as the
    client writes it, since this string is handed to SendChatMessage's
    hyperlink validator.
]]
local C_SPELL_LINK = ns.SPELL_LINK_COLOR:lower()

function ns.GetSpellLink(spellId)
	local name = C_Spell.GetSpellName(spellId)
	if name then
		return ("|cff" .. C_SPELL_LINK .. "|Hspell:%d:0|h[%s]|h|r"):format(spellId, name)
	end
	local link = C_Spell.GetSpellLink(spellId)
	if link and link ~= "" then
		return link
	end
	return nil
end

--------------------------------------------------------------------------------
-- GUID Helpers
--------------------------------------------------------------------------------

--[[
    Is this GUID a player character? The client stamps every GUID with its own
    type -- "Player-<realm>-<hex>" for characters, "Pet-...", "Creature-...",
    "Vehicle-..." for everything else -- which makes this the authoritative test,
    independent of the combat log's TYPE_PLAYER flag. It guards the whisper
    paths: a whisper addressed to a pet bounces back as "No player named 'X' is
    currently playing", so a pet name must never reach SendChatMessage.
]]
function ns.IsPlayerGUID(guid)
	return type(guid) == "string" and guid:sub(1, 7) == "Player-"
end

--------------------------------------------------------------------------------
-- Sound
--------------------------------------------------------------------------------

--[[
    The sound plays on the Master channel so it stays audible for players who
    run with game sound effects turned down. The file name must match
    Includes/Sounds/ exactly.
]]
local SOUND_ROOT = "Interface/AddOns/" .. ADDON_NAME .. "/Includes/Sounds/"

-- Any buff landing on you shares this one, stranger or teammate alike.
function ns.PlayBuffSound()
	PlaySoundFile(SOUND_ROOT .. "Buff.ogg", "Master")
end

--------------------------------------------------------------------------------
-- Aura API Compatibility
--------------------------------------------------------------------------------

--[[
    Duration of a HELPFUL aura on `unit` for `spellId`, or nil when absent. A live
    buff can legitimately report 0 (no timer), so callers must nil-check the result,
    not test it for truthiness. 40 is the aura cap the client exposes.
]]
function ns.GetBuffDuration(unit, spellId)
	for i = 1, 40 do
		local data = C_UnitAuras.GetBuffDataByIndex(unit, i, "HELPFUL")
		if not data then
			return nil
		end
		if ns.IsPlain(data.spellId) and data.spellId == spellId then
			return data.duration or 0
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Unit Resolution
--------------------------------------------------------------------------------

--[[
    A usable emote target must be a live unit token: C_ChatInfo.PerformEmote
    only directs "you cheer at X" at a real unit, and a combat-log name is not
    one -- cross-realm sources arrive as "Name-Realm" and never resolve. Map the
    buffer's GUID to a unit we actually have (the player, a group member, or the
    current target / focus / mouseover) and return nil when none matches; the
    emote caller then falls back to the bare name, which still degrades to the
    undirected emote when the client can't resolve it.
]]
local POINTED_UNITS = { "target", "focus", "mouseover" }

function ns.GetUnitByGUID(guid)
	if not guid then
		return nil
	end
	if UnitGUID("player") == guid then
		return "player"
	end
	local prefix, count = "party", 4
	if IsInRaid() then
		prefix, count = "raid", 40
	end
	for i = 1, count do
		local unit = prefix .. i
		if UnitExists(unit) and UnitGUID(unit) == guid then
			return unit
		end
	end
	for _, unit in ipairs(POINTED_UNITS) do
		if UnitExists(unit) and UnitGUID(unit) == guid then
			return unit
		end
	end
	return nil
end
