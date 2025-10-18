return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  opts = {
    panel = { enabled = false },
    suggestion = {
      auto_trigger = true,
      hide_during_completion = false,
      keymap = {
        accept = '<C-y>',
        accept_word = '<C-w>',
        accept_line = '<C-l>',
        next = '<C-j>',
        prev = '<C-k>',
        dismiss = '<Esc>',
      },
    },
    filetypes = {
      markdown = true,
      yaml = true,
    },
  },
}
