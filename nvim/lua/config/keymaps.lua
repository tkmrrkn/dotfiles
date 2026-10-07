vim.keymap.set("i", "jk", "<Esc>", { desc = "Escの代替" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "検索ハイライトを消す" })

-- VSCode（vscode-neovim）では、ウィンドウ操作と LSP を VSCode のコマンドに振り替える。
-- gd・K・gr・gc は vscode-neovim が最初から VSCode のコマンドに割り当てている。
if vim.g.vscode then
  local vscode = require("vscode")
  local function action(name)
    return function()
      vscode.action(name)
    end
  end

  vim.keymap.set("n", "<C-h>", action("workbench.action.navigateLeft"), { desc = "左のエディタグループへ移動" })
  vim.keymap.set("n", "<C-j>", action("workbench.action.navigateDown"), { desc = "下のエディタグループへ移動" })
  vim.keymap.set("n", "<C-k>", action("workbench.action.navigateUp"), { desc = "上のエディタグループへ移動" })
  vim.keymap.set("n", "<C-l>", action("workbench.action.navigateRight"), { desc = "右のエディタグループへ移動" })

  vim.keymap.set("n", "<leader>sv", action("workbench.action.splitEditorRight"), { desc = "左右に分割" })
  vim.keymap.set("n", "<leader>sh", action("workbench.action.splitEditorDown"), { desc = "上下に分割" })

  vim.keymap.set("n", "<leader>rn", action("editor.action.rename"), { desc = "リネーム" })
  vim.keymap.set("n", "<leader>ca", action("editor.action.quickFix"), { desc = "コードアクション" })
  return
end

local smart_splits = require("smart-splits")
vim.keymap.set("n", "<C-h>", smart_splits.move_cursor_left, { desc = "左のウィンドウ/ペインへ移動" })
vim.keymap.set("n", "<C-j>", smart_splits.move_cursor_down, { desc = "下のウィンドウ/ペインへ移動" })
vim.keymap.set("n", "<C-k>", smart_splits.move_cursor_up, { desc = "上のウィンドウ/ペインへ移動" })
vim.keymap.set("n", "<C-l>", smart_splits.move_cursor_right, { desc = "右のウィンドウ/ペインへ移動" })

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "左右に分割" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "上下に分割" })

-- コメントのトグル(gc/gcc)はNeovim組み込み機能。Ctrl+/からも呼べるようにする。
-- 端末によってCtrl+/は<C-_>と<C-/>のどちらかで届くため両方にマップする。
vim.keymap.set("n", "<C-_>", "gcc", { desc = "コメントをトグル", remap = true })
vim.keymap.set("v", "<C-_>", "gc", { desc = "選択範囲のコメントをトグル", remap = true })
vim.keymap.set("n", "<C-/>", "gcc", { desc = "コメントをトグル", remap = true })
vim.keymap.set("v", "<C-/>", "gc", { desc = "選択範囲のコメントをトグル", remap = true })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "定義へジャンプ")
    map("K", vim.lsp.buf.hover, "ホバー説明")
    map("gr", vim.lsp.buf.references, "参照を検索")
    map("<leader>rn", vim.lsp.buf.rename, "リネーム")
    map("<leader>ca", vim.lsp.buf.code_action, "コードアクション")
  end,
})
