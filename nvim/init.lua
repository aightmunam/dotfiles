require 'core.options'
require 'core.keymaps'
require 'core.lsp'
require 'core.diagnostics'
require 'core.autocmd'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Local hairline colorscheme (colors/hairline.lua), matching wezterm and herdr.
-- Loaded before lazy so bufferline and lualine see its highlight groups.
vim.cmd.colorscheme 'hairline'

require('lazy').setup {
  require 'plugins.bufferline',
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.snacks',
  require 'plugins.mason',
  require 'plugins.conform',
  require 'plugins.gitsigns',
  require 'plugins.misc',
  require 'plugins.mini',
  require 'plugins.auto_session',
  require 'plugins.blink',
  require 'plugins.harpoon',
  -- require 'plugins.copilot',
}
