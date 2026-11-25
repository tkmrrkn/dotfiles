# Claude Code の設定

`link.ps1` / `link.sh` で `~/.claude` 配下に symlink を張る。

- `CLAUDE.md` … 全プロジェクト共通のルール。`[rule-id]` で名指しできる。
- `skills/` … skill 単位でリンクする。`~/.claude/skills` は claude.ai 同期分（`synced/`）の置き場でもあるため、フォルダごと差し替えない。
- `statusline-command.sh` … ステータスライン。

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
  }
}
```
