#Requires -PSEdition Core
#Requires -RunAsAdministrator
# Scancode Map でキーを差し替える。冪等。反映には再起動が必要。
# 解除は -Remove を付けて実行し、同じく再起動する。

[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'

$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$name = 'Scancode Map'

# 0x001D=左 Ctrl, 0x003A=CapsLock, 0x0001=Esc, 0x0070=カタカナ/ひらがな。
$mappings = @(
  @{ From = 0x003A; To = 0x001D; Label = 'CapsLock -> 左 Ctrl' }
  @{ From = 0x0070; To = 0x0001; Label = 'カタカナ/ひらがな -> Esc' }
)

# 先頭から version 4 バイト、flags 4 バイト、エントリ数 4 バイト（マッピング数 + 終端 1）、
# マッピング 4 バイト x n（「変換後、変換元」の順に 16bit リトルエンディアン）、終端 4 バイト。
$bytes = [System.Collections.Generic.List[byte]]::new()
$bytes.AddRange([byte[]] @(0, 0, 0, 0, 0, 0, 0, 0))
$bytes.AddRange([BitConverter]::GetBytes([uint32]($mappings.Count + 1)))
foreach ($m in $mappings) {
  $bytes.AddRange([BitConverter]::GetBytes([uint16]$m.To))
  $bytes.AddRange([BitConverter]::GetBytes([uint16]$m.From))
}
$bytes.AddRange([byte[]] @(0, 0, 0, 0))
$map = $bytes.ToArray()

if ($Remove) {
  Remove-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
  Write-Host "削除しました: $name"
} else {
  Set-ItemProperty -Path $path -Name $name -Type Binary -Value $map
  Write-Host "書き込みました: $name"
  foreach ($m in $mappings) { Write-Host "  $($m.Label)" }
}

Write-Host '反映には再起動が必要です。'
