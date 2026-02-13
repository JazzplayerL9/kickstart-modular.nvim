return {
  name = "cargo-test",
  builder = function()
    return {
      cmd = { "cargo", "test" },
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
