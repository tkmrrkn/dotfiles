local gitsigns = require("gitsigns")

gitsigns.setup({
  signs = {
    add          = {hl = 'GitGutterAdd'   , text = '+'},
    change       = {hl = 'GitGutterChange', text = '~'},
    delete       = {hl = 'GitGutterDelete', text = '_'},
    topdelete    = {hl = 'GitGutterDelete', text = '‾'},
    changedelete = {hl = 'GitGutterChange', text = '~'},
  },
  numhl = true,
  linehl = false,
  watch_gitdir = {interval=1000},
})

-- キーマップ
local map = vim.keymap.set
map("n", "<leader>hs", gitsigns.stage_hunk, {desc="Stage Hunk"})
map("n", "<leader>hr", gitsigns.reset_hunk, {desc="Reset Hunk"})
map("n", "<leader>hp", gitsigns.preview_hunk, {desc="Preview Hunk"})
map("n", "<leader>hb", function() gitsigns.blame_line{full=true} end, {desc="Blame Line"})
