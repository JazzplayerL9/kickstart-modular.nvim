return {
  name = "cargo-build",
  builder = function()
    return {
      cmd = { "cargo", "build" },
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
