return {
  "shellRaining/hlchunk.nvim",
  -- 初回バッファ描画に間に合わせるため VeryLazy ではなくこの2イベント
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    chunk = { enable = true },
    indent = { enable = true },
    line_num = { enable = true },
    blank = { enable = true },
  },
}
