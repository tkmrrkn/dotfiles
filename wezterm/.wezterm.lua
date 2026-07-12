-- 公式推奨のdotfile形式。編集して保存すると自動でリロードされる。

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- === シェル =========================================================
-- デフォルトを PowerShell 7 (pwsh) にする。-NoLogo で起動時の著作権表示を消す。
config.default_prog = { 'pwsh.exe', '-NoLogo' }

-- === 外観 ===========================================================
-- 同梱カラースキーム。kanagawa(nvim)のwaveに合わせる。
-- nvim側を transparent=true にしているので、nvimの背景はこのweztermの背景色が透けて見える。
-- dragon調にしたいなら 'Kanagawa Dragon (Gogh)' に変更。
config.color_scheme = 'Kanagawa (Gogh)'

-- フォント。JetBrainsMono Nerd Font（導入済み）。アイコンも綺麗に出る。
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 11.0

-- === ウィンドウ =====================================================
config.window_background_opacity = 0.98
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }
config.adjust_window_size_when_changing_font_size = false

-- === タブバー =======================================================
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false

-- === その他 =========================================================
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'

-- === 透過トグル（Ctrl+Shift+O） =====================================
-- 押すたびに、うしろが透ける状態 ⇄ 通常(0.98) を切り替える。
wezterm.on('toggle-opacity', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.5 -- 透過時の不透明度（小さいほど透ける）
  else
    overrides.window_background_opacity = nil  -- 上書きを外して既定(0.98)に戻す
  end
  window:set_config_overrides(overrides)
end)

-- === tmux風: リーダーキー + ペイン/ワークスペース =====================
-- tmuxの prefix に相当する「リーダーキー」を Ctrl+a に設定。Ctrl+a に続けて下のキーを押す。
-- ※ pwsh の Ctrl+a(行頭移動) が潰れるが、リーダー→Ctrl+a で従来通り送れるようにしてある。
config.leader = { key = 'a', mods = 'CTRL' }

local act = wezterm.action

-- === smart-splits.nvim連携: Ctrl+hjklでnvimの分割とweztermのペインを継ぎ目なく移動 ===
-- nvim側がsmart-splits.nvimでユーザー変数 IS_NVIM を自動セット/解除してくれるので、
-- それを見て「nvim実行中ならキーをそのまま転送」「そうでなければweztermがペイン移動」を切り替える。
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(key)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action({ SendKey = { key = key, mods = 'CTRL' } }, pane)
      else
        win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
      end
    end),
  }
end

config.keys = {
  -- Ctrl+hjkl: nvimの外ではweztermのペイン移動、nvimの中はnvim側(smart-splits.nvim)に委譲
  split_nav('h'),
  split_nav('j'),
  split_nav('k'),
  split_nav('l'),

  -- 透過トグル（既存）
  { key = 'O', mods = 'CTRL|SHIFT', action = act.EmitEvent 'toggle-opacity' },

  -- リーダー→Ctrl+a で本来の Ctrl+a を送る（pwshの行頭移動などを温存）
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },

  -- --- ペイン分割（nvimの :vsplit / :split と同じ感覚）---
  { key = 'v', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } }, -- 左右に分割
  { key = 's', mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } }, -- 上下に分割

  -- --- ペイン移動（vim風 h/j/k/l）---
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- --- ペイン: ズーム(1画面に最大化) / クローズ ---
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- --- ワークスペース ---
  { key = 'g', mods = 'LEADER', action = act.EmitEvent 'ghq-open-workspace' },                  -- ghqから開く
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } }, -- 開いている中から切替
}

-- === ghq: リポジトリを選んでワークスペースを開く（Ctrl+a → g）=========
-- ghq はPATHにある前提（PATH更新後にweztermを起動し直せば認識される）。
wezterm.on('ghq-open-workspace', function(window, pane)
  local ok, stdout = wezterm.run_child_process { 'ghq', 'list', '--full-path' }
  if not ok then return end
  local choices = {}
  for _, path in ipairs(wezterm.split_by_newlines(stdout)) do
    local p = path:gsub('%s+$', '') -- 末尾の空白/CRを除去
    if p ~= '' then
      table.insert(choices, { id = p, label = p:gsub('.*[/\\]', '') })
    end
  end
  window:perform_action(
    act.InputSelector {
      title = 'ghq: 開くリポジトリ',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, p, id, label)
        if id then
          win:perform_action(act.SwitchToWorkspace { name = label, spawn = { cwd = id } }, p)
        end
      end),
    }, pane)
end)

return config
