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
  view.create_dividing_win()
end

function M.NvimSeparatorDel()
end

function M.setup(opts)
end

return M
