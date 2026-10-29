--[[
	The muteErrors option's macro lines: BBBMute(1) first and BBBMute() last, the one
	global a macro body reaches through /run. The game plays an error's sound (the "woosh", or the voice when
	error speech is on) as it shows the error, which for a spell pressed while not ready, short of power or out
	of range is while the macro's /cast line runs; muting sound effects and error speech around that line
	silences it, and the spell's own sound still plays, since the cast starts after the macro ends. Each
	setting is read first, written only when on, and put back to exactly what was read; a timer puts it back
	within a second should the macro's last line never run.
]]
local MUTED_CVARS = { "Sound_EnableSFX", "Sound_EnableErrorSpeech" }
local mutedValues -- cvar -> the value read before muting, while muted

local function RestoreSounds()
	if not mutedValues then
		return
	end
	for cvar, value in pairs(mutedValues) do
		C_CVar.SetCVar(cvar, value)
	end
	mutedValues = nil
end

function BBBMute(on)
	if not on then
		RestoreSounds()
		return
	end
	if mutedValues then
		return
	end
	mutedValues = {}
	for _, cvar in ipairs(MUTED_CVARS) do
		local value = C_CVar.GetCVar(cvar)
		if value and value ~= "0" then
			mutedValues[cvar] = value
			C_CVar.SetCVar(cvar, "0")
		end
	end
	C_Timer.After(1, RestoreSounds)
end
