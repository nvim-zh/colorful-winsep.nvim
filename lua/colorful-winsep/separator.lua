local utils = require("colorful-winsep.utils")
local config = require("colorful-winsep.config")
local api = vim.api
local uv = vim.uv

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
        winid = nil,
        -- for nvim_open_win
        window = {
            style = "minimal",
            border = "none",
            relative = "editor",
            zindex = 1,
            focusable = false,
            height = 1,
            width = 1,
            row = 0,
            col = 0,
        },
        extmarks = {},
        timer = uv.new_timer(),
        _show = false,
    }

    self.__index = self
    setmetatable(o, self)
    return o
end

--- vertically initialize the separator window and buffer
---@param height integer
function Separator:vertical_init(height)
    self.window.height = height
    self.window.width = 1
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
    self.window.height = 1
    self.window.width = width
    local content = { self.start_symbol .. string.rep(self.body_symbol, width - 2) .. self.end_symbol }
    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, content)
end

--- reload the separator window config immediately
function Separator:reload_config()
    if self.winid ~= nil and api.nvim_win_is_valid(self.winid) then
        api.nvim_win_set_config(self.winid, self.window)
    end
end

---move the window to a sepcified coordinate relative to window
---@param row integer
---@param col integer
function Separator:move(row, col)
    self.window.row = row
    self.window.col = col
    self:reload_config()
end

--- move the windows with shift animate
---@param row integer
---@param col integer
function Separator:shift_move(row, col)
    local current_row, current_col = unpack(api.nvim_win_get_position(self.winid))
    if not self.timer:is_closing() then
        self.timer:stop()
        self.timer:close()
    end
    self.timer = vim.uv.new_timer()

    local animate_config = config.opts.animate.shift
    self.timer:start(
        0,
        animate_config.delay,
        vim.schedule_wrap(function()
            -- calculate exponential decay
            local decay_factor = math.exp(-animate_config.smooth_speed * animate_config.delta_time)

            -- perform linear interpolation
            current_row = utils.lerp(row, current_row, decay_factor)
            current_col = utils.lerp(col, current_col, decay_factor)

            -- update line position
            self:move(math.floor(current_row + 0.5), math.floor(current_col + 0.5)) -- round

            -- check if position is close enough to the target
            if math.abs(current_row - row) < 0.5 and math.abs(current_col - col) < 0.5 then
                if not self.timer:is_closing() then
                    self.timer:stop()
                    self.timer:close()
                end
            end
        end)
    )
end

--- show the separator window
function Separator:show()
    if api.nvim_buf_is_valid(self.buffer) then
        vim.schedule(function()
            if not api.nvim_buf_is_valid(self.buffer) then
                return
            end
            local win = api.nvim_open_win(self.buffer, false, self.window)
            api.nvim_set_option_value("winhl", "Normal:ColorfulWinSep", { win = win })
            self.winid = win
            self._show = true
        end)
    end
end

--- hide the separator window
function Separator:hide()
    if self.winid ~= nil and api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_hide(self.winid)
        self.winid = nil
        self._show = false
    end
end

return Separator
