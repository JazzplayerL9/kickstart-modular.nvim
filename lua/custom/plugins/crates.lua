return {
  {
    'saecki/crates.nvim',
    tag = 'stable',
    config = function()
      require('crates').setup()

      local crates = require 'crates'

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'toml',
        callback = function()
          if vim.fn.expand('%:t') == 'Cargo.toml' then
            local function map(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = true, silent = true, desc = 'Crates: ' .. desc })
            end

            map('n', '<leader>ct', crates.toggle, '[T]oggle')
            map('n', '<leader>cr', crates.reload, '[R]eload')

            map('n', '<leader>cv', crates.show_versions_popup, 'Show [V]ersions')
            map('n', '<leader>cf', crates.show_features_popup, 'Show [F]eatures')
            map('n', '<leader>cd', crates.show_dependencies_popup, 'Show [D]ependencies')

            map('n', '<leader>cu', crates.update_crate, '[U]pdate Crate')
            map('v', '<leader>cu', crates.update_crates, '[U]pdate Crates')
            map('n', '<leader>ca', crates.update_all_crates, 'Update [A]ll Crates')
            map('n', '<leader>cU', crates.upgrade_crate, '[U]pgrade Crate')
            map('v', '<leader>cU', crates.upgrade_crates, '[U]pgrade Crates')
            map('n', '<leader>cA', crates.upgrade_all_crates, 'Upgrade [A]ll Crates')

            map('n', '<leader>cx', crates.expand_plain_crate_to_inline_table, 'E[x]pand to Inline Table')
            map('n', '<leader>cX', crates.extract_crate_into_table, 'E[x]tract into Table')

            map('n', '<leader>cH', crates.open_homepage, 'Open [H]omepage')
            map('n', '<leader>cR', crates.open_repository, 'Open [R]epository')
            map('n', '<leader>cD', crates.open_documentation, 'Open [D]ocumentation')
            map('n', '<leader>cC', crates.open_crates_io, 'Open [C]rates.io')
          end
        end,
      })
    end,
  },
}
