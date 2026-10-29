local _, ns = ...

--[[
	The ranged weapon attacks (Throw, Shoot Bow, Shoot Gun, Shoot Crossbow) folded into one Shoot macro that
	casts the one for the weapon worn.
]]

local MacroBody = ns.MacroBody
local SpellName = ns.SpellName

local WEAPON_CLASS = 2 -- Enum.ItemClass.Weapon
local RANGED_SLOT = 18

--[[
	The name a [worn:] macro condition takes for a ranged attack's weapon (ns.RANGED_ATTACKS): the client's own
	for its item subclass ("Bows"), which the condition matches in every locale, or nil when the client can't
	name it.
]]
function ns.RangedWornName(attack)
	local subclassInfo = C_Item.GetItemSubClassInfo or GetItemSubClassInfo
	return subclassInfo and subclassInfo(WEAPON_CLASS, attack.subclass) or nil
end

--[[
	The Shoot macro's spell for the weapon in the ranged slot now, where the player knows it, else the macro's
	own (the first of them learned): its icon, its tooltip and the spell #showtooltip names. The cast line
	itself tries each by the weapon worn, so it never waits on this.
]]
local function EquippedRangedAttack(macro)
	local link = GetInventoryItemLink("player", RANGED_SLOT)
	local subclass = link and select(7, C_Item.GetItemInfoInstant(link))
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = attack.subclass == subclass and ns.SpellName(attack.id)
		if name and macro.rangedAttacks[name] then
			return name
		end
	end
	return macro.name
end

ns.EquippedRangedAttack = EquippedRangedAttack

--[[
	Folds the ranged weapon attacks (ns.RANGED_ATTACKS: Throw, Shoot Bow, Shoot Gun, Shoot Crossbow) into one
	Shoot macro when more than one is learned: only the one for the weapon worn works, so the one macro tries
	each by the weapon worn ("[worn:Bows] Shoot Bow", see CastBody in Features/Spellbook/Macro-Body.lua), and shows the
	one equipped (ns.CastSpellName), redrawn when the gear changes. The first of them learned
	carries it, with its settings, copies and WoW macro, so those stay put whatever is equipped; the others go
	off the page (hidden), their WoW macros still kept up to date where the player placed them.
]]
local function FoldRangedAttacks()
	local own = {}
	for _, macro in ipairs(ns.macros) do
		if not macro.copy and not macro.focus and not macro.rank and not macro.unlearned then
			own[macro.name] = macro
		end
	end
	local folded = {}
	for _, attack in ipairs(ns.RANGED_ATTACKS) do
		local name = SpellName(attack.id)
		if name and own[name] then
			folded[#folded + 1] = name
		end
	end
	if #folded < 2 then
		return
	end
	local carrier, attacks = folded[1], {}
	for _, name in ipairs(folded) do
		attacks[name] = true
	end
	-- the client's own name for Shoot, or the carrier's while that spell's data hasn't loaded
	local label = C_Spell.GetSpellName(ns.SHOOT_SPELL_ID) or carrier
	for _, macro in ipairs(ns.macros) do
		if macro.name == carrier and not macro.unlearned then
			macro.rangedAttacks = attacks
			macro.label = label .. (macro.copy and " " .. macro.copy or "")
			macro.sortName = label
			macro.icon = C_Spell.GetSpellTexture(ns.CastSpellName(macro)) or macro.icon
			macro.body = MacroBody(macro)
		elseif attacks[macro.name] and not macro.unlearned then
			macro.hidden = true
		end
	end
end

ns.FoldRangedAttacks = FoldRangedAttacks
