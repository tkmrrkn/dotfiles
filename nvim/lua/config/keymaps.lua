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
