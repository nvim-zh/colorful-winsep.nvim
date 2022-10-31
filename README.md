# colorful-winsep.nvim

https://user-images.githubusercontent.com/57088952/198973680-77c6d8f7-73fa-40a8-9c98-1f1d56defeb7.mp4

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
  no_exec_files = { "packer" },
  symbols = { "━", "┃", "┣", "┫", "╋", "┻", "┳" },
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

## Thank you
- Thank [jdhao](https://github.com/jdhao)  technical support and encouragement

## License
This plugin is released under the MIT License.
