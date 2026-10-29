local _, ns = ...

-- What became of the casts the Buff Window and its key make: a buff refused for a stronger one, and resurrections.

local BuffWindow = ns.BuffWindow

--------------------------------------------------------------------------------
-- More Powerful Spell
--------------------------------------------------------------------------------

--[[
    How long after a click or Buff Key press a "more powerful spell" refusal
    still belongs to that cast; the error comes back from the server.
]]
local BOUNCE_WINDOW = 2
local lastAttempt -- { guid, unit, key, at }: the last buff cast the window or key made
-- The error type this client gives the refusal, learned from its text, for Diagnostics.
local bounceErrorType

--[[
    Forever has no combat log, so its SPELL_RESURRECT never arrives to keep a
    resurrected player's icon away while they decide to accept
    (BuffWindow.NoteResurrect). There, a resurrection the window or key cast is
    noted from the player's own cast going off instead.
]]
local RESURRECT_CAST_SECONDS = 15 -- a resurrection's cast time, with room for lag
local lastResurrect -- { guid, ids, expires }: the last resurrection the window or key cast, on Forever

function ns.OnResurrectCastSucceeded(unit, spellID)
	if not lastResurrect or unit ~= "player" or not ns.IsPlain(spellID) then
		return
	end
	if GetTime() > lastResurrect.expires then
		lastResurrect = nil
	elseif lastResurrect.ids[spellID] then
		BuffWindow.NoteResurrect(lastResurrect.guid)
		lastResurrect = nil
	end
end

-- Called from a window icon's PreClick and the Buff Key's, for every cast they make.
function ns.NoteBuffCastAttempt(spec)
	lastAttempt = nil
	if ns.FLAVOR == "Camelot" and spec and spec.isResurrection and spec.unit then
		local guid = UnitGUID(spec.unit)
		if guid and ns.IsPlain(guid) then
			local ids = {}
			for _, id in ipairs(spec.castIds or { spec.spellId }) do
				ids[id] = true
			end
			lastResurrect = { guid = guid, ids = ids, expires = GetTime() + RESURRECT_CAST_SECONDS }
		end
	end
	if not spec or not spec.buffKey then
		return
	end
	local guid = spec.favorGUID or (spec.unit and UnitGUID(spec.unit))
	if guid and ns.IsPlain(guid) then
		lastAttempt = { guid = guid, unit = spec.unit, key = spec.buffKey, at = GetTime() }
	end
end

-- Diagnostics' event-log filter asks whether an error type is the one this file acts on.
function ns.IsBuffBounceError(errorType)
	return bounceErrorType ~= nil and errorType == bounceErrorType
end

--[[
    The refusal names no target, so it is pinned on the cast the window or
    the Buff Key just made. A favor's macro leaves them targeted, so a unit
    is found for them by GUID. The text is the client's own
    SPELL_FAILED_AURA_BOUNCED, so it matches in every locale.
]]
local function OnUIErrorMessage(errorType, message)
	if not lastAttempt or not ns.IsPlain(message) or message ~= SPELL_FAILED_AURA_BOUNCED then
		return
	end
	if ns.IsPlain(errorType) and errorType ~= bounceErrorType then
		-- The event log counted this firing before the type was known; log it in full.
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEventNow("UI_ERROR_MESSAGE", errorType, message)
		end
		bounceErrorType = errorType
	end
	local attempt = lastAttempt
	lastAttempt = nil
	if GetTime() - attempt.at > BOUNCE_WINDOW then
		return
	end
	local unit = attempt.unit
	if not unit or UnitGUID(unit) ~= attempt.guid then
		unit = ns.GetUnitByGUID(attempt.guid)
	end
	if unit then
		BuffWindow.NoteBounce(unit, attempt.key)
		ns.RequestBuffWindowRefresh()
	end
end

ns.SetEventHandler("UI_ERROR_MESSAGE", OnUIErrorMessage)
