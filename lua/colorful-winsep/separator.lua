local utils = require("colorful-winsep.utils")
local config = require("colorful-winsep.config")
local api = vim.api
local uv = vim.uv

---@class Separator
---@field start_symbol string
---@field body_symbol string
---@field end_symbol string
---@field buffer integer
---@field winid integer?
---@field window { style: string, border: string, relative: string, zindex: integer, focusable: boolean, height: integer, width: integer, row: integer, col: integer }
---@field extmarks table
---@field timer uv.uv_timer_t?
---@field _show boolean
---@field _animate_actived boolean
local Separator = {}

--- create a new separator
---@return Separator
function Separator:new()
    local buf = api.nvim_create_buf(false, true)
    api.nvim_set_option_value("buftype", "nofile", { buf = buf })

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
        _animate_actived = false,
    }

    self.__index = self
    setmetatable(o, self)
    return o
end

--- vertically initialize the separator window and buffer
---@param height integer
function Separator:vertical_init(height)
    self:stop_animation()
    utils.clear_extmarks(self.buffer)
    self.window.height = height
    self.window.width = 1
    local content = { self.start_symbol }
    for i = 2, height - 1 do
        content[i] = self.body_symbol
    end
    content[height] = self.end_symbol
    api.nvim_buf_set_lines(self.buffer, 0, -1, false, content)
end

--- horizontally initialize the separator window and buffer
---@param width integer
function Separator:horizontal_init(width)
    self:stop_animation()
    utils.clear_extmarks(self.buffer)
    self.window.height = 1
    self.window.width = width
    local content = { self.start_symbol .. string.rep(self.body_symbol, width - 2) .. self.end_symbol }
    api.nvim_buf_set_lines(self.buffer, 0, -1, false, content)
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
    if self.winid == nil or not api.nvim_win_is_valid(self.winid) then
        return
    end
    self:stop_animation()

    local start_row, start_col = unpack(api.nvim_win_get_position(self.winid))
    local animate_config = config.opts.animate.shift
    local frames = animate_config.frames
    local i = 0

    self._animate_actived = true
    self.timer:start(
        0,
        animate_config.delay,
        vim.schedule_wrap(function()
            if not (self._animate_actived and self._show and self.winid and api.nvim_win_is_valid(self.winid)) then
                self:stop_animation()
                return
            end

            i = i + 1
            local t = math.min(i / frames, 1)
            local k = utils.ease_out_cubic(t)

            local cur_row = math.floor(utils.lerp(start_row, row, k) + 0.5)
            local cur_col = math.floor(utils.lerp(start_col, col, k) + 0.5)

            self:move(cur_row, cur_col)

            if t >= 1 then
                self:stop_animation()
            end
        end)
    )
end

function Separator:stop_animation()
    self._animate_actived = false
    if self.timer and not self.timer:is_closing() then
        self.timer:stop()
        self.timer:close()
    end
    self.timer = uv.new_timer()
end

---@param reverse boolean? default to false
function Separator:progressive_animate_vertical(reverse)
    reverse = reverse or false

    self:stop_animation()
    utils.clear_extmarks(self.buffer)
    if not self._show then
        return
    end

    local target_height = self.window.height
    local rendered_lines = 0

    self._animate_actived = true
    self.timer:start(
        0,
        config.opts.animate.progressive.delay,
        vim.schedule_wrap(function()
            if not (self._animate_actived and self._show) then
                self:stop_animation()
                return
            end

            local start_pos = rendered_lines + 1
            local end_pos = math.min(
                math.ceil(utils.lerp(rendered_lines, target_height, config.opts.animate.progressive.vertical_lerp_factor)),
                target_height
            )
            if reverse then
                utils.color(self.buffer, target_height - end_pos + 1, 1, target_height - start_pos + 1, 1)
            else
                utils.color(self.buffer, start_pos, 1, end_pos, 1)
            end
            rendered_lines = end_pos

            if rendered_lines >= target_height then
                self:stop_animation()
            end
        end)
    )
end

---@param reverse boolean? default to false
function Separator:progressive_animate_horizontal(reverse)
    reverse = reverse or false

    self:stop_animation()
    utils.clear_extmarks(self.buffer)
    if not self._show then
        return
    end

    local lines = api.nvim_buf_get_lines(self.buffer, 0, 1, false)
    local actual_byte_length = lines[1] and #lines[1]
    local rendered_cols = 0

    self._animate_actived = true
    self.timer:start(
        0,
        config.opts.animate.progressive.delay,
        vim.schedule_wrap(function()
            if not (self._animate_actived and self._show) then
                self:stop_animation()
                return
            end

            local start_pos = rendered_cols + 1
            local end_pos = math.min(
                math.ceil(
                    utils.lerp(rendered_cols, actual_byte_length, config.opts.animate.progressive.horizontal_lerp_factor)
                ),
                actual_byte_length
            )
            if reverse then
                utils.color(self.buffer, 1, actual_byte_length - end_pos + 1, 1, actual_byte_length - start_pos + 1)
            else
                utils.color(self.buffer, 1, start_pos, 1, end_pos)
            end
            rendered_cols = end_pos

            if rendered_cols >= actual_byte_length then
                self:stop_animation()
            end
        end)
    )
end

--- show the separator window
function Separator:show()
    if api.nvim_buf_is_valid(self.buffer) then
        local win = api.nvim_open_win(self.buffer, false, self.window)
        self.winid = win
        self._show = true
        if config.opts.animate.enabled ~= "progressive" then
            api.nvim_set_option_value("winhl", "Normal:ColorfulWinSep", { win = win })
        else
            api.nvim_set_option_value("winhl", "Normal:WinSeparator", { win = win })
        end
    end
end

--- hide the separator window
function Separator:hide()
    if self.winid ~= nil and api.nvim_win_is_valid(self.winid) then
        api.nvim_win_hide(self.winid)
        self.winid = nil
        self:stop_animation()
        utils.clear_extmarks(self.buffer)
        self._show = false
    end
end

return Separator
