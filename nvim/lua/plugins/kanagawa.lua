return {
  "rebelot/kanagawa.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    require("kanagawa").setup({ transparent = true })
    vim.cmd.colorscheme("kanagawa")
  end,
}
