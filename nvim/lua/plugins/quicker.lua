return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  opts = {},
  keys = {
    {
      "<leader>q",
      function()
        require("quicker").toggle()
      end,
      desc = "quickfixウィンドウをトグル",
    },
  },
}
