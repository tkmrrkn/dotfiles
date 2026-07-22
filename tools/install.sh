#!/usr/bin/env bash
# WSL 用。apt/pnpm 以外のインストールコマンド。
# 導入先の ~/.local/bin は Ubuntu 標準の ~/.profile で PATH に入る（初回はシェルを開き直す）。
set -euo pipefail

# Claude Code CLI
curl -fsSL https://claude.ai/install.sh | bash

# oh-my-posh（apt に無いので公式インストールスクリプトを使う）
curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"

# ghq（apt に無いので GitHub Releases のバイナリを入れる）
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL -o "$tmp/ghq.zip" https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_amd64.zip
unzip -q "$tmp/ghq.zip" -d "$tmp"
install -D "$tmp/ghq_linux_amd64/ghq" "$HOME/.local/bin/ghq"
