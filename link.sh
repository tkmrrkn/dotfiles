#!/usr/bin/env bash
# WSL 用。設定ファイルの symlink を冪等に張る。何度実行してもよい。
# 注: リポジトリは WSL 内に clone して使う。/mnt/c 側の clone へ symlink を張ると
#     9p ファイルシステム越しの I/O になり nvim(telescope/lazy.nvim) が著しく遅くなる。
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"

# 既に正しいリンクなら何もしない。別の実体がある場合は壊さず警告してスキップ。
ensure_symlink() {
  local path="$1" target="$2"
  if [ -L "$path" ] && [ "$(readlink "$path")" = "$target" ]; then
    echo "リンク済み: $path"
    return
  fi
  if [ -e "$path" ] || [ -L "$path" ]; then
    echo "スキップ: $path が既に存在します。退避してから再実行してください。" >&2
    return
  fi
  mkdir -p "$(dirname "$path")"
  ln -s "$target" "$path"
  echo "リンク作成: $path -> $target"
}

ensure_symlink "$HOME/.config/nvim" "$repo/nvim"

# ~/.bashrc に shell/bashrc の読み込みを追記（済みなら何もしない）
line=". \"$repo/shell/bashrc\""
if ! grep -qxF "$line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# dotfiles\n%s\n' "$line" >>"$HOME/.bashrc"
  echo "追記: ~/.bashrc に shell/bashrc の読み込みを追加"
else
  echo "追記済み: ~/.bashrc"
fi
