local api = vim.api
local fn = vim.fn
local utils = require('colorful-winsep.utils')
local M = {
  config = utils.defaultopts,
  wins = {},
  bufs = {}
}

function M.create_dividing_win()
  if not utils.can_create(M.config.no_exec_files) then
    vim.notify("no create")
    return
  else
    vim.notify('create')
  end
  local direction = utils.direction
  for _, value in pairs(direction) do
    -- @todo
    if utils.direction_have(value) then
      local opts = utils.create_direction_win_option(value)
      local buf = api.nvim_create_buf(false, false)
      table.insert(M.bufs, buf)
      api.nvim_buf_set_option(buf, "buftype", "nofile")
      local win = api.nvim_open_win(buf, false, opts)
      table.insert(M.wins, win)
      api.nvim_win_set_option(win, 'winhl', 'Normal:NvimSeparator')
    end
  end
end

function M.close_dividing()
  for i = 1, #M.bufs do
    api.nvim_buf_delete(M.bufs[i], { force = true })
    M.bufs[i] = nil
  end
  M.bufs = {}
  for i = 1, #M.wins do
    api.nvim_win_close(M.wins[i], true)
    M.wins[i] = nil
  end
  M.wins = {}
end

function M.set_config(opts)
  if type(opts) == "table" or opts ~= {} then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end
end

return M
