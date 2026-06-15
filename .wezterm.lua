-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Create config
local config = wezterm.config_builder()

-- Customize Catppuccin Mocha
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"
custom.tab_bar.background = "#040404"
custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
custom.tab_bar.new_tab.bg_color = "#080808"

-- confi

config.color_schemes = {
	["OLEDppuccin"] = custom,
}

config.color_scheme = "OLEDppuccin"
config.font_size = 12

config.window_padding = {
	-- left = 0,
	-- right = 0,
	-- top = "1cell",
	bottom = 0,
}
-- Hide title bar
config.window_decorations = "NONE"
-- config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.enable_scroll_bar = false
config.enable_tab_bar = false

--- Fonts
-- config.font = wezterm.font("Fira Code", {weight="Bold", stretch="Normal", style="Normal"})
-- config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium", stretch = "Normal", style = "Normal" })
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "DemiBold", stretch = "Normal", style = "Normal" })

config.enable_kitty_keyboard = false
config.enable_csi_u_key_encoding = false

config.debug_key_events = true

return config
