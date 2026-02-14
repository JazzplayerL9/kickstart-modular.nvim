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
          vim.cmd 'LspRestart'
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
