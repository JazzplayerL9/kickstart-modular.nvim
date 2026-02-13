-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'stevearc/overseer.nvim',
    opts = {
      templates = { 'builtin', 'cargo' },
      component_aliases = {
        -- Most tasks use the "default" alias. We'll add the quickfix component to it
        -- so it opens automatically on failure.
        ['default'] = {
          { 'display_duration' },
          { 'on_output_parse', problem_matcher = '$rustc' },
          { 'on_exit_set_status' },
          { 'on_complete_notify' },
          { 'on_output_quickfix', open_on_exit = 'failure' },
        },
      },
    },
    config = function(_, opts)
      local overseer = require 'overseer'
      overseer.setup(opts)

      vim.keymap.set('n', '<leader>mo', '<cmd>OverseerToggle<cr>', { desc = '[M]anage [O]pen' })
      vim.keymap.set('n', '<leader>mr', '<cmd>OverseerRun<cr>', { desc = '[M]anage [R]un' })
      vim.keymap.set('n', '<leader>ma', '<cmd>OverseerTaskAction<cr>', { desc = '[M]anage [A]ction' })
      vim.keymap.set('n', '<leader>ms', '<cmd>LspRestart<cr>', { desc = '[M]anage LSP [S]tart/Restart' })
    end,
  },
}
