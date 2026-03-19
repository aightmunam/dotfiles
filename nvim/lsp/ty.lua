---@type vim.lsp.Config
return {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
  settings = {
    ty = {
      diagnosticMode = 'openFilesOnly',
      showSyntaxErrors = true,
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
      },
      completions = {
        autoImport = true,
      },
    },
  },
}
