local lspconfig = require("lspconfig")
local python = require("config.python")

lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format({ async = true })
    end, {})
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format()")
  end,
  before_init = function(params, config)
    config.settings.python.pythonPath = python.get_python_path()
  end,
})

-- カーソル停止時の診断表示
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end
})
