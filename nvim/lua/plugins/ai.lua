return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    strategies = {
      chat = {
        adapter = 'gemini',
      },
      inline = {
        adapter = 'gemini',
      },
      cmd = {
        adapter = 'gemini'
      }
    },
    gemini = function()
      return require('codecompanion.adapters').extend('gemini', {
        schema = {
          model = {
            default = 'gemini-2.5-flash-preview-05-20',
          },
        },
        env = {
          api_key = 'GEMINI_API_KEY',
        },
      })
    end,
    display = {
      diff = {
        provider = 'mini_diff',
      },
    },
  },
}
