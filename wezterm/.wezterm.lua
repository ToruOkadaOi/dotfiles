local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- left option key behaviour
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- KEYBINDINGS

config.keys = {

--launcher menu
  { key = 'l', mods = 'CMD', action = wezterm.action.ShowLauncher },

-- cmd + 5 = split horizontally
{
  key = '5',
  mods = 'CMD',
  action = wezterm.action.SplitHorizontal {
    domain = 'CurrentPaneDomain',
  },
},

-- cmd + 6 = split vertically (top/bottom)
{
  key = '6',
  mods = 'CMD',
  action = wezterm.action.SplitVertical {
    domain = 'CurrentPaneDomain',
  },
},

-- cmd + shift + w

  {
    key = 'w',
    mods = 'CMD|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

-- cmd + 9; 
-- activate pane selection mode with numeric labels
  {
    key = '9',
    mods = 'CMD',
    action = wezterm.action.PaneSelect {
      alphabet = '1234567890',
    },
  },

-- prompt inline for renaming tabs,panes & windows # TODO
  
}

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 10

config.color_scheme = 'Dracula'

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