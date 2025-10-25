" plugin/helloworld.vim
if exists('g:loaded_helloworld')
  finish
endif
let g:loaded_helloworld = 1

command! HelloWorld echo "🌍 Hello from my first Neovim plugin!"

