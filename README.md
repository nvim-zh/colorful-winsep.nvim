# colorful-winsep.nvim
![head](https://user-images.githubusercontent.com/57088952/198960392-ced352c9-2e93-4726-8c74-eab5251b42f8.png) 
> Can configurable dividing line

## install
### Using a plugin manager

Using plug:

```lua
Plug 'colorful-winsep.nvim'
```

Using Packer:
```lua
return require("packer").startup( function(use)
 	use "colorful-winsep.nvim"
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
