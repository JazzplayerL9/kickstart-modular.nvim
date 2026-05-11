-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    {
      's1n7ax/nvim-window-picker',
      version = '2.*',
      config = function()
        require('window-picker').setup {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              buftype = { 'terminal', 'quickfix' },
            },
          },
          -- Custom filter function to handle the case where no windows are left
          filter_func = function(window_ids, filters)
            local default_filter = require('window-picker.filters.default-window-filter'):new()
            default_filter:set_config(filters)
            local filtered = default_filter:filter_windows(window_ids)

            if #filtered == 0 then
              -- Fallback: If everything was filtered out, just return the current window
              return { vim.api.nvim_get_current_win() }
            end

            return filtered
          end,
        }
      end,
    },
    {
      'antosha417/nvim-lsp-file-operations',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('lsp-file-operations').setup()
      end,
    },
    {
      'folke/snacks.nvim',
      priority = 1000,
      lazy = false,
      opts = {
        image = { enabled = true },
      },
    },
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- when true, they will be displayed even if they match a filter
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          -- '.DS_Store',
          -- 'thumbs.db',
        },
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<cr>'] = function(state)
            local node = state.tree:get_node()
            if node.type == 'file' then
              local winid = require('window-picker').pick_window()
              if winid then
                vim.api.nvim_set_current_win(winid)
                require('neo-tree.sources.filesystem.commands').open(state)
              end
            else
              require('neo-tree.sources.filesystem.commands').open(state)
            end
          end,
          ['s'] = 'split_with_window_picker',
          ['v'] = 'vsplit_with_window_picker',
        },
      },
    },
  },
}
