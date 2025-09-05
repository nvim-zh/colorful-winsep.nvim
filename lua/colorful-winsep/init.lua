local config = require("colorful-winsep.config")
local view = require("colorful-winsep.view")
local api = vim.api

local M = {}
M.enabled = true

local function create_command()
    api.nvim_create_user_command("Winsep", function(ctx)
        local subcommand = ctx.args
        if subcommand == "enable" then
            M.enabled = true
            view.render()
        elseif subcommand == "disable" then
            M.enabled = false
            view.hide_all()
        elseif subcommand == "toggle" then
            if M.enabled then
                M.enabled = false
                view.hide_all()
            else
                M.enabled = true
                view.render()
            end
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
        callback = config.opts.highlight,
    })
end

return M
