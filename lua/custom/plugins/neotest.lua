return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rouge8/neotest-rust',
      'Issafalcon/neotest-dotnet',
    },
    keys = {
      {
        '<leader>tr',
        function()
          require('neotest').run.run()
        end,
        desc = '[T]est [R]un nearest',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = '[T]est [F]ile',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = '[T]est [S]ummary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = '[T]est [O]utput',
      },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-rust',
          require 'neotest-dotnet',
        },
      }
    end,
  },
}
