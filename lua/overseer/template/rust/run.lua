return {
  name = "cargo-run",
  builder = function()
    return {
      cmd = { "cargo", "run" },
      components = {
        "default",
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob("Cargo.toml") ~= ""
    end,
  },
}
