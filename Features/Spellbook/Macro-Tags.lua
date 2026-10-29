local _, ns = ...

--[[
	The macro tag register: the tag line every macro the add-on writes ends with, and the account-wide register
	that hands the tags out. Features/Spellbook/Macro-Body.lua writes the text the tag line ends.
]]

--[[
	The tag line that ends every macro the add-on writes, "#4K", kept as short as it can be since it costs
	the player macro text. WoW runs only the "#" lines it knows (#showtooltip, #show), so the line does
	nothing; it names the page macro the WoW macro is for, whatever the macro is called, so the page finds its
	macros by tag rather than by name. Only the body's last line is read as a tag, so a short "#" line
	higher up in a macro is never taken for one. The tag is two of the 62 digits
	and letters, handed out in turn from an account-wide register (ns.db.global.macroTags), so no two macros
	ever share one, which a hash this short couldn't promise; past 3,843 tags they run to three. A page macro
	gets its tag only when a WoW macro is written for it (ns.AssignMacroTag); until then its body carries "00",
	which is never handed out, so its length is already right. The register is keyed by what the macro is
	for: this character's key with the spell's full name, so a character finds only its own.
]]
local TAG_PREFIX = "#"
local TAG_DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local TAG_WIDTH = 2
local UNASSIGNED_TAG = "00"

--[[
	The character a macro the add-on writes belongs to, as AceDB names it in its profile list. Read from the
	client rather than ns.db.keys.char, which AceDB can take from the client's placeholder name before the
	character is named (see Features/Core.lua), and which would then be one key for several characters.
]]
function ns.MacroOwnerKey()
	return ns.GetCharacterProfileName() or ns.db.keys.char
end

local function MacroIdentity(macro)
	local kind = macro.focus and "focus"
		or macro.copy and "copy" .. macro.copy
		or macro.rank and "rank " .. macro.rank
		or "spell"
	return ns.MacroOwnerKey() .. ":" .. kind .. ":" .. macro.name
end

-- The register key of this character's own macro for a spell, by the spell's name.
local function SpellIdentity(name)
	return MacroIdentity({ name = name })
end

-- Whether a WoW macro was ever written for this character's own macro for a spell.
function ns.HasSpellMacroTag(name)
	return ns.db.global.macroTags[SpellIdentity(name)] ~= nil
end

-- Moves one macro's tag from the first spell's identity to the second's, when the second has none yet.
local function MoveTag(fromMacro, toMacro)
	local tags, fromIdentity, toIdentity = ns.db.global.macroTags, MacroIdentity(fromMacro), MacroIdentity(toMacro)
	if not tags[fromIdentity] or tags[toIdentity] then
		return false
	end
	tags[toIdentity], tags[fromIdentity] = tags[fromIdentity], nil
	return true
end

--[[
	Moves the tag of one spell's macro to another spell's, when that spell has no tag of its own yet, so the
	WoW macro written for the first is found, rewritten and renamed as the second's (see ns.HandOverMacro).
	Its focus copy's tag and each Duplicate's (copies, the first spell's copy numbers) move with it. Returns
	whether the spell's own tag moved.
]]
function ns.HandOverMacroTag(from, to, copies)
	if not MoveTag({ name = from }, { name = to }) then
		return false
	end
	MoveTag({ name = from, focus = true }, { name = to, focus = true })
	for _, number in ipairs(copies) do
		MoveTag({ name = from, copy = number }, { name = to, copy = number })
	end
	return true
end

-- The nth tag, n from 1: n in base 62, padded to TAG_WIDTH digits.
local function TagNumber(n)
	local base, digits = #TAG_DIGITS, ""
	repeat
		local digit = n % base
		digits = TAG_DIGITS:sub(digit + 1, digit + 1) .. digits
		n = math.floor(n / base)
	until n == 0
	return string.rep("0", TAG_WIDTH - #digits) .. digits
end

function ns.MacroTag(macro)
	return ns.db.global.macroTags[MacroIdentity(macro)] or UNASSIGNED_TAG
end

-- The tag a WoW macro's body carries, or nil for a macro the add-on didn't tag.
function ns.BodyTag(body)
	local tag = body and ("\n" .. body):match("\n" .. TAG_PREFIX .. "(%w%w%w?)\n*$")
	return tag ~= UNASSIGNED_TAG and tag or nil
end

-- body, less any trailing blank lines, with the macro's tag line added at its end.
function ns.TaggedBody(macro, body)
	return (body:gsub("\n+$", "")) .. "\n" .. TAG_PREFIX .. ns.MacroTag(macro)
end

-- body without its tag line, as the page shows macro text.
function ns.UntaggedBody(body)
	return (("\n" .. body):gsub("\n" .. TAG_PREFIX .. "%w%w%w?\n*$", ""):sub(2))
end

--[[
	Hands the page macro the next tag, once, as a WoW macro is about to be written for it, and puts the tag in
	its body. A macro that has one keeps it. A tag some WoW macro's body already carries is skipped, whoever
	wrote it: Macro Spellbook's macros carry tags from the same sequence, and a lookup by tag would otherwise
	find one of them and rewrite it.
]]
function ns.AssignMacroTag(macro)
	local global = ns.db.global
	local identity = MacroIdentity(macro)
	if global.macroTags[identity] then
		return
	end
	local inUse = ns.ReadMacroIndexes().tags
	local tag
	repeat
		global.macroTagCount = global.macroTagCount + 1
		tag = TagNumber(global.macroTagCount)
	until not inUse[tag]
	global.macroTags[identity] = tag
	macro.body = ns.TaggedBody(macro, ns.UntaggedBody(macro.body))
end
