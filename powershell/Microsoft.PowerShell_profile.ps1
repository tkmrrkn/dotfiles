# === oh-my-posh ======================================================
# kanagawa.nvim に合わせたテーマでプロンプトを描画。
# $PROFILE はこのファイルへの symlink なので、Target からリポジトリのルートを辿る。
$dotfilesRoot = Split-Path (Split-Path (Get-Item $PROFILE -Force).Target -Parent) -Parent
oh-my-posh init pwsh --config "$dotfilesRoot\oh-my-posh\prompt.omp.json" | Invoke-Expression

# === zoxide =========================================================
# `z <部分名>` でよく行くディレクトリへ即移動（frecencyで学習するcd代替）
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# === fnm =============================================================
# Nodeのバージョン管理。--use-on-cdで.nvmrc等を見てディレクトリ移動時に切り替える。
# zoxideの`z`はcdエイリアスを通らないので切り替わらない（defaultの版が使われる）。
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

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

# === ssh 系コマンドを Git 同梱の OpenSSH に向ける ======================
# PATH では Windows 標準の OpenSSH（System32）が先に見つかるが、版が古く新しい
# サーバの鍵交換方式（sntrup761x25519 等）に対応しない。git も Git 同梱版を使うので揃える。
# alias は PATH より優先されるので、PATH 自体は触らない。
$gitSshDir = 'C:\Program Files\Git\usr\bin'
if (Test-Path $gitSshDir) {
  foreach ($cmd in 'ssh', 'scp', 'sftp', 'ssh-add', 'ssh-agent', 'ssh-keygen', 'ssh-keyscan') {
    Set-Alias -Name $cmd -Value "$gitSshDir\$cmd.exe"
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

# === 依頼をさばく ======================================================
# 今いるフォルダで /req を画面なしで動かし、報告だけを出す。依頼の渡し方は 3 通り。
#   req <リンク>          Chatwork・Backlog のリンク
#   req（引数なし）       別の画面でコピーした依頼の本文。クリップボードから読む
#   <コマンド> | req      パイプで渡した本文
# 本文は引数に埋め込まず標準入力で渡す（引数だと改行で崩れたり、長い文が切れたりするため）。
# コードを触る依頼は、作業したいリポジトリに移って（z）から使う。Skill はリポジトリを探さない。
# 承認するときは `claude -c` で同じ会話を開き、投稿の文面を確かめてから番号で承認する。
# 画面なしではファイルの編集や git は許可されないので、コードの修正は調べるところで止まる。続きも `claude -c` で行う。
function req {
  param(
    [Parameter(Position = 0, ValueFromRemainingArguments)][string[]]$Request,
    [Parameter(ValueFromPipeline)][object]$InputObject
  )
  begin { $lines = [System.Collections.Generic.List[string]]::new() }
  process { if ($null -ne $InputObject) { $lines.Add([string]$InputObject) } }
  end {
    if ($lines.Count -gt 0) {
      ($lines -join "`n") | claude -p '/req'
    } elseif ($Request) {
      claude -p "/req $($Request -join ' ')"
    } else {
      $clip = Get-Clipboard -Raw
      if ([string]::IsNullOrWhiteSpace($clip)) { Write-Error 'クリップボードが空です。依頼の本文をコピーしてから実行してください。'; return }
      $clip | claude -p '/req'
    }
  }
}

# === エラーの原因を調べる ==============================================
# 今いるフォルダで /why を画面なしで動かし、原因・根拠・確かめ方だけを出す。ファイルは変えない。
#   npm test 2>&1 | why   … 直前のコマンドのエラー
#   why .\logs\app.log    … ログファイル（長くても必要なところだけ読ませる）
#   why                   … クリップボードにコピーしたエラー
# 本文は引数ではなく標準入力で渡す。改行や引用符で壊れず、コマンドラインの長さ上限も受けないため。
function why {
  param(
    [Parameter(Position = 0)][string]$Path,
    [Parameter(ValueFromPipeline)][object]$InputObject
  )
  begin { $lines = [System.Collections.Generic.List[string]]::new() }
  # 2>&1 で来る標準エラーの行は ErrorRecord なので、文字列にしてから集める
  process { if ($null -ne $InputObject) { $lines.Add([string]$InputObject) } }
  end {
    if ($lines.Count -gt 0) {
      ($lines -join "`n") | claude -p '/why'
    } elseif ($Path) {
      if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Write-Error "ファイルが見つかりません: $Path"; return }
      claude -p "/why $((Resolve-Path -LiteralPath $Path).Path)"
    } else {
      $clip = Get-Clipboard -Raw
      if ([string]::IsNullOrWhiteSpace($clip)) { Write-Error 'クリップボードが空です。エラーをコピーしてから実行してください。'; return }
      $clip | claude -p '/why'
    }
  }
}

# === カレントディレクトリをOSプロセスCWDに同期 ==========================
# $PWDと[Environment]::CurrentDirectoryが同期されず、外部プロセスから見たcwdが
# 起動時のまま固定される問題（wezhtermのcwd取得等に影響）への対策。
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = {
  param($sender, $eventArgs)
  [Environment]::CurrentDirectory = $eventArgs.NewPath.ProviderPath
}

# === ローカル設定 =========================================
# $PROFILE と同じ場所に置く。dotfiles管理外なので存在しない環境もある。
$localProfile = Join-Path (Split-Path $PROFILE -Parent) 'profile.local.ps1'
if (Test-Path $localProfile) { . $localProfile }
