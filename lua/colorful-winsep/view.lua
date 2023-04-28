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

local function calculate_layout(dir, only_2wins)
    local current_row, current_col = unpack(api.nvim_win_get_position(0))
    local sep_height = fn.winheight(0)
    local sep_width = fn.winwidth(0)

    local layout = {
        anchor_row = current_row,
        anchor_col = current_col,
        size = 0,
        is_vertical = false,
        start_symbol = "",
        body_symbol = "",
        end_symbol = ""
    }

    if dir == "left" then
        layout.is_vertical = true
        layout.anchor_col = current_col - 1
        layout.size = sep_height
        layout.start_symbol = config.opts.border[2]
        layout.body_symbol = config.opts.border[2]
        layout.end_symbol = config.opts.border[2]

        if utils.has_winbar() then layout.size = layout.size + 1 end
        if utils.has_adjacent_win(directions.up) then
            layout.start_symbol = config.opts.border[3]
            layout.size = layout.size + 1
            layout.anchor_row = layout.anchor_row - 1
        end
        if utils.has_adjacent_win(directions.down) then
            layout.end_symbol = config.opts.border[5]
            layout.size = layout.size + 1
        end

        if only_2wins then
            layout.anchor_row = layout.size - math.ceil(layout.size / 2)
            layout.size = math.ceil(layout.size / 2)
            local pos = config.opts.indicator_for_2wins.position
            local syms = config.opts.indicator_for_2wins.symbols
            if pos == "center" or pos == "start" or pos == "both" then
                layout.start_symbol = syms.start_left
            end
            if pos == "end" or pos == "both" then
                layout.end_symbol = syms.end_left
            end
        end

    elseif dir == "down" then
        layout.is_vertical = false
        layout.anchor_row = current_row + sep_height
        layout.size = sep_width
        layout.start_symbol = config.opts.border[1]
        layout.body_symbol = config.opts.border[1]
        layout.end_symbol = config.opts.border[1]

        if utils.has_winbar() then layout.anchor_row = layout.anchor_row + 1 end
        if utils.has_adjacent_win(directions.right) then
            layout.end_symbol = config.opts.border[6]
            layout.size = layout.size + 1
        end

        if only_2wins then
            layout.size = math.ceil(layout.size / 2)
            local pos = config.opts.indicator_for_2wins.position
            local syms = config.opts.indicator_for_2wins.symbols
            if pos == "start" or pos == "both" then
                layout.start_symbol = syms.start_down
            end
            if pos == "center" or pos == "end" or pos == "both" then
                layout.end_symbol = syms.end_down
            end
        end

    elseif dir == "up" then
        layout.is_vertical = false
        layout.anchor_row = current_row - 1
        layout.size = sep_width
        layout.start_symbol = config.opts.border[1]
        layout.body_symbol = config.opts.border[1]
        layout.end_symbol = config.opts.border[1]

        if utils.has_adjacent_win(directions.right) then
            layout.end_symbol = config.opts.border[4]
            layout.size = layout.size + 1
        end

        if only_2wins then
            layout.anchor_col = layout.size - math.ceil(layout.size / 2)
            layout.size = math.ceil(layout.size / 2)
            local pos = config.opts.indicator_for_2wins.position
            local syms = config.opts.indicator_for_2wins.symbols
            if pos == "center" or pos == "start" or pos == "both" then
                layout.start_symbol = syms.start_up
            end
            if pos == "end" or pos == "both" then
                layout.end_symbol = syms.end_up
            end
        end

    elseif dir == "right" then
        layout.is_vertical = true
        layout.anchor_col = current_col + sep_width
        layout.size = sep_height
        layout.start_symbol = config.opts.border[2]
        layout.body_symbol = config.opts.border[2]
        layout.end_symbol = config.opts.border[2]

        if utils.has_winbar() then layout.size = layout.size + 1 end

        if only_2wins then
            layout.size = math.ceil(layout.size / 2)
            local pos = config.opts.indicator_for_2wins.position
            local syms = config.opts.indicator_for_2wins.symbols
            if pos == "start" or pos == "both" then
                layout.start_symbol = syms.start_right
            end
            if pos == "center" or pos == "end" or pos == "both" then
                layout.end_symbol = syms.end_right
            end
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
