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
        require('dapui').toggle()
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
      dapui.open()
      vim.schedule(function()
        pcall(vim.cmd, 'Neotree close')
      end)
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
      vim.schedule(function()
        pcall(vim.cmd, 'Neotree reveal')
      end)
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
      -- No reveal here to avoid double-triggering with terminated event
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

    local function find_executable()
      -- Try Rust (Cargo)
      if vim.fn.glob 'Cargo.toml' ~= '' then
        local target_dir = 'target'
        -- Try to get the actual target directory from cargo metadata, but don't crash if it fails
        local ok, metadata = pcall(function()
          local out = vim.fn.system 'cargo metadata --format-version 1 --no-deps'
          return vim.fn.json_decode(out)
        end)

        if ok and metadata and metadata.target_directory then
          target_dir = metadata.target_directory
        end

        local executable = target_dir .. (vim.fn.has 'win32' == 1 and '\\debug\\' or '/debug/') .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        if vim.fn.has 'win32' == 1 then
          executable = executable .. '.exe'
        end

        if vim.fn.filereadable(executable) == 1 then
          return executable
        end
      end

      -- Try .NET
      local csproj = vim.fn.glob '*.csproj'
      if csproj ~= '' then
        local bin_dir = vim.fn.getcwd() .. (vim.fn.has 'win32' == 1 and '\\bin\\Debug\\' or '/bin/Debug/')
        local frameworks = vim.fn.glob(bin_dir .. '*', 0, 1)
        if #frameworks > 0 then
          local executable = frameworks[1] .. (vim.fn.has 'win32' == 1 and '\\' or '/') .. vim.fn.fnamemodify(csproj, ':t:r')
          if vim.fn.has 'win32' == 1 then
            executable = executable .. '.exe'
          else
            -- On Linux, it might be the DLL or a standalone binary
            if vim.fn.filereadable(executable) == 0 then
              executable = executable .. '.dll'
            end
          end
          if vim.fn.filereadable(executable) == 1 then
            return executable
          end
        end
      end

      -- Default fallback to manual selection
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. (vim.fn.has 'win32' == 1 and '\\' or '/'), 'file')
    end

    dap.configurations.rust = {
      {
        name = 'Debug with codelldb',
        type = 'codelldb',
        request = 'launch',
        program = find_executable,
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
        program = find_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = find_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }
    dap.configurations.c = dap.configurations.cpp

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = find_executable,
      },
    }

    dap.configurations.nasm = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = find_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
      },
    }
  end,
}
