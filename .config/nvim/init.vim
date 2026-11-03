set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

lua require('lsp')

" symbols
nnoremap <leader>o <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <leader>O <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
