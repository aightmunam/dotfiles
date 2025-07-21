return {
  'jay-babu/mason-null-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'williamboman/mason.nvim',
    'nvimtools/none-ls.nvim',
  },
  config = function()
    require('mason-null-ls').setup {
      ensure_installed = {
        -- Opt to list sources here, when available in mason.
        'bash-language-server',
        'django-template-lsp',
        'docker-compose-language-service',
        'dockerfile-language-server',
        'gh-actions-language-server',
        'goimports',
        'gopls',
        'html-lsp',
        'json-lsp',
        'lua-language-server',
        'prettier',
        'pyproject-fmt',
        'ruff',
        'shfmt',
        'stylua',
        'terraform',
        'terraform-ls ',
      },
      automatic_installation = true,
      handlers = {},
    }
  end,
}
