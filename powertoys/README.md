# PowerToys Keyboard Manager

JSON にコメントが書けないため、`keyboard-manager/default.json` の内容をここに記す。

| キー | 動作 | 用途 |
| --- | --- | --- |
| `CapsLock` | `Ctrl`（左） | Ctrl をホームポジション化。CapsLock の大文字固定を無効化する |

## Ctrl 系のショートカットリマップを入れない理由

`Ctrl + HJKL` などで矢印移動を作ると、`Ctrl+A`(全選択) や `Ctrl+W`(タブを閉じる)、
ブラウザの `Ctrl+L/K/J/U` を全アプリで潰してしまうため見送った。

PowerToys には kanata の tap-hold がないので、「単独押しは文字、長押しは修飾キー」は作れない。
なお bash / PSReadLine では `Ctrl+A`/`Ctrl+E` が元から行頭・行末で、リマップ不要。

## 注意

このリマップは PowerToys 起動中のみ有効。ログオン画面や PowerToys 停止中は CapsLock が通常動作に戻る。
常時無効にしたい場合はレジストリの Scancode Map で置き換える。

GUI で編集して保存すると `default.json` が置き換えられ symlink が外れることがある。
その場合は `link.ps1` を再実行する。直接編集した変更が反映されないときは PowerToys を再起動する。
