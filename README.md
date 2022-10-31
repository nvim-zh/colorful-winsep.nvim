# colorful-winsep.nvim

https://user-images.githubusercontent.com/57088952/199041710-7f234dc8-2ab0-4cb1-81dc-ae65d2dc16e9.mp4
> Can configurable dividing line

## install
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
<details>
<summary>default configuration</summary>

```lua
{
  direction = {
    down = "j",
    left = "h",
    right = "l",
    up = "k"
  },
  highlight = {
    guibg = "bg",
    guifg = "#957CC6"
  },
  interval = 100,
  no_exec_files = { "packer", "TelescopePrompt", "mason", "CompetiTest" },
  symbols = { "━", "┃", "┏", "┓", "┗", "┛" },
  win_opts = {
    relative = "editor",
    style = "minimal"
  }
})
```
</details>


## Setup

```lua
require('colorful-winsep').setup({})
```

## License
This plugin is released under the MIT License.
