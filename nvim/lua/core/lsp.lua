-- Create keybindings, commands, inlay hints and autocommands on LSP attach {{{
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    ---@diagnostic disable-next-line need-check-nil
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      -- vim.bo[bufnr].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    end
    ---@diagnostic disable-next-line need-check-nil
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

    --- Disable semantic tokens
    ---@diagnostic disable-next-line need-check-nil
    client.server_capabilities.semanticTokensProvider = nil

    -- All the keymaps
    -- stylua: ignore start
    local keymap = vim.keymap.set
    local lsp = vim.lsp
    local opts = { silent = true }
    local function opt(desc, others)
      return vim.tbl_extend('force', opts, { desc = desc }, others or {})
    end
    keymap('n', 'K', function() lsp.buf.hover({ border = 'single', max_height = 30, max_width = 120 }) end, opt('Toggle hover'))
    keymap('n', '<Leader>lF', vim.cmd.FormatToggle, opt('Toggle AutoFormat'))
    keymap('n', '<Leader>la', lsp.buf.code_action, opt('Code Action'))
    keymap('n', '<Leader>li', vim.cmd.LspInfo, opt('LspInfo'))
    keymap('n', '<Leader>ll', lsp.codelens.run, opt('Run CodeLens'))
    keymap('n', '<Leader>lr', lsp.buf.rename, opt('Rename'))
  end,
})
-- }}}

-- Language Servers

-- Go
vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gotempl', 'gowork', 'gomod' },
  root_markers = { '.git', 'go.mod', 'go.work', vim.uv.cwd() },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      ['ui.inlayhint.hints'] = {
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
vim.lsp.enable 'gopls'
--

-- Lua
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git', vim.uv.cwd() },
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = {
        globals = { 'vim' },
        disable = { 'missing-fields' },
      },
    },
  },
}
vim.lsp.enable 'lua_ls'
--

-- Ruff
vim.lsp.config.ruff_lsp = {
  filetypes = { 'python' },
  cmd = { 'ruff', 'server', '--preview' }, -- use `--preview` to enable LSP mode
  on_attach = function(client, _)
    client.server_capabilities.hoverProvider = false
  end,
  options = {
    settings = {
      args = {}, -- e.g., { '--config', 'pyproject.toml' }
    },
  },
}
vim.lsp.enable 'ruff_lsp'

local capabilities = vim.lsp.protocol.make_client_capabilities()
vim.lsp.config.basedpyright = {
  name = 'basedpyright',
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  capabilities = (function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
    return capabilities
  end)(),
  handlers = {
    ['textDocument/publishDiagnostics'] = function() end,
  },
  on_attach = function(client, _)
    client.server_capabilities.codeActionProvider = false
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        typeCheckingMode = 'basic',
        useLibraryCodeForTypes = true,
      },
    },
    basedpyright = {
      disableOrganizeImports = true,
    },
  },
}
vim.lsp.enable 'basedpyright'

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  desc = 'Start python lsp server(s)',
  callback = function()
    local root = vim.fs.root(0, {
      'pyproject.toml',
      'ruff.toml',
      '.git',
      'requirements.txt',
      'setup.cfg',
    })

    vim.lsp.start(
      vim.tbl_extend('force', vim.lsp.config.basedpyright, {
        root_dir = root,
      }),
      { attach = false }
    )

    vim.lsp.start(
      vim.tbl_extend('force', vim.lsp.config.ruff_lsp, {
        root_dir = root,
      }),
      { attach = false }
    )
  end,
})

-- Bash
vim.lsp.config.bashls = {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh', 'zsh' },
  root_markers = { '.git', vim.uv.cwd() },
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    },
  },
}
vim.lsp.enable 'bashls'
--

-- Start, Stop, Restart, Log commands
vim.api.nvim_create_user_command('LspStart', function()
  vim.cmd.e()
end, { desc = 'Starts LSP clients in the current buffer' })

vim.api.nvim_create_user_command('LspStop', function(opts)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if opts.args == '' or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ': stopped')
    end
  end
end, {
  desc = 'Stop all LSP clients or a specific client attached to the current buffer.',
  nargs = '?',
  complete = function(_, _, _)
    local clients = vim.lsp.get_clients { bufnr = 0 }
    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    return client_names
  end,
})

vim.api.nvim_create_user_command('LspRestart', function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify 'Servers are stopped but havent been restarted'
  end
  timer:start(
    100,
    50,
    vim.schedule_wrap(function()
      for name, client in pairs(detach_clients) do
        local client_id = vim.lsp.start(client[1].config, { attach = false })
        if client_id then
          for _, buf in ipairs(client[2]) do
            vim.lsp.buf_attach_client(buf, client_id)
          end
          vim.notify(name .. ': restarted')
        end
        detach_clients[name] = nil
      end
      if next(detach_clients) == nil and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end, {
  desc = 'Restart all the language client(s) attached to the current buffer',
})

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = 'Get all the lsp logs',
})

vim.api.nvim_create_user_command('LspInfo', function()
  vim.cmd 'silent checkhealth vim.lsp'
end, {
  desc = 'Get all the information about all LSP attached',
})
--
