local wezterm = require("wezterm")
local config = require("config")
require("events")

-- Apply color scheme based on the WEZTERM_THEME environment variable
local themes = {
	nord = "Nord (Gogh)",
	onedark = "One Dark (Gogh)",
}
local success, stdout, stderr = wezterm.run_child_process({ os.getenv("SHELL"), "-c", "printenv WEZTERM_THEME" })
local selected_theme = stdout:gsub("%s+", "") -- Remove all whitespace characters including newline

-- Default to Hairline Dark, matching herdr's theme (herdr can't follow a light switch here)
config.color_schemes = require("hairline")
config.color_scheme = themes[selected_theme] or "Hairline Dark"

return config
