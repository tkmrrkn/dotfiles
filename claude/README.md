# Claude Code の設定

`link.ps1` / `link.sh` で `~/.claude` 配下に symlink を張る。

- `CLAUDE.md` … 全プロジェクト共通のルール。`[rule-id]` で名指しできる。
- `skills/` … skill 単位でリンクする。`~/.claude/skills` は claude.ai 同期分（`synced/`）の置き場でもあるため、フォルダごと差し替えない。
- `statusline-command.sh` … ステータスライン。
- `hooks/notify.ps1` … Stop / Notification フック。応答の完了や、承認・入力待ちを Windows の通知で知らせる。そのフォルダを開いている VSCode のウィンドウが最前面のときは出さない（別フォルダのウィンドウを見ているときは出す）。クリックすると、そのフォルダを開いている VSCode のウィンドウに切り替わる。初回実行時に、差出人を「Claude Code」にするための `HKCU:\Software\Classes\AppUserModelId\ClaudeCode.Notify`（アイコンは Claude Code 拡張の画像を借りる）と、クリック用のリンク `HKCU:\Software\Classes\claude-notify` を登録する。
- `hooks/notify-focus.vbs` … 通知のクリックで開くリンクを受け取り、`notify.ps1 -Focus` を黒い画面を出さずに起動する。Windows PowerShell 5.1 で動かすため BOM 付き UTF-8 で保存している（Windows 専用なので `link.ps1` だけでリンクする）。`~/.claude/hooks` にはマシン専用のフックも置くため、ファイル単位でリンクする。

## settings.json は管理対象外

`~/.claude/settings.json` はマシンごとの実ファイルとして持ち、このリポジトリには置かない。
業務PCの設定には社内 Git ホストの marketplace URL と業務用パスが入り、公開リポジトリに
出せないため。user レベルには `settings.local.json` のような分離先が無い。

## 新しいマシンでの手順

`link.ps1` / `link.sh` を実行したあと、`~/.claude/settings.json` に以下を手で足す。

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\Users\\<ユーザー名>\\.claude\\hooks\\notify.ps1\""
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\Users\\<ユーザー名>\\.claude\\hooks\\notify.ps1\""
          }
        ]
      }
    ]
  }
}
```
