return {
  {
    'AckslD/swenv.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('swenv').setup {
        -- Should return a list of python executables.
        -- In this case, we'll look for .venv folders in the current directory
        get_venvs = function(venvs_path)
          return require('swenv.api').get_venvs(venvs_path)
        end,
        post_set_venv = function()
          local clients = vim.lsp.get_clients()
          for _, client in ipairs(clients) do
            client.stop()
          end
          vim.schedule(function()
            vim.cmd 'edit'
          end)
        end,
      }
    end,
    keys = {
      {
        '<leader>vs',
        function()
          require('swenv.api').pick_venv()
        end,
        desc = '[V]env [S]elect',
      },
    },
  },
}
