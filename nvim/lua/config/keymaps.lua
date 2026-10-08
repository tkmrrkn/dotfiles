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

  -- VSCode で読み込まないプラグイン（telescope・gitsigns・diffview・quicker）のキーは、同じ働きの VSCode のコマンドに振り替える。
  vim.keymap.set("n", "<leader>ff", action("workbench.action.quickOpen"), { desc = "ファイル検索" })
  vim.keymap.set("n", "<leader>fg", action("workbench.action.findInFiles"), { desc = "全文検索" })
  vim.keymap.set("n", "<leader>fb", action("workbench.action.showAllEditors"), { desc = "開いているエディタ一覧" })

  vim.keymap.set("n", "]c", action("workbench.action.editor.nextChange"), { desc = "次のハンク" })
  vim.keymap.set("n", "[c", action("workbench.action.editor.previousChange"), { desc = "前のハンク" })
  vim.keymap.set({ "n", "x" }, "<leader>hs", action("git.stageSelectedRanges"), { desc = "ハンクをstage" })
  vim.keymap.set({ "n", "x" }, "<leader>hr", action("git.revertSelectedRanges"), { desc = "ハンクをreset" })
  vim.keymap.set("n", "<leader>hp", action("editor.action.dirtydiff.next"), { desc = "ハンクをプレビュー" })
  vim.keymap.set("n", "<leader>tb", action("gitlens.toggleLineBlame"), { desc = "行blame表示をトグル" })

  vim.keymap.set("n", "<leader>gd", action("workbench.view.scm"), { desc = "変更の一覧を開く" })
  vim.keymap.set("n", "<leader>gh", action("gitlens.showQuickFileHistory"), { desc = "現在のファイルの履歴" })

  vim.keymap.set("n", "<leader>q", action("workbench.actions.view.toggleProblems"), { desc = "問題パネルをトグル" })

  -- oil.nvim は VSCode で動かないため、oil.nvim を真似た拡張 oil.code を同じキーで呼ぶ。
  vim.keymap.set("n", "-", action("oil-code.open"), { desc = "親ディレクトリを開く(oil.code)" })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function(event)
      local map = function(keys, name, desc)
        vim.keymap.set("n", keys, action(name), { buffer = event.buf, desc = desc })
      end

      map("-", "oil-code.openParent", "親ディレクトリへ")
      map("_", "oil-code.openCwd", "作業ディレクトリへ")
      map("`", "oil-code.cd", "作業ディレクトリを変更")
      map("<CR>", "oil-code.select", "開く")
      map("<C-s>", "oil-code.selectVertical", "左右に分割して開く")
      map("<C-t>", "oil-code.selectTab", "新しいタブで開く")
      map("<C-p>", "oil-code.preview", "プレビュー")
      map("<C-l>", "oil-code.refresh", "再読み込み")
      map("g?", "oil-code.help", "ヘルプ")
    end,
  })
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
