# colorful-winsep.nvim

https://github.com/user-attachments/assets/6ea56aa3-b5fc-485b-bd62-2cfd162a7f78
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
    -- choose between "single", "rounded", "bold" and "double".
    -- Or pass a table like this: { "─", "│", "┌", "┐", "└", "┘" },
    border = "bold",
    excluded_ft = { "packer", "TelescopePrompt", "mason" },
    highlight = "#957CC6", -- string or function. See the docs's Highlights section
    animate = {
        enabled = "shift", -- false to disable, or choose a option below (e.g. "shift") and set option for it if needed
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
})
```

### animate
By default, we use the `shift` animation. If you want to disable it, set the `animate.enabled` to false.

#### shift
Have a look at the top of this README

#### progressive

https://github.com/user-attachments/assets/4cc29832-ed46-44ec-80db-0f1da350deeb

### indicator_for_2wins
When using the plugin with two windows only, it becomes difficult to discern which window is currently active. With this feature we can identify the active window more easily. To disable it, set the `indicator_for_2wins.position` to false. Here come the showcases of default `center` option:

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

If you want to change it through plugin's setup function, you can pass a string or function to the `highlight` field. When you pass a string, it will work as the fg, and the bg will be linked to "Normal" highlight group automatically (see `:h hl-Normal`). When you pass a function, the function will be called when the plugin runs and every time the colorscheme is changed.

If you don't want the plugin do anything about the highlight in certain situations, such as your colorscheme creates the highlights on its own (like catppuccin), you can pass `nil` to the highlight setting. (this is the default)

## TODO
- [ ] add marquee

## License

This plugin is released under the [MIT](./LICENSE) License.
