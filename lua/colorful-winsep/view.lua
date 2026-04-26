local Separator = require("colorful-winsep.separator")
local config = require("colorful-winsep.config")
local utils = require("colorful-winsep.utils")
local api = vim.api
local fn = vim.fn
local directions = utils.directions

local BorderModel = require("colorful-winsep.model")

local M = {}
M.separators = {
    left = Separator:new(),
    down = Separator:new(),
    up = Separator:new(),
    right = Separator:new(),
}
M.border_model = BorderModel:new()

local corner_types = {
    top_left_corner = true,
    top_right_corner = true,
    bottom_left_corner = true,
    bottom_right_corner = true,
}

local dir_config = {
    left = {
        is_vertical = true,
        base_anchor = function(row, col)
            return row, col - 1
        end,
        adj_checks = {
            { dir = "up", start_symbol_idx = 3, anchor_adj = { row = -1 } },
            { dir = "down", end_symbol_idx = 5 },
        },
        only_2wins_anchor = function(layout)
            layout.anchor_row = layout.size - math.ceil(layout.size / 2)
        end,
    },
    down = {
        is_vertical = false,
        base_anchor = function(row, col)
            return row + fn.winheight(0), col
        end,
        adj_checks = {
            { dir = "right", end_symbol_idx = 6 },
        },
    },
    up = {
        is_vertical = false,
        base_anchor = function(row, col)
            return row - 1, col
        end,
        adj_checks = {
            { dir = "right", end_symbol_idx = 4 },
        },
        only_2wins_anchor = function(layout)
            layout.anchor_col = layout.size - math.ceil(layout.size / 2)
        end,
    },
    right = {
        is_vertical = true,
        base_anchor = function(row, col)
            return row, col + fn.winwidth(0)
        end,
        adj_checks = {},
    },
}

local function calculate_layout(dir, only_2wins)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local cfg = dir_config[dir]
    local border = config.opts.border
    local default_sym = border[cfg.is_vertical and 2 or 1]
    local size = cfg.is_vertical and fn.winheight(0) or fn.winwidth(0)

    local layout = {
        is_vertical = cfg.is_vertical,
        size = size,
        start_symbol = default_sym,
        body_symbol = default_sym,
        end_symbol = default_sym,
    }
    layout.anchor_row, layout.anchor_col = cfg.base_anchor(current_row, current_col)

    if utils.has_winbar() and (dir == "left" or dir == "down" or dir == "right") then
        layout.size = layout.size + 1
        if dir == "down" then
            layout.anchor_row = layout.anchor_row + 1
        end
    end

    for _, check in ipairs(cfg.adj_checks) do
        if utils.has_adjacent_win(directions[check.dir]) then
            if check.start_symbol_idx then
                layout.start_symbol = border[check.start_symbol_idx]
            end
            if check.end_symbol_idx then
                layout.end_symbol = border[check.end_symbol_idx]
            end
            if check.anchor_adj then
                layout.anchor_row = layout.anchor_row + (check.anchor_adj.row or 0)
                layout.anchor_col = layout.anchor_col + (check.anchor_adj.col or 0)
            end
            layout.size = layout.size + 1
        end
    end

    if only_2wins then
        layout.size = math.ceil(layout.size / 2)
        if cfg.only_2wins_anchor then
            cfg.only_2wins_anchor(layout)
        end
        local ind = config.opts.indicator_for_2wins
        local pos = ind.position
        local syms = ind.symbols
        if pos == "start" or pos == "both" then
            layout.start_symbol = syms["start_" .. dir]
        end
        if pos == "center" or pos == "end" or pos == "both" then
            layout.end_symbol = syms["end_" .. dir]
        end
    end

    return layout
end

--- the order of rendering a full set of separators:  left -> down -> up -> right (i.e. hjlkl)
function M.render()
    local only_2wins = (utils.count_windows() == 2)
    local dir_list = { "left", "down", "up", "right" }
    local animate_mode = config.opts.animate.enabled

    local planned_layouts = {}
    for _, dir in ipairs(dir_list) do
        if utils.has_adjacent_win(directions[dir]) then
            planned_layouts[dir] = calculate_layout(dir, only_2wins)
        end
    end

    M.border_model:build(planned_layouts)

    local nodes = M.border_model:get_nodes()
    for _, node in ipairs(nodes) do
        local layout = planned_layouts[node.win_dir]
        if layout then
            if corner_types[node.type] then
                if node.buf_idx == 1 then
                    layout.start_symbol = node.char
                elseif node.buf_idx == layout.size then
                    layout.end_symbol = node.char
                end
            else
                layout.body_symbol = node.char
            end
        end
    end

    for _, dir in ipairs(dir_list) do
        local layout = planned_layouts[dir]
        local sep = M.separators[dir]

        if layout then
            sep.start_symbol = layout.start_symbol
            sep.body_symbol = layout.body_symbol
            sep.end_symbol = layout.end_symbol

            if layout.is_vertical then
                sep:vertical_init(layout.size)
            else
                sep:horizontal_init(layout.size)
            end

            if not sep._show then
                sep:move(layout.anchor_row, layout.anchor_col)
                sep:show()
            elseif animate_mode == "shift" then
                sep:shift_move(layout.anchor_row, layout.anchor_col)
            else
                sep:move(layout.anchor_row, layout.anchor_col)
            end

            if animate_mode == "progressive" then
                if layout.is_vertical then
                    sep:progressive_animate_vertical(dir == "right")
                else
                    sep:progressive_animate_horizontal(dir == "down")
                end
            end
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
