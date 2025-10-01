return {
  { 'nvim-mini/mini.bracketed', version = false },
  {
    'nvim-mini/mini.files',
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 60,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        '<leader>ff',
        function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
          local mini = require 'mini.files'
          mini.open(path)
          mini.reveal_cwd()
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '\\',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },
  { 'nvim-mini/mini.ai', version = false },
  { 'nvim-mini/mini.surround', version = false },
}
