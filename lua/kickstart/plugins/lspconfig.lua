-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- `mason-tool-installer` ensures the tools we need are installed.
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- This function gets run when an LSP attaches to a particular buffer.
      -- It's used to set up keymaps and other buffer-local settings.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, 'LSP: [R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, 'LSP: [C]ode [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, 'LSP: [G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, 'LSP: [G]oto [I]mplementation')

          map('grd', function()
            if vim.bo.filetype == 'cs' then
              require('omnisharp_extended').telescope_lsp_definitions()
            else
              require('telescope.builtin').lsp_definitions()
            end
          end, 'LSP: [G]oto [D]efinition')

          map('grD', vim.lsp.buf.declaration, 'LSP: [G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'LSP: Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'LSP: Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, 'LSP: [G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method('textDocument/inlayHint', { bufnr = event.buf }) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},

        virtual_text = {
          -- This is the key setting. It tells Neovim to show virtual text
          -- for any diagnostic that is a WARNING or more severe (i.e., ERROR).
          severity_min = vim.diagnostic.severity.WARN,
          source = 'always', -- Always show the source of the diagnostic
          spacing = 4, -- Add some space for readability
        },
      }

      -- Set up mason-tool-installer to ensure required LSPs and tools are installed.
      require('mason-tool-installer').setup {
        ensure_installed = {
          'bashls',
          'clangd',
          'codelldb',
          'cmake',
          'gopls',
          'lua_ls',
          'netcoredbg',
          'omnisharp',
          'basedpyright',
          'ruff',
          'debugpy',
          'rust_analyzer',
          'stylua',
          'taplo',
        },
      }

      -- 💡 --- NEW LSP SETUP LOGIC --- 💡
      -- This section is updated for the new mason-lspconfig standard.

      -- 1. Set up mason itself.
      require('mason').setup()

      -- 2. Set up mason-lspconfig. This now simply ensures that installed
      --    servers are enabled and ready for configuration.
      require('mason-lspconfig').setup()

      -- 3. Configure each language server individually using vim.lsp.config.
      --    This is the new, recommended way to add custom settings.

      -- Configure basedpyright.
      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
              typeCheckingMode = 'standard',
              diagnosticSeverityOverrides = {
                reportUnusedImport = 'none',
                reportUnusedVariable = 'none',
              },
            },
          },
        },
      })

      -- Configure ruff.
      vim.lsp.config('ruff', {
        on_attach = function(client, _)
          -- Disable hover in favor of basedpyright
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- Configure rust_analyzer with more comprehensive settings.
      vim.lsp.config('rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            check = {
              command = 'clippy',
            },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
            diagnostics = {
              enable = true,
            },
          },
        },
      })

      -- Configure lua_ls.
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })

      -- 4. Enable the servers.
      --    This is REQUIRED in Neovim 0.11+ to actually start the clients.
      local servers = {
        'bashls',
        'clangd',
        'cmake',
        'gopls',
        'lua_ls',
        'omnisharp',
        'basedpyright',
        'ruff',
        'rust_analyzer',
        'taplo',
      }

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- You can add configurations for other servers here, for example:
      -- vim.lsp.config('pyright', { ...pyright settings... })
      -- vim.lsp.config('gopls', { ...gopls settings... })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
