local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Theme
config.color_scheme = "Catppuccin Mocha"

-- Font
config.font = wezterm.font("FiraCode Nerd Font", { weight = "DemiBold" })
config.font_size = 16
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- Window
config.window_padding = { left = 12, right = 12, top = 8, bottom = 8 }
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_close_confirmation = "NeverPrompt"

-- macOS
config.send_composed_key_when_right_alt_is_pressed = false

-- Cursor
config.default_cursor_style = "SteadyBlock"

-- Tabs
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Mouse
config.mouse_bindings = {
  -- Copy on select to clipboard (like Ghostty copy-on-select = clipboard)
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
  },
}

-- Keys
config.keys = {
  -- Clear scrollback (Cmd+K, like Ghostty default)
  {
    key = "k",
    mods = "SUPER",
    action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
  },
  -- Split pane right (Cmd+D, like Ghostty)
  {
    key = "d",
    mods = "SUPER",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- Split pane down (Cmd+Shift+D)
  {
    key = "D",
    mods = "SUPER|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- Navigate panes (Cmd+Shift+Arrow, like Ghostty)
  {
    key = "LeftArrow",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Left"),
  },
  {
    key = "RightArrow",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Right"),
  },
  {
    key = "UpArrow",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Up"),
  },
  {
    key = "DownArrow",
    mods = "SUPER|SHIFT",
    action = wezterm.action.ActivatePaneDirection("Down"),
  },
  -- Rename tab (Cmd+Shift+E)
  {
    key = "E",
    mods = "SUPER|SHIFT",
    action = wezterm.action.PromptInputLine({
      description = "Enter new tab title",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

return config
