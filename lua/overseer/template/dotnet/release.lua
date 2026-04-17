return {
  name = "dotnet-release",
  builder = function()
    return {
      cmd = { "dotnet", "build", "-c", "Release" },
      components = {
        "default",
        { "on_output_parse", problem_matcher = "$mscompile" },
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob("*.sln") ~= "" or vim.fn.glob("*.csproj") ~= ""
    end,
  },
}
