# dotfiles

Windows / WSL 共通の開発環境設定。`link.ps1` / `link.sh` で各設定ファイルを symlink する。

## 構成

```
dotfiles/
├── link.ps1        # 設定ファイルの symlink を張る（冪等）／Windows
├── link.sh          # 同上／WSL（~/.bashrc への読み込み追記も行う）
├── wezterm/         # WezTerm 設定
├── nvim/            # Neovim 設定（Windows/WSL 共通、symlink で共有）
├── powershell/      # PowerShell プロファイル
├── shell/           # WSL 用 bash 設定
├── oh-my-posh/      # プロンプトテーマ
├── lazygit/         # lazygit 設定
├── claude/          # Claude Code の設定・ルール・スキル・hook
├── keyboard/        # キーの差し替え（Scancode Map）／Windows
├── winget/          # winget で入れるツール一式／Windows
├── apt/             # 同上／WSL
├── pnpm/            # pnpm グローバルパッケージ導入
├── tools/           # winget/pnpm 以外のインストール（Claude Code CLI など）
└── git/hooks/       # 個人リポジトリ用の git hook（業務メール名義の混入を防ぐ）
```

各フォルダの詳細は中身を参照。

## git hook（業務メール名義の混入防止）

個人の公開リポジトリに業務用ドメイン名義のコミットが入るのを防ぐ。`pre-commit` が
コミット時に、`pre-push` が送信時に author / committer を検査して該当すれば中止する。
禁止ドメインは `git/hooks/blocked-domains` に1行1件で列挙する。

`~/.gitconfig` の `includeIf` で読み込む個人用設定にだけ `core.hooksPath` を置き、
業務リポジトリには一切適用しない。有効化は各マシンで1回だけ実行する。

```bash
git config --file ~/.gitconfig-personal core.hooksPath ~/dotfiles/git/hooks
```

個人リポジトリを新たに追加するときは、`~/.gitconfig` に `includeIf` を足せば
名義とフックの両方がまとめて効く。

## 導入手順（Windows）

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

### 3. ツールを導入

```powershell
./winget/install.ps1
```

PATH を反映するため、pwsh を開き直す。

```powershell
./pnpm/install.ps1
./tools/install.ps1
```

### 4. 設定ファイルを symlink

```powershell
./link.ps1   # 冪等・再実行可
```

### 5. キーリマップを適用

CapsLock → 左 Ctrl、カタカナ/ひらがな → Esc の Scancode Map をレジストリに書き込む。
管理者権限の pwsh で実行し、再起動して反映する。差し替えを増やすときは `install.ps1` の
`$mappings` に足す。

```powershell
./keyboard/install.ps1            # 適用
./keyboard/install.ps1 -Remove    # 解除
```

システム全体かつ全ユーザーに適用され、ドライバ段階の変換なのでログオン画面でも効く。
半角/全角・無変換・変換は触っていないので IME の操作は従来どおり。

## 導入手順（WSL）

nvim 設定は Windows と共通。WezTerm からは Ctrl+Space → d で WSL タブを開ける。

### 1. リポジトリを取得

```bash
# /mnt/c への symlink は遅いので、WSL 内に別途 clone する
# git が無ければ先に: sudo apt-get install -y git
git clone https://github.com/tkmrrkn/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. ツールを導入

```bash
./apt/install.sh
./pnpm/install.sh
./tools/install.sh
```

### 3. 設定ファイルを symlink

```bash
./link.sh    # 冪等・再実行可
exec bash    # シェル設定を反映
```
