return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {
    ensure_installed = { "lua_ls", "basedpyright", "ts_ls", "ruff", "sqlls" },
    -- kotlin_language_server is superseded by kmp_lsp below; exclude it so a
    -- reinstalled package doesn't get auto-enabled and fight over diagnostics.
    automatic_enable = { exclude = { "kotlin_language_server" } },
  },
  config = function(_, opts)
    require("mason-lspconfig").setup(opts)

    -- kotlin-language-server (fwcd) fails to resolve the classpath when
    -- org.gradle.configuration-cache=true is set, causing false
    -- "Unresolved reference" diagnostics across the whole project.
    -- kmp-lsp is not registered in mason-lspconfig's server mapping, so it
    -- has to be installed and wired up manually.
    local kmp_lsp_pkg = "kmp-lsp"
    local mason_registry = require("mason-registry")
    if mason_registry.has_package(kmp_lsp_pkg) then
      local pkg = mason_registry.get_package(kmp_lsp_pkg)
      if not pkg:is_installed() then
        pkg:install()
      end
    end

    vim.lsp.config("kmp_lsp", {
      cmd = { "kmp-lsp" },
      filetypes = { "kotlin", "java" },
      root_markers = {
        "settings.gradle",
        "settings.gradle.kts",
        "build.gradle",
        "build.gradle.kts",
        "pom.xml",
      },
    })
    vim.lsp.enable("kmp_lsp")
  end,
}
