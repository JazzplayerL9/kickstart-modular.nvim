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
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'cs', 'fsharp', 'vb' },
        callback = function()
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = true, desc = '.NET: ' .. desc })
          end
          map('<leader>np', '<cmd>DotnetUI new_item<cr>', '[N]ew [P]roject/Item')
          map('<leader>na', '<cmd>DotnetUI project package add<cr>', '[A]dd Package')
          map('<leader>nx', '<cmd>DotnetUI project package remove<cr>', '[R]emove Package')
          map('<leader>nr', '<cmd>DotnetUI project reference add<cr>', 'Add [R]eference')
          map('<leader>nd', '<cmd>DotnetUI project reference remove<cr>', 'Remove [D]eference')
        end,
      })
    end,
  },
  {
    'stevearc/overseer.nvim',
    opts = {
      templates = { 'builtin', 'cargo', 'dotnet', 'rust', 'python', 'release', 'nasm' },
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
          elseif vim.bo.filetype == 'nasm' or vim.fn.glob '*.asm' ~= '' then
            overseer.run_task({ name = 'nasm-build', autostart = true })
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
          elseif vim.bo.filetype == 'nasm' or vim.fn.glob '*.asm' ~= '' then
            overseer.run_task({ name = 'nasm-run', autostart = true })
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
      {
        '<leader>rs',
        function()
          local clients = vim.lsp.get_clients()
          for _, client in ipairs(clients) do
            client.stop()
          end
          vim.schedule(function()
            vim.cmd 'edit'
          end)
          vim.notify('Restarting LSP clients...', vim.log.levels.INFO)
        end,
        desc = 'Task: [S]tart/Restart LSP',
      },
      { '<leader>rm', '<cmd>OverseerRun<cr>', desc = 'Task: [M]anual run' },
    },
    config = function(_, opts)
      local overseer = require 'overseer'
      overseer.setup(opts)
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      {
        '<leader>q',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
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
-- vim: ts=2 sts=2 sw=2 et
