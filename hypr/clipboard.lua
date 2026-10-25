-- Mac-style Super+C / Super+V copy and paste in every app, terminal included.
-- Super+C sends Ctrl+Insert and Super+V sends Shift+Insert to the focused window:
-- GTK, Qt, Electron and browsers already treat those as copy/paste, and
-- wezterm/config.lua points them at the clipboard on Linux.
--
-- Load it last from ~/.config/hypr/hyprland.lua, so the unbinds below drop any
-- existing Super+C/V binds (unbind only removes binds registered before it):
--   ln -s ~/dotfiles/hypr/clipboard.lua ~/.config/hypr/dotfiles-clipboard.lua
--   require("dotfiles-clipboard")

-- unbind matches the key string case-sensitively, so cover the common spellings
for _, key in ipairs({ "SUPER + C", "SUPER + c", "SUPER + V", "SUPER + v" }) do
	hl.unbind(key)
end

hl.bind("SUPER + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind("SUPER + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
