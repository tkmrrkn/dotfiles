return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "全文検索(grep)" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプ検索" },
  },
  opts = {},
}
