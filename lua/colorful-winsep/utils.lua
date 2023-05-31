local fn = vim.fn
local bo = vim.bo
local api = vim.api
local comments = require("colorful-winsep.comments")
local M = {
	defaultopts = {
		symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
		no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest" },
		highlight = { fg = "#957CC6", bg = api.nvim_get_hl_by_name("Normal", true)["background"] },
		interval = 100,
		enable = true,
		create_event = function() end,
		close_event = function() end,
	},
	direction = { left = "h", right = "l", up = "k", down = "j" },
	c_win = -1,
	pos = api.nvim_win_get_position(0),
}

--- Judge whether the current can be started and colorful line
---@param no_exec_files table
---@return boolean
function M.can_create(no_exec_files)
	if vim.fn.win_gettype(0) == "popup" then -- Skip the floating window
		M.c_win = api.nvim_get_current_win()
		return false
	end
	local win = api.nvim_get_current_win()
	if M.c_win == win then
		return false
	end
	local cursor_win_filetype = bo.filetype
	for i = 1, #no_exec_files do
		if no_exec_files[i] == cursor_win_filetype then
			M.c_win = api.nvim_get_current_win()
			return false
		end
	end
	M.c_win = win
	return true
end

--- is old create
function M.isWinMove()
	--local win = api.nvim_get_current_win()
	local pos = api.nvim_win_get_position(0)
	if M.pos[1] ~= pos[1] or M.pos[2] ~= pos[2] then
		M.pos = pos
		M.c_win = -1
		return true
	else
		return false
	end
end

--- Determine if there are neighbors in the direction
---@param direction string
---@return boolean
function M.direction_have(direction)
	local winnum = vim.fn.winnr()
	if vim.fn.winnr(direction) ~= winnum and fn.win_gettype(winnum) ~= "popup" then
		return true
	end
	return false
end

--- @class WinOption
--- @field style string
--- @field relative string
--- @field zindex number
--- @field focusable boolean
--- @field height number
--- @field width number
--- @field row number
--- @field col number
---
--- Get the win property of the orientation
--- @param direction string left = 'h', right = 'l', up = 'k', down = 'j'
--- @return WinOption | nil
function M.create_direction_win_option(direction)
	local opts = {
		style = "minimal",
		relative = "editor",
		zindex = 10,
		focusable = false,
		height = 0,
		width = 0,
		row = 0,
		col = 0,
	}
	local cursor_win_pos = api.nvim_win_get_position(0)
	local cursor_win_width = fn.winwidth(0)
	local cursor_win_height = fn.winheight(0)
	if fn.has("nvim-0.8") then
		if vim.o.winbar ~= "" then
			cursor_win_height = cursor_win_height + 1
		end
	end
	-- vertical line
	if direction == M.direction.left or direction == M.direction.right then
		opts.width = 1
		if M.direction_have(M.direction.up) and (M.direction_have(M.direction.down) or vim.o.laststatus ~= 3) then
			if vim.o.laststatus == 0 then
				opts.height = cursor_win_height + 1
			else
				opts.height = cursor_win_height + 2
			end
		elseif not M.direction_have(M.direction.up) and not M.direction_have(M.direction.down) then
			if vim.o.laststatus ~= 3 then
				opts.height = cursor_win_height + 1
			else
				opts.height = cursor_win_height
			end
		else
			opts.height = cursor_win_height + 1
		end
		if not M.direction_have(M.direction.up) and vim.o.showtabline == 2 then
			opts.row = cursor_win_pos[1]
		elseif not M.direction_have(M.direction.up) and vim.o.showtabline == 1 then
			if fn.tabpagenr("$") > 1 then
				opts.row = cursor_win_pos[1]
			else
				opts.row = cursor_win_pos[1] - 1
			end
		else
			opts.row = cursor_win_pos[1] - 1
		end
		if direction == M.direction.left then
			opts.col = cursor_win_pos[2] - 1
		else
			opts.col = cursor_win_pos[2] + cursor_win_width
		end

		--- Used to distinguish only two window, do special processing line
		if M.calculate_number_windows() == 2 then
			local even_height = opts.height % 2 == 0
			opts.height = math.ceil(opts.height / 2)
			if M.direction_have(M.direction.left) and not M.direction_have(M.direction.right) then
				if vim.o.cmdheight == 0 and not even_height then
					opts.row = opts.row + opts.height
				else
					opts.row = opts.row + opts.height + 1
				end
			end
		end
	end

	-- horizontal line
	if direction == M.direction.up or (direction == M.direction.down and vim.o.laststatus == 3) then
		opts.width = cursor_win_width
		opts.height = 1
		if direction == M.direction.up then
			opts.row = cursor_win_pos[1] - 1
		else
			opts.row = cursor_win_pos[1] + cursor_win_height
		end
		opts.col = cursor_win_pos[2]

		--- Used to distinguish only two window, do special processing line
		if M.calculate_number_windows() == 2 then
			opts.width = math.ceil(opts.width / 2)
			if M.direction_have(M.direction.up) and not M.direction_have(M.direction.down) then
				opts.col = opts.col + opts.width
			end
		end
	end
	if opts.height == 0 and opts.width == 0 and opts.row == 0 and opts.col == 0 then
		return nil
	end
	return opts
end

--- Override user configuration
---@param opts table
function M.set_user_config(opts)
	if type(opts) == "table" and opts ~= {} then
		comments.check(opts)
		M.defaultopts = vim.tbl_deep_extend("force", M.defaultopts, opts)
	end
end

--- Calculation window number,Rule out floating window to get the real number
---@return number
function M.calculate_number_windows()
	local win_len = fn.winnr("$")
	for i = 1, win_len do
		if fn.win_gettype(i) == "popup" then
			win_len = win_len - 1
		end
	end
	return win_len
end

function M.getWinNumber()
	comments.Rename_getWinNumber()
	return M.calculate_number_windows()
end

--- Determine if given version is above or equal current nvim version.
---@param major number
---@param minor number
---@param patch number
---@return boolean
function M.check_version(major, minor, patch)
	return major >= vim.version()["major"] and minor >= vim.version()["minor"] and patch >= vim.version()["patch"]
end

return M
