---@type vim.lsp.Config
return {
  filetypes = { 'python' },
  cmd = { 'ruff', 'server', '--preview' }, -- use `--preview` to enable LSP mode
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
  options = {
    settings = {
      args = {}, -- e.g., { '--config', 'pyproject.toml' }
    },
  },
}
