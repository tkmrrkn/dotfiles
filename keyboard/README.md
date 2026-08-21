# キーボード

## CapsLock を左 Ctrl にする

`install.ps1` が `HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout` の
`Scancode Map` に、CapsLock の位置のスキャンコードを左 Ctrl へ差し替える 1 件を書き込む。

```powershell
./keyboard/install.ps1            # 管理者権限の pwsh で実行 → 再起動
./keyboard/install.ps1 -Remove    # 解除 → 再起動
```

## 注意

システム全体かつ全ユーザーに適用される。書き込みと解除のどちらも再起動するまで反映されない。
ドライバ段階での変換なので、ログオン画面や管理者権限のウィンドウでも効く。
