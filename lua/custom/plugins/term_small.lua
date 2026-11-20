vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      size = 15,
      direction = 'horizontal',
    },
    keys = {
      { '<leader>st', '<cmd>ToggleTerm<cr>', desc = '[S]mall [T]erminal toggle' },
    },
  },
}
