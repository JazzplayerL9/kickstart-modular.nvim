return {
  name = "dotnet-run",
  builder = function()
    return {
      cmd = { "dotnet", "run" },
      components = {
        "default",
      },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.glob("*.sln") ~= "" or vim.fn.glob("*.csproj") ~= ""
    end,
  },
}
