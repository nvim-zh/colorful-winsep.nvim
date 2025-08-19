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

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_left(only_2wins)
    local sep_height = fn.winheight(0)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local anchor_row = current_row
    local anchor_col = current_col - 1
    local sep = M.separators.left
    sep.start_symbol = config.opts.border[2]
    sep.body_symbol = config.opts.border[2]
    sep.end_symbol = config.opts.border[2]

    if utils.has_winbar() then
        sep_height = sep_height + 1
    end

    if utils.has_adjacent_win(directions.up) then
        sep.start_symbol = config.opts.border[3]
        sep_height = sep_height + 1
        anchor_row = anchor_row - 1
    end
    if utils.has_adjacent_win(directions.down) then
        sep.end_symbol = config.opts.border[5]
        sep_height = sep_height + 1
    end

    if only_2wins then
        anchor_row = sep_height - math.ceil(sep_height / 2)
        sep_height = math.ceil(sep_height / 2)
        if config.opts.indicator_for_2wins.position == "center" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_left
        elseif config.opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_left
        elseif config.opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_left
        elseif config.opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_left
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_left
        end
    end

    sep:vertical_init(sep_height)
    if not sep._show then
        sep:move(anchor_row, anchor_col)
        sep:show()
    elseif config.opts.animate.enabled == "shift" then
        sep:shift_move(anchor_row, anchor_col)
    else
        sep:move(anchor_row, anchor_col)
    end
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_down(only_2wins)
    local sep_width = fn.winwidth(0)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local anchor_row = current_row + fn.winheight(0)
    local anchor_col = current_col
    local sep = M.separators.down
    sep.start_symbol = config.opts.border[1]
    sep.body_symbol = config.opts.border[1]
    sep.end_symbol = config.opts.border[1]

    if utils.has_winbar() then
        anchor_row = anchor_row + 1
    end

    if utils.has_adjacent_win(directions.right) then
        sep.end_symbol = config.opts.border[6]
        sep_width = sep_width + 1
    end

    if only_2wins then
        sep_width = math.ceil(sep_width / 2)
        if config.opts.indicator_for_2wins.position == "center" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_down
        elseif config.opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_down
        elseif config.opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_down
        elseif config.opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_down
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_down
        end
    end

    sep:horizontal_init(sep_width)
    if not sep._show then
        sep:move(anchor_row, anchor_col)
        sep:show()
    elseif config.opts.animate.enabled == "shift" then
        sep:shift_move(anchor_row, anchor_col)
    else
        sep:move(anchor_row, anchor_col)
    end
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_up(only_2wins)
    local sep_width = fn.winwidth(0)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local anchor_row = current_row - 1
    local anchor_col = current_col
    local sep = M.separators.up
    sep.start_symbol = config.opts.border[1]
    sep.body_symbol = config.opts.border[1]
    sep.end_symbol = config.opts.border[1]

    if utils.has_adjacent_win(directions.right) then
        sep.end_symbol = config.opts.border[4]
        sep_width = sep_width + 1
    end

    if only_2wins then
        anchor_col = sep_width - math.ceil(sep_width / 2)
        sep_width = math.ceil(sep_width / 2)
        if config.opts.indicator_for_2wins.position == "center" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_up
        elseif config.opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_up
        elseif config.opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_up
        elseif config.opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_up
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_up
        end
    end

    sep:horizontal_init(sep_width)
    if not sep._show then
        sep:move(anchor_row, anchor_col)
        sep:show()
    elseif config.opts.animate.enabled == "shift" then
        sep:shift_move(anchor_row, anchor_col)
    else
        sep:move(anchor_row, anchor_col)
    end
end

---@param only_2wins boolean we should deal with 2 windows situation
function M.render_right(only_2wins)
    local sep_height = fn.winheight(0)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local anchor_row = current_row
    local anchor_col = current_col + fn.winwidth(0)
    local sep = M.separators.right
    sep.start_symbol = config.opts.border[2]
    sep.body_symbol = config.opts.border[2]
    sep.end_symbol = config.opts.border[2]

    if utils.has_winbar() then
        sep_height = sep_height + 1
    end

    if only_2wins then
        sep_height = math.ceil(sep_height / 2)
        if config.opts.indicator_for_2wins.position == "center" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_right
        elseif config.opts.indicator_for_2wins.position == "start" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_right
        elseif config.opts.indicator_for_2wins.position == "end" then
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_right
        elseif config.opts.indicator_for_2wins.position == "both" then
            sep.start_symbol = config.opts.indicator_for_2wins.symbols.start_right
            sep.end_symbol = config.opts.indicator_for_2wins.symbols.end_right
        end
    end

    sep:vertical_init(sep_height)
    if not sep._show then
        sep:move(anchor_row, anchor_col)
        sep:show()
    elseif config.opts.animate.enabled == "shift" then
        sep:shift_move(anchor_row, anchor_col)
    else
        sep:move(anchor_row, anchor_col)
    end
end

--- draw the progressive animation
---@param separator Separator
---@param animate_config table
---@param reverse boolean
local function vertical_progressive(separator, animate_config, reverse)
    local position = 0
    if not separator.timer:is_closing() then
        separator.timer:stop()
        separator.timer:close()
    end
    separator.timer = vim.uv.new_timer()
    separator.timer:start(
        1,
        animate_config.vertical_delay,
        vim.schedule_wrap(function()
            if separator._show then
                position = position + 1
                if reverse then
                    utils.color(separator.buffer, separator.window.height - position + 1, 1)
                else
                    utils.color(separator.buffer, position, 1)
                end
            end
            if position == separator.window.height and not separator.timer:is_closing() then
                separator.timer:stop()
                separator.timer:close()
            end
        end)
    )
end

--- draw the progressive animation
---@param separator Separator
---@param animate_config table
---@param reverse boolean
local function horizontal_progressive(separator, animate_config, reverse)
    local position = 0
    if not separator.timer:is_closing() then
        separator.timer:stop()
        separator.timer:close()
    end
    separator.timer = vim.uv.new_timer()
    separator.timer:start(
        1,
        animate_config.horizontal_delay,
        vim.schedule_wrap(function()
            if separator._show then
                position = position + 1
                if reverse then
                    utils.color(separator.buffer, 1, separator.window.width * 3 - position + 1)
                else
                    utils.color(separator.buffer, 1, position)
                end
            end
            if position == separator.window.width * 3 and not separator.timer:is_closing() then
                separator.timer:stop()
                separator.timer:close()
            end
        end)
    )
end

local function progressive_animate()
    local animate_config = config.opts.animate.progressive
    for dir, sep in pairs(M.separators) do
        if dir == "left" or dir == "right" then
            vertical_progressive(sep, animate_config, dir == "right")
        else
            horizontal_progressive(sep, animate_config, dir == "down")
        end
    end
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

    if config.opts.animate.enabled == "progressive" then
        progressive_animate()
    end
end

function M.hide_all()
    for _, sep in pairs(M.separators) do
        sep:hide()
    end
end

return M
