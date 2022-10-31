-- @author      : aero (2254228017@qq.com)
-- @file        : init
-- @created     : 星期日 10月 30, 2022 19:59:08 CST
-- @github      : https://github.com/denstiny
-- @blog        : https://denstiny.github.io

local api = vim.api
local fn = vim.fn
local M = {}


local defaultopts = {
  symbols = { "━", "┃", "┣", "┫", "╋", "┻", "┳" },
  highlight = { guifg = "#957CC6", guibg = "bg" },
  win_opts = { style = 'minimal', relative = 'editor' },
  no_exec_files = { "packer" },
  direction = { right = 'l', left = 'h', down = 'j', up = 'k' }
}

function M:highlight()
  local opts = M.config.highlight
  vim.api.nvim_set_hl(0, 'NvimSeparator', { fg = opts.guifg, bg = opts.guibg })
end

function M:can_create()
  local cursor_win_filetype = vim.bo.filetype
  local no_exec_files = M.config.no_exec_files
  for i = 1, #no_exec_files do
    if cursor_win_filetype == no_exec_files[i] then
      return true
    end
  end
  return false
end

function M:new_buffer()
  M.buf_left = api.nvim_create_buf(false, false)
  M.buf_right = api.nvim_create_buf(false, false)
  M.buf_up = api.nvim_create_buf(false, false)
  M.buf_down = api.nvim_create_buf(false, false)
end

function M:initbuf()
  -- left
  local symbols = M.config.symbols
  if M.win_up ~= nil then
    local len = fn.winwidth(M.win_up)
    local str = { "" }
    for i = 1, len do
      str[1] = str[1] .. symbols[1]
    end
    api.nvim_buf_set_lines(M.buf_up, 0, -1, false, str)
  end

  if M.win_down ~= nil then
    local len = fn.winwidth(M.win_down)
    local str = { "" }
    for i = 1, len do
      str[1] = str[1] .. symbols[1]
    end
    api.nvim_buf_set_lines(M.buf_down, 0, -1, false, str)
  end

  if M.win_left ~= nil then
    local len = fn.winheight(M.win_left)
    local str = {}
    for i = 1, len do
      str[i] = symbols[2]
    end
    api.nvim_buf_set_lines(M.buf_left, 0, -1, false, str)
  end

  if M.win_right ~= nil then
    local len = fn.winheight(M.win_right)
    local str = { "" }
    for i = 1, len do
      str[i] = symbols[2]
    end
    api.nvim_buf_set_lines(M.buf_right, 0, -1, false, str)
  end
end

function M:create_float_win()
  M:close_win_space()
  M:close_buf_space()
  if M:can_create() then
    return
  end
  M:new_buffer()
  local cursor_win_pos = api.nvim_win_get_position(0)
  local cursor_win_width = fn.winwidth(0)
  local cursor_win_height = fn.winheight(0)
  if vim.o.winbar ~= '' then
    cursor_win_height = cursor_win_height + 1
  end
  local direction = M.config.direction
  -- left
  if M:direction_have(direction.left) then
    local opts = M.config.win_opts
    opts.width = 1
    opts.height = cursor_win_height
    opts.row = cursor_win_pos[1]
    opts.col = cursor_win_pos[2] - 1
    M.win_left = api.nvim_open_win(M.buf_left, false, opts)
    api.nvim_win_set_option(M.win_left, 'winhl', 'Normal:NvimSeparator')
  end
  -- right
  if M:direction_have(direction.right) then
    local opts = M.config.win_opts
    opts.width = 1
    opts.height = cursor_win_height
    opts.row = cursor_win_pos[1]
    opts.col = cursor_win_pos[2] + cursor_win_width
    M.win_right = api.nvim_open_win(M.buf_right, false, opts)
    api.nvim_win_set_option(M.win_right, 'winhl', 'Normal:NvimSeparator')
  end
  -- up
  if M:direction_have(direction.up) then
    local opts = M.config.win_opts
    --if M:direction_have(direction.left) and M:direction_have(direction.right) then
    --  opts.width = cursor_win_width + 2
    --else
    --  opts.width = cursor_win_width + 1
    --end
    opts.width = cursor_win_width
    opts.height = 1
    opts.row = cursor_win_pos[1] - 1
    opts.col = cursor_win_pos[2]
    M.win_up = api.nvim_open_win(M.buf_up, false, opts)
    api.nvim_win_set_option(M.win_up, 'winhl', 'Normal:NvimSeparator')
  end
  -- down
  if M:direction_have(direction.down) then
    local opts = M.config.win_opts
    --if M:direction_have(direction.left) and M:direction_have(direction.right) then
    --  opts.width = cursor_win_width + 2
    --else
    --  opts.width = cursor_win_width + 1
    --end
    opts.width = cursor_win_width
    opts.height = 1
    opts.row = cursor_win_pos[1] + cursor_win_height
    opts.col = cursor_win_pos[2]
    M.win_down = api.nvim_open_win(M.buf_down, false, opts)
    api.nvim_win_set_option(M.win_down, 'winhl', 'Normal:NvimSeparator')
  end
  M.initbuf()
end

function M:close_win_space()
  if M.win_left ~= nil then
    api.nvim_win_close(M.win_left, true)
    M.win_left = nil
  end
  if M.win_right ~= nil then
    api.nvim_win_close(M.win_right, true)
    M.win_right = nil
  end
  if M.win_up ~= nil then
    api.nvim_win_close(M.win_up, true)
    M.win_up = nil
  end
  if M.win_down ~= nil then
    api.nvim_win_close(M.win_down, true)
    M.win_down = nil
  end
end

function M:close_buf_space()
  if M.buf_left ~= nil and M.buf_right ~= nil and M.buf_down ~= nil and M.buf_up ~= nil then
    api.nvim_buf_delete(M.buf_left, { force = true })
    api.nvim_buf_delete(M.buf_right, { force = true })
    api.nvim_buf_delete(M.buf_up, { force = true })
    api.nvim_buf_delete(M.buf_down, { force = true })
    M.buf_left = nil
    M.buf_right = nil
    M.buf_up = nil
    M.buf_down = nil
  end
end

function M:direction_have(direction)
  local winnum = vim.fn.winnr()
  api.nvim_command('wincmd ' .. direction)
  if winnum ~= vim.fn.winnr() then
    --local pos = api.nvim_win_get_position(vim.fn.winnr())
    api.nvim_command("exe " .. winnum .. "\"wincmd w\"")
    return true
  end
  return false
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", defaultopts, opts)
  M:highlight()
  M.auto_group = api.nvim_create_augroup("NvimSeparator", { clear = true })
  api.nvim_create_autocmd({ "WinEnter", "VimResized", "BufCreate", "BufEnter", "BufWinEnter", "CursorHold" }
    , {
    group = M.auto_group,
    callback = function()
      M:create_float_win()
    end
  })
  api.nvim_create_autocmd({ "VimLeave" }, {
    group = M.auto_group,
    callback = function()
      M:close_win_space()
      M:close_buf_space()
    end
  })
end

return M
