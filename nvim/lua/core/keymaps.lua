-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local keymap = vim.keymap.set

-- Disable the spacebar key's default behavior in Normal and Visual modes
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- save file
keymap('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
keymap('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
keymap('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
keymap('n', 'x', '"_x', opts)

-- Vertical scroll and center
keymap('n', '<C-d>', '<C-d>zz', opts)
keymap('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
keymap('n', 'n', 'nzzzv', opts)
keymap('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
keymap('n', '<Up>', ':resize -5<CR>', opts)
keymap('n', '<Down>', ':resize +5<CR>', opts)
keymap('n', '<Left>', ':vertical resize -5<CR>', opts)
keymap('n', '<Right>', ':vertical resize +5<CR>', opts)

-- Buffers
keymap('n', '<Tab>', ':bnext<CR>', opts)
keymap('n', '<S-Tab>', ':bprevious<CR>', opts)
keymap('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
keymap('n', '<leader>=', '<C-w>v', opts) -- split window vertically
keymap('n', '<leader>-', '<C-w>s', opts) -- split window horizontally
keymap('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
keymap('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Tabs
keymap('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
keymap('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
keymap('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
keymap('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
keymap('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Keep last yanked when pasting
keymap('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
keymap('n', '<Leader>dn', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' , unpack(opts) })

keymap('n', '<Leader>dp', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to next diagnostic message', unpack(opts) })
