return {
  name = 'python-run',
  builder = function()
    local file = vim.fn.expand '%:p'
    return {
      cmd = { 'python', file },
      components = {
        'default',
      },
    }
  end,
  condition = {
    callback = function()
      return vim.bo.filetype == 'python'
    end,
  },
}
