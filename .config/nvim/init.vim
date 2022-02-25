set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
luafile ~/.config/nvim/lua/lsp.lua
luafile ~/.config/nvim/lua/cmp.lua
