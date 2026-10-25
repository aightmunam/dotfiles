-- Mac-style copy and paste on the same physical key as the Mac, where Command sits
-- next to the spacebar (labelled Alt on a PC keyboard). Super keeps its normal binds.
-- Alt+C sends Ctrl+Insert and Alt+V sends Shift+Insert to the focused window:
-- GTK, Qt, Electron and browsers already treat those as copy/paste, and
-- wezterm/config.lua points them at the clipboard on Linux.
--
-- Load it from ~/.config/hypr/custom.lua (ML4W) or the end of hyprland.lua:
--   ln -s ~/dotfiles/hypr/clipboard.lua ~/.config/hypr/dotfiles-clipboard.lua
--   require("dotfiles-clipboard")

hl.bind("ALT + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind("ALT + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))

-- Clipboard history (ML4W's cliphist picker, also on Super+V)
local cliphist = os.getenv("HOME") .. "/.config/ml4w/scripts/ml4w-cliphist"
local f = io.open(cliphist, "r")
if f then
	f:close()
	hl.bind("SUPER + H", hl.dsp.exec_cmd(cliphist), { description = "Open clipboard manager" })
end
