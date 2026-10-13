' 通知のクリックで開く claude-notify:// を受け取り、notify.ps1 -Focus をコンソール画面を出さずに起動する。
' powershell.exe を直接登録すると -WindowStyle Hidden でも一瞬黒い画面が出るため、VBScript を挟む。
' リンクは Web ページなど誰からでも開けるので、決まった形以外は PowerShell に渡さない。
Option Explicit

Dim shell, re, script, target
If WScript.Arguments.Count < 1 Then WScript.Quit 1
target = WScript.Arguments(0)

' 引用符などでコマンドラインを壊されないよう、URL エンコード済みの文字だけを許す
Set re = New RegExp
re.Pattern = "^claude-notify://focus/[A-Za-z0-9%._~-]+/?$"
If Not re.Test(target) Then WScript.Quit 1

Set shell = CreateObject("WScript.Shell")
script = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\")) & "notify.ps1"

' 第2引数 0 = ウィンドウを表示しない、第3引数 False = 終了を待たない
shell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & script & """ -Focus """ & target & """", 0, False
