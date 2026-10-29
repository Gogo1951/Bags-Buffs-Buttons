local _, ns = ...

-- The page's own settings: which spells it lists, how it sorts them, and which macros are marked placed.

--[[
	Whether the page also lists a macro for each lower rank known of a spell, after the spell's own, each fixed
	to its rank. Only where spells have ranks (ns.HAS_SPELL_RANKS).
]]
function ns.ShowsAllRanks()
	return ns.HAS_SPELL_RANKS and ns.db.profile.showAllRanks
end

function ns.SetShowAllRanks(on)
	ns.db.profile.showAllRanks = on
end

--[[
	Whether the page lists every learned spell of a SPELL_GROUPS group, or only the last one learned (Cleanse,
	not Purify). The ones left off the page still have their WoW macros rewritten.
]]
function ns.ShowsGroupedSpells()
	return ns.db.profile.showGroupedSpells
end

function ns.SetShowGroupedSpells(on)
	ns.db.profile.showGroupedSpells = on
end

-- Whether the page also lists the class spells not learned yet, in an Unlearned section after the rest.
function ns.ShowsUnlearned()
	return ns.db.profile.showUnlearned
end

function ns.SetShowUnlearned(on)
	ns.db.profile.showUnlearned = on
end

--[[
	Whether a plain spell on an action bar counts as its macro being placed even when the macro has options
	on (see ns.IsOnActionBars). Macros with no options on always count it. Nothing turns it off: it is the
	saved default, on, kept as a setting so Diagnostics can show it.
]]
function ns.CountsSpellsOnBars()
	return ns.db.profile.countSpellsOnBars
end

--[[
	How the page groups its macros: "category", under each kind of macro (ns.MACRO_KINDS), or "school", under
	each spellbook tab, as the book lists them.
]]
function ns.PageSort()
	return ns.db.profile.pageSort
end

function ns.SetPageSort(sort)
	ns.db.profile.pageSort = sort
end

--[[
	Whether the macro was marked placed by Mark All Spells As Placed, which stops it glowing wherever it is.
	A spell learned after the mark still glows until it is placed.
]]
function ns.IsMarkedPlaced(macro)
	return ns.db.profile.markedPlaced[macro.macroName] == true
end

function ns.MarkAllPlaced()
	for _, macro in ipairs(ns.macros) do
		if not macro.unlearned then
			ns.db.profile.markedPlaced[macro.macroName] = true
		end
	end
	for _, macro in ipairs(ns.ConsumablePageMacros()) do
		ns.db.profile.markedPlaced[macro.macroName] = true
	end
end

-- Undoes Mark All Spells As Placed, so every macro not on the bars glows again.
function ns.ClearPlacedMarks()
	wipe(ns.db.profile.markedPlaced)
end

function ns.HasPlacedMarks()
	return next(ns.db.profile.markedPlaced) ~= nil
end
