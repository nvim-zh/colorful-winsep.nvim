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
  highlight = {
    guibg = "#16161E",
    guifg = "#1F3442"
  },
  interval = 30,
  no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest", "NvimTree" },
  symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
  close_event = function()
  end,
  create_event = function()
  end
}
```


## Setup

```lua
require('colorful-winsep').setup({})
```

# Todolist
- [x] Refactor more delicate logic for creating floating windows
- [x] ~~will provide enable and disable api~~ `create_event` and `close_event`

## License
This plugin is released under the MIT License.
