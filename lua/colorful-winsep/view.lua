local Separator = require("colorful-winsep.separator")
local config = require("colorful-winsep.config")
local utils = require("colorful-winsep.utils")
local api = vim.api
local fn = vim.fn
local directions = utils.directions

local M = {}
M.separators = {
    left = Separator:new(),
    down = Separator:new(),
    up = Separator:new(),
    right = Separator:new(),
}

local render_order = { "left", "down", "up", "right" }

local function apply_indicator_for_2wins(direction, sep, anchor_row, anchor_col, height, width)
    local pos = config.opts.indicator_for_2wins.position
    if direction == "left" then
        anchor_row = height - math.ceil(height / 2)
        height = math.ceil(height / 2)
        if pos == "center" or pos == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_left
        elseif pos == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_left
        elseif pos == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_left
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_left
        end
    elseif direction == "down" then
        width = math.ceil(width / 2)
        if pos == "center" or pos == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_down
        elseif pos == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_down
        elseif pos == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_down
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_down
        end
    elseif direction == "up" then
        anchor_col = width - math.ceil(width / 2)
        width = math.ceil(width / 2)
        if pos == "center" or pos == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_up
        elseif pos == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_up
        elseif pos == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_up
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_up
        end
    elseif direction == "right" then
        height = math.ceil(height / 2)
        if pos == "center" or pos == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_right
        elseif pos == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_right
        elseif pos == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_right
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_right
        end
    end

    return anchor_row, anchor_col, height, width
end

local function render_separator(direction, only_2wins, ctx)
    local sep = M.separators[direction]
    local height = ctx.winheight
    local width = ctx.winwidth
    local anchor_row = ctx.current_row
    local anchor_col = ctx.current_col

    if direction == "left" then
        anchor_col = anchor_col - 1
        sep.start_symbol = config.opts.border[2]
        sep.body_symbol = config.opts.border[2]
        sep.end_symbol = config.opts.border[2]

        if ctx.has_winbar then
            height = height + 1
        end
        if ctx.adjacent.up then
            sep.start_symbol = config.opts.border[3]
            height = height + 1
            anchor_row = anchor_row - 1
        end
        if ctx.adjacent.down then
            sep.end_symbol = config.opts.border[5]
            height = height + 1
        end

        if only_2wins then
            anchor_row, anchor_col, height, width = apply_indicator_for_2wins(direction, sep, anchor_row, anchor_col, height, width)
        end

        sep:vertical_init(height)
        if not sep._show then
            sep:move(anchor_row, anchor_col)
            sep:show()
        elseif config.opts.animate.enabled == "shift" then
            sep:shift_move(anchor_row, anchor_col)
        else
            sep:move(anchor_row, anchor_col)
        end
        if config.opts.animate.enabled == "progressive" then
            sep:progressive_animate_vertical()
        end
        return
    end

    if direction == "down" then
        anchor_row = anchor_row + ctx.winheight
        sep.start_symbol = config.opts.border[1]
        sep.body_symbol = config.opts.border[1]
        sep.end_symbol = config.opts.border[1]

        if ctx.has_winbar then
            anchor_row = anchor_row + 1
        end
        if ctx.adjacent.right then
            sep.end_symbol = config.opts.border[6]
            width = width + 1
        end

        if only_2wins then
            anchor_row, anchor_col, height, width = apply_indicator_for_2wins(direction, sep, anchor_row, anchor_col, height, width)
        end

        sep:horizontal_init(width)
        if not sep._show then
            sep:move(anchor_row, anchor_col)
            sep:show()
        elseif config.opts.animate.enabled == "shift" then
            sep:shift_move(anchor_row, anchor_col)
        else
            sep:move(anchor_row, anchor_col)
        end
        if config.opts.animate.enabled == "progressive" then
            sep:progressive_animate_horizontal(true)
        end
        return
    end

    if direction == "up" then
        anchor_row = anchor_row - 1
        sep.start_symbol = config.opts.border[1]
        sep.body_symbol = config.opts.border[1]
        sep.end_symbol = config.opts.border[1]

        if ctx.adjacent.right then
            sep.end_symbol = config.opts.border[4]
            width = width + 1
        end

        if only_2wins then
            anchor_row, anchor_col, height, width = apply_indicator_for_2wins(direction, sep, anchor_row, anchor_col, height, width)
        end

        sep:horizontal_init(width)
        if not sep._show then
            sep:move(anchor_row, anchor_col)
            sep:show()
        elseif config.opts.animate.enabled == "shift" then
            sep:shift_move(anchor_row, anchor_col)
        else
            sep:move(anchor_row, anchor_col)
        end
        if config.opts.animate.enabled == "progressive" then
            sep:progressive_animate_horizontal()
        end
        return
    end

    anchor_col = anchor_col + ctx.winwidth
    sep.start_symbol = config.opts.border[2]
    sep.body_symbol = config.opts.border[2]
    sep.end_symbol = config.opts.border[2]
    if ctx.has_winbar then
        height = height + 1
    end

    if only_2wins then
        anchor_row, anchor_col, height, width = apply_indicator_for_2wins(direction, sep, anchor_row, anchor_col, height, width)
    end

    sep:vertical_init(height)
    if not sep._show then
        sep:move(anchor_row, anchor_col)
        sep:show()
    elseif config.opts.animate.enabled == "shift" then
        sep:shift_move(anchor_row, anchor_col)
    else
        sep:move(anchor_row, anchor_col)
    end
    if config.opts.animate.enabled == "progressive" then
        sep:progressive_animate_vertical(true)
    end
end

--- the order of rendering a full set of separators:  left -> down -> up -> right (i.e. hjlkl)
function M.render()
    local only_2wins = (utils.count_windows() == 2) and true or false
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local ctx = {
        current_row = current_row,
        current_col = current_col,
        winheight = fn.winheight(0),
        winwidth = fn.winwidth(0),
        has_winbar = utils.has_winbar(),
        adjacent = {
            left = utils.has_adjacent_win(directions.left),
            down = utils.has_adjacent_win(directions.down),
            up = utils.has_adjacent_win(directions.up),
            right = utils.has_adjacent_win(directions.right),
        },
    }

    for _, direction in ipairs(render_order) do
        local sep = M.separators[direction]
        if ctx.adjacent[direction] then
            render_separator(direction, only_2wins, ctx)
        else
            sep:hide()
        end
    end
end

function M.hide_all()
    for _, sep in pairs(M.separators) do
        sep:hide()
    end
end

return M
