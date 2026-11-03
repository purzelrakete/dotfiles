-- the bundled nvim-lspconfig predates vim.lsp.enable's lsp/ configs, so
-- servers are defined in full here
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
})

vim.lsp.enable('gopls')
