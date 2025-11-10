local function get_python_env(executable_name)
  if vim.env.VIRTUAL_ENV then
    local executable_path = vim.env.VIRTUAL_ENV .. '/bin/' .. executable_name
    -- Use filereadable to ensure the python executable actually exists
    if vim.fn.filereadable(executable_path) == 1 then
      vim.api.nvim_echo({ { 'Using $VIRTUAL_ENV path: ' .. executable_path, 'None' } }, false, {})
      return executable_path
    end
  end

  local poetry_lock = vim.fn.findfile('poetry.lock', '.;')
  if poetry_lock ~= '' then
    -- Use `poetry env info --path` to get the virtualenv path
    -- -C changes the directory for the command
    local poetry_env_path_list = vim.fn.systemlist('poetry env info --path -C ' .. vim.fn.fnamemodify(poetry_lock, ':h'))

    if #poetry_env_path_list > 0 then
      local selected_poetry_env_path = poetry_env_path_list[1]
      selected_poetry_env_path = vim.fn.trim((string.gsub(selected_poetry_env_path, '%s*%(Activated%)$', '')))
      if selected_poetry_env_path ~= '' then
        local venv_path_to_python = selected_poetry_env_path .. '/bin/' .. executable_name
        if vim.fn.filereadable(venv_path_to_python) == 1 then
          vim.api.nvim_echo({ { 'Using Poetry venv path: ' .. venv_path_to_python, 'None' } }, false, {})
          return venv_path_to_python
        end
      end
    end
  end

  vim.api.nvim_echo({ { 'No venv found. Using global ' .. executable_name, 'WarnMsg' } }, false, {})
  return nil
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
