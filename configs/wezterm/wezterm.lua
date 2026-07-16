-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 12
-- config.window_frame.font_size = 13
config.window_background_opacity = 1.0
config.macos_window_background_blur = 50
-- config.font = wezterm.font 'Hack Nerd Font'

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


-- Finally, return the configuration to wezterm:
return config
