return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Standard parser management
      local ts = require('nvim-treesitter')
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'diff',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'vim',
          'vimdoc',
          'rust',
          'toml',
          'c_sharp',
          'python',
          'ninja',
        },
        -- Autoinstall languages that are not installed
        auto_install = true,
        -- We disable the plugin-managed highlight/indent modules here 
        -- and use the native Neovim 0.11+ methods instead in the autocmd below.
        highlight = { enable = false },
        indent = { enable = true },
      }

      -- Enable Treesitter features (Highlight, Folds, Indent) via autocmd
      -- This is the "new release" native-first approach for Neovim 0.11+
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
          if lang then
            -- Native highlighting (0.11+)
            pcall(vim.treesitter.start)
            
            -- Native folding
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldmethod = 'expr'
          end
        end,
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
