return {
  name = 'python-install-requirements',
  builder = function()
    return {
      cmd = { 'pip', 'install', '-r', 'requirements.txt' },
      components = {
        'default',
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob 'requirements.txt' ~= ''
    end,
  },
}
