-- lua/pico-8-nvim
local M = {}

function M.say_hello()
  vim.notify("👋 Hello from my first Neovim plugin written in Lua!", vim.log.levels.INFO)
end

return M

