-- 組み込みの]m/[mはブレース依存でPython/PHPに効かないため、treesitter版で上書きする。
local function move(fn, capture)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](capture, "textobjects")
  end
end

return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    -- python の ftplugin はバッファローカルな]m/[mを張り、グローバルな設定を握り潰す。
    vim.g.no_python_maps = 1
  end,
  keys = {
    { "]m", move("goto_next_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "次の関数/メソッドの先頭へ" },
    { "[m", move("goto_previous_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "前の関数/メソッドの先頭へ" },
    { "]M", move("goto_next_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "次の関数/メソッドの末尾へ" },
    { "[M", move("goto_previous_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "前の関数/メソッドの末尾へ" },
  },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      move = { set_jumps = true },
    })
  end,
}
