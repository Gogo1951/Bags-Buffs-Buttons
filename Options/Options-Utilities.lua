local _, ns = ...
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    Dot-defined widget constructors shared by every options panel. Each
    feature's own helpers live beside its panels, in
    Options/<Feature>/Options-<Feature>-Utilities.lua.

    Every section header is a real AceConfig "header" -- the ruled line with
    the title set into it -- and no panel draws its own out of a colored
    description. `hidden` is optional (a function or a boolean) on every one,
    so a gated section collapses whole instead of leaving a stray gap behind.
]]
function ns.OptionsHeader(text, order, hidden)
	return { type = "header", name = GetColor("TITLE") .. text .. "|r", order = order, hidden = hidden }
end

function ns.OptionsDesc(text, order, hidden)
	return { type = "description", name = text, fontSize = "medium", order = order, hidden = hidden }
end

function ns.OptionsSpacer(order, hidden)
	return { type = "description", name = " ", order = order, hidden = hidden }
end

--[[
    The left half of a label-beside-control row: this cell, then the control
    with name = "" ordered immediately after it. A caption left on the control
    would put the label back above the widget and break the row. A label has
    no state of its own, so on a panel behind a master switch it takes the
    same `hidden` as the control beside it.
]]
function ns.OptionsRowLabel(text, order, width, hidden)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
		hidden = hidden,
	}
end
