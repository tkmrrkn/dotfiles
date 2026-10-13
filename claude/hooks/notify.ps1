# Claude Code の Stop / Notification フック。応答の完了や、承認・入力待ちを Windows の通知で知らせる。
# Claude は VSCode 拡張で使うため、端末を介さず WinRT で直接トースト通知を出す。
# そのフォルダの VSCode ウィンドウを見ているときは画面で気づけるので出さない（別フォルダのウィンドウなら出す）。
# 通知をクリックすると独自のリンク claude-notify://focus/<フォルダ名> が開き、notify-focus.vbs 経由で
# このスクリプトが -Focus 付きで呼ばれて、そのフォルダの VSCode ウィンドウを手前に出す。vscode://file/ を使うと VSCode が毎回確認ダイアログを出すため。
# WinRT の型は pwsh 7 からは読めないため、Windows PowerShell 5.1（powershell.exe）で動かす前提。
# 5.1 は BOM の無いファイルを Shift_JIS として読むので、このファイルは BOM 付き UTF-8 で保存する。
# どんな失敗でも Claude を止めないよう、常に exit 0 で終わる。

param([string]$Focus)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class ClaudeNotifyWin32 {
  delegate bool EnumProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc proc, IntPtr lParam);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int max);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hWnd);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr hWnd);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr hWnd, int cmd);
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
  [DllImport("user32.dll")] static extern bool AttachThreadInput(uint attach, uint attachTo, bool on);
  [DllImport("user32.dll")] static extern bool BringWindowToTop(IntPtr hWnd);
  [DllImport("kernel32.dll")] static extern uint GetCurrentThreadId();

  static string TitleOf(IntPtr hWnd) {
    var text = new StringBuilder(512);
    GetWindowText(hWnd, text, text.Capacity);
    return text.ToString();
  }

  // VSCode の既定のタイトルは「<ファイル> - <フォルダ> - Visual Studio Code」か「<フォルダ> - Visual Studio Code」
  static bool IsVSCodeOf(string title, string folder) {
    string suffix = folder + " - Visual Studio Code";
    return title == suffix || title.EndsWith(" - " + suffix);
  }

  public static bool IsForegroundVSCodeOf(string folder) {
    return IsVSCodeOf(TitleOf(GetForegroundWindow()), folder);
  }

  public static bool FocusVSCode(string folder) {
    IntPtr found = IntPtr.Zero;
    EnumWindows((hWnd, lParam) => {
      if (IsWindowVisible(hWnd) && IsVSCodeOf(TitleOf(hWnd), folder)) { found = hWnd; return false; }
      return true;
    }, IntPtr.Zero);
    if (found == IntPtr.Zero) return false;
    if (IsIconic(found)) ShowWindow(found, 9); // SW_RESTORE
    // 裏のプロセスからの SetForegroundWindow は Windows に拒否されるので、
    // いま手前にあるウィンドウの入力処理に一時的に相乗りしてから切り替える
    uint ignored;
    uint foregroundThread = GetWindowThreadProcessId(GetForegroundWindow(), out ignored);
    uint currentThread = GetCurrentThreadId();
    bool attached = foregroundThread != currentThread && AttachThreadInput(currentThread, foregroundThread, true);
    BringWindowToTop(found);
    bool ok = SetForegroundWindow(found);
    if (attached) AttachThreadInput(currentThread, foregroundThread, false);
    return ok;
  }
}
'@

# 通知のクリックから呼ばれたとき。リンクは Web ページなど誰からでも開けるので、ウィンドウを手前に出す以外は何もしない
if ($Focus) {
  try {
    if ($Focus -match '^claude-notify://focus/([^/?#]+)/?$') {
      [ClaudeNotifyWin32]::FocusVSCode([Uri]::UnescapeDataString($Matches[1])) | Out-Null
    }
  } catch {}
  exit 0
}

try {
  # 5.1 の既定の入力エンコーディングでは日本語のフォルダ名が化けるため UTF-8 で読む
  $stdin = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)
  $payload = $stdin.ReadToEnd() | ConvertFrom-Json
  # Stop フックの結果で Claude が続行している最中は通知しない
  if ($payload.stop_hook_active) { exit 0 }

  # バックグラウンドのサブエージェントやコマンドの完了を待つ間にもターンが終わって Stop が来るため、
  # 今のターン（最後の人間の発言以降）で起動して、まだ完了通知が来ていない作業があれば出さない。
  # 以前のターンから動き続ける開発サーバーなどで通知がずっと止まらないよう、今のターンの分だけを見る。
  # 記録を読めなかったときは通知する（消えるより余分に出るほうがまし）。
  if ($payload.hook_event_name -eq 'Stop' -and $payload.transcript_path) {
    try {
      $lines = [System.IO.File]::ReadAllLines($payload.transcript_path, [System.Text.Encoding]::UTF8)
      $start = 0
      for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i].Contains('"origin":{"kind":"human"}')) { $start = $i; break }
      }
      # ツール結果の構造化された項目だけを見る。ツールの出力本文に同じ文字列があっても、
      # そちらは引用符がエスケープされて記録されるので取り違えない。
      $launched = @{}
      $finished = @{}
      for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        # バックグラウンドに回したコマンド（時間切れで回ったものも含む）
        if ($line -match '"backgroundTaskId":"(\w+)"') { $launched[$Matches[1]] = $true }
        # バックグラウンドで起動したサブエージェント
        if ($line.Contains('"status":"async_launched"') -and $line -match '"agentId":"(\w+)"') { $launched[$Matches[1]] = $true }
        # 完了通知（完了・失敗・停止のいずれも）
        if ($line.Contains('"origin":{"kind":"task-notification"') -and $line -match '<task-id>(\w+)</task-id>') { $finished[$Matches[1]] = $true }
      }
      if (@($launched.Keys | Where-Object { -not $finished.ContainsKey($_) }).Count -gt 0) { exit 0 }
    } catch {}
  }

  $folder = if ($payload.cwd) { Split-Path $payload.cwd -Leaf } else { '' }
  if ($folder -and [ClaudeNotifyWin32]::IsForegroundVSCodeOf($folder)) { exit 0 }

  $status = switch ($payload.hook_event_name) {
    'Notification' {
      switch ($payload.notification_type) {
        'permission_prompt' { '承認待ちです' }
        'idle_prompt' { '入力待ちです' }
        # 種類が増えたときや notification_type が無い版では、Claude Code の英文メッセージをそのまま出す
        default { if ($payload.message) { $payload.message } else { '確認待ちです' } }
      }
    }
    default { '応答が完了しました' }
  }

  # 通知の差出人を「Claude Code」にするため、独自のアプリ ID をユーザー単位のレジストリに登録する。
  # アイコンは VSCode の Claude Code 拡張の画像を借りる。拡張の更新でフォルダ名が変わるので毎回最新版を探し直す。
  $appId = 'ClaudeCode.Notify'
  $appKey = "HKCU:\Software\Classes\AppUserModelId\$appId"
  $extension = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -Filter 'anthropic.claude-code-*' -ErrorAction SilentlyContinue |
    Sort-Object { [version]($_.Name -replace '^anthropic\.claude-code-([\d.]+).*$', '$1') } | Select-Object -Last 1
  $icon = if ($extension) { Join-Path $extension.FullName 'resources\claude-logo.png' } else { '' }
  if (-not (Test-Path $appKey)) { New-Item $appKey -Force | Out-Null }
  if ((Get-ItemProperty $appKey -ErrorAction SilentlyContinue).IconUri -ne $icon) {
    Set-ItemProperty $appKey -Name DisplayName -Value 'Claude Code'
    Set-ItemProperty $appKey -Name IconUri -Value $icon
  }

  # クリック用のリンク claude-notify:// を、notify-focus.vbs 経由でこのスクリプトを -Focus 付きで呼ぶよう登録する
  $protocolKey = 'HKCU:\Software\Classes\claude-notify'
  $launcher = Join-Path (Split-Path $PSCommandPath) 'notify-focus.vbs'
  $command = "wscript.exe `"$launcher`" `"%1`""
  if ((Get-ItemProperty "$protocolKey\shell\open\command" -ErrorAction SilentlyContinue).'(default)' -ne $command) {
    New-Item "$protocolKey\shell\open\command" -Force | Out-Null
    Set-ItemProperty $protocolKey -Name '(default)' -Value 'URL:Claude Code 通知'
    Set-ItemProperty $protocolKey -Name 'URL Protocol' -Value ''
    Set-ItemProperty "$protocolKey\shell\open\command" -Name '(default)' -Value $command
  }

  $title =if ($folder) { $folder } else { 'Claude Code' }
  $launch = ''
  if ($folder) {
    $uri = 'claude-notify://focus/' + [Uri]::EscapeDataString($folder)
    $launch = ' activationType="protocol" launch="' + [System.Security.SecurityElement]::Escape($uri) + '"'
  }

  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
  $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
  $xml.LoadXml("<toast$launch><visual><binding template=""ToastGeneric""><text>" +
    [System.Security.SecurityElement]::Escape($title) + '</text><text>' +
    [System.Security.SecurityElement]::Escape($status) + '</text></binding></visual></toast>')
  [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show(
    [Windows.UI.Notifications.ToastNotification]::new($xml))
} catch {}
exit 0
