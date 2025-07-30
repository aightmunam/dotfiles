return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
      end,
      separator = { left = '' },
      right_padding = 2,
    }

    local filename = {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
      cond = hide_in_width,
    }
    -- stylua: ignore
    local colors = {
      navy  = '#112D4E',
      blue  = '#3F72AF',
      light = '#DBE2EF',
      white = '#F9F7F7',
    }

    local bubbles_theme = {
      normal = {
        a = { fg = colors.white, bg = colors.blue },
        b = { fg = colors.navy, bg = colors.light },
        c = { fg = colors.white },
      },

      insert = {
        a = { fg = colors.white, bg = colors.blue },
      },

      visual = {
        a = { fg = colors.white, bg = colors.light },
      },

      replace = {
        a = { fg = colors.white, bg = colors.navy },
      },

      inactive = {
        a = { fg = colors.light, bg = colors.navy },
        b = { fg = colors.light, bg = colors.navy },
        c = { fg = colors.light },
      },
    }
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = bubbles_theme, -- Set theme based on environment variable
        -- Some useful glyphs:
        -- https://www.nerdfonts.com/cheat-sheet
        --        
        component_separators = '',
        section_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
