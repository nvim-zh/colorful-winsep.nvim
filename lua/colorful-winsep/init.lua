local config = require("colorful-winsep.config")
local view = require("colorful-winsep.view")

local M = {}
M.enabled = true

local function highlight()
    if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = "ColorfulWinSep" })) then
        vim.api.nvim_set_hl(0, "ColorfulWinSep", config.opts.highlight)
    end
end

local function create_command()
    vim.api.nvim_create_user_command("Winsep", function(ctx)
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

    local auto_group = vim.api.nvim_create_augroup("colorful_winsep", { clear = true })
    vim.api.nvim_create_autocmd({ "WinEnter", "WinResized", "BufWinEnter" }, {
        group = auto_group,
        callback = function(ctx)
            if not M.enabled then
                return
            end

            -- exclude floating windows
            local current_win = vim.fn.bufwinid(ctx.buf)
            if current_win ~= -1 then
                local win_config = vim.api.nvim_win_get_config(current_win)
                if win_config.relative ~= nil and win_config.relative ~= "" then
                    return
                end
            end

            if vim.tbl_contains(config.opts.excluded_ft, vim.bo[ctx.buf].ft) then
                view.hide_all()
                return
            end
            view.render()
        end,
    })

    vim.api.nvim_create_autocmd({ "WinLeave" }, {
        group = auto_group,
        callback = function()
            if not M.enabled then
                return
            end
            view.hide_all()
        end,
    })
    -- for some cases that close the separators windows(fail to trigger the WinLeave event), like `:only` command
    for _, sep in pairs(view.separators) do
        vim.api.nvim_create_autocmd({ "BufHidden" }, {
            buffer = sep.buffer,
            callback = function()
                if not M.enabled then
                    return
                end
                sep:hide()
            end,
        })
    end

    highlight()
    vim.api.nvim_create_autocmd({ "ColorScheme", "ColorSchemePre" }, {
        group = auto_group,
        callback = highlight,
    })
end

return M
