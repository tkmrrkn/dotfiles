-- lua/config/python.lua
local M = {}

-- 現在の作業ディレクトリに .venv/bin/python があれば使う
function M.get_python_path()
    local cwd = vim.fn.getcwd()
    local venv_path = cwd .. "/.venv/bin/python"
    if vim.fn.filereadable(venv_path) == 1 then
        return venv_path
    else
        return "/usr/bin/python3"  -- デフォルト
    end
end

-- Neovim Python プロバイダーに設定
vim.g.python3_host_prog = M.get_python_path()

return M
