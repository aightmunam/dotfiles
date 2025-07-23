return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    harpoon:setup {}

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    --- Keybinds
    local keymap = vim.keymap.set
        --stylua: ignore start
        keymap("n", "<leader>hh", function() harpoon:list():add()                        end, { noremap = true, silent = true, desc = "Add file" })
        keymap("n", "<leader>h1", function() harpoon:list():select(1)                    end, { noremap = true, silent = true, desc = "Goto 1" })
        keymap("n", "<leader>h2", function() harpoon:list():select(2)                    end, { noremap = true, silent = true, desc = "Goto 2" })
        keymap("n", "<leader>h3", function() harpoon:list():select(3)                    end, { noremap = true, silent = true, desc = "Goto 3" })
        keymap("n", "<leader>h4", function() harpoon:list():select(4)                    end, { noremap = true, silent = true, desc = "Goto 4" })
        keymap("n", "<leader>hn", function() harpoon:list():next()                       end, { noremap = true, silent = true, desc = "Goto next" })
        keymap("n", "<leader>hp", function() harpoon:list():prev()                       end, { noremap = true, silent = true, desc = "Goto prev" })
        keymap("n", "<leader>hq", function() toggle_telescope(harpoon:list()) end)
        keymap("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    --stylua: ignore end
  end,
}
