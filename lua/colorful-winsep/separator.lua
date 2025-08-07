local api = vim.api

---@class Separator
local Separator = {}

--- create a new separator
---@return Separator
function Separator:new()
    local buf = api.nvim_create_buf(false, true)
    api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    api.nvim_set_option_value("filetype", "colorful-winsep", { buf = buf })

    local o = {
        start_symbol = "",
        body_symbol = "",
        end_symbol = "",
        buffer = buf,
        window = nil,
        -- for nvim_open_win
        config = {
            style = "minimal",
            border = "none",
            relative = "win",
            zindex = 1,
            focusable = false,
            height = 1,
            width = 1,
            row = 0,
            col = 0,
        },
        extmarks = {},
        _show = false,
    }

    self.__index = self
    setmetatable(o, self)
    return o
end

--- vertically initialize the separator window and buffer
---@param height integer
function Separator:vertical_init(height)
    self.config.height = height
    self.config.width = 1
    local content = { self.start_symbol }
    for i = 2, height - 1 do
        content[i] = self.body_symbol
    end
    content[height] = self.end_symbol
    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, content)
end

--- horizontally initialize the separator window and buffer
---@param width integer
function Separator:horizontal_init(width)
    self.config.height = 1
    self.config.width = width
    local content = { self.start_symbol .. string.rep(self.body_symbol, width - 2) .. self.end_symbol }
    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, content)
end

--- reload the separator window config immediately
function Separator:reload_config()
    if self.win ~= nil and api.nvim_win_is_valid(self.win) then
        api.nvim_win_set_config(self.win, self.config)
    end
end

---move the window to a sepcified coordinate relative to window
---@param row integer
---@param col integer
function Separator:move(row, col)
    self.config.row = row
    self.config.col = col
    self:reload_config()
end

--- show the separator window
function Separator:show()
    if vim.api.nvim_buf_is_valid(self.buffer) then
        local win = api.nvim_open_win(self.buffer, false, self.config)
        api.nvim_set_option_value("winhl", "Normal:ColorfulWinSep", { win = win })
        self.win = win
        self._show = true
    end
end

--- hide the separator window
function Separator:hide()
    if self.win ~= nil and api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_hide(self.win)
        self.win = nil
        self._show = false
    end
end

return Separator
