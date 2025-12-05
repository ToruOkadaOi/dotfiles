local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- left option key behaviour
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 10

config.color_scheme = 'AtelierSulphurpool'

config.window_background_opacity = 0.95

config.enable_scroll_bar = true

config.enable_tab_bar = true

config.use_fancy_tab_bar = true

config.window_close_confirmation = 'AlwaysPrompt'

config.window_frame = {
  font = require('wezterm').font 'Jet Brains Mono',
  font_size = 12,
}

return config