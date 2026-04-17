return {
  name = "cargo-release",
  builder = function()
    return {
      cmd = { "cargo", "build", "--release" },
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
