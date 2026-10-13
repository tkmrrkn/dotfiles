-- 公式推奨のdotfile形式。編集して保存すると自動でリロードされる。

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- === シェル =========================================================
-- デフォルトを PowerShell 7 (pwsh) にする。-NoLogo で起動時の著作権表示を消す。
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- === 外観 ===========================================================
-- 同梱カラースキーム。kanagawa(nvim)のwaveに合わせる。
-- nvim側を transparent=true にしているので、nvimの背景はこのweztermの背景色が透けて見える。
-- dragon調にしたいなら 'Kanagawa Dragon (Gogh)' に変更。
config.color_scheme = "Kanagawa (Gogh)"

-- フォント。JetBrainsMono Nerd Font（導入済み）。アイコンも綺麗に出る。
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- === ウィンドウ =====================================================
config.window_background_opacity = 0.98
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.adjust_window_size_when_changing_font_size = false

-- === タブバー =======================================================
-- OSのタイトルバーを消し、タブバーにウィンドウのボタン(最小化/最大化/閉じる)を同居させる。
-- ボタンとドラッグ移動の置き場所がタブバーになるので、タブが1つでも常に出す。
-- レトロ式のタブバーだとボタンが崩れて描画されるため、ファンシー式にする。
-- タブごとの×は 20240203 版では消せない(show_close_tab_button_in_tabs は未対応)。
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 24

-- Kanagawa Wave。アクティブなタブだけをWindowsのアクセント(crystalBlue)の丸いピルで塗る。
local tab_colors = {
	bar = "#16161D", -- sumiInk0
	active = "#7E9CD8", -- crystalBlue
	inactive_fg = "#727169", -- fujiGray
	hover_fg = "#DCD7BA", -- fujiWhite
}

config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
	font_size = 10.5,
	active_titlebar_bg = tab_colors.bar,
	inactive_titlebar_bg = tab_colors.bar,
}

config.colors = {
	tab_bar = {
		active_tab = { bg_color = tab_colors.bar, fg_color = tab_colors.active },
		inactive_tab = { bg_color = tab_colors.bar, fg_color = tab_colors.inactive_fg },
		inactive_tab_hover = { bg_color = tab_colors.bar, fg_color = tab_colors.hover_fg },
		inactive_tab_edge = tab_colors.bar,
	},
}

local nf = wezterm.nerdfonts
local process_icons = {
	nvim = nf.custom_vim,
	pwsh = nf.md_powershell,
	powershell = nf.md_powershell,
	wsl = nf.linux_tux,
}
local default_process_icon = nf.dev_terminal

-- タブ名は番号とプロセスのアイコンだけにする。プロセス名やパスが出ても識別に使えないため。
-- nvimはsmart-splits.nvimが立てるIS_NVIMで見る(プロセス名は親のpwshが返ることがあるため)。
local function tab_icon(pane)
	if pane.user_vars.IS_NVIM == "true" then
		return process_icons.nvim
	end
	local name = (pane.foreground_process_name or ""):gsub(".*[/\\]", ""):gsub("%.exe$", ""):lower()
	return process_icons[name] or default_process_icon
end

wezterm.on("format-tab-title", function(tab)
	local zoomed = tab.active_pane.is_zoomed and " " .. nf.md_magnify or ""
	local label = " " .. tostring(tab.tab_index + 1) .. "  " .. tab_icon(tab.active_pane) .. zoomed .. " "
	if not tab.is_active then
		return " " .. label .. " "
	end
	return {
		{ Background = { Color = tab_colors.bar } },
		{ Foreground = { Color = tab_colors.active } },
		{ Text = nf.ple_left_half_circle_thick },
		{ Background = { Color = tab_colors.active } },
		{ Foreground = { Color = tab_colors.bar } },
		{ Text = label },
		{ Background = { Color = tab_colors.bar } },
		{ Foreground = { Color = tab_colors.active } },
		{ Text = nf.ple_right_half_circle_thick },
	}
end)

-- === その他 =========================================================
config.scrollback_lines = 10000
config.audible_bell = "Disabled"

-- === 透過トグル（Ctrl+Shift+O） =====================================
-- 押すたびに、うしろが透ける状態 ⇄ 通常(0.98) を切り替える。
wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.5 -- 透過時の不透明度（小さいほど透ける）
	else
		overrides.window_background_opacity = nil -- 上書きを外して既定(0.98)に戻す
	end
	window:set_config_overrides(overrides)
end)

-- === tmux風: リーダーキー + ペイン/ワークスペース =====================
-- tmuxの prefix に相当する「リーダーキー」を Ctrl+Space に設定。続けて下のキーを押す。
-- ※ 潰れる Ctrl+Space(PSReadLineの補完メニュー) は リーダー→Ctrl+Space で従来通り送れる。
config.leader = { key = "Space", mods = "CTRL" }

local act = wezterm.action

-- === 画像クイックビュー ================================================
-- 「すぐ見たい1枚」をF1一発でimgcat表示する。
-- 画像はマシンごとに置くものが変わる想定のため、dotfiles/wezterm/assets/ に置きつつ.gitignoreで
-- リポジトリには含めない。ファイルが存在しないマシンでもエラーにならないようにする。
local quickview_image = wezterm.home_dir .. "\\dotfiles\\wezterm\\assets\\F1.png"

-- === メモ ===========================================================
-- F2でペインのいるリポジトリのルート直下に置く。Gitに追跡させないよう ~/.config/git/ignore に載せている。
local memo_name = ".memo.md"

-- ペインの実カレントディレクトリをWindows形式で返す。
-- get_foreground_process_info() でOSに直接フォアグラウンドプロセスの実cwdを問い合わせる。
-- OSC7（oh-my-posh側で "pwd": "osc7" 有効化済み）だけに頼ると、WezTermがホスト名不一致等を理由に
-- cwd更新を無視し続け、常にペイン起動時の初期ディレクトリが返る不具合があったため、
-- get_foreground_process_infoを優先し、取得できない場合のみOSC7にフォールバックする。
local function pane_cwd(pane)
	local path

	-- 優先: OSに直接問い合わせるので常に正確（OSC7のホスト名検証などに影響されない）
	local proc = pane:get_foreground_process_info()
	if proc and proc.cwd then
		path = proc.cwd
	else
		-- フォールバック: OSC7経由。file_pathは "/C:/Users/..." 形式
		local cwd = pane:get_current_working_dir()
		if cwd then
			path = cwd.file_path
		end
	end

	if path then
		return (path:gsub("^/(%a:)", "%1"):gsub("/", "\\"))
	end
end

-- === smart-splits.nvim連携: Ctrl+hjklでnvimの分割とweztermのペインを継ぎ目なく移動 ===
-- nvim側がsmart-splits.nvimでユーザー変数 IS_NVIM を自動セット/解除してくれるので、
-- それを見て「nvim実行中ならキーをそのまま転送」「そうでなければweztermがペイン移動」を切り替える。
local function is_vim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				win:perform_action({ SendKey = { key = key, mods = "CTRL" } }, pane)
			else
				win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

config.keys = {
	-- Ctrl+hjkl: nvimの外ではweztermのペイン移動、nvimの中はnvim側(smart-splits.nvim)に委譲
	split_nav("h"),
	split_nav("j"),
	split_nav("k"),
	split_nav("l"),

	-- 透過トグル（既存）
	{ key = "O", mods = "CTRL|SHIFT", action = act.EmitEvent("toggle-opacity") },

	-- リーダー→Ctrl+Space で本来の Ctrl+Space を送る（PSReadLineの補完メニューなどを温存）
	{ key = "Space", mods = "LEADER|CTRL", action = act.SendKey({ key = "Space", mods = "CTRL" }) },

	-- --- ペイン分割（nvimの :vsplit / :split と同じ感覚）---
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) }, -- 左右に分割
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) }, -- 上下に分割

	-- --- ペイン移動（vim風 h/j/k/l）---
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- --- ペイン: ズーム(1画面に最大化) / クローズ ---
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

	-- --- ドメイン（WSL など）を fuzzy で選んで新規タブ ---
	-- WSL の distro は WezTerm が自動検出して "WSL:Ubuntu" のような名前で並ぶ。
	{ key = "d", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" }) },

	-- --- ワークスペース ---
	{ key = "w", mods = "LEADER", action = act.EmitEvent("workspace-launcher") }, -- 開く/切替を1つの一覧で

	-- --- Quick Select上書き（Ctrl+Shift+Space）---
	-- 常にコピーした上で、URLやWindowsのフルパス（コマンド出力等に出てくる本物のパス）なら追加で開く。
	-- ※ oh-my-poshのプロンプト自体は "style": "letter" で末尾以外のフォルダ名を1文字に省略表示するため
	--   （例: 深い階層だと "C/U/t/dotfiles" のようになる）、表示文字列からの復元は原理的に不可能。
	--   「今いるディレクトリを開く」はこのQuick Selectではなく下のLEADER+eで実カレントディレクトリを使う。
	{
		key = "Space",
		mods = "CTRL|SHIFT",
		action = act.QuickSelectArgs({
			patterns = {
				"https?://\\S+", -- URL
				"[A-Za-z]:\\\\[^\\s]+", -- Windowsパス (例: C:\path\to\file)
			},
			action = wezterm.action_callback(function(window, pane)
				local text = window:get_selection_text_for_pane(pane)
				window:copy_to_clipboard(text)

				if text:match("^https?://") then
					wezterm.open_with(text)
				elseif text:match("^[A-Za-z]:\\\\") then
					wezterm.background_child_process({ "explorer.exe", text })
				end
			end),
		}),
	},

	-- --- カレントディレクトリをエクスプローラで開く（LEADER + e）---
	{
		key = "e",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local path = pane_cwd(pane)
			if path then
				wezterm.background_child_process({ "explorer.exe", path })
			end
		end),
	},

	-- --- 画像を一発表示（F1）: F1.png を新規タブでimgcat表示 ---
	{
		key = "F1",
		mods = "NONE",
		action = act.SpawnCommandInNewTab({
			args = {
				"pwsh.exe",
				"-NoLogo",
				"-NoExit",
				"-Command",
				"if (Test-Path '"
					.. quickview_image
					.. "') { wezterm imgcat --width 100% '"
					.. quickview_image
					.. "' } else { Write-Host '画像が見つかりません: "
					.. quickview_image
					.. "' }",
			},
		}),
	},

	-- --- メモ（F2）: ペインのいるリポジトリのルート直下の .memo.md を新規タブのnvimで開く ---
	-- リポジトリの外ではホームディレクトリに置く。
	{
		key = "F2",
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local root = wezterm.home_dir
			local cwd = pane_cwd(pane)
			if cwd then
				local ok, stdout = wezterm.run_child_process({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
				if ok and stdout ~= "" then
					root = stdout:gsub("%s+$", ""):gsub("/", "\\")
				end
			end
			-- dotfiles配下のnvimディレクトリを実行ファイルと誤解決させないため拡張子まで書く
			window:perform_action(
				act.SpawnCommandInNewTab({ cwd = root, args = { "nvim.exe", root .. "\\" .. memo_name } }),
				pane
			)
		end),
	},
}

-- === ワークスペース: 開く/切替を1つの一覧に統合（Ctrl+Space → w）=====
-- 開いているものを上、ghqの未オープンリポジトリを下に並べる。ghqはPATHにある前提。

-- ghqのフルパスを namespace(github.com/owner など)とリポジトリ名に分ける
local function ghq_split(path)
	local segs = {}
	for seg in path:gmatch("[^/\\]+") do
		table.insert(segs, seg)
	end
	-- ghqルートより手前(ドライブレターなど)は表示に不要なので捨てる
	local root = 0
	for i, seg in ipairs(segs) do
		if seg == "ghq" then
			root = i
		end
	end
	local repo = table.remove(segs)
	return table.concat(segs, "/", root + 1), repo
end

wezterm.on("workspace-launcher", function(window, pane)
	local active = window:active_workspace()
	local choices, open = {}, {}

	for _, name in ipairs(wezterm.mux.get_workspace_names()) do
		open[name] = true
		table.insert(choices, { id = "ws\t" .. name, label = (name == active and "● " or "○ ") .. name })
	end

	local ok, stdout = wezterm.run_child_process({ "ghq", "list", "--full-path" })
	if ok then
		local repos, basename_count = {}, {}
		for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
			local full = path:gsub("%s+$", "") -- 末尾の空白/CRを除去
			if full ~= "" then
				local ns, repo = ghq_split(full)
				basename_count[repo] = (basename_count[repo] or 0) + 1
				table.insert(repos, { path = full, repo = repo, ns = ns })
			end
		end
		for _, r in ipairs(repos) do
			-- 同名リポジトリが複数あるときだけ owner/repo にして名前の衝突を避ける
			local name = r.repo
			if basename_count[r.repo] > 1 then
				name = r.ns:gsub(".*/", "") .. "/" .. r.repo
			end
			if not open[name] then
				table.insert(choices, {
					id = "new\t" .. name .. "\t" .. r.path,
					label = "  " .. r.repo .. "  " .. r.ns,
				})
			end
		end
	end

	window:perform_action(
		act.InputSelector({
			title = "ワークスペース",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end
				local kind, rest = id:match("^(%a+)\t(.*)$")
				if kind == "ws" then
					win:perform_action(act.SwitchToWorkspace({ name = rest }), p)
				else
					local name, cwd = rest:match("^(.-)\t(.*)$")
					win:perform_action(act.SwitchToWorkspace({ name = name, spawn = { cwd = cwd } }), p)
				end
			end),
		}),
		pane
	)
end)

-- === 起動時の定位置: dotfilesシェル ================================
-- defaultワークスペースに置く。リポジトリを開く前の起点をここが兼ねる。
wezterm.on("gui-startup", function(cmd)
	-- gui-startupを定義するとコマンドライン指定は無視されるため、cmdがあれば明示的に開く。
	-- エクスプローラの右クリックからnvimを開くのがこの経路。
	if cmd then
		wezterm.mux.spawn_window(cmd)
		return
	end

	wezterm.mux.spawn_window({
		cwd = wezterm.home_dir .. "\\dotfiles",
		args = { "pwsh.exe", "-NoLogo" },
	})
end)

return config
