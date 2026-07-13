#!/usr/bin/env bash
# WSL 用。pnpm 本体・Node.js・グローバルパッケージの導入。
set -euo pipefail

# pnpm 本体（apt に無いので公式スクリプトで導入。~/.bashrc への PATH 追記も行われる）
curl -fsSL https://get.pnpm.io/install.sh | sh -

# このセッションにも PATH を反映（~/.bashrc への追記はインストーラーが行う）
# pnpm 本体は $PNPM_HOME/bin、グローバルパッケージのコマンドは $PNPM_HOME に入る
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"

# Node.js LTS（pnpm 経由で導入・管理。winget の OpenJS.NodeJS.LTS に相当）
pnpm env use --global lts

# サプライチェーン対策: 公開から24時間(1440分)未満のバージョンはインストールしない
pnpm config set minimum-release-age 1440

pnpm add -g @google/clasp

# tree-sitter-cli は postinstall でバイナリを取得するため、ビルドスクリプトの実行を明示的に許可する
# （pnpm は既定で依存パッケージのビルドスクリプトをブロックする）
pnpm add -g --allow-build=tree-sitter-cli tree-sitter-cli

# 注: 今後追加したツールが動かない場合も同様に --allow-build か `pnpm approve-builds -g` で許可する。
