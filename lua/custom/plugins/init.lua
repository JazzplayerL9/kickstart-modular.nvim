-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'Hoffs/omnisharp-extended-lsp.nvim',
  },
  {
    'MoaidHathot/dotnet.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {},
    config = function(_, opts)
      require('dotnet').setup(opts)
      vim.keymap.set('n', '<leader>np', '<cmd>DotnetUI new_item<cr>', { desc = '.NET: [N]ew [P]roject/Item' })
      vim.keymap.set('n', '<leader>na', '<cmd>DotnetUI project package add<cr>', { desc = '.NET: [A]dd Package' })
      vim.keymap.set('n', '<leader>nx', '<cmd>DotnetUI project package remove<cr>', { desc = '.NET: [R]emove Package' })
      vim.keymap.set('n', '<leader>nr', '<cmd>DotnetUI project reference add<cr>', { desc = '.NET: Add [R]eference' })
      vim.keymap.set('n', '<leader>nd', '<cmd>DotnetUI project reference remove<cr>', { desc = '.NET: Remove [D]eference' })
    end,
  },
  {
    'stevearc/overseer.nvim',
    opts = {
      templates = { 'builtin', 'cargo', 'dotnet', 'rust', 'python', 'release' },
      component_aliases = {
        ['default'] = {
          { 'on_output_parse', problem_matcher = { '$rustc', '$mscompile' } },
          { 'on_exit_set_status' },
          { 'on_complete_notify' },
          { 'on_output_quickfix', open_on_exit = 'failure' },
        },
      },
    },
    keys = {
      {
        '<leader>rb',
        function()
          local overseer = require 'overseer'
          if vim.fn.glob '*.sln' ~= '' or vim.fn.glob '*.csproj' ~= '' then
            overseer.run_task({ name = 'dotnet-build', autostart = true })
          elseif vim.fn.glob 'Cargo.toml' ~= '' then
            overseer.run_task({ name = 'cargo-build', autostart = true })
          elseif vim.fn.glob 'requirements.txt' ~= '' then
            overseer.run_task({ name = 'python-install-requirements', autostart = true })
          else
            overseer.run_task()
          end
        end,
        desc = 'Task: [B]uild',
      },
      {
        '<leader>rl',
        function()
          local overseer = require 'overseer'
          if vim.fn.glob '*.sln' ~= '' or vim.fn.glob '*.csproj' ~= '' then
            overseer.run_task({ name = 'dotnet-release', autostart = true })
          elseif vim.fn.glob 'Cargo.toml' ~= '' then
            overseer.run_task({ name = 'cargo-release', autostart = true })
          else
            overseer.run_task()
          end
        end,
        desc = 'Task: Re[l]ease Build',
      },
      {
        '<leader>rr',
        function()
          local overseer = require 'overseer'
          if vim.fn.glob '*.sln' ~= '' or vim.fn.glob '*.csproj' ~= '' then
            overseer.run_task({ name = 'dotnet-run', autostart = true })
          elseif vim.fn.glob 'Cargo.toml' ~= '' then
            overseer.run_task({ name = 'cargo-run', autostart = true })
          elseif vim.bo.filetype == 'python' then
            overseer.run_task({ name = 'python-run', autostart = true })
          else
            overseer.run_task()
          end
        end,
        desc = 'Task: [R]un',
      },
      {
        '<leader>rt',
        function()
          local overseer = require 'overseer'
          if vim.fn.glob '*.sln' ~= '' or vim.fn.glob '*.csproj' ~= '' then
            overseer.run_task({ name = 'dotnet-test', autostart = true })
          elseif vim.fn.glob 'Cargo.toml' ~= '' then
            overseer.run_task({ name = 'cargo-test', autostart = true })
          elseif vim.bo.filetype == 'python' or vim.fn.glob 'pytest.ini' ~= '' or vim.fn.glob 'tests/' ~= '' then
            overseer.run_task({ name = 'python-test', autostart = true })
          else
            overseer.run_task()
          end
        end,
        desc = 'Task: [T]est',
      },
      { '<leader>ro', '<cmd>OverseerToggle<cr>', desc = 'Task: [O]pen list' },
      { '<leader>ra', '<cmd>OverseerTaskAction<cr>', desc = 'Task: [A]ction' },
      { '<leader>rs', '<cmd>LspRestart<cr>', desc = 'Task: [S]tart/Restart LSP' },
      { '<leader>rm', '<cmd>OverseerRun<cr>', desc = 'Task: [M]anual run' },
    },
    config = function(_, opts)
      local overseer = require 'overseer'
      overseer.setup(opts)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
      max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
  },
}
