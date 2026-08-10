-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local target = wezterm.target_triple or ''
local is_windows = target:find('windows') ~= nil
local is_macos = target:find('apple') ~= nil

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 12
-- config.window_frame.font_size = 13
config.window_background_opacity = 1.0
if is_macos then
  config.macos_window_background_blur = 50
end
if is_windows then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }

  -- Wispr Flow inserts dictation by simulating Ctrl+V. Handle that shortcut
  -- in WezTerm so terminal apps receive a normal text paste instead of the
  -- raw key chord (which Codex reserves for attaching clipboard images).
  config.keys = {
    {
      key = 'v',
      mods = 'CTRL',
      action = wezterm.action.PasteFrom 'Clipboard',
    },
  }

  -- Use hinted, LCD subpixel rendering for crisper text on Windows.
  config.freetype_load_flags = 'DEFAULT'
  config.freetype_load_target = 'Normal'
  config.freetype_render_target = 'HorizontalLcd'
end
-- IosevkaTerm Nerd Font is the Nerd Fonts family name; WezTerm falls back
-- cleanly until the optional font is installed.
config.font = wezterm.font_with_fallback { 'IosevkaTerm NF', 'Iosevka Term', 'Consolas' }

config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false

config.color_scheme = 'Black Metal (Gorgoroth) (base16)'
-- config.font = wezterm.font 'JetBrains Mono'


config.max_fps = 120

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
  left = 40,
  right = 40,
  top = 80,
  bottom = 80,
}

-- No title bar (window_decorations = "RESIZE"), so give ourselves a drag handle:
-- hold Win (Cmd on macOS) and drag anywhere in the terminal to move the window.
config.mouse_bindings = {
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.StartWindowDrag,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.Nop,
  },
}


-- Finally, return the configuration to wezterm:
return config
