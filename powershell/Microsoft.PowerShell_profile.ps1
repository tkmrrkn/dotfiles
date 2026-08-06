# === oh-my-posh ======================================================
# kanagawa.nvim に合わせたテーマでプロンプトを描画。
# $PROFILE はこのファイルへの symlink なので、Target からリポジトリのルートを辿る。
$dotfilesRoot = Split-Path (Split-Path (Get-Item $PROFILE -Force).Target -Parent) -Parent
oh-my-posh init pwsh --config "$dotfilesRoot\oh-my-posh\prompt.omp.json" | Invoke-Expression

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

# === DeepL翻訳 ========================================================
# `trans <text>` で日本語訳、`trans -To EN <text>` で英訳などターミナル内で完結。
# APIキーは事前に `gopass insert deepl/api-key` で登録しておく（DeepL API Free/Pro のキー）。
function trans {
  param(
    # Position を明示しないと $To にも暗黙で位置引数が割り当てられ、`trans hello world` の
    # "world" が $To に奪われてしまう（PowerShell の ValueFromRemainingArguments の罠）。
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments)]
    [string[]]$Text,
    [string]$To = 'JA'
  )
  # gopass の PIN 入力プロンプトは stderr に出るため、握り潰さない。
  $apiKey = gopass show -o deepl/api-key
  # Free プランのキーは末尾が ":fx"。エンドポイントが Free/Pro で異なる。
  $endpoint = if ($apiKey.EndsWith(':fx')) {
    'https://api-free.deepl.com/v2/translate'
  } else {
    'https://api.deepl.com/v2/translate'
  }
  # -Body にハッシュテーブルを渡すと multipart/form-data になり DeepL 側で値を解釈できないため、JSON で明示的に送る。
  $body = @{ text = @($Text -join ' '); target_lang = $To } | ConvertTo-Json
  $res = Invoke-RestMethod -Uri $endpoint -Method Post `
    -Headers @{ Authorization = "DeepL-Auth-Key $apiKey" } `
    -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
  $res.translations.text
}

# === カレントディレクトリをOSプロセスCWDに同期 ==========================
# $PWDと[Environment]::CurrentDirectoryが同期されず、外部プロセスから見たcwdが
# 起動時のまま固定される問題（wezhtermのcwd取得等に影響）への対策。
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = {
  param($sender, $eventArgs)
  [Environment]::CurrentDirectory = $eventArgs.NewPath.ProviderPath
}
