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

local dir_config = {
    left = {
        is_vertical = true,
        size_fn = function()
            return fn.winheight(0)
        end,
        base_anchor = function(row, col)
            return row, col - 1
        end,
        default_symbol = function()
            return config.opts.border[2]
        end, -- 统一 body/start/end 默认符号
        adj_checks = { -- 要检测的相邻窗口方向及对其符号/锚点的影响
            { dir = "up", start_symbol_idx = 3, anchor_adj = { row = -1 } },
            { dir = "down", end_symbol_idx = 5 },
        },
        only_2wins_anchor = function(layout) -- 仅两个窗口时特殊的锚点调整
            layout.anchor_row = layout.size - math.ceil(layout.size / 2)
        end,
        only_2wins_symbols = {
            start_left = "start_left",
            end_left = "end_left",
            start = "start_left",
            center = "start_left",
            both = "start_left",
            end_sym = "end_left",
        },
    },
    down = {
        is_vertical = false,
        size_fn = function()
            return fn.winwidth(0)
        end,
        base_anchor = function(row, col)
            return row + fn.winheight(0), col
        end,
        default_symbol = function()
            return config.opts.border[1]
        end,
        adj_checks = {
            { dir = "right", end_symbol_idx = 6 },
        },
        only_2wins_symbols = {
            start_down = "start_down",
            end_down = "end_down",
            start = "start_down",
            both = "start_down",
            center = "end_down",
            end_sym = "end_down",
        },
    },
    up = {
        is_vertical = false,
        size_fn = function()
            return fn.winwidth(0)
        end,
        base_anchor = function(row, col)
            return row - 1, col
        end,
        default_symbol = function()
            return config.opts.border[1]
        end,
        adj_checks = {
            { dir = "right", end_symbol_idx = 4 },
        },
        only_2wins_anchor = function(layout)
            layout.anchor_col = layout.size - math.ceil(layout.size / 2)
        end,
        only_2wins_symbols = {
            start_up = "start_up",
            end_up = "end_up",
            start = "start_up",
            center = "start_up",
            both = "start_up",
            end_sym = "end_up",
        },
    },
    right = {
        is_vertical = true,
        size_fn = function()
            return fn.winheight(0)
        end,
        base_anchor = function(row, col)
            return row, col + fn.winwidth(0)
        end,
        default_symbol = function()
            return config.opts.border[2]
        end,
        adj_checks = {}, -- 右侧没有额外相邻检查（除 winbar）
        only_2wins_symbols = {
            start_right = "start_right",
            end_right = "end_right",
            start = "start_right",
            both = "start_right",
            center = "end_right",
            end_sym = "end_right",
        },
    },
}

local function calculate_layout(dir, only_2wins)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local cfg = dir_config[dir]

    local layout = {
        is_vertical = cfg.is_vertical,
        size = cfg.size_fn(),
        start_symbol = cfg.default_symbol(),
        body_symbol = cfg.default_symbol(),
        end_symbol = cfg.default_symbol(),
    }
    layout.anchor_row, layout.anchor_col = cfg.base_anchor(current_row, current_col)

    -- winbar 处理（垂直方向）或下方向的特殊偏移
    if utils.has_winbar() and (dir == "left" or dir == "down" or dir == "right") then
        layout.size = layout.size + 1
        if dir == "down" then
            layout.anchor_row = layout.anchor_row + 1
        end
    end

    -- 相邻窗口导致符号与锚点变化
    for _, check in ipairs(cfg.adj_checks) do
        if utils.has_adjacent_win(directions[check.dir]) then
            if check.start_symbol_idx then
                layout.start_symbol = config.opts.border[check.start_symbol_idx]
            end
            if check.end_symbol_idx then
                layout.end_symbol = config.opts.border[check.end_symbol_idx]
            end
            if check.anchor_adj then
                layout.anchor_row = layout.anchor_row + (check.anchor_adj.row or 0)
                layout.anchor_col = layout.anchor_col + (check.anchor_adj.col or 0)
            end
            layout.size = layout.size + 1 -- 根据原逻辑，大多会尺寸+1
        end
    end

    -- 两窗口模式特殊处理
    if only_2wins then
        layout.size = math.ceil(layout.size / 2)
        if cfg.only_2wins_anchor then
            cfg.only_2wins_anchor(layout)
        end
        local pos = config.opts.indicator_for_2wins.position
        local syms = config.opts.indicator_for_2wins.symbols
        local map = cfg.only_2wins_symbols
        if pos == "start" or pos == "both" then
            layout.start_symbol = syms[map.start]
        end
        if pos == "center" or pos == "end" or pos == "both" then
            layout.end_symbol = syms[map.end_sym or map.center]
        end
    end

    return layout
end

--- the order of rendering a full set of separators:  left -> down -> up -> right (i.e. hjlkl)
function M.render()
    local only_2wins = (utils.count_windows() == 2)
    local dir_list = { "left", "down", "up", "right" }

    local planned_layouts = {}
    -- pre-calculate before render
    for _, dir in ipairs(dir_list) do
        if utils.has_adjacent_win(directions[dir]) then
            planned_layouts[dir] = calculate_layout(dir, only_2wins)
        end
    end

    -- build circular border model
    M.border_model:build(planned_layouts)

    -- Override layout symbols with potentially modified node chars
    local nodes = M.border_model:get_nodes()
    for _, node in ipairs(nodes) do
        local layout = planned_layouts[node.win_dir]
        if layout then
            if node.type:find("corner") then
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

    -- render using direction array
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
            elseif config.opts.animate.enabled == "shift" then
                sep:shift_move(layout.anchor_row, layout.anchor_col)
            else
                sep:move(layout.anchor_row, layout.anchor_col)
            end

            if config.opts.animate.enabled == "progressive" then
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
