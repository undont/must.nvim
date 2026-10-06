<div align="center">

# must.nvim

**RFC inside Neovim, because why not?**

[![Lua](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat&logo=lua&logoColor=white)](https://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-0.11+-57A143?style=flat&logo=neovim&logoColor=white)](https://neovim.io)

</div>

![intro demo image](./.demo/must_intro.png)
![demo image](./.demo/must.png)

## Usage

Run `:Must <number>` to open a new instance, which is created in its own tab. Once inside, `:Must toc` or `\` will toggle open the Table of Contents (if the RFC has one). `gd` within the main content body jumps to sections within the body, other RFCs, and other sections in other RFCs based on the cursor's position.

That's basically it, it's quite simple, and I don't have any grandiose plans to make it overly complex. Caching will be added later down the line.
