return {

  {
    'rust-lang/rust.vim',
    enabled = false, -- Disabled: conform.nvim handles rustfmt and treesitter/rust_analyzer handle syntax/LSP
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 0
    end,
  },
}
