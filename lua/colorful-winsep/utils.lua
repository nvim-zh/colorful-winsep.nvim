local fn = vim.fn
local M = {}

local ns_id = vim.api.nvim_create_namespace("colorful-winsep")

M.directions = { left = "h", down = "j", up = "k", right = "l" }

--- check if there is adjacent window in specified direction
---@param direction "h"|"l"|"k"|"j"
---@return boolean
function M.has_adjacent_win(direction)
    local winnum = vim.fn.winnr()
    if fn.winnr(direction) ~= winnum and fn.win_gettype(winnum) ~= "popup" then
        return true
    end
    return false
end

--- check if user enable the nvim winbar feature
---@return boolean
function M.has_winbar()
    return vim.o.winbar ~= ""
end

--- count the number of all windws except floating windows
---@return integer
function M.count_windows()
    local win_len = fn.winnr("$")
    for i = 1, win_len do
        if fn.win_gettype(i) == "popup" then
            win_len = win_len - 1
        end
    end
    return win_len
end

--- color the character (1-indexed)
---@param buf integer
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
function M.color(buf, start_row, start_col, end_row, end_col)
    vim.api.nvim_buf_set_extmark(buf, ns_id, start_row - 1, start_col - 1, {
        end_row = end_row - 1,
        end_col = end_col,
        hl_group = "ColorfulWinSep",
        hl_eol = false, -- do not highlight beyond EOL
    })
end

function M.clear_extmarks(buf)
    if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    end
end

--- current + (target - current) * factor
---@param current integer
---@param target integer
---@param factor integer
---@return number
function M.lerp(current, target, factor)
    return current + (target - current) * factor
end

---- 1 - (1 - t)^3
---@param t integer
---@return number
function M.ease_out_cubic(t)
    return 1 - math.pow(1 - t, 3)
end

return M
