# pnpm のグローバル環境を初期化（PNPM_HOME の作成とユーザー PATH への追加）
pnpm setup

# setup はユーザー環境変数に書き込むだけなので、このセッションにも反映する
$env:PNPM_HOME = "$env:LOCALAPPDATA\pnpm"
$env:Path = "$env:PNPM_HOME;$env:Path"

# サプライチェーン対策: 公開から24時間(1440分)未満のバージョンはインストールしない
pnpm config set minimum-release-age 1440

pnpm add -g @google/clasp
pnpm add -g tree-sitter-cli

# 注: pnpm は依存パッケージのビルドスクリプトを既定でブロックする。
# 入れたツールが動かない場合は `pnpm approve-builds -g` で個別に許可する。
