local M = {}
M.opts = {
    -- choose between "signle", "rounded", "bold" and "double".
    -- Or pass a tbale like this: { "─", "│", "┌", "┐", "└", "┘" },
    border = "bold",
    excluded_ft = { "packer", "TelescopePrompt", "mason" },
    highlight = { fg = "#957CC6", bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg },
    animate = {
        enabled = "shift", -- choose a option among bellow choices and set option for it if needed
        shift = {},
    },
    indicator_for_2wins = {
        -- only work when the total of windows is two
        position = nil, -- nil to disable or choose between "center", "start", "end" and "both"
        symbols = {
            -- the meaning of left, down ,up, right is the position of separator
            start_left = "󱞬",
            end_left = "󱞪",
            start_down = "󱞾",
            end_down = "󱟀",
            start_up = "󱞢",
            end_up = "󱞤",
            start_right = "󱞨",
            end_right = "󱞦",
        },
    },
}

function M.merge_config(user_opts)
    user_opts = user_opts or {}
    M.opts = vim.tbl_deep_extend("force", M.opts, user_opts)

    if M.opts.border == "single" then
        M.opts.border = { "─", "│", "┌", "┐", "└", "┘" }
    elseif M.opts.border == "rounded" then
        M.opts.border = { "─", "│", "╭", "╮", "╰", "╯" }
    elseif M.opts.border == "bold" then
        M.opts.border = { "━", "┃", "┏", "┓", "┗", "┛" }
    elseif M.opts.border == "double" then
        M.opts.border = { "═", "║", "╔", "╗", "╚", "╝" }
    end
end

return M
