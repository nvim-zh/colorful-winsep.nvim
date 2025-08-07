# colorful-winsep.nvim


https://github.com/SomesOver/accidentslipt/assets/160035610/2c8ad939-bb42-4a45-997b-a164e2c43108
> configurable window separtor

## Motivation

Currently in Neovim, we can not make the active window distinguishable via the window separator.
This plugin will color the border of active window, like what tmux does for its different panes.

## Requirements

+ Neovim 0.11.3+
+ [Nerd Fonts](https://www.nerdfonts.com/)

## Install
### Using a plugin manager

Using vim-plug:

```lua
Plug 'nvim-zh/colorful-winsep.nvim'
```

Using Packer.nvim:

```lua
use {
    "nvim-zh/colorful-winsep.nvim",
    config = function ()
        require('colorful-winsep').setup()
    end
}
```

Using lazy.nvim

```lua
{
  "nvim-zh/colorful-winsep.nvim",
  config = true,
  event = { "WinLeave" },
}
```

## Default configuration

```lua
M.opts = {
    symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
    excluded_ft = { "packer", "TelescopePrompt", "mason" },
    highlight = { fg = "#957CC6", bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg },
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
```

## TODO
- [ ] add marquee
- [ ] highlight the floating window border

## License

This plugin is released under the MIT License.
