# colorful-winsep.nvim

https://user-images.githubusercontent.com/57088952/199041710-7f234dc8-2ab0-4cb1-81dc-ae65d2dc16e9.mp4
> Can configurable dividing line

## Install
### Using a plugin manager

Using plug:

```lua
Plug 'nvim-zh/colorful-winsep.nvim'
```

Using Packer:
```lua
return require("packer").startup( function(use)
 	use "nvim-zh/colorful-winsep.nvim"
 end
)
``` 

---
## Default configuration

```lua
{
  -- Window divider color definition
  highlight = {
    guibg = "#16161E",
    guifg = "#1F3442"
  },
  -- timer refresh rate
  interval = 30,
  -- filetype in the list, will not be executed
  no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest", "NvimTree" },
  -- Split line symbol definition
  symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
  close_event = function()
    -- Executed after closing the window divider
  end,
  create_event = function()
    -- Executed after creating the window divider
  end
}
```

### `api`

`NvimSeparatorDel` close cursor win winsep
`NvimSeparatorShow` cursor win show winsep (Cannot be used on already created windows)

## Setup

```lua
require('colorful-winsep').setup({})
```

##  Hide border for nvim-tree [#8](https://github.com/nvim-zh/colorful-winsep.nvim/issues/8)
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

# Todolist
- [x] Refactor more delicate logic for creating floating windows
- [x] ~~will provide enable and disable api~~ `create_event` and `close_event`

## License
This plugin is released under the MIT License.
