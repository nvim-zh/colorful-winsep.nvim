# colorful-winsep.nvim

https://user-images.githubusercontent.com/57088952/199041710-7f234dc8-2ab0-4cb1-81dc-ae65d2dc16e9.mp4
> configurable window separtor

## Motivation

Currently in Neovim, we can not make the active window distinguishable via the window separator.
This plugin will color the border of active window, like what tmux does for its different panes.

## Requirements

+ Neovim 0.8.0+
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

## Default configuration

```lua
require("colorful-winsep").setup({
  -- highlight for Window separator
  highlight = {
    guibg = "#16161E",
    guifg = "#1F3442",
  },
  -- timer refresh rate
  interval = 30,
  -- This plugin will not be activated for filetype in the following table.
  no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest", "NvimTree" },
  -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
  symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
  close_event = function()
    -- Executed after closing the window separator
  end,
  create_event = function()
    -- Executed after creating the window separator
  end,
})
```

### API function

- `NvimSeparatorDel`: close active window separtors.
- `NvimSeparatorShow`: show active window separtors (cannot be used on already activated windows)

## FAQ

###  How to disable this plugin for nvim-tree [#8](https://github.com/nvim-zh/colorful-winsep.nvim/issues/8)

```lua
create_event = function()
  if fn.winnr('$') == 3 then
    local win_id = fn.win_getid(vim.fn.winnr('h'))
    local filetype = api.nvim_buf_get_option(api.nvim_win_get_buf(win_id), 'filetype')
    if filetype == "NvimTree" then
      colorful_winsep.NvimSeparatorDel()
    end
  end
end
```

# TODO list

- [x] Refactor more delicate logic for creating floating windows
- [x] ~~will provide enable and disable api~~ `create_event` and `close_event`

## License

This plugin is released under the MIT License.
