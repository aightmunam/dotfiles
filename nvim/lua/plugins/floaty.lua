return {
  -- floating terminal
  'ingur/floatty.nvim',
  config = function()
    local term = require('floatty').setup {
      -- Bottom-aligned Terminal
      window = {
        row = function()
          return vim.o.lines - 11
        end,
        width = 1.0,
        height = 8,
      },
    }

    -- set toggle keybinds (supports v:count by default!)
    vim.keymap.set('n', '<leader>tt', function()
      term.toggle()
    end)
    vim.keymap.set('t', '<leader>tt', function()
      term.toggle()
    end)
  end,
}
