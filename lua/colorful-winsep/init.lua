-- @author      : aero (2254228017@qq.com)
-- @file        : init
-- @created     : 星期日 10月 30, 2022 19:59:08 CST
-- @github      : https://github.com/denstiny
-- @blog        : https://denstiny.github.io

local api = vim.api
local fn = vim.fn
local M = {
  lock = false
}
local view = require("colorful-winsep.view")

function M.NvimSeparatorShow()
  view.lock = true
  if view.create_dividing_win(true) then
    view.set_buf_char()
    view.start_timer()
    --else
    --  if view.move_dividing_win() then
    --    view.set_buf_char()
    --  end
  end
  view.lock = false
end

function M.SeparatorShow()
  --M.NvimSeparatorDel()
  view.lock = true
  -- @todo
  if view.create_dividing_win(false) then
    view.set_buf_char()
    view.start_timer()
  end
  view.lock = false
end

function M.NvimSeparatorDel()
  view.stop_timer()
  view.close_dividing()
end

function M.setup(opts)
  view.set_config(opts)
  view.highlight()
  M.auto_group = api.nvim_create_augroup("NvimSeparator", { clear = true })
  if view.config.auto_show then
    api.nvim_create_autocmd({ "WinEnter" }, {
      group = M.auto_group,
      callback = function()
        if M.lock then
          return
        end
        M.NvimSeparatorShow()
      end
    })
  end
  api.nvim_create_autocmd({ "WinLeave", "CmdlineLeave", "WinClosed" }, {
    group = M.auto_group,
    callback = function()
      if M.lock then
        return
      end
      M.NvimSeparatorDel()
    end
  })
end

return M
