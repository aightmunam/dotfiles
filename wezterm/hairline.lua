-- Hairline design system v1.5.0 (~/Developer/design-system/systems/hairline).
-- Comments name the source token. Kept in sync by hand with herdr/config.toml.
return {
	["Hairline Dark"] = {
		foreground = "#ffffff", -- --text
		background = "#010120", -- --bg navy canvas
		cursor_bg = "#bdbbff", -- --focus periwinkle
		cursor_fg = "#010120",
		cursor_border = "#bdbbff",
		selection_bg = "#292648", -- --sev-low-soft
		selection_fg = "#ffffff",
		split = "#26263a", -- --line
		ansi = {
			"#22223f", -- --raised
			"#ff6b8b", -- --sev-critical
			"#7fdc9a", -- --ok
			"#f5b041", -- --sev-medium
			"#aeacff", -- --cat-1
			"#f58ad8", -- --cat-2
			"#5edadb", -- --cat-6
			"#9a9ab0", -- --muted
		},
		brights = {
			"#6b6b85", -- --faint
			"#ff8e6f", -- --cat-3
			"#7fdc9a",
			"#f5b041",
			"#6cc8f5", -- --cat-4
			"#d496f9", -- --cat-5
			"#5edadb",
			"#ffffff",
		},
	},
	["Hairline Light"] = {
		foreground = "#000000",
		background = "#ffffff",
		cursor_bg = "#000000",
		cursor_fg = "#ffffff",
		cursor_border = "#000000",
		selection_bg = "#eef1ff",
		selection_fg = "#000000",
		split = "#ebebeb",
		ansi = {
			"#000000",
			"#d4183d",
			"#227c45",
			"#a15c00",
			"#4643c9",
			"#b0228a",
			"#00787d",
			"#6b6b6b",
		},
		brights = {
			"#999999",
			"#b23b19",
			"#227c45",
			"#a15c00",
			"#0a6c9e",
			"#8d3cb6",
			"#00787d",
			"#d4d4d4",
		},
	},
}
