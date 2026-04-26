local config = require("colorful-winsep.config")
local view = require("colorful-winsep.view")
local api = vim.api

local M = {}
M.enabled = true
M.colors = {}
M.marquee_timer = nil
M.marquee_offset = 0
local marquee_ns_id = api.nvim_create_namespace("colorful-winsep-marquee")

function M.enable()
    M.enabled = true
    view.render()
end

function M.disable()
    M.enabled = false
    view.hide_all()
end

function M.toggle()
    if M.enabled then
        M.disable()
    else
        M.enable()
    end
end

--- Set custom colors for separators. 
--- Single color will be statically applied, while multiple colors will create a marquee effect.
---@param colors table A list of hex color strings (e.g. {"#FF0000", "#00FF00"})
function M.set_colors(colors)
    if type(colors) ~= "table" or #colors == 0 then return end
    M.colors = colors

    if M.marquee_timer and not M.marquee_timer:is_closing() then
        M.marquee_timer:stop()
        M.marquee_timer:close()
        M.marquee_timer = nil
    end

    local bg = api.nvim_get_hl(0, { name = "Normal" }).bg

    if #colors == 1 then
        api.nvim_set_hl(0, "ColorfulWinSep", { fg = colors[1], bg = bg })
        for _, sep in pairs(view.separators) do
             if sep.buffer and api.nvim_buf_is_valid(sep.buffer) then
                 api.nvim_buf_clear_namespace(sep.buffer, marquee_ns_id, 0, -1)
             end
        end
    else
        for i, c in ipairs(colors) do
            api.nvim_set_hl(0, "ColorfulWinSep_" .. i, { fg = c, bg = bg })
        end
        
        M.marquee_offset = 0
        M.marquee_timer = vim.uv.new_timer()
        M.marquee_timer:start(0, 100, vim.schedule_wrap(function()
            if not M.enabled then return end
            
            M.marquee_offset = (M.marquee_offset + 1) % #M.colors
            
            local nodes = view.border_model:get_nodes()
            if #nodes == 0 then return end
            
            -- First pass: clear old extmarks for all valid buffers
            for _, sep in pairs(view.separators) do
                if sep._show and api.nvim_buf_is_valid(sep.buffer) then
                    api.nvim_buf_clear_namespace(sep.buffer, marquee_ns_id, 0, -1)
                end
            end
            
            -- Second pass: map global color index to each buffer
            for _, node in ipairs(nodes) do
                local color_idx = ((node.index + M.marquee_offset) % #M.colors) + 1
                local hl_group = "ColorfulWinSep_" .. color_idx

                local sep = view.separators[node.win_dir]
                
                if sep and sep._show and api.nvim_buf_is_valid(sep.buffer) then
                    local virt_char = nil
                    
                    -- Allow user to completely override char and hl_group per frame
                    if config.opts.on_frame_render then
                        local custom_char, custom_hl = config.opts.on_frame_render(node, color_idx, M.marquee_offset, #M.colors, #nodes)
                        if custom_char then virt_char = custom_char end
                        if custom_hl then hl_group = custom_hl end
                    end

                    local extmark_opts = {
                        end_row = node.buf_idx,
                        end_col = 0,
                        hl_group = hl_group,
                    }

                    if node.win_dir == "left" or node.win_dir == "right" then
                        -- For vertical bars, `buf_idx` translates to line number (1-indexed)
                        local target_char = virt_char or node.char
                        local old_line = api.nvim_buf_get_lines(sep.buffer, node.buf_idx - 1, node.buf_idx, false)[1]
                        if old_line and target_char and old_line ~= target_char then
                            api.nvim_buf_set_lines(sep.buffer, node.buf_idx - 1, node.buf_idx, false, { target_char })
                        end
                        api.nvim_buf_set_extmark(sep.buffer, marquee_ns_id, node.buf_idx - 1, 0, extmark_opts)
                    else
                        -- For horizontal bars, `buf_idx` translates to column position
                        local lines = api.nvim_buf_get_lines(sep.buffer, 0, 1, false)
                        if lines[1] then
                            local byte_start = vim.fn.byteidx(lines[1], node.buf_idx - 1)
                            local byte_end = vim.fn.byteidx(lines[1], node.buf_idx)
                            
                            extmark_opts.end_row = 0
                            extmark_opts.end_col = byte_end
                            
                            local target_char = virt_char or node.char
                            local current_char = string.sub(lines[1], byte_start + 1, byte_end)
                            if target_char and current_char ~= target_char then
                                local new_line = string.sub(lines[1], 1, byte_start) .. target_char .. string.sub(lines[1], byte_end + 1)
                                api.nvim_buf_set_lines(sep.buffer, 0, 1, false, { new_line })
                                
                                byte_end = byte_start + #target_char
                                extmark_opts.end_col = byte_end
                            end
                            api.nvim_buf_set_extmark(sep.buffer, marquee_ns_id, 0, byte_start, extmark_opts)
                        end
                    end
                end
            end
        end))
    end
end

local function create_command()
    api.nvim_create_user_command("Winsep", function(ctx)
        local subcommand = ctx.args
        if subcommand == "enable" then
            M.enable()
        elseif subcommand == "disable" then
            M.disable()
        elseif subcommand == "toggle" then
            M.toggle()
        else
            vim.notify("Colorful-Winsep: no command " .. ctx.args)
        end
    end, {
        nargs = 1,
        complete = function(arg)
            local list = { "enable", "disable", "toggle" }
            return vim.tbl_filter(function(s)
                return string.match(s, "^" .. arg)
            end, list)
        end,
    })
end

function M.setup(user_opts)
    user_opts = user_opts or {}
    config.merge_config(user_opts)

    create_command()

    if config.opts.colors and #config.opts.colors > 0 then
        M.set_colors(config.opts.colors)
    end

    local auto_group = api.nvim_create_augroup("colorful_winsep", { clear = true })
    api.nvim_create_autocmd({ "WinEnter", "WinResized", "BufWinEnter" }, {
        group = auto_group,
        callback = function(ctx)
            if not M.enabled then
                return
            end

            -- exclude floating windows
            local current_win = vim.fn.bufwinid(ctx.buf)
            if current_win ~= -1 then
                local win_config = api.nvim_win_get_config(current_win)
                if win_config.relative ~= nil and win_config.relative ~= "" then
                    return
                end
            end

            if vim.tbl_contains(config.opts.excluded_ft, vim.bo[ctx.buf].ft) then
                view.hide_all()
                return
            end
            vim.schedule(view.render)
        end,
    })

    -- after loading a session, any pre-existing buffers are removed
    api.nvim_create_autocmd("SessionLoadPost", {
        group = auto_group,
        callback = function()
            for _, sep in pairs(view.separators) do
                if not api.nvim_buf_is_valid(sep.buffer) then
                    sep.buffer = api.nvim_create_buf(false, true)
                end
            end
        end,
    })

    -- for some cases that close the separators windows(fail to trigger the WinLeave event), like `:only` command
    for _, sep in pairs(view.separators) do
        api.nvim_create_autocmd({ "BufHidden" }, {
            buffer = sep.buffer,
            callback = function()
                if not M.enabled then
                    return
                end
                sep:hide()
            end,
        })
    end

    config.opts.highlight()
    api.nvim_create_autocmd({ "ColorSchemePre" }, {
        group = auto_group,
        callback = function()
            api.nvim_set_hl(0, "ColorfulWinSep", {})
        end,
    })
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = auto_group,
        callback = function()
            if M.colors and #M.colors > 0 then
                M.set_colors(M.colors)
            else
                config.opts.highlight()
            end
        end,
    })
end

return M
