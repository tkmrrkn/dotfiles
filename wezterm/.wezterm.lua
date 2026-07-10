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

config.keys = {
  {
    key = 'O',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.EmitEvent 'toggle-opacity',
  },
}

return config
