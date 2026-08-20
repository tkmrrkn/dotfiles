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

GUI で編集して保存すると、symlink 越しに dotfiles 側の実体がそのまま上書きされる。
書式も PowerToys 独自の minify 形式になるので、GUI を使った後は必ず git diff を見る。

直接編集した変更は PowerToys の再起動まで反映されない。
このリマップは PowerToys 起動中のみ有効で、ログオン画面や停止中は CapsLock が通常動作に戻る。
