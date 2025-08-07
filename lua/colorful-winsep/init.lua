local M = {}
local view = require("colorful-winsep.view")

function M.setup(opts)
  view:init(opts)
end

function M.hide()
  view:hide()
end

function M.render()
  view:dividing_split_line()
end

return M
