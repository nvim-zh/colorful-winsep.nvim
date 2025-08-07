local Separator = require("colorful-winsep.separator")
local opts = require("colorful-winsep.config").opts
local utils = require("colorful-winsep.utils")
local fn = vim.fn
local directions = utils.directions

local M = {}
M.separators = {
    left = Separator:new(),
    down = Separator:new(),
    up = Separator:new(),
    right = Separator:new(),
}

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_left(only_2wins)
    local sep_height = fn.winheight(0)
    local anchor_row = 0
    local anchor_col = -1
    local sep = M.separators.left
    sep.start_symbol = opts.symbols[2]
    sep.body_symbol = opts.symbols[2]
    sep.end_symbol = opts.symbols[2]

    if utils.has_winbar() then
        sep_height = sep_height + 1
        anchor_row = anchor_row - 1
    end

    if utils.has_adjacent_win(directions.up) then
        sep.start_symbol = opts.symbols[3]
        sep_height = sep_height + 1
        anchor_row = anchor_row - 1
    end
    if utils.has_adjacent_win(directions.down) then
        sep.end_symbol = opts.symbols[5]
        sep_height = sep_height + 1
    end

    if only_2wins then
        anchor_row = sep_height - math.ceil(sep_height / 2)
        sep_height = math.ceil(sep_height / 2)
        if utils.has_winbar() then
            anchor_row = anchor_row - 1
        end
        if opts.indicator_for_2wins.position == "center" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_left
        elseif opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_left
        elseif opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_left
        elseif opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_left
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_left
        end
    end

    sep:vertical_init(sep_height)
    if not sep._show then
        sep:show()
    end
    sep:move(anchor_row, anchor_col)
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_down(only_2wins)
    local sep_width = fn.winwidth(0)
    local anchor_row = fn.winheight(0)
    local anchor_col = 0
    local sep = M.separators.down
    sep.start_symbol = opts.symbols[1]
    sep.body_symbol = opts.symbols[1]
    sep.end_symbol = opts.symbols[1]

    if utils.has_adjacent_win(directions.right) then
        sep.end_symbol = opts.symbols[6]
        sep_width = sep_width + 1
    end

    if only_2wins then
        sep_width = math.ceil(sep_width / 2)
        if opts.indicator_for_2wins.position == "center" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_down
        elseif opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_down
        elseif opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_down
        elseif opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_down
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_down
        end
    end

    sep:horizontal_init(sep_width)
    if not sep._show then
        sep:show()
    end
    sep:move(anchor_row, anchor_col)
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_up(only_2wins)
    local sep_width = fn.winwidth(0)
    local anchor_row = -1
    local anchor_col = 0
    local sep = M.separators.up
    sep.start_symbol = opts.symbols[1]
    sep.body_symbol = opts.symbols[1]
    sep.end_symbol = opts.symbols[1]

    if utils.has_winbar() then
        anchor_row = anchor_row - 1
    end

    if utils.has_adjacent_win(directions.right) then
        sep.end_symbol = opts.symbols[4]
        sep_width = sep_width + 1
    end

    if only_2wins then
        anchor_col = sep_width - math.ceil(sep_width / 2)
        sep_width = math.ceil(sep_width / 2)
        if opts.indicator_for_2wins.position == "center" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_up
        elseif opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_up
        elseif opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_up
        elseif opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_up
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_up
        end
    end

    sep:horizontal_init(sep_width)
    if not sep._show then
        sep:show()
    end
    sep:move(anchor_row, anchor_col)
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_right(only_2wins)
    local sep_height = fn.winheight(0)
    local anchor_row = 0
    local anchor_col = fn.winwidth(0)
    local sep = M.separators.right
    sep.start_symbol = opts.symbols[2]
    sep.body_symbol = opts.symbols[2]
    sep.end_symbol = opts.symbols[2]

    if utils.has_winbar() then
        sep_height = sep_height + 1
        anchor_row = anchor_row - 1
    end

    if only_2wins then
        sep_height = math.ceil(sep_height / 2)
        if opts.indicator_for_2wins.position == "center" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_right
        elseif opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_right
        elseif opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_right
        elseif opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = opts.indicator_for_2wins.symbols.start_right
            sep.end_symbol = opts.indicator_for_2wins.symbols.end_right
        end
    end

    sep:vertical_init(sep_height)
    if not sep._show then
        sep:show()
    end
    sep:move(anchor_row, anchor_col)
end

--- the order of rendering a full set of separators:  left -> down -> up -> right (i.e. hjlkl)
function M.render()
    local only_2wins = (utils.count_windows() == 2) and true or false
    if utils.has_adjacent_win(directions.left) then
        M.render_left(only_2wins)
    else
        M.separators.left:hide()
    end
    if utils.has_adjacent_win(directions.down) then
        M.render_down(only_2wins)
    else
        M.separators.down:hide()
    end
    if utils.has_adjacent_win(directions.up) then
        M.render_up(only_2wins)
    else
        M.separators.up:hide()
    end
    if utils.has_adjacent_win(directions.right) then
        M.render_right(only_2wins)
    else
        M.separators.right:hide()
    end
end

function M.hide_all()
    for _, sep in pairs(M.separators) do
        sep:hide()
    end
end

return M
