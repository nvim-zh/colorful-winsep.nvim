local M = {}
local api = vim.api
local utils = require("colorful-winsep.utils")

local ns_id = api.nvim_create_namespace("colorful-winsep")

function M:create_line()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "filetype", "NvimSeparator")
  local line = {
    start_symbol = "",
    body_symbol = "",
    end_symbol = "",
    loop = vim.loop.new_timer(),
    buffer = buf,
    window = nil,
    opts = {
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
    _show = false,
  }

  function line:is_show()
    return self._show
  end

  function line:set_parrent(parrent)
    self.parrent = parrent
  end

  function line:height()
    return self.opts.height
  end

  function line:width()
    return self.opts.width
  end

  function line:smooth_height(start_height, end_height)
    local timer = vim.loop.new_timer()
    local _line = self
    local cu = math.abs(start_height - end_height)
    timer:start(
      0,
      30,
      vim.schedule_wrap(function()
        if start_height > end_height then
          start_height = start_height - 1
        elseif start_height < end_height then
          start_height = start_height + 1
        end

        cu = cu - 1
        _line:set_height(start_height)
        if cu < 0 then
          timer:stop()
          --timer:close()
        end
      end)
    )
  end

  function line:smooth_width(start_width, end_width)
    local timer = vim.loop.new_timer()
    local _line = self
    local cu = math.abs(start_width - end_width)
    timer:start(
      0,
      10,
      vim.schedule_wrap(function()
        if start_width > end_width then
          start_width = start_width - 1
        elseif start_width < end_width then
          start_width = start_width + 1
        end
        cu = cu - 1
        _line:set_width(start_width)
        if cu < 0 then
          timer:stop()
          --timer:close()
        end
      end)
    )
  end

  function line:smooth_move_x(start_x, end_x)
    if not self.loop:is_closing() then
      self.loop:stop()
      self.loop:close()
      self.loop = vim.loop.new_timer()
    else
      self.loop = vim.loop.new_timer()
    end
    local _line = self
    local cu = math.abs(start_x - end_x)
    self.loop:start(
      0,
      10,
      vim.schedule_wrap(function()
        if start_x > end_x then
          start_x = start_x - 1
        elseif start_x < end_x then
          start_x = start_x + 1
        end
        cu = cu - 1
        _line:move(start_x, _line:y())
        if cu < 0 then
          if not self.loop:is_closing() then
            self.loop:stop()
            self.loop:close()
          end
        end
      end)
    )
  end

  --- 高亮指定位置
  ---@param x integer
  ---@param y integer
  ---@param color integer
  function line:pos_color(x, y, color, symbol)
    --local char = utils.get_buffer_char(self.buffer, x, y)
    local opt = {
      virt_text = { { symbol, color } },
      virt_text_pos = "overlay",
    }
    local id = vim.api.nvim_buf_set_extmark(self.buffer, ns_id, x, y, opt)
    local key = string.format("%s_%s", x, y)
    if self.extmarks[key] ~= nil then
      vim.api.nvim_buf_del_extmark(self.buffer, ns_id, self.extmarks[key])
    end
    self.extmarks[key] = id
  end

  function line:smooth_move_y(start_y, end_y)
    if not self.loop:is_closing() then
      self.loop:stop()
      self.loop:close()
      self.loop = vim.loop.new_timer()
    else
      self.loop = vim.loop.new_timer()
    end

    local _line = self
    local cu = math.abs(start_y - end_y)
    self.loop:start(
      0,
      3,
      vim.schedule_wrap(function()
        if start_y > end_y then
          start_y = start_y - 1
        elseif start_y < end_y then
          start_y = start_y + 1
        end
        _line:move(_line:x(), start_y)
        cu = cu - 1
        if cu < 0 then
          if not self.loop:is_closing() then
            self.loop:stop()
            self.loop:close()
          end
        end
      end)
    )
  end

  function line:smooth_move_x_exp(start_x, end_x)
    if not self.loop:is_closing() then
      self.loop:stop()
      self.loop:close()
      self.loop = vim.loop.new_timer()
    else
      self.loop = vim.loop.new_timer()
    end

    local _line = self
    local position = start_x -- Initialize position to start_x
    local target = end_x   -- Set the target position
    local delta_time = 0.1 -- Default delta time
    local smooth_speed = 1 -- Default smoothing speed

    self.loop:start(
      0,
      3,
      vim.schedule_wrap(function()
        -- Calculate exponential decay
        local decay_factor = math.exp(-smooth_speed * delta_time)

        -- Update position based on direction
        if start_x > end_x then
          position = math.max(target, position - 1)
        elseif start_x < end_x then
          position = math.min(target, position + 1)
        end

        -- Perform linear interpolation
        position = utils.lerp(target, position, decay_factor)

        -- Update line position
        _line:move(position, _line:y())

        -- Check if position is close enough to the target
        if math.abs(position - target) < 0.1 then
          if not self.loop:is_closing() then
            self.loop:stop()
            self.loop:close()
          end
        end
      end)
    )
  end

  function line:smooth_move_y_exp(start_y, end_y)
    if not self.loop:is_closing() then
      self.loop:stop()
      self.loop:close()
      self.loop = vim.loop.new_timer()
    else
      self.loop = vim.loop.new_timer()
    end

    local _line = self
    local position = start_y -- Initialize position to start_y
    local target = end_y   -- Set the target position
    local delta_time = 0.1 -- Default delta time
    local smooth_speed = 1 -- Default smoothing speed

    self.loop:start(
      0,
      3,
      vim.schedule_wrap(function()
        -- Calculate exponential decay
        local decay_factor = math.exp(-smooth_speed * delta_time)

        -- Update position based on direction
        if start_y > end_y then
          position = math.max(target, position - 1)
        elseif start_y < end_y then
          position = math.min(target, position + 1)
        end

        -- Perform linear interpolation
        position = utils.lerp(target, position, decay_factor)

        -- Update line position
        _line:move(_line:x(), position)

        -- Check if position is close enough to the target
        if math.abs(position - target) < 0.1 then
          if not self.loop:is_closing() then
            self.loop:stop()
            self.loop:close()
          end
        end
      end)
    )
  end

  function line:hide()
    if self.window ~= nil and api.nvim_win_is_valid(self.window) then
      vim.api.nvim_win_close(self.window, false)
      self.window = nil
      self._show = false
      if not self.loop:is_closing() then
        self.loop:stop()
        self.loop:close()
      end
    end
  end

  function line:show()
    if vim.api.nvim_buf_is_valid(self.buffer) then
      win = api.nvim_open_win(self.buffer, false, self.opts)
      api.nvim_win_set_option(win, "winhl", "Normal:NvimSeparator")
      self.window = win
      self._show = true
    end
  end

  function line:x()
    return self.opts.row
  end

  function line:y()
    return self.opts.col
  end

  ---@param x
  ---@param y
  function line:move(x, y)
    self:movecorrection()
    self.opts.row = x
    self.opts.col = y
    self:load_opts(self.opts)
  end

  function line:load_opts(opts)
    if self.window ~= nil and api.nvim_win_is_valid(self.window) then
      api.nvim_win_set_config(self.window, opts)
    end
  end

  function line:movecorrection() end

  function line:hcorrection(height) end

  function line:vcorrection(width) end

  function line:set_width(width)
    self:vcorrection(width)
    self.opts.width = width
    self:load_opts(self.opts)
  end

  function line:set_height(height)
    --print(string.format("winheight %s", vim.fn.winheight(0)))
    if utils.direction_have(utils.direction.up) then
      height = height + 1
    end

    if vim.o.winbar ~= "" then
      height = height + 1
    end

    if not utils.direction_have(utils.direction.bottom) and vim.o.laststatus == 3 then
      height = height - 1
    end

    self:hcorrection(height)
    --print(string.format("winseip height %s", height))
    self.opts.height = height
    self:load_opts(self.opts)
  end

  return line
end

-- create vertical line
function M:create_vertical_line(width, start_symbol, body_symbol, end_symbol)
  local line = M:create_line()
  line.start_symbol = start_symbol
  line.body_symbol = body_symbol
  line.end_symbol = end_symbol

  line:set_width(width)
  line.opts.height = 1
  function line:vcorrection(width)
    if vim.api.nvim_buf_is_valid(self.buffer) then
      local line = utils.build_vertical_line_symbol(width, self.start_symbol, self.body_symbol, self.end_symbol)
      vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, line)
    end
  end

  return line
end

-- create horizontal line
function M:create_horizontal_line(height, start_symbol, body_symbol, end_symbol)
  local line = M:create_line()
  line.start_symbol = start_symbol
  line.body_symbol = body_symbol
  line.end_symbol = end_symbol

  line.opts.width = 1
  line:set_height(height)
  function line:hcorrection(height)
    if vim.api.nvim_buf_is_valid(self.buffer) then
      local line = utils.build_horizontal_line_symbol(height, self.start_symbol, self.body_symbol, self.end_symbol)
      vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, line)
    end
  end

  return line
end

return M
