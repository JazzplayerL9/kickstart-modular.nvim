return {
  name = 'nasm-build',
  builder = function()
    if vim.fn.glob 'Makefile' ~= '' then
      return {
        cmd = { 'make' },
        components = { 'default' },
      }
    else
      local file = vim.fn.expand '%:p'
      local obj = vim.fn.expand '%:p:r' .. '.o'
      local bin = vim.fn.expand '%:p:r'
      return {
        cmd = string.format('nasm -g -f elf64 "%s" -o "%s" && ld "%s" -o "%s"', file, obj, obj, bin),
        shell = true,
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
