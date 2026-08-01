return {
  "romus204/tree-sitter-manager.nvim",
  event = "VeryLazy",
  config = function()
    require("tree-sitter-manager").setup({
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "json",
        "javascript",
        "typescript",
        "python",
        "bash",
        "kotlin",
      },
    })
  end,
}
