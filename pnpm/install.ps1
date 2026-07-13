# pnpm のグローバル環境を初期化（PNPM_HOME の作成とユーザー PATH への追加）
pnpm setup

# setup はユーザー環境変数に書き込むだけなので、このセッションにも反映する
# pnpm 11 からグローバルパッケージのコマンドは PNPM_HOME 直下ではなく bin サブディレクトリに入る
$env:PNPM_HOME = "$env:LOCALAPPDATA\pnpm"
$env:Path = "$env:PNPM_HOME\bin;$env:PNPM_HOME;$env:Path"

# サプライチェーン対策: 公開から24時間(1440分)未満のバージョンはインストールしない
pnpm config set minimum-release-age 1440

pnpm add -g @google/clasp

# tree-sitter-cli は postinstall でバイナリを取得するため、ビルドスクリプトの実行を明示的に許可する
# （pnpm は既定で依存パッケージのビルドスクリプトをブロックする）
pnpm add -g --allow-build=tree-sitter-cli tree-sitter-cli

# 注: 今後追加したツールが動かない場合も同様に --allow-build か `pnpm approve-builds -g` で許可する。
