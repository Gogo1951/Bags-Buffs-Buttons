local _, ns = ...

-- Writes a page macro's text from its spell and the options the player turned on (Features/Spellbook/Macro-Options.lua).

--[[
	A macro conditional joining the given conditions (nil or "" ones are skipped), e.g.
	"[@mouseover,harm,nodead]". Returns "" when there is nothing to check, so a plain cast stays "/cast Name".
]]
local function Condition(...)
	local parts = {}
	for i = 1, select("#", ...) do
		local c = select(i, ...)
		if c and c ~= "" then
			parts[#parts + 1] = c
		end
	end
	return #parts > 0 and "[" .. table.concat(parts, ",") .. "]" or ""
end

--[[
	A /cast trying each clause in turn. A clause is { condition, unit, spell }: the condition ("" for none),
	and the spell the clause casts, or spellFor(unit) without one. Neighbouring clauses that cast the same spell share it
	("[@mouseover,help,nodead][] Name"), and a lone clause with nothing to check drops its brackets, so a plain
	cast stays "/cast Name". With reset ("combat", "target" or both as "combat/target") the line is a
	/castsequence of the spell then nothing, so it casts once until that reset.
]]
local function CastLine(clauses, spellFor, reset)
	local groups = {}
	for _, clause in ipairs(clauses) do
		local condition = Condition(clause[1])
		local spell = clause[3] or spellFor(clause[2])
		local last = groups[#groups]
		if last and last.spell == spell then
			last.condition = last.condition .. (condition ~= "" and condition or "[]")
		else
			groups[#groups + 1] = { condition = condition, spell = spell }
		end
	end
	local parts = {}
	for i, g in ipairs(groups) do
		parts[i] = (g.condition ~= "" and g.condition .. " " or "")
			.. (reset and "reset=" .. reset .. " " or "")
			.. g.spell
			.. (reset and ", NULL" or "")
	end
	return (reset and "/castsequence " or "/cast ") .. table.concat(parts, "; ")
end

--[[
	A rank can go on a player at most this many levels below the level it is learned at; lower than that,
	the cast fails with "Target is too low level".
]]
local RANK_LEVEL_GAP = 10

--[[
	The rank text ("Rank 4") the targetRank option casts on unit: the highest known rank its level can
	take, or nil for the highest rank, which a plain cast already picks. A unit that isn't there, or that
	can't be helped, means the cast lands on the player; an unknown level (UnitLevel's -1, a target too far
	above to show) takes the highest rank too.
]]
local function RankFor(ranks, unit)
	if not unit or unit == "player" or not UnitExists(unit) or not UnitCanAssist("player", unit) then
		return nil
	end
	local level = UnitLevel(unit)
	if not level or level <= 0 then
		return nil
	end
	for i, rank in ipairs(ranks) do
		if level >= rank.level - RANK_LEVEL_GAP then
			return i > 1 and rank.text or nil
		end
	end
	return ranks[#ranks].text -- too low for any rank; the lowest fails with the game's own message
end

--[[
	The body MacroBody gives a spell macro with no options on, which does just what the plain spell does,
	before its tag line (see ns.TaggedBody, in Features/Spellbook/Macro-Tags.lua).
]]
function ns.BareBody(name)
	return "#showtooltip\n/cast " .. name
end

--[[
	A stance's slot on the stance bar (the n of [stance:n]), or nil when unknown. A Warrior stance not learned
	yet takes its slot from the class lists' stanceSlots, the order they are learned in.
]]
local function StanceSlot(stance)
	local c = ns.ClassConfig()
	local stanceId = c.stanceIds[stance]
	for i = 1, GetNumShapeshiftForms() do
		local spellID = select(4, GetShapeshiftFormInfo(i))
		if spellID and spellID == stanceId then
			return i
		end
	end
	return c.stanceSlots[stance]
end

--[[
	A line switching to the first of a spell's stances unless already in one of them, e.g.
	"/cast [nostance:1/3] Battle Stance\n", or "" when the first stance's slot is unknown.
]]
local function StanceLine(stances)
	if not StanceSlot(stances[1]) then
		return ""
	end
	local slots = {}
	for _, stance in ipairs(stances) do
		slots[#slots + 1] = StanceSlot(stance)
	end
	return "/cast [nostance:" .. table.concat(slots, "/") .. "] " .. stances[1] .. "\n"
end

--[[
	The stances a spell can be cast in, the one to switch to first, or nil for a spell that needs none. Only
	the class lists' stances count: a spell's tooltip names the stances' form names, which some locales (esES)
	name differently from the stance spells, so it can't be matched against them.
]]
function ns.StancesOf(name)
	local c = ns.ClassConfig()
	if not c.hasStances then
		return nil
	end
	return c.stances[name]
end

--[[
	A target priority's clauses (see ns.TargetPriority), target being the spell's help, harm or exists and life
	the unit's state it needs, "nodead", or "dead" for a resurrection: each unit only when it can take the
	spell, then a plain cast. The target last is that plain cast, and the player always takes it, so nothing
	after the player is ever tried.
]]
local function TargetClauses(list, target, life)
	local clauses = {}
	for i, unit in ipairs(list) do
		if unit == "player" then
			clauses[#clauses + 1] = { "@player", "player" }
			return clauses
		elseif unit == "target" then
			if i == #list then
				break
			end
			clauses[#clauses + 1] = { target .. "," .. life, "target" }
		else
			clauses[#clauses + 1] = { "@" .. unit .. "," .. target .. "," .. life, unit }
		end
	end
	clauses[#clauses + 1] = { "", "target" }
	return clauses
end

local function CastBody(macro)
	--[[
		The lines, in the order written: one /stopmacro for stopIfChanneling's [channeling],
		stopIfStealthed's [stealth] and the combat check's [nocombat] or [combat], so a press can't break a
		channel or stealth, and on the wrong side of the combat check does nothing at all, not even its item
		or attack lines, ahead of the mute so a stopped press never leaves the sounds muted; muteErrors' mute; stopAttack's /stopattack; stopCast's
		/stopcasting; cancelForm's /cancelform; targetEnemy's /targetenemy, for when there is no living hostile
		target, and targetFriend's /targetfriend, for when there is no living friendly one; the useItems slots, in the order ticked; the stance switch; then the cast, its Conditionals rows first. oncePerCombat makes the
		cast a /castsequence that casts once until combat ends or the target changes, oncePerTarget one that
		casts once until the target changes. With items, a stance switch or a cast sequence, #showtooltip
		names the spell so the button shows the spell.
	]]
	local combatCheck = ns.CombatCheck(macro)
	local stops = (ns.IsOptionOn(macro, "stopIfChanneling") and "[channeling]" or "")
		.. (ns.IsOptionOn(macro, "stopIfStealthed") and "[stealth]" or "")
		.. (combatCheck == "combatOnly" and "[nocombat]" or combatCheck == "noCombat" and "[combat]" or "")
	-- oncePerCombat also resets when the target changes, so a new pull mid-combat can take the cast again
	local perCombat = ns.IsOptionOn(macro, "oncePerCombat")
	local perTarget = perCombat or ns.IsOptionOn(macro, "oncePerTarget")
	local reset = perCombat and "combat/target" or perTarget and "target" or nil
	local stopCast = ns.IsOptionOn(macro, "stopCast") and "/stopcasting\n"
	local useLines = {}
	for i, slot in ipairs(ns.UseItemSlots(macro)) do
		useLines[i] = "/use " .. slot .. "\n"
	end
	local use = table.concat(useLines)
	local stance = ns.IsOptionOn(macro, "stance") and StanceLine(macro.stances) or ""
	--[[
		a /castsequence's button would show the step after the cast, so it names the spell too, and a summon
		macro casting its pet's ability names the ability while the pet is out, as its cast line does.
	]]
	local namesSpell = stance ~= "" or use ~= "" or reset ~= nil
	-- the spell cast: the spell's own, or the one its Grouped Spells picks
	local cast = ns.CastSpellName(macro)
	local shown = cast
	if ns.IsOptionOn(macro, "pet") then
		shown = "[pet:" .. macro.petFamily .. "] " .. macro.petAbility .. "; " .. shown
	end
	local header = "#showtooltip"
		.. (namesSpell and " " .. shown or "")
		.. "\n"
		.. (stops ~= "" and "/stopmacro " .. stops .. "\n" or "")
		.. (ns.IsOptionOn(macro, "muteErrors") and "/run BBBMute(1)\n" or "")
		.. (ns.IsOptionOn(macro, "stopAttack") and "/stopattack\n" or "")
		.. (stopCast or "")
		.. (ns.IsOptionOn(macro, "cancelForm") and "/cancelform\n" or "")
		.. (ns.IsOptionOn(macro, "targetEnemy") and "/targetenemy [noexists][dead][help]\n" or "")
		.. (ns.IsOptionOn(macro, "targetFriend") and "/targetfriend [noexists][dead][harm]\n" or "")
		.. use
		.. stance
	--[[
		the noToggle option casts "!Name", which refreshes a form or aspect that is on instead of cancelling
		it; the targetRank option names the highest rank each clause's unit can take, by its level now
	]]
	local prefix = ns.IsOptionOn(macro, "noToggle") and "!" or ""
	-- the ranks are the spell's own, so a grouped spell cast in its place takes its highest
	local ownSpell = cast == macro.name
	local targetRank = ownSpell and ns.IsOptionOn(macro, "targetRank")
	local fixedRank = ownSpell and ns.FixedRank(macro)
	local name = cast
	local target = macro.target
	local function spellFor(unit)
		local rank = fixedRank or (targetRank and macro.ranks and RankFor(macro.ranks, unit))
		return prefix .. name .. (rank and "(" .. rank .. ")" or "")
	end
	local spell = spellFor(nil)
	--[[
		who the cast tries, in turn: the focus copy its focus then the target; else its target priority. A
		resurrection looks for a dead unit, every other spell a living one
	]]
	local life = macro.kind == "resurrect" and "dead" or "nodead"
	local clauses
	if macro.focus then
		clauses = { { "@focus," .. target .. "," .. life, "focus" }, { "", "target" } }
	else
		clauses = TargetClauses(ns.TargetPriority(macro), target, life)
	end
	if ns.IsOptionOn(macro, "cursor") then
		clauses = { { "@cursor" } }
	end
	--[[
		the Shoot macro tries each ranged attack it stands for, each only with its weapon worn, on the same units
		in the same order: "[worn:Thrown] Throw; [worn:Bows] Shoot Bow; ...", so a weapon swapped mid-fight
		needs no rewrite
	]]
	if macro.rangedAttacks then
		local worn = {}
		for _, attack in ipairs(ns.RANGED_ATTACKS) do
			local attackName = ns.SpellName(attack.id)
			local wornName = ns.RangedWornName(attack)
			-- a weapon the client can't name gets no clause, rather than an English one that never matches
			if attackName and wornName and macro.rangedAttacks[attackName] then
				local condition = "worn:" .. wornName
				for _, clause in ipairs(clauses) do
					local unitCondition = clause[1] or ""
					worn[#worn + 1] = {
						(unitCondition ~= "" and unitCondition .. "," or "") .. condition,
						clause[2],
						prefix .. attackName,
					}
				end
			end
		end
		clauses = worn
	end
	--[[
		a right-click casts the group (or single) version on the same units in the same order, ahead of every
		left-click clause; with Dynamic Rank it takes the highest of its own ranks each unit's level can take,
		so a right-click Power Word: Fortitude on a low-level target doesn't fail as too low level
	]]
	if ns.IsOptionOn(macro, "groupVersion") then
		local rightClick, ranks = ns.RightClickSpell(macro), macro.rightClickRanks
		local dynamic = ns.IsOptionOn(macro, "targetRank") and ranks
		local clicks = {}
		for i, clause in ipairs(clauses) do
			local rank = dynamic and RankFor(ranks, clause[2])
			clicks[i] = {
				"btn:2" .. ((clause[1] or "") ~= "" and "," .. clause[1] or ""),
				clause[2],
				rightClick .. (rank and "(" .. rank .. ")" or ""),
			}
		end
		for _, clause in ipairs(clauses) do
			clicks[#clicks + 1] = clause
		end
		clauses = clicks
	end
	if ns.IsOptionOn(macro, "pet") then
		-- [pet:X] matches the pet's creature family, so another demon being out still summons this one
		clauses = { { "pet:" .. macro.petFamily, nil, macro.petAbility }, { "", nil, spell } }
		reset = nil
	end
	--[[
		the Conditionals rows (Features/Spellbook/Conditionals.lua) come first, in their order, each a plain cast
		of its own spell, so the first that matches casts and the macro's own clauses are what is left:
		"[mod:shift] Frost Nova; [spec:2,mod:alt] Blizzard; [@mouseover,harm,nodead][] Fireball". In a cast
		sequence each row's spell casts once until the same reset, as the macro's own does.
	]]
	local rows = ns.ConditionalClauses(macro)
	for _, clause in ipairs(clauses) do
		rows[#rows + 1] = clause
	end
	return header .. CastLine(rows, spellFor, reset)
end

--[[
	After the cast: the autoShot option starts Auto Shot (or the wand's Shoot) with "!", which never stops
	it; the startAttack option starts melee, never while stealthed (Stealth, Prowl, Shadowmeld), where Pick
	Pocket, Sap or Distract would pull the player out of it; the petAttack option sends the pet in; the
	hideErrors option clears the red error text the macro's failed lines leave; the muteErrors option, last,
	puts back the sounds its first line muted. The tag line ends it.
]]
function ns.MacroBody(macro)
	return ns.TaggedBody(
		macro,
		CastBody(macro)
			.. (ns.IsOptionOn(macro, "autoShot") and "\n/cast !" .. ns.ClassConfig().autoShot or "")
			.. (ns.IsOptionOn(macro, "startAttack") and "\n/startattack [nostealth]" or "")
			.. (ns.IsOptionOn(macro, "petAttack") and "\n/petattack" or "")
			.. (ns.IsOptionOn(macro, "hideErrors") and "\n/run UIErrorsFrame:Clear()" or "")
			.. (ns.IsOptionOn(macro, "muteErrors") and "\n/run BBBMute()" or "")
	)
end
