# dotfiles

## 構成

```
dotfiles/
├── link.ps1                # 設定ファイルの symlink を張る（冪等）
├── wezterm/
│   └── .wezterm.lua        # WezTerm 設定（pwsh 既定・kanagawa 配色・透過トグル・Nerd Font）
├── nvim/                   # Neovim 設定（→ %LOCALAPPDATA%\nvim に symlink）
│   ├── init.lua            # 司令塔（config/* を読み込むだけ）
│   ├── lazy-lock.json      # プラグインのバージョン固定
│   └── lua/
│       ├── config/
│       │   ├── options.lua # エディタ基本設定
│       │   ├── keymaps.lua # キーマップ（LSP の LspAttach 含む）
│       │   └── lazy.lua    # lazy.nvim ブートストラップ
│       └── plugins/        # プラグイン定義（1ファイル1プラグイン）
│           ├── kanagawa.lua              # 配色
│           ├── which-key.lua             # キー補助ポップアップ
│           ├── lualine.lua               # ステータスライン
│           ├── noice.lua                 # コマンドライン/通知のポップアップ表示
│           ├── telescope.lua             # ファジー検索
│           ├── gitsigns.lua              # git 差分表示
│           ├── fugitive.lua              # git 操作
│           ├── oil.lua                   # ファイラ
│           ├── mason.lua                 # LSP サーバー管理
│           ├── lsp.lua                   # mason-lspconfig + lspconfig（lua_ls）
│           ├── blink.lua                 # 補完エンジン
│           ├── lazydev.lua               # Neovim Lua 開発支援
│           ├── tree-sitter-manager.lua   # treesitterパーサー管理・ハイライト
│           ├── indent-blankline.lua      # インデントガイド表示
│           ├── flash.lua                 # ラベルジャンプ(sキー)
│           ├── nvim-autopairs.lua        # 括弧・クォートの自動閉じ
│           └── smart-splits.lua          # nvim分割/weztermペインの移動統合
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1  # PowerShell プロファイル（zoxide 初期化・fzf 連携）→ $PROFILE に symlink
├── winget/
│   └── install.ps1        # winget で入れるツール一式
├── pnpm/
│   └── install.ps1        # pnpm グローバルパッケージ
└── tools/
    └── install.ps1        # winget/pnpm 以外のインストールコマンド（Claude Code CLI 等）
```

## 導入の仕方

### 1. 開発者モードを有効化

symlink 作成に必要（dotfiles の symlink、tree-sitter-manager.nvim のパーサー追加時も同様）。
設定 → プライバシーとセキュリティ → 開発者向け → 「開発者モード」をオン。
（管理者権限の pwsh で代用も可。作業が終わったらオフに戻す）

### 2. リポジトリを取得

```powershell
# git が無ければ先に: winget install --id Git.Git -e
git clone https://github.com/tkmrrkn/dotfiles.git "$HOME\dotfiles"
cd "$HOME\dotfiles"
```

### 3. セットアップを実行

```powershell
# 主要ツールを winget で入れる
#   WezTerm / Neovim / PowerShell / ripgrep / Nerd Font /
#   Git / GitHub CLI(gh) / ghq / Node.js / pnpm / zoxide / fzf /
#   Visual Studio Build Tools(C++ワークロード。treesitterパーサーのビルドに使用)
./winget/install.ps1

# pwsh を起動（新しいセッションで PATH を反映）
pwsh -NoLogo

# pnpm グローバル（clasp / tree-sitter-cli）
./pnpm/install.ps1

# その他（Claude Code CLI など）
./tools/install.ps1

# 設定ファイルの symlink（冪等・再実行可）
./link.ps1
```
