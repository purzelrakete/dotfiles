require'lspconfig'.pylsp.setup{}

local on_attach = function(client, bufnr)
  -- Enable omnifunc
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end
