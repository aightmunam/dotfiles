return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local status_ok, harpoon = pcall(require, 'harpoon')
    if not status_ok then
      return
    end
    harpoon:setup()

    local function generate_harpoon_picker()
      local file_paths = {}
      for _, item in ipairs(harpoon:list().items) do
        table.insert(file_paths, {
          text = item.value,
          file = item.value,
        })
      end
      return file_paths
    end

    local normalize_list = function(t)
      local normalized = {}
      for _, v in pairs(t) do
        if v ~= nil then
          table.insert(normalized, v)
        end
      end
      return normalized
    end

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end)

    vim.keymap.set('n', '<leader>sm', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end)

    vim.keymap.set('n', '<leader>hh', function()
      Snacks.picker {
        finder = generate_harpoon_picker,
        win = {
          input = {
            keys = { ['dd'] = { 'harpoon_delete', mode = { 'n', 'x' } } },
          },
          list = {
            keys = { ['dd'] = { 'harpoon_delete', mode = { 'n', 'x' } } },
          },
        },
        actions = {
          harpoon_delete = function(picker, item)
            local to_remove = item or picker:selected()
            harpoon:list():remove { value = to_remove.text }
            harpoon:list().items = normalize_list(harpoon:list().items)
            picker:find { refresh = true }
          end,
        },
      }
    end)
  end,
}
