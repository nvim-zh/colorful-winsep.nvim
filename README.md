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

## Configuration

The following is the default configuration (read the comments carefully if you want to change it):
```lua
require("colorful-winsep").setup({
    -- choose between "signle", "rounded", "bold" and "double".
    -- Or pass a tbale like this: { "─", "│", "┌", "┐", "└", "┘" },
    border = "bold",
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
})
```

### indicator_for_2wins
When using the plugin with two windows only, it becomes difficult to discern which window is currently active. With this feature we can identify the active window more easily. To enable it, set the `indicator_for_2wins.position` to a available option (`center` is recommended). Here come the showcases:

<img width="1082" height="765" alt="Image" src="https://github.com/user-attachments/assets/f4779ad8-259a-4367-b922-3db154c6ad8e" />

<img width="1082" height="765" alt="Image" src="https://github.com/user-attachments/assets/f1614390-cf6f-4c9a-9a2e-6c9fd2231a80" />


## Commands
The user command of the plugin is `Winsep`, and here comes the subcommands of it:
| subcommand | function           |
| ---------- | :-------------:    |
| enable     | enable the plugin  |
| disable    | disable the plugin |
| toggle     | toggle the plugin  |

## Highlights
The highlight's name is `ColorfulWinSep`. You can change it using nvim's builtin function or changing the plugin's configuration

## TODO
- [ ] smooth animation
- [ ] add marquee

## License

This plugin is released under the [MIT](./LICENSE) License.
