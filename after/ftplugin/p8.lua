vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "getline(v:lnum)=~'-->8'?'<1':'='"
vim.opt_local.foldlevelstart = 99

