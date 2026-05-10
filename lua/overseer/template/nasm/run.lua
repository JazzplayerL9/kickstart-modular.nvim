return {
  name = 'nasm-run',
  builder = function()
    if vim.fn.glob 'Makefile' ~= '' then
      -- If there's a Makefile, we assume 'make run' exists or we run the binary with the same name as the first .asm file found
      local asm_files = vim.fn.glob('*.asm', false, true)
      local bin = #asm_files > 0 and vim.fn.fnamemodify(asm_files[1], ':r') or './hello'
      return {
        cmd = { './' .. bin },
        components = { 'default' },
      }
    else
      local bin = vim.fn.expand '%:p:r'
      return {
        cmd = { bin },
        components = { 'default' },
      }
    end
  end,
  condition = {
    callback = function()
      return vim.bo.filetype == 'nasm' or vim.fn.glob '*.asm' ~= ''
    end,
  },
}
