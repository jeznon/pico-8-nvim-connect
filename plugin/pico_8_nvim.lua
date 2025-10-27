-- plugin/pico8_connect.lua
if vim.g.loaded_pico8_connect then
  return
end
vim.g.loaded_pico8_connect = true

vim.api.nvim_create_user_command("Pico8Pick", function()
  require("pico8_connect").pick_cartridge()
end, {})

vim.api.nvim_create_user_command("Pico8Inject", function()
  require("pico8_connect").inject_cartridge_code()
end, {})

vim.api.nvim_create_user_command("Pico8SetCartsDir", function()
  require("pico8_connect").set_carts_dir()
end, {})

