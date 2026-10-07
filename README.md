<div align="center">

# must.nvim

**RFC inside Neovim, because why not?**

[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat&logo=lua&logoColor=white)](https://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-0.12+-57A143?style=flat&logo=neovim&logoColor=white)](https://neovim.io)

</div>

![intro demo image](./.demo/must_intro.png)
![demo image](./.demo/must.png)

## Usage

Run `:Must <number>` to open a new instance, which is opened in a shared tab for the session. Once inside, `:Must toc` or `\` will toggle open the Table of Contents (if the RFC has one). `gd` within the main content body jumps to sections within the body, other RFCs, and other sections in other RFCs based on the cursor's position.

Caches RFCs locally at `stdpath("cache")/must/` with no expiry (they're pretty small `.txt` files). Clean the directory out manually if you ever want to get (a very little amount of) disk space back, I might add cache expiry later on.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "undont/must.nvim",
}
```

### vim.pack

```lua
vim.pack.add({ "https://github.com/undont/must.nvim" })
```

### [mini.deps](https://github.com/nvim-mini/mini.nvim/blob/main/readmes/mini-deps.md)

```lua
MiniDeps.add({
  source = "undont/must.nvim",
})
```

## Configuration

Calling `setup` is entirely optional, defaults listed here. Feel free to override any of the "keymap" ones with `false` if you want them disabled.

```lua
require("must").setup({
    -- keymaps
    jump_to = "gd",
    toggle_toc = "\\", -- literal backslash
    open_toc_entry = "<CR>",
    toc = {
        split = "right", -- left/right
        width = 55,      -- integer
    },
})
```
