-- @author      : aero (2254228017@qq.com)
-- @file        : init
-- @created     : 星期日 10月 30, 2022 19:59:08 CST
-- @github      : https://github.com/denstiny
-- @blog        : https://denstiny.github.io

local api = vim.api
local view = require("colorful-winsep.view")
local fn = vim.fn
local M = { lock = false }

function M.NvimSeparatorShow()
	vim.defer_fn(function()
		M.lock = true
		if view.create_dividing_win() then
			view.set_buf_char()
		else
			if view.move_dividing_win() then
				view.set_buf_char()
			end
		end
		M.lock = false
		view.config.create_event()
	end, require("colorful-winsep.utils").defaultopts.interval)
end

function M.NvimSeparatorDel()
	view.close_dividing()
	view.config.close_event()
end

function M.setup(opts)
	view.set_config(opts)
	M.auto_group = api.nvim_create_augroup("NvimSeparator", { clear = true })
	if view.config.enable then
		api.nvim_create_autocmd(
			{ "WinEnter", "WinScrolled", "VimResized", "WinClosed", "ColorScheme", "ColorSchemePre" },
			{
				group = M.auto_group,
				callback = function(opts)
					if M.lock then
						return
					end
					if opts.event == "WinClosed" then
						local winnr = fn.bufwinid(opts.buf)
						if fn.win_gettype(winnr) == "popup" then
							return
						end
						M.NvimSeparatorDel()
					end
					if opts.event == "ColorScheme" or opts.event == "WinEnter" then
						view.highlight()
					end
					M.NvimSeparatorShow()
				end,
			}
		)
	end
	api.nvim_create_autocmd({ "WinLeave", "BufModifiedSet" }, {
		group = M.auto_group,
		callback = function(opts)
			if ModifiedSet_no_closed_solt(opts) then
				return
			end
			M.NvimSeparatorDel()
		end,
	})
	view.start_timer()
end

function ModifiedSet_no_closed_solt(opts)
	if opts.event == "BufModifiedSet" then
		local filetype_lock = false
		for i = 1, #view.config.no_exec_files do
			if view.config.no_exec_files[i] == vim.bo.filetype then
				filetype_lock = true
			end
		end
		if not filetype_lock then
			return true
		end
	end
	if M.lock then
		return true
	else
		return false
	end
end

return M
