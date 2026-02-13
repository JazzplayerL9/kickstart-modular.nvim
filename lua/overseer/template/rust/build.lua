return {
  name = "cargo-build",
  builder = function()
    return {
      cmd = { "cargo", "build" },
      components = {
        "default",
        { "on_output_parse", problem_matcher = "$rustc" },
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob("Cargo.toml") ~= ""
    end,
  },
}
