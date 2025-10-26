-- plugin/pico-8-nvim
if vim.g.loaded_pico8_connect_nvim then
  return
end
vim.g.loaded_pico8_connect_nvim = true

vim.api.nvim_create_user_command("HelloWorld", function()
  require("helloworld").say_hello()
end, {})


