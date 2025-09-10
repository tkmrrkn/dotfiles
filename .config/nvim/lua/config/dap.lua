local dap = require("dap")
local dapui = require("dapui")
local python = require("config.python")

dap.adapters.python = {
  type = 'executable',
  command = python.get_python_path(),
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return python.get_python_path()
    end,
  },
}

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

-- DAP キーマップ
local map = vim.keymap.set
map("n", "<F9>", dap.toggle_breakpoint)
map("n", "<F5>", dap.continue)
map("n", "<F10>", dap.step_over)
map("n", "<F11>", dap.step_into)
map("n", "<F12>", dap.step_out)
map("n", "<leader>du", function() require("dapui").toggle() end)
