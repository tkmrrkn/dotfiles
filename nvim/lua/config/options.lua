vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true

-- 保存時のフォーマッタ（ktlint・sqlfluff・rustfmt）が空白 4 個で整形する言語は、入力中も 4 個にそろえる。
-- Python は組み込みの ftplugin が 4 個にしている。
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "kotlin", "sql", "rust" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
})
