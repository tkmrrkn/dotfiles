return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "diffviewを開く" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "現在のファイルの履歴" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "diffviewを閉じる" },
  },
}
