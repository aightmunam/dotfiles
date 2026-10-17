local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config = {
	term = "wezterm",
	default_cursor_style = "SteadyBar",
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	adjust_window_size_when_changing_font_size = false,
	window_decorations = "RESIZE",
	check_for_updates = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	-- Type and spacing follow the Hairline tokens (~/Developer/design-system/systems/hairline)
	line_height = 1.15, -- --leading-tight
	font_size = 14, -- --text-md
	font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono", weight = "Regular" }, -- --font-mono, 400
		"Herdr Agent Icons Max", -- agent logos at U+E1A0-U+E1B7 for herdr-bar
	}),
	-- Hairline never goes above weight 500, so terminal bold renders as Medium
	font_rules = {
		{ intensity = "Bold", italic = false, font = wezterm.font_with_fallback({ { family = "JetBrains Mono", weight = "Medium" }, "Herdr Agent Icons Max" }) },
		{ intensity = "Bold", italic = true, font = wezterm.font_with_fallback({ { family = "JetBrains Mono", weight = "Medium", italic = true }, "Herdr Agent Icons Max" }) },
	},
	enable_tab_bar = false,
	window_padding = {
		left = 16, -- --space-4
		right = 16,
		top = 16,
		bottom = 16,
	},
	-- herdr reads these CSI-u sequences as ctrl+alt+<key>
	keys = {
		{ key = "k", mods = "CMD", action = wezterm.action.SendString("\x1b[107;7u") }, -- herdr-bar command bar
		{ key = "b", mods = "CMD", action = wezterm.action.SendString("\x1b[98;7u") }, -- herdr-projects work board
	},
	front_end = "WebGpu",
	max_fps = 120,
	-- from: https://akos.ma/blog/adopting-wezterm/
	hyperlink_rules = {
		-- Matches: a URL in parens: (URL)
		{
			regex = "\\((\\w+://\\S+)\\)",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in brackets: [URL]
		{
			regex = "\\[(\\w+://\\S+)\\]",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in curly braces: {URL}
		{
			regex = "\\{(\\w+://\\S+)\\}",
			format = "$1",
			highlight = 1,
		},
		-- Matches: a URL in angle brackets: <URL>
		{
			regex = "<(\\w+://\\S+)>",
			format = "$1",
			highlight = 1,
		},
		-- Then handle URLs not wrapped in brackets
		{
			-- Before
			--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
			--format = '$0',
			-- After
			regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
			format = "$1",
			highlight = 1,
		},
		-- implicit mailto link
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},
	},
}
return config
