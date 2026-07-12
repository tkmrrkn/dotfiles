# dotfiles

## 構成

```
dotfiles/
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
│   └── Microsoft.PowerShell_profile.ps1  # PowerShell プロファイル（zoxide 初期化）→ $PROFILE に symlink
├── winget/
│   └── install.ps1        # winget で入れるツール一式
├── npm/
│   └── install.ps1        # npm グローバルパッケージ
└── tools/
    └── install.ps1        # winget/npm 以外のインストールコマンド（Claude Code CLI 等）
```

## 導入の仕方

### 1. ツールを入れる

```powershell
# 主要ツール
#   WezTerm / Neovim / PowerShell / ripgrep / Nerd Font /
#   Git / GitHub CLI(gh) / ghq / Node.js / zoxide /
#   Visual Studio Build Tools(C++ワークロード。treesitterパーサーのビルドに使用)
./winget/install.ps1

# npm グローバル（Node.js インストール後に）
#   clasp / tree-sitter-cli(treesitterパーサーのビルドに使用)
./npm/install.ps1

# その他（Claude Code CLI など）
./tools/install.ps1
```

### 2. 開発者モードを有効化

symlink 作成に必要（dotfiles の symlink、tree-sitter-manager.nvim のパーサー追加時も同様）。
設定 → プライバシーとセキュリティ → 開発者向け → 「開発者モード」をオン。
（管理者権限の pwsh で代用も可。作業が終わったらオフに戻す）

### 3. リポジトリを取得

```powershell
git clone https://github.com/tkmrrkn/dotfiles.git "$HOME\dotfiles"
```

### 4. symlink を張る

```powershell
# WezTerm
New-Item -ItemType SymbolicLink -Path "$HOME\.wezterm.lua" -Target "$HOME\dotfiles\wezterm\.wezterm.lua"

# Neovim
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\dotfiles\nvim"

# PowerShell プロファイル（親フォルダが無ければ先に作成）
if (-not (Test-Path (Split-Path $PROFILE))) {
  New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force
}
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$HOME\dotfiles\powershell\Microsoft.PowerShell_profile.ps1"
```
