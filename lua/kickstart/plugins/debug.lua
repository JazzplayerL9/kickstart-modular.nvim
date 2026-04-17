-- debug.lua
-- RESTORED to the minimal version that worked with launch.json
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',
    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- Language specific extensions
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: [C]ontinue',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step [I]nto',
    },
    {
      '<leader>dv',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step O[v]er',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step [O]ut',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle [B]reakpoint',
    },
    {
      '<leader>du',
      function()
        local dapui = require 'dapui'
        dapui.toggle()
        -- Attempt to keep Neotree state in sync if you're toggling manually
        local state = require('neo-tree.sources.manager').get_state 'filesystem'
        if state.window and state.window.winid then
          vim.cmd 'Neotree close'
        else
          vim.cmd 'Neotree reveal'
        end
      end,
      desc = 'Debug: [U]I Toggle',
    },
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'delve', 'codelldb', 'debugpy', 'coreclr' },
      handlers = {
        function(config)
          -- all sources with no handler get passed here
          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
        codelldb = function(config)
          config.server_ready_timeout = 20 -- Increase timeout to 20 seconds
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    }

    dapui.setup()
    dap.listeners.after.event_initialized['dapui_config'] = function()
      vim.cmd 'Neotree close'
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
      vim.cmd 'Neotree reveal'
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
      vim.cmd 'Neotree reveal'
    end

    require('dap-go').setup {
      delve = { detached = vim.fn.has 'win32' == 0 },
    }

    local debugpy_bin = vim.fn.has 'win32' == 1 and '/venv/Scripts/python.exe' or '/venv/bin/python'
    local debugpy_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy' .. debugpy_bin
    if vim.fn.filereadable(debugpy_path) == 1 then
      require('dap-python').setup(debugpy_path)
    end

    -- Minimal adapter definition
    dap.adapters['probe-rs-debug'] = {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = {
        command = 'probe-rs',
        args = { 'dap-server', '--port', '${port}', '--single-session' },
      },
    }
    dap.adapters['probe-rs'] = dap.adapters['probe-rs-debug']

    dap.configurations.rust = {
      {
        name = 'Debug with codelldb',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. (vim.fn.has 'win32' == 1 and '\\' or '/'), 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        terminal = 'integrated',
        sourceLanguages = { 'rust' },
      },
      {
        name = 'Debug with probe-rs',
        type = 'probe-rs',
        request = 'launch',
        chip = function()
          return vim.fn.input 'Chip: '
        end,
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. (vim.fn.has 'win32' == 1 and '\\' or '/'), 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }
  end,
}
