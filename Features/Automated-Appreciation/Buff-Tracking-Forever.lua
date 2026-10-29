local _, ns = ...
local Data = ns.Data

local GetAuraEntry = ns.GetAuraEntry
local HandleStrangersBuff = ns.HandleStrangersBuff
local HandleTracked = ns.HandleTracked
local GetPetOwnerUnit = ns.GetPetOwnerUnit

--[[
    Buff detection on WoW Forever, which has no combat log for an add-on: the
    auras added to you, read off UNIT_AURA, credited to whoever cast them. The
    rest of the engine is Buff-Tracking.lua's.
]]

--[[
    Who to credit for an aura on you, as creditGUID, creditName, and the unit token
    we hold for them (nil for a stranger we can only name). Same rule as
    ResolveSource: a player or nobody, with a pet traded for its owner.

    The aura's sourceUnit is the first choice: a group token for a teammate, a
    nameplate token for a stranger. A stranger without a nameplate leaves it nil,
    so the caster is then read from the aura itself by GUID and named with
    UnitNameFromGUID -- no unit token needed. That GUID may still belong to a
    teammate whose token the aura didn't carry, so the group is checked first.
]]
local function ResolveAuraCaster(aura)
	local sourceUnit = aura.sourceUnit
	local creditUnit
	if sourceUnit then
		if not ns.IsPlain(sourceUnit) then
			return nil
		end
		local sourceGUID = UnitGUID(sourceUnit)
		if not sourceGUID or not ns.IsPlain(sourceGUID) then
			return nil
		end
		creditUnit = ns.IsPlayerGUID(sourceGUID) and sourceUnit or GetPetOwnerUnit(sourceGUID)
	else
		local instanceID = aura.auraInstanceID
		if not instanceID or not ns.IsPlain(instanceID) then
			return nil
		end
		local ok, casterGUID = pcall(C_UnitAuras.GetAuraCasterGUID, "player", instanceID)
		if not ok or not casterGUID or not ns.IsPlain(casterGUID) then
			return nil
		end
		local isPlayer = ns.IsPlayerGUID(casterGUID)
		creditUnit = isPlayer and ns.GetUnitByGUID(casterGUID) or GetPetOwnerUnit(casterGUID)
		if not creditUnit then
			if not isPlayer then
				return nil
			end
			-- A stranger out of nameplate range: name them from the GUID alone.
			local name, realm = UnitNameFromGUID(casterGUID)
			if not name or not ns.IsPlain(name) or name == "" then
				return nil
			end
			-- Whispers need "Name-Realm" across realms, and a realm name has no spaces there.
			if realm and ns.IsPlain(realm) and realm ~= "" then
				name = name .. "-" .. realm:gsub("%s", "")
			end
			return casterGUID, name, nil
		end
	end

	local creditGUID = creditUnit and UnitGUID(creditUnit)
	local creditName = creditUnit and GetUnitName(creditUnit, true)
	if not (creditGUID and creditName and ns.IsPlain(creditGUID) and ns.IsPlain(creditName)) then
		return nil
	end
	return creditGUID, creditName, creditUnit
end

--[[
    Forever has no combat log, so buffs on you are read from UNIT_AURA instead.
    Nothing is read while C_Secrets reports auras secret or while you are in
    combat, so a buff that lands then is skipped, never queued. Only newly added auras count; a recast of a buff you already have is
    not seen.
]]
local function HandleAddedAura(aura)
	local spellID = aura.spellId
	if not (ns.IsPlain(spellID) and ns.IsPlain(aura.isHelpful)) then
		return
	end
	if not aura.isHelpful then
		return
	end

	local creditGUID, creditName, creditUnit = ResolveAuraCaster(aura)
	if not creditGUID or creditGUID == ns.GetPlayerGUID() then
		return
	end

	if creditUnit and (UnitInParty(creditUnit) or UnitInRaid(creditUnit)) then
		local entry = GetAuraEntry(spellID)
		if entry and entry.type ~= Data.BUFF.SERVICE then
			HandleTracked(entry, spellID, creditGUID, creditName, ns.GetPlayerGUID())
		end
	elseif ns.IsPlayerGUID(creditGUID) then
		--[[
		    Only a unit can be asked whether it's friendly. A player we know by GUID
		    alone just put a helpful buff on you, which the other faction can't do.
		]]
		if creditUnit then
			local isFriend = UnitIsFriend("player", creditUnit)
			if not (ns.IsPlain(isFriend) and isFriend) then
				return
			end
		end
		HandleStrangersBuff(creditGUID, creditName, spellID)
		if ns.NoteFavor then
			ns.NoteFavor(creditGUID, creditName)
		end
	end
end

--[[
    The first gate that stops Forever's buff detection from reading an aura
    update, or nil when it goes on: OnUnitAura below checks it, and the
    Diagnostics event log names it (ns:LogAuraUpdateInfo), so the two can never
    disagree.
]]
local function AuraGate()
	if not ns.IsBuffTrackingReady() then
		return "not ready"
	elseif not ns.db then
		return "no db"
	elseif InCombatLockdown() then
		return "in combat"
	elseif ns.AreAurasSecret() then
		return "auras secret"
	end
end

ns.BuffAuraGate = AuraGate

-- Forever's buff detection, from Buff-Tracking.lua's UNIT_AURA handler: the auras just added to you.
function ns.OnForeverPlayerAura(updateInfo)
	if ns.diagnostics and ns.diagnostics.logging and ns.LogAuraUpdateInfo then
		ns:LogAuraUpdateInfo(updateInfo)
	end
	if AuraGate() then
		return
	end
	if not updateInfo or not ns.IsPlain(updateInfo.isFullUpdate) or updateInfo.isFullUpdate then
		return
	end
	local added = updateInfo.addedAuras
	if not added or not ns.IsPlain(added) then
		return
	end

	for _, aura in ipairs(added) do
		HandleAddedAura(aura)
	end
end
