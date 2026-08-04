return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      typescript = { "prettier" },
      javascript = { "prettier" },
      kotlin = { "ktlint" },
      sql = { "sqlfluff" },
    },
    format_on_save = {
      timeout_ms = 5000,
      lsp_format = "fallback",
    },
  },
}
