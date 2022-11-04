-- @author      : aero (2254228017@qq.com)
-- @file        : init
-- @created     : 星期日 10月 30, 2022 19:59:08 CST
-- @github      : https://github.com/denstiny
-- @blog        : https://denstiny.github.io

local api = vim.api
local fn = vim.fn
local M = {}
local view = require("colorful-winsep.view")

function M.NvimSeparatorShow()
  if view.create_dividing_win() then
    view.set_buf_char()
    view.start_timer()
    --else
    --  if view.move_dividing_win() then
    --    view.set_buf_char()
    --  end
  end
end

function M.NvimSeparatorDel()
  view.stop_timer()
  view.close_dividing()
end

function M.setup(opts)
  view.set_config(opts)
  view.highlight()
  M.auto_group = api.nvim_create_augroup("NvimSeparator", { clear = true })
  api.nvim_create_autocmd({ "WinEnter" }, {
    group = M.auto_group,
    callback = function()
      M.NvimSeparatorShow()
    end
  })
  api.nvim_create_autocmd({ "WinLeave" }, {
    group = M.auto_group,
    callback = function()
      M.NvimSeparatorDel()
    end
  })
end

return M
