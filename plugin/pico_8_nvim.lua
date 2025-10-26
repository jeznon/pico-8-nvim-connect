if vim.g.loaded_pico8_connect then return end
vim.g.loaded_pico8_connect = true

vim.api.nvim_create_user_command('Pico8Hello', function()
  require('pico_8_nvim').hello()
end, {})


