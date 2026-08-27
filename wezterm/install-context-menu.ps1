#Requires -PSEdition Core
# エクスプローラのファイル右クリックに「WezTerm の nvim で開く」を登録する。冪等。
# HKCU 配下なので管理者権限は不要。

$ErrorActionPreference = 'Stop'

$nvim = 'C:\Program Files\Neovim\bin\nvim.exe'
# pwsh を直接呼ぶとコンソールが点滅するので、GUI サブシステムの wscript から起動する。
$wscript = "$env:WINDIR\System32\wscript.exe"
$launcher = "$PSScriptRoot\open-in-nvim.vbs"
$body = "$PSScriptRoot\open-in-nvim.ps1"

foreach ($p in $nvim, $wscript, $launcher, $body) {
  if (-not (Test-Path -LiteralPath $p)) { throw "見つかりません: $p" }
}

# キー名に * が入るので、ワイルドカード解釈される *-Item 系ではなく .NET の API を使う。
$key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey('Software\Classes\*\shell\NvimWezTerm')
try {
  $key.SetValue('MUIVerb', 'WezTerm の nvim で開く')
  $key.SetValue('Icon', "$nvim,0")
  $command = $key.CreateSubKey('command')
  try {
    $command.SetValue('', "`"$wscript`" `"$launcher`" `"%L`"")
  } finally { $command.Dispose() }
} finally { $key.Dispose() }

Write-Host '登録しました。Windows 11 では「その他のオプションを表示」(Shift+F10) の中に出ます。'
