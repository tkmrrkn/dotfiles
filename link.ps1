#Requires -PSEdition Core
# 設定ファイルの symlink を冪等に張る。何度実行してもよい。

$ErrorActionPreference = 'Stop'

$links = @(
  @{ Path = "$HOME\.wezterm.lua";     Target = "$PSScriptRoot\wezterm\.wezterm.lua" }
  @{ Path = "$env:LOCALAPPDATA\nvim"; Target = "$PSScriptRoot\nvim" }
  @{ Path = $PROFILE;                 Target = "$PSScriptRoot\powershell\Microsoft.PowerShell_profile.ps1" }
)

# 作成すべきリンクが残っている場合のみ、symlink 作成権限（開発者モード or 管理者）を要求。
# 全リンク作成済みなら権限なしで通る。
$needsLink = $links | Where-Object { -not (Get-Item $_.Path -Force -ErrorAction SilentlyContinue) }
if ($needsLink) {
  $devMode = 0
  try {
    $devMode = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
      -Name AllowDevelopmentWithoutDevLicense -ErrorAction Stop
  } catch {}
  $isAdmin = [Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if ($devMode -ne 1 -and -not $isAdmin) {
    throw 'symlink の作成に開発者モードか管理者権限が必要です（READMEの手順1参照）'
  }
}

# 既に正しいリンクなら何もしない。別の実体がある場合は壊さず警告してスキップ。
function Ensure-Symlink($Path, $Target) {
  $item = Get-Item $Path -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Target) {
    Write-Host "リンク済み: $Path"
    return
  }
  if ($item) {
    Write-Warning "スキップ: $Path が既に存在します。退避してから再実行してください。"
    return
  }
  $parent = Split-Path $Path
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
  Write-Host "リンク作成: $Path -> $Target"
}

foreach ($l in $links) {
  Ensure-Symlink $l.Path $l.Target
}
