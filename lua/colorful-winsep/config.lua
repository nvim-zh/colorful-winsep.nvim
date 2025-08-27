local M = {}
M.opts = {
    -- choose between "single", "rounded", "bold" and "double".
    -- Or pass a table like this: { "─", "│", "┌", "┐", "└", "┘" },
    border = "bold",
    excluded_ft = { "packer", "TelescopePrompt", "mason" },
    highlight = nil, -- nil|string|function. See the docs's Highlights section
    animate = {
        enabled = "shift", -- false to disable or choose a option below (e.g. "shift") and set option for it if needed
        shift = {
            delta_time = 0.1,
            smooth_speed = 1,
            delay = 3,
        },
        progressive = {
            -- animation's speed for different direction
            vertical_delay = 20,
            horizontal_delay = 2,
        },
    },
    indicator_for_2wins = {
        -- only work when the total of windows is two
        position = "center", -- false to disable or choose between "center", "start", "end" and "both"
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

    if type(M.opts.highlight) == "string" then
        local fg = M.opts.highlight
        M.opts.highlight = function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            vim.api.nvim_set_hl(0, "ColorfulWinSep", { fg = fg, bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg })
        end
    elseif type(M.opts.highlight) == "table" then
        vim.notify("Colorful-winsep: highlight field don't support table now, check the docs!", vim.log.levels.ERROR)
        M.opts.highlight = function() end
    elseif type(M.opts.highlight) == "nil" then
        M.opts.highlight = function()
            if vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = "ColorfulWinSep" })) then
                vim.api.nvim_set_hl(
                    0,
                    "ColorfulWinSep",
                    { fg = "#957CC6", bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg }
                )
            end
        end
    end
end

return M
