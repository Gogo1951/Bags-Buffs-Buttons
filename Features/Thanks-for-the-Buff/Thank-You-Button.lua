local _, ns = ...
local Data = ns.Data
local L = ns.L

--[[
    The manual thank-you feature: auto-created macros and the /thankyou commands
    that emote at and whisper your current target. Core's login sequence calls
    CreateAutoMacro; Options/Options.lua registers the slash commands against
    RunThankYou.

    There are several independent buttons, listed in Data.THANK_YOU_BUTTONS --
    each with its own macro, command, whisper text and emote selection, so one
    can thank a stranger and another can heckle a guildmate. Nothing here knows
    how many there are.
]]

--------------------------------------------------------------------------------
-- Auto Macro
--------------------------------------------------------------------------------

--[[
    The texture file ID a button's macro wears: its picked icon when this
    client's list offers it, otherwise the macros' own icon, since profiles
    travel between flavors.
]]
function ns.GetThankYouIcon(config)
	local picked = config and config.macroIcon
	for _, icon in ipairs(ns.THANK_YOU_MACRO_ICONS) do
		if icon[1] == picked then
			return picked
		end
	end
	return Data.THANK_YOU_DEFAULT_ICON
end

--[[
    Bring every button's macro in line with the profile: create the ones switched
    on that are missing, give the ones already there their picked icon, and
    delete the ones switched off that are still there. Runs at login and on
    every profile change, so a profile switch moves the macros with it instead
    of leaving the previous profile's on the bars until a reload.

    The global macro cap is re-read inside the loop, not hoisted: each macro this
    creates counts against it, so five buttons enabled at once on a nearly-full
    list must stop at the real limit rather than at the count taken before any of
    them existed.
]]
function ns.ReconcileMacros()
	if InCombatLockdown() or not ns.db then
		return
	end

	for _, button in ipairs(Data.THANK_YOU_BUTTONS) do
		local config = ns.db.global[button.profileKey]
		if config and config.createMacro then
			local icon = ns.GetThankYouIcon(config)
			local index = GetMacroIndexByName(button.macroName)
			if index == 0 then
				if GetNumMacros() < Data.MAX_GLOBAL_MACROS then
					CreateMacro(button.macroName, icon, button.command, nil)
				end
			elseif select(2, GetMacroInfo(index)) ~= icon then
				-- nil keeps the name and body, the way the game's own macro window edits one.
				EditMacro(index, nil, icon)
			end
		elseif config then
			--[[
			    Only a button we hold settings for is reconciled downward; a missing
			    config is not an instruction to delete anything.
			]]
			ns:DeleteAutoMacro(button)
		end
	end
end

--[[
    The login and options-toggle entry point; reconciling is the same work in both
    directions, so it has one implementation.
]]
function ns:CreateAutoMacro()
	ns.ReconcileMacros()
end

--[[
    Remove one button's macro, for when its Enable Macro toggle is turned off.

    Deletes by INDEX resolved from this button's exact name, never by a name
    match at delete time: DeleteMacro accepts a name, but resolving first lets
    the "does it exist" check and the delete agree on the same macro, and makes
    the no-op case explicit rather than relying on DeleteMacro tolerating a name
    that isn't there.

    Combat-guarded like creation is -- the macro API is unavailable in combat, so
    a toggle flipped mid-fight simply leaves the macro alone rather than erroring.
]]
function ns:DeleteAutoMacro(button)
	if InCombatLockdown() or not button then
		return
	end
	local index = GetMacroIndexByName(button.macroName)
	if index and index > 0 then
		DeleteMacro(index)
	end
end

--------------------------------------------------------------------------------
-- Thank You Command
--------------------------------------------------------------------------------

--[[
    Body of the /thankyou commands; the registration lives in Options/Options.lua,
    which passes the Data.THANK_YOU_BUTTONS entry that was invoked. A missing one
    falls back to button 1 rather than erroring.
]]
function ns.RunThankYou(button)
	--[[
	    A target whose identity is secret can't be checked or whispered, but the
	    emote only needs the "target" token.
	]]
	local identitySecret = ns.IsUnitIdentitySecret("target")
	if not UnitExists("target") or (not identitySecret and not UnitIsPlayer("target")) then
		ns:PrintMessage(L["MESSAGE_SELECT_PLAYER"])
		return
	end
	if not identitySecret and UnitIsUnit("target", "player") then
		ns:PrintMessage(L["MESSAGE_CANT_THANK_SELF"])
		return
	end

	local db = ns.db and ns.db.global[(button and button.profileKey) or "slash"]
	if not db then
		return
	end

	--[[
	    A single-emote button stores one token chosen from everything the client
	    offers, so it cannot go through DoRandomEmote -- that one is bounded by
	    Data.EMOTES, the curated twelve the praise panels use.
	]]
	if button and button.singleEmote then
		ns:DoEmoteToken(db.emote, "target")
	else
		ns:DoRandomEmote(db.emotes, "target")
	end

	if
		not identitySecret
		and UnitFactionGroup("player") == UnitFactionGroup("target")
		and db.message
		and db.message ~= ""
	then
		ns:Whisper(GetUnitName("target", true), db.message)
	end
end
