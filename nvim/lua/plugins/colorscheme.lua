return {
  'rebelot/kanagawa.nvim',
  name = 'kanagawa',
  priority = 1000, -- Give it high priority to load early
  config = function()
    -- Optional: Configure Kanagawa if you want specific settings
    -- e.g., to set a different background style or enable specific features
    require('kanagawa').setup {
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors) -- add/modify highlights
        return {
          BlinkCmpMenu = { bg = colors.palette.dragonBlack3 },
          BlinkCmpLabelDetail = { bg = colors.palette.dragonBlack3 },
          BlinkCmpMenuSelection = { bg = colors.palette.waveBlue1 },
        }
      end,
      theme = 'dragon', -- Load "wave" theme
    }

    require('kanagawa').load 'dragon'
  end,
}
