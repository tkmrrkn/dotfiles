return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  opts = {
    current_line_blame = false,
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local map = function(mode, keys, fn, desc)
        vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = desc })
      end
      map("n", "]c", function() gitsigns.nav_hunk("next") end, "次のハンク")
      map("n", "[c", function() gitsigns.nav_hunk("prev") end, "前のハンク")
      map("n", "<leader>hs", gitsigns.stage_hunk, "ハンクをstage")
      map("n", "<leader>hr", gitsigns.reset_hunk, "ハンクをreset")
      map("n", "<leader>hp", gitsigns.preview_hunk, "ハンクをプレビュー")
      map("n", "<leader>hb", gitsigns.blame_line, "行のblameを表示")
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "行blame表示をトグル")
    end,
  },
}
