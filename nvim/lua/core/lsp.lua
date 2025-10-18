-- INFO: read filenames on lsp/ directory and enable those
-- Copied from https://github.com/edr3x/nvim/blob/main/plugin/lsp.lua

local lsp_files = {}
local lsp_dir = vim.fn.stdpath 'config' .. '/lsp/'

for _, file in ipairs(vim.fn.globpath(lsp_dir, '*.lua', false, true)) do
  -- Read the first line of the file
  local f = io.open(file, 'r')
  local first_line = f and f:read '*l' or ''
  if f then
    f:close()
  end
  -- Only include the file if it doesn't start with "-- disable"
  if not first_line:match '^%-%- disable' then
    local name = vim.fn.fnamemodify(file, ':t:r') -- `:t` gets filename, `:r` removes extension
    table.insert(lsp_files, name)
  end
end

vim.lsp.enable(lsp_files)

-- Create keybindings, commands, inlay hints and autocommands on LSP attach
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    ---@diagnostic disable-next-line need-check-nil
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
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

vim.api.nvim_create_user_command('LspInfo', function()
  vim.cmd 'silent checkhealth vim.lsp'
end, {
  desc = 'Get all the information about all LSP attached',
})
--
