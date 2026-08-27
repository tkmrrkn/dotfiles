' open-in-nvim.ps1 をコンソールを出さずに起動するだけのラッパ。pwsh を直接呼ぶと点滅する。
' このファイルは UTF-16LE + BOM 固定。理由は .gitattributes を参照。
Option Explicit

Dim shell, script, target, pwsh
If WScript.Arguments.Count < 1 Then WScript.Quit 1

Set shell = CreateObject("WScript.Shell")
script = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\")) & "open-in-nvim.ps1"
pwsh = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\WindowsApps\pwsh.exe"
target = WScript.Arguments(0)

' 第2引数 0 = ウィンドウを表示しない、第3引数 False = 終了を待たない
shell.Run """" & pwsh & """ -NoLogo -NoProfile -File """ & script & """ """ & target & """", 0, False
