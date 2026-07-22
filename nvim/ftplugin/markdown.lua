local function find_browser()
  local candidates = {
    "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
    "C:/Program Files/Microsoft/Edge/Application/msedge.exe",
    "C:/Program Files/Google/Chrome/Application/chrome.exe",
    "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe",
  }
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

local css_path = debug.getinfo(1, "S").source:sub(2):gsub("markdown%.lua$", "markdown-pdf.css")

vim.api.nvim_buf_create_user_command(0, "MdToPdf", function()
  local browser = find_browser()
  if not browser then
    vim.notify("Edge/Chromeが見つかりませんでした", vim.log.levels.ERROR)
    return
  end

  local src = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r") .. ".pdf"
  local html = (vim.fn.tempname() .. ".html")

  vim.system(
    { "pandoc", src, "--standalone", "--embed-resources", "--css", css_path, "-o", html },
    { text = true },
    vim.schedule_wrap(function(pandoc_result)
      if pandoc_result.code ~= 0 then
        vim.notify("HTML変換に失敗しました:\n" .. pandoc_result.stderr, vim.log.levels.ERROR)
        return
      end

      local html_url = "file:///" .. html:gsub("\\", "/")
      vim.system(
        {
          browser,
          "--headless",
          "--disable-gpu",
          "--no-pdf-header-footer",
          "--print-to-pdf=" .. out,
          html_url,
        },
        { text = true },
        vim.schedule_wrap(function(browser_result)
          vim.fn.delete(html)
          if browser_result.code == 0 then
            vim.notify("PDFを出力しました: " .. out, vim.log.levels.INFO)
          else
            vim.notify("PDF出力に失敗しました:\n" .. browser_result.stderr, vim.log.levels.ERROR)
          end
        end)
      )
    end)
  )
end, { desc = "現在のMarkdownファイルをPDFに変換(pandoc + ヘッドレスブラウザ)" })

vim.keymap.set("n", "<leader>mp", "<cmd>MdToPdf<cr>", { buffer = 0, desc = "MarkdownをPDF出力" })
