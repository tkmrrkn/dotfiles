# === zoxide =========================================================
# `z <部分名>` でよく行くディレクトリへ即移動（frecencyで学習するcd代替）
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# === fzf =============================================================
# 共通オプション（高さ/レイアウト/枠/プロンプト）。fzfはwinget導入でPATH済み。
$env:FZF_DEFAULT_OPTS = '--height 40% --layout reverse --border rounded --info inline --prompt "> "'

# Ctrl+r : コマンド履歴を fzf で絞り込んで挿入（新しい順・重複除去）
Set-PSReadLineKeyHandler -Key 'Ctrl+r' -BriefDescription 'FzfHistory' -ScriptBlock {
  $histPath = (Get-PSReadLineOption).HistorySavePath
  if (-not (Test-Path $histPath)) { return }
  $lines = [System.IO.File]::ReadAllLines($histPath)
  [array]::Reverse($lines)
  $result = $lines |
    Where-Object { $_ -notmatch '^\s*$' } |
    Select-Object -Unique |
    fzf --no-sort --prompt 'history> ' --scheme history
  if ($result) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($result)
  }
}

# Ctrl+t : カレント配下のファイル/ディレクトリを fzf で選んで挿入
Set-PSReadLineKeyHandler -Key 'Ctrl+t' -BriefDescription 'FzfFiles' -ScriptBlock {
  $result = fzf --prompt 'files> ' --walker file,dir,hidden,follow
  if ($result) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("'$result'")
  }
}
