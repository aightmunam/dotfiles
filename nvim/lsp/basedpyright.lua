local function get_python_env(executable_name)
  -- Return the path to the executable if $VIRTUAL_ENV is set and the binary exists somewhere beneath the $VIRTUAL_ENV path
  if vim.env.VIRTUAL_ENV then
    local paths = vim.fn.glob(vim.env.VIRTUAL_ENV .. '/**/bin/' .. executable_name, true, true)
    local executable_path = table.concat(paths, ', ')
    if executable_path ~= '' then
      vim.api.nvim_echo({ { 'Using path for ' .. executable_name .. ': ' .. executable_path, 'None' } }, false, {})
      return executable_path
    end
  end

  -- find poetry.lock file in current directory or parent directories
  local poetry_lock = vim.fn.findfile('poetry.lock', '.;')
  if poetry_lock ~= '' then
    -- use `poetry env info -p -C <path of folder containing poetry.lock>` to get the virtualenv path
    local poetry_env_path = vim.fn.systemlist('poetry env info --path -C ' .. vim.fn.fnamemodify(poetry_lock, ':h'))

    if #poetry_env_path > 0 then
      local candidate_paths = {}
      for _, env_path in ipairs(poetry_env_path) do
        if env_path ~= '' then
          if string.sub(env_path, 0, 1) == '/' then
            table.insert(candidate_paths, 0, env_path)
          end
        end
      end
      local selected_poetry_env_path = candidate_paths[0]

      -- TODO: Evaluate if this might ever be needed
      -- if #poetry_env_path > 1 then
      --   for _, env_path in ipairs(candidate_paths) do
      --     if string.find(selected_poetry_env_path, 'Activated') then
      --       selected_poetry_env_path = string.gsub(selected_poetry_env_path, ' %(Activated%)', '')
      --       selected_poetry_env_path = vim.fn.trim(selected_poetry_env_path)
      --       break
      --     end
      --   end
      -- end
      local venv_path_to_python = selected_poetry_env_path .. '/bin/' .. executable_name
      if vim.fn.filereadable(venv_path_to_python) == 1 then
        return venv_path_to_python
      end
    end
  end
end

local active_python_path = get_python_env 'python'

return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    'pyrightconfig.json',
    '.git',
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = function() end,
  },
  settings = {
    python = {
      pythonPath = active_python_path,
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

  on_attach = function(client, bufnr)
    local function update_python_path()
      local new_path = get_python_env 'python'

      -- Send a workspace/didChangeConfiguration notification
      client.notify('workspace/didChangeConfiguration', {
        settings = {
          python = {
            pythonPath = new_path,
          },
        },
      })

      vim.api.nvim_echo({ { 'LSP pythonPath updated to: ' .. (new_path or 'global'), 'None' } }, false, {})
    end

    vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', update_python_path, {
      desc = 'Re-scan for Python venv and update basedpyright',
      nargs = 0,
    })
  end,
}
