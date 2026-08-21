#Requires -PSEdition Core
#Requires -RunAsAdministrator
# CapsLock を左 Ctrl にする Scancode Map を書き込む。冪等。反映には再起動が必要。
# 解除は -Remove を付けて実行し、同じく再起動する。

[CmdletBinding()]
param([switch]$Remove)

$ErrorActionPreference = 'Stop'

$path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout'
$name = 'Scancode Map'

# バイナリの構成は先頭から version 4 バイト、flags 4 バイト、エントリ数 4 バイト、
# マッピング 4 バイト x n、終端 4 バイト。エントリ数はマッピング 1 件と終端 1 件で 2。
# マッピングは「変換後、変換元」の順に 16bit リトルエンディアンで並べる。
# 0x001D が左 Ctrl、0x003A が CapsLock の位置のスキャンコード。
$map = [byte[]] @(
  0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00,
  0x02, 0x00, 0x00, 0x00,
  0x1D, 0x00, 0x3A, 0x00,
  0x00, 0x00, 0x00, 0x00
)

if ($Remove) {
  Remove-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
  Write-Host "削除しました: $name"
} else {
  Set-ItemProperty -Path $path -Name $name -Type Binary -Value $map
  Write-Host "書き込みました: $name = CapsLock -> 左 Ctrl"
}

Write-Host '反映には再起動が必要です。'
