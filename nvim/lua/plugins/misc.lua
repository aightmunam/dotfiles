-- Standalone plugins with less than 10 lines of config go here
return {
  {
    -- Tmux & split window navigation
    'christoomey/vim-tmux-navigator',
  },
  {
    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
  },
  {
    -- Powerful Git integration for Vim
    'tpope/vim-fugitive',
  },
  {
    -- GitHub integration for vim-fugitive
    'tpope/vim-rhubarb',
  },
  {
    -- Hints key binds
    'folke/which-key.nvim',
  },
  {
    -- Auto-close parentheses, brackets, quotes, etc.
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    opts = {},
  },
  {
    -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    -- High-performance color highlighter
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },
  {
    -- Shows function name up top when scrolling
    'nvim-treesitter/nvim-treesitter-context',
  },
  {
    -- figure out tab/space number automatically
    'tpope/vim-sleuth',
  },
  {
    -- Start up screen
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        theme = 'hyper',
        config = {
          week_header = {
            enable = true,
          },
          shortcut = {},
          project = {
            enable = true,
            limit = 8,
            icon = '󰏓 ',
            label = '',
            action = function(path)
              require('snacks').picker.projects { cwd = path }
            end,
          },
        },
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
  {
    'sontungexpt/url-open',
    branch = 'mini',
    cmd = 'URLOpenUnderCursor',
    opts = {},
    keys = {
      {
        '<leader>o',
        '<cmd>URLOpenUnderCursor<cr>',
        desc = 'Open url under cursor',
        mode = 'n',
      },
    },
  },
  {
    -- manually select python interpreter without restarting LSP
    'neolooong/whichpy.nvim',
  },
  {
    'chrisgrieser/nvim-early-retirement',
    config = true,
    event = 'VeryLazy',
  },
  {
    'declancm/cinnamon.nvim',
    version = '*',
    opts = {},
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>mp', function()
        require('render-markdown').toggle()
      end)
    end,
  },
  {
    'alexghergh/nvim-tmux-navigation',
    config = function()
      require('nvim-tmux-navigation').setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = '<C-h>',
          down = '<C-j>',
          up = '<C-k>',
          right = '<C-l>',
          last_active = '<C-a>',
          next = '<C-Space>',
        },
      }
    end,
  },
  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
  },
}
