#Requires -PSEdition Core
# エクスプローラの右クリックからファイルを nvim で開く。
# WezTerm が起動していれば表示中のウィンドウに新しいタブ、起動していなければ新しいウィンドウ。

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path
)

$ErrorActionPreference = 'Stop'
# 終了コードで分岐したいので、ネイティブコマンドの失敗を例外にしない。
$PSNativeCommandUseErrorActionPreference = $false

$wezterm = 'C:\Program Files\WezTerm\wezterm.exe'
$weztermGui = 'C:\Program Files\WezTerm\wezterm-gui.exe'
# 拡張子まで書く。省略すると wezterm 側の名前解決が失敗する。
$nvim = 'nvim.exe'

$target = (Resolve-Path -LiteralPath $Path).ProviderPath
if (Test-Path -LiteralPath $target -PathType Container) {
  $cwd = $target
} else {
  $cwd = [System.IO.Path]::GetDirectoryName($target)
}

function Start-NewWindow {
  & $weztermGui start --no-auto-connect --cwd $cwd -- $nvim $target
}

# 終了した WezTerm のソケットファイルは残るので、wezterm cli は WEZTERM_UNIX_SOCKET が無いと
# 古い方を拾って失敗する。エクスプローラ起動時はそれが無いため、生きたプロセスの分だけを返す。
function Get-LiveSocket {
  if ($env:WEZTERM_UNIX_SOCKET) { return @($env:WEZTERM_UNIX_SOCKET) }
  $dir = Join-Path $HOME '.local\share\wezterm'
  if (-not (Test-Path -LiteralPath $dir)) { return @() }
  $alive = @((Get-Process wezterm-gui -ErrorAction SilentlyContinue).Id)
  @(Get-ChildItem -LiteralPath $dir -Filter 'gui-sock-*' -ErrorAction SilentlyContinue |
    Where-Object { $alive -contains [int]($_.Name -replace '^gui-sock-', '') } |
    ForEach-Object { $_.FullName })
}

# 複数インスタンスがあり得るので、応答したうちアイドル時間が最短＝直前まで触っていた方を選ぶ。
$best = $null
foreach ($socket in Get-LiveSocket) {
  $env:WEZTERM_UNIX_SOCKET = $socket
  $json = & $wezterm cli list-clients --format json 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $json) { continue }
  $client = $null
  try { $client = @($json | ConvertFrom-Json)[0] } catch { continue }
  if (-not $client) { continue }
  $idle = [double]$client.idle_time.secs
  if (-not $best -or $idle -lt $best.Idle) { $best = @{ Socket = $socket; Client = $client; Idle = $idle } }
}

if (-not $best) {
  Start-NewWindow
  return
}

$env:WEZTERM_UNIX_SOCKET = $best.Socket
$client = $best.Client

# spawn 先はフォーカスのあるペインの所属ウィンドウ。指定しないと常に最初のウィンドウに落ちる。
$spawn = @('cli', 'spawn', '--cwd', $cwd)
if ($null -ne $client.focused_pane_id) { $spawn += @('--pane-id', $client.focused_pane_id) }
$pane = & $wezterm @spawn -- $nvim $target 2>$null
if ($LASTEXITCODE -ne 0) {
  Start-NewWindow
  return
}

& $wezterm cli activate-pane --pane-id $pane 2>$null
# 既存の WezTerm は自力で前面に出られないため、フォーカス権を持つこちらから引き上げる。
try { (New-Object -ComObject WScript.Shell).AppActivate([int]$client.pid) | Out-Null } catch { }
