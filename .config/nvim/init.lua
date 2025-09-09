-- ==========================
-- 基本設定
-- ==========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.smartindent = true
vim.o.clipboard = "unnamedplus"

-- Leaderキー
vim.g.mapleader = " "
local map = vim.keymap.set

-- ==========================
-- Python パス (一元管理)
-- ==========================
local python_path = "/home/takemurark/hydro_fw_controller/.venv/bin/python"
vim.g.python3_host_prog = python_path  -- Neovim Python プロバイダー用

-- ==========================
-- lazy.nvim プラグイン管理
-- ==========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "akinsho/toggleterm.nvim",
  "nvim-treesitter/nvim-treesitter",
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "theHamsta/nvim-dap-virtual-text",
  "nvim-neotest/nvim-nio",
  "tpope/vim-fugitive",
  "lewis6991/gitsigns.nvim"
})

-- ==========================
-- require モジュール
-- ==========================
local cmp = require("cmp")
local lspconfig = require("lspconfig")
local dap = require("dap")
local dapui = require("dapui")
local nvim_tree = require("nvim-tree")
local gitsigns = require("gitsigns")

-- ==========================
-- キーマッピング
-- ==========================
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("i", "jj", "<Esc>")
map("i", "jk", "<Esc>")
map("n", "<leader>e", ":NvimTreeToggle<CR>")

-- DAP キーマップ
map("n", "<F9>", dap.toggle_breakpoint)
map("n", "<F5>", dap.continue)
map("n", "<F10>", dap.step_over)
map("n", "<F11>", dap.step_into)
map("n", "<F12>", dap.step_out)
map("n", "<leader>du", function() require("dapui").toggle() end)

-- Gitsigns キーマップ
map("n", "<leader>hs", gitsigns.stage_hunk, {desc="Stage Hunk"})
map("n", "<leader>hr", gitsigns.reset_hunk, {desc="Reset Hunk"})
map("n", "<leader>hp", gitsigns.preview_hunk, {desc="Preview Hunk"})
map("n", "<leader>hb", function() gitsigns.blame_line{full=true} end, {desc="Blame Line"})

-- カーソル停止時の診断表示
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end
})

-- ==========================
-- nvim-cmp 設定
-- ==========================
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- ==========================
-- LSP 設定 (Python)
-- ==========================
lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format({ async = true })
    end, {})
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
  end,
  before_init = function(params, config)
    config.settings.python.pythonPath = python_path
  end,
})

-- ==========================
-- nvim-tree 設定
-- ==========================
nvim_tree.setup({
  view = { width = 30, side = "right" },
  update_focused_file = { enable = true },
})

-- ==========================
-- toggleterm 設定
-- ==========================
require("toggleterm").setup({
  size = 15,
  open_mapping = [[<leader>t]],
  direction = "horizontal",
  close_on_exit = true,
})

-- ==========================
-- Treesitter 設定
-- ==========================
require("nvim-treesitter.configs").setup({
  ensure_installed = { "python", "lua", "javascript", "html", "css" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
})

-- ==========================
-- DAP (Python)
-- ==========================
dap.adapters.python = {
  type = 'executable',
  command = python_path,  -- ← 一元管理した python_path を使用
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return python_path  -- ← ここも同じく一元管理
    end,
  },
}

-- ==========================
-- DAP UI & VirtualText
-- ==========================
dapui.setup()

require("nvim-dap-virtual-text").setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  show_stop_reason = true,
})

-- デバッグ開始・終了時に自動で UI を開閉
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- ==========================
-- Gitsigns setup
-- ==========================
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
