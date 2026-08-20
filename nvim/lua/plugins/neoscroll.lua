return {
  "karb94/neoscroll.nvim",
  event = "VeryLazy",
  opts = {
    -- 半画面移動を目で追えるようにするだけなので<C-u>/<C-d>に絞る
    mappings = { "<C-u>", "<C-d>" },
    easing = "quadratic",
    duration_multiplier = 0.6,
  },
}
