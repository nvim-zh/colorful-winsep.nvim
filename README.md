# colorful-winsep.nvim

> configurable window separator

https://github.com/user-attachments/assets/6ea56aa3-b5fc-485b-bd62-2cfd162a7f78

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
    border = "bold",
    excluded_ft = { "packer", "TelescopePrompt", "mason" },
    highlight = nil, -- nil|string|function. See the docs's Highlights section
    animate = {
        ---@type "shift"|"progressive"|false
        enabled = "shift", -- false to disable or choose a option below (e.g. "shift") and set option for it if needed
        shift = {
            delay = 16, -- about 60fps
            frames = 15, -- how many frames are required to complete the animation
            easing = "ease_out_cubic", -- available algorithms: linear, ease_out_cubic, ease_in_out_sine, ease_out_quad, ease_out_expo
        },
        progressive = {
            delay = 16,
            vertical_lerp_factor = 0.15, -- between 0 and 1
            horizontal_lerp_factor = 0.15, -- between 0 and 1
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
    colors = {}, -- Add a custom color array. Single color applies statically, multiple colors will create a marquee effect.
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
| subcommand | lua call                             | function           |
| ---------- | -------------                        | :-------------:    |
| enable     | require("colorful-winsep").enable()  | enable the plugin  |
| disable    | require("colorful-winsep").disable() | disable the plugin |
| toggle     | require("colorful-winsep").toggle()  | toggle the plugin  |

## Highlights
The highlight's name is `ColorfulWinSep`. You can change it using nvim's builtin function or changing the plugin's configuration

If you want to change it through plugin's setup function, you can pass a string or function to the `highlight` field. When you pass a string, it will work as the fg, and the bg will be set up the same as "Normal" highlight group's bg automatically (see `:h hl-Normal`). When you pass a function, the function will be called when the plugin runs and every time the color scheme is changed.

By default, the configuration's `highlight` field is `nil`. This means the plugin will do nothing if you set the highlight group before it loads. Otherwise, the highlight is set to `#957CC6`. This is useful if you use your color scheme plugin (like catppuccin) to control highlights.

## Multi-color Marquee Effect (Local Addition)
You can create a marquee/neon light effect or override the default highlight simply by passing an array of hex colors to the `colors` option in your `setup()`, or dynamically by calling `set_colors()`. 

```lua
-- Static custom color
require("colorful-winsep").setup({
    colors = { "#a6d189" }
})

-- Multi-color marquee effect
require("colorful-winsep").setup({
    colors = { "#a6d189", "#e5c890", "#e78284", "#ca9ee6", "#8caaee" }
})
```

## on_frame_render (Advanced)
We represent the border as a circular linked list model (Left -> Top -> Right -> Bottom). You can intercept each node (character point) before it is rendered to apply highly custom styling or characters by providing an `on_frame_render` function.

The `node` parameter contains:
- `index`: (integer) The global 0-based index tracing the entire active border loop.
- `type`: (string) Enumeration of the border position: `"vertical_left"`, `"top_left_corner"`, `"horizontal_top"`, `"top_right_corner"`, `"vertical_right"`, `"bottom_right_corner"`, `"horizontal_bottom"`, `"bottom_left_corner"`.
- `char`: (string) The character intended to be rendered at this spot.
- `win_dir`: (string) Which window direction this node belongs to: `"left"`, `"up"`, `"right"`, `"down"`.
- `buf_idx`: (integer) Physical position of the extmark on the underlying local buffer.

Example: Changing corner characters and coloring the corners separately.
```lua
require("colorful-winsep").setup({
    colors = { "#a6d189", "#e5c890", "#ca9ee6" }, -- Base marquee colors
    
    -- Interceptor
    on_frame_render = function(node, color_idx, offset, total_colors, total_nodes)
        -- If it's one of the 4 corners, we replace its character and color
        if node.type:find("corner") then
            return "X", "ColorfulWinSep_1"
        end
        
        -- Keep original character and color
        return node.char, "ColorfulWinSep_" .. color_idx
    end,
})
```

## License

This plugin is released under the [MIT](./LICENSE) License.
