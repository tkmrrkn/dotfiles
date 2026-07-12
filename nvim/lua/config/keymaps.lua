vim.keymap.set("i", "jk", "<Esc>", { desc = "Escの代替" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウへ移動" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ移動" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ移動" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウへ移動" })

vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "左右に分割" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "上下に分割" })

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
