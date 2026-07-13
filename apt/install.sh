#!/usr/bin/env bash
# WSL (Ubuntu) 用。apt で入れるツール一式。winget/install.ps1 に相当。
# WezTerm と Nerd Font は Windows 側が担当するので WSL には入れない。
set -euo pipefail

sudo apt-get update

# build-essential: treesitter パーサーのビルドに使用（VS Build Tools に相当）
# gh: Ubuntu 23.04 以降は標準リポジトリにある。古い distro の場合は公式 apt リポジトリを使う。
sudo apt-get install -y \
  build-essential \
  git \
  gh \
  ripgrep \
  fzf \
  zoxide \
  curl \
  ca-certificates \
  unzip

# Neovim は apt 標準だと古く、PPA は開発版(unstable)か更新の滞りがちな安定版(stable)しか
# ないので、公式の最新安定版 tarball を /opt に展開する。winget 版と同じ安定版系列に揃う。
# 更新はこのスクリプトの再実行で行う（展開し直すだけなので冪等）。
tmp="$(mktemp)"
curl -fsSL -o "$tmp" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "$tmp"
sudo ln -sfn /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -f "$tmp"
