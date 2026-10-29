local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

local SubRow = ns.OptionsSubRow
local SubLabel = ns.OptionsSubLabel

--------------------------------------------------------------------------------
-- Restocker Panel
--------------------------------------------------------------------------------

--[[
    The Restocker's settings live on ns.db.global.restocker, bound to
    ns.restockSettings at PLAYER_LOGIN. They are account-wide rather than
    per-character, which is why these controls read through this accessor
    instead of ns.db.profile -- each character still defaults to its own
    restock list, but the toggles below are one choice for the account.
]]
local function GetRestockerSettings()
	return ns.restockSettings
end

-- The sound row only means anything while the in-town reminder itself is on.
local function RemindHidden()
	local settings = GetRestockerSettings()
	return not (settings and settings.restockReminderChat)
end

-- Repaint the panel so a toggle's dependent rows appear without a reopen.
local function Refresh()
	LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.Restocker)
end

local function PlayAlert()
	if ns.RESTOCK_ALERT_SOUND then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

--[[
    Each reminder is a toggle with the dropdown choosing how much it says on
    the same line, sized like every other toggle-and-dropdown row (the Options
    Layout Grid in Data/Data.lua) so the three rows end together.
]]
local function ReminderModes()
	return {
		[ns.REMINDER_SIMPLE] = L["OPTIONS_RESTOCKER_MODE_SIMPLE"],
		[ns.REMINDER_VERBOSE] = L["OPTIONS_RESTOCKER_MODE_VERBOSE"],
	}
end

local REMINDER_MODE_ORDER = { ns.REMINDER_SIMPLE, ns.REMINDER_VERBOSE }

-- Hides a reminder's Example and the break above it while that reminder is off.
local function ReminderOff(enabledKey)
	return function()
		local settings = GetRestockerSettings()
		return not (settings and settings[enabledKey])
	end
end

-- The one short staple a reminder's Verbose Example lists.
local SAMPLE_GROCERIES = { { itemID = ns.SAMPLE_RESTOCK_ITEM_ID, have = 5, wanted = 20 } }

--[[
    A reminder's Example, drawn through the same builder the reminder prints
    with, in the mode its dropdown has chosen: the headline alone in Simple,
    and a line per short item under it in Verbose.
]]
local function ReminderExample(order, enabledKey, modeKey, headlineFunction)
	return ns.OptionsExample(order, function()
		local settings = GetRestockerSettings()
		local mode = (settings and settings[modeKey]) or ns.REMINDER_VERBOSE
		return ns.BuildRestockShortfallLines(headlineFunction(), mode, SAMPLE_GROCERIES)
	end, ReminderOff(enabledKey))
end

-- What a restock prints: a merchant run's summary and a bank run's finished line.
local function RestockExampleLines()
	local lines = ns.BuildRestockSummaryLines(3, 1)
	lines[#lines + 1] = ns.BuildBankRestockCompleteLine()
	return lines
end

local function TownHeadline()
	return L["RESTOCKER_TOWN_REMINDER"]
end

local function ClosingHeadline()
	return ns.RestockShortfallHeadline(1)
end

-- The Gold Reserve amounts as the game writes money: the number and the gold coin.

local function GoldReserveAmounts()
	local values = {}
	for _, amount in ipairs(ns.GOLD_RESERVE_AMOUNTS) do
		values[amount] = amount .. ns.GOLD_ICON
	end
	return values
end

-- A reminder's on/off toggle, and the Gold Reserve's; width defaults to the label cell its dropdown sits beside.
local function ReminderToggle(labelKey, descKey, settingKey, order, onSet, width)
	return {
		type = "toggle",
		name = L[labelKey],
		desc = L[descKey],
		order = order,
		width = width or ns.OPTIONS_LABEL_WIDTH,
		get = function()
			local settings = GetRestockerSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
			if onSet then
				onSet()
			end
		end,
	}
end

--[[
    The Simple/Verbose dropdown beside a reminder toggle. Hidden with the
    reminder off -- how loudly a silent reminder speaks is not a question.
]]
local function ReminderModeSelect(settingKey, enabledKey, order, onSubRow)
	local dropdown = {
		type = "select",
		name = "",
		desc = L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"],
		order = order,
		width = ns.OPTIONS_CONTROL_WIDTH,
		hidden = function()
			local settings = GetRestockerSettings()
			return not (settings and settings[enabledKey])
		end,
		values = ReminderModes,
		sorting = REMINDER_MODE_ORDER,
		get = function()
			local settings = GetRestockerSettings()
			return (settings and settings[settingKey]) or ns.REMINDER_VERBOSE
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
		end,
	}
	-- On a sub-row the row itself hides, so the dropdown carries no hidden of its own.
	if onSubRow then
		dropdown.hidden = nil
	end
	return dropdown
end

--[[
    Page order: the description, the Restocker's master switch and what a
    restock prints, the Gold Reserve, the Reminders section, the window's
    auto-open behavior, then the Inventory Report's switch.

    The three reminders are peers under their header. The merchant and bank
    reminders are a toggle with the dropdown choosing how much it reports on
    the same line; the in-town reminder, with a sound as well, puts both on
    indented sub-rows under its toggle.
]]
function ns.BuildRestockerOptions()
	return {
		type = "group",
		name = L["TAB_RESTOCKER"],
		args = {
			descRestocker = Desc(
				GetColor("BODY")
					.. string.format(
						L["OPTIONS_RESTOCKER_DESCRIPTION"],
						GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
					)
					.. "|r",
				1
			),
			spaceEnabled = Spacer(1.1),
			toggleRestockerEnabled = ns.OptionsFeatureSwitch("Restocker", 1.2),
			spaceRestockExample = Spacer(1.3),
			exampleRestock = ns.OptionsExample(1.4, RestockExampleLines),

			--[[
			    The Gold Reserve: the floor the merchant restock never spends
			    below. Built like a reminder row, the toggle with its dropdown on
			    the same line, and like theirs the dropdown hides while the
			    toggle is off.
			]]
			spaceGold0 = Spacer(4),
			toggleGoldReserve = ReminderToggle(
				"OPTIONS_RESTOCKER_GOLD_RESERVE",
				"OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION",
				"goldReserve",
				5,
				Refresh
			),
			amountGoldReserve = {
				type = "select",
				name = "",
				desc = L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"],
				order = 6,
				width = ns.OPTIONS_CONTROL_WIDTH,
				hidden = function()
					local settings = GetRestockerSettings()
					return not (settings and settings.goldReserve)
				end,
				values = GoldReserveAmounts,
				sorting = ns.GOLD_RESERVE_AMOUNTS,
				get = function()
					local settings = GetRestockerSettings()
					return (settings and settings.goldReserveAmount) or ns.GOLD_RESERVE_AMOUNTS[1]
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.goldReserveAmount = value
					end
				end,
			},

			-- Reminders
			spaceReminders0 = Spacer(7),
			headerReminders = Header(L["OPTIONS_RESTOCKER_REMINDERS_HEADER"], 8),
			spaceReminders1 = Spacer(9),

			--[[
			    In-Town Reminders. Both the chat line and the sound fire on the
			    same signal -- the game's resting status, which turns on in inns
			    and cities -- and only when the Restock List is actually short
			    of something. All three reminders ship on; this one defaults to
			    Verbose and the other two to Simple (Data/Default-Settings.lua).
			]]
			toggleRestockerRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_REMIND",
				"OPTIONS_RESTOCKER_REMIND_DESCRIPTION",
				"restockReminderChat",
				10,
				-- Reveal or hide its two sub-rows without a reopen.
				Refresh,
				"full"
			),
			-- Two settings of its own, so each takes an indented sub-row under the toggle rather than its line.
			modeRestockerRemind = SubRow(11, RemindHidden, {
				ns.OptionsRowLabel(
					SubLabel(L["OPTIONS_RESTOCKER_REMIND_MODE_CAPTION"]),
					0,
					ns.OPTIONS_LABEL_WIDTH - ns.OPTIONS_SUB_INDENT_WIDTH - 0.05
				),
				ReminderModeSelect("restockReminderMode", "restockReminderChat", 0, true),
			}),

			--[[
			    The speaker shares the sound's sub-row, so that toggle takes a
			    plain unit width -- full-width would push the speaker onto a
			    line of its own.

			    Only the in-town reminder gets a sound: it arrives while you are
			    running around, where a chat line is easy to miss. The merchant
			    and bank reminders fire on a window you just closed, so you are
			    already looking at the screen.
			]]
			soundRow = SubRow(12, RemindHidden, {
				{
					type = "toggle",
					name = SubLabel(L["OPTIONS_RESTOCKER_REMIND_SOUND"]),
					desc = L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"],
					get = function()
						local settings = GetRestockerSettings()
						return settings and settings.restockReminderSound
					end,
					set = function(_, value)
						local settings = GetRestockerSettings()
						if settings then
							settings.restockReminderSound = value
						end
					end,
				},
				ns.DefineSoundPreview(PlayAlert, nil, nil, L["OPTIONS_RESTOCKER_SOUND_PREVIEW"]),
			}),
			exampleRestockerRemindSpace = Spacer(12.4, ReminderOff("restockReminderChat")),
			exampleRestockerRemind = ReminderExample(12.5, "restockReminderChat", "restockReminderMode", TownHeadline),

			--[[
			    Closing-window reminders. Peers of the in-town one, not children
			    of it -- each answers a different moment, and turning off the
			    nudge you get walking into town should not silence the report
			    you get walking away from a vendor. Both stay quiet unless
			    something is actually short.
			]]
			spaceMerchant0 = Spacer(13),
			toggleRestockerMerchantRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_MERCHANT_REMIND",
				"OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION",
				"merchantReminder",
				14,
				Refresh
			),
			modeRestockerMerchantRemind = ReminderModeSelect("merchantReminderMode", "merchantReminder", 15),
			exampleRestockerMerchantRemindSpace = Spacer(15.4, ReminderOff("merchantReminder")),
			exampleRestockerMerchantRemind = ReminderExample(
				15.5,
				"merchantReminder",
				"merchantReminderMode",
				ClosingHeadline
			),

			spaceBank0 = Spacer(16),
			toggleRestockerBankRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_BANK_REMIND",
				"OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION",
				"bankReminder",
				17,
				Refresh
			),
			modeRestockerBankRemind = ReminderModeSelect("bankReminderMode", "bankReminder", 18),
			exampleRestockerBankRemindSpace = Spacer(18.4, ReminderOff("bankReminder")),
			exampleRestockerBankRemind = ReminderExample(18.5, "bankReminder", "bankReminderMode", ClosingHeadline),

			-- Restocker Window
			spaceWindow0 = Spacer(20),
			headerWindow = Header(L["OPTIONS_RESTOCKER_WINDOW_HEADER"], 21),
			spaceWindow1 = Spacer(22),
			descWindow = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] .. "|r", 23),
			spaceWindow2 = Spacer(24),
			toggleRestockerBank = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_BANK"],
				desc = L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"],
				order = 25,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtBank
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtBank = value
					end
				end,
			},
			spaceWindow3 = Spacer(26),
			toggleRestockerMerchant = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_MERCHANT"],
				desc = L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"],
				order = 27,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtMerchant
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtMerchant = value
					end
				end,
			},

			--[[
			    Inventory Report: the counts Features/Inventory-Restocker/Inventory-Report-Tooltip.lua adds to
			    item tooltips. It sits on this panel because it covers every
			    item on the Restock List, even one nobody holds; it shows bag and bank counts, never
			    a keep amount. The header is the block's title, so the panel and
			    the tooltip cannot name it two ways.

			    Read at every tooltip, so switching it takes effect on the next
			    one without a reload. Not a Restocker settings key: it sits on
			    ns.db.global itself (Data/Default-Settings.lua), so it goes
			    through the database rather than the settings accessor.
			]]
			spaceInventory0 = Spacer(30),
			headerInventory = Header(L["INVENTORY_REPORT_TITLE"], 31),
			spaceInventory1 = Spacer(32),
			descInventory = Desc(GetColor("BODY") .. L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] .. "|r", 33),
			spaceInventory2 = Spacer(34),
			toggleInventoryReport = ns.OptionsFeatureSwitch("InventoryReport", 35),
		},
	}
end
