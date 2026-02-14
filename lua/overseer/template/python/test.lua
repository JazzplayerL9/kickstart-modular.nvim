return {
  name = 'python-test',
  builder = function()
    local cmd = { 'pytest' }
    if vim.fn.executable 'pytest' == 0 then
      cmd = { 'python', '-m', 'unittest', 'discover' }
    end
    return {
      cmd = cmd,
      components = {
        'default',
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob 'requirements.txt' ~= ''
        or vim.fn.glob 'pyproject.toml' ~= ''
        or vim.fn.glob 'setup.py' ~= ''
        or vim.fn.glob 'tests/' ~= ''
    end,
  },
}
