return {
  "romus204/tree-sitter-manager.nvim",
  event = "VeryLazy",
  config = function()
    require("tree-sitter-manager").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "json",
        "javascript",
        "typescript",
        "python",
        "bash",
      },
    })
  end,
}
