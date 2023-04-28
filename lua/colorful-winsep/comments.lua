local M = {}
local NotifyTitle = "colorful-winsep.nvim"
function Notify(body_text)
	local msg = table.concat(body_text, "\n")
	vim.notify_once(msg, vim.log.levels.WARN, {
		title = NotifyTitle,
	})
end

-- fix comments ,check code
M.check = function(opts)
	Compatiblehighlight(opts)
end

--- check key in table
---@param tab
---@param key
---@return
function has_key(tab, key)
	for k, _ in pairs(tab) do
		if k == key then
			return true
		end
	end
	return false
end

---  fix(#21): repair highlight #21
---@param opts
function Compatiblehighlight(opts)
	if has_key(opts, "highlight") then
		if has_key(opts.highlight, "guifg") or has_key(opts.highlight, "guibg") then
			Notify({
				"fix(#21): repair highlight",
				"guifg and guibg Has been launched",
				"```lua",
				"colorful_winsep.setup({",
				"    highlight = {",
				'        fg = "#DB6889",',
				'        bg = "#0D0F18",',
				"    }",
				"})",
				"```",
			})
			local utils = require("colorful-winsep.utils")
			opts.highlight = utils.defaultopts.highlight
		end
	end
end

function M.Rename_getWinNumber()
	Notify({
		'Rename the API `require("colorful-winsep.utils").getWinNumber()`',
		'use `require("colorful-winsep.utils").calculate_number_windows()`',
	})
end

return M
