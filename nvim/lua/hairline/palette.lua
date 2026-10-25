-- Hairline design system v1.5.0 (~/Developer/design-system/systems/hairline).
-- Comments name the source token. Kept in sync by hand with wezterm/hairline.lua
-- and herdr/config.toml.
local M = {}

M.dark = {
  bg = '#010120', -- --bg navy canvas
  raised = '#22223f', -- --raised
  sunken = '#0b0b2b', -- --sunken
  line = '#26263a', -- --line
  line_strong = '#4a4a63', -- --line-strong
  text = '#ffffff', -- --text
  muted = '#9a9ab0', -- --muted
  faint = '#6b6b85', -- --faint
  link = '#bdbbff', -- --link periwinkle
  focus = '#bdbbff', -- --focus
  critical = '#ff6b8b', -- --sev-critical
  high = '#fc6b33', -- --sev-high
  medium = '#f5b041', -- --sev-medium
  low = '#bdbbff', -- --sev-low
  ok = '#7fdc9a', -- --ok
  critical_soft = '#441d25', -- --sev-critical-soft
  high_soft = '#442013', -- --sev-high-soft
  medium_soft = '#3c2601', -- --sev-medium-soft
  low_soft = '#292648', -- --sev-low-soft
  ok_soft = '#0f341c', -- --ok-soft
  cat1 = '#aeacff', -- --cat-1
  cat2 = '#f58ad8', -- --cat-2
  cat3 = '#ff8e6f', -- --cat-3
  cat4 = '#6cc8f5', -- --cat-4
  cat5 = '#d496f9', -- --cat-5
  cat6 = '#5edadb', -- --cat-6
  -- ansi slots 0-15, copied from "Hairline Dark" in wezterm/hairline.lua
  terminal = {
    '#22223f',
    '#ff6b8b',
    '#7fdc9a',
    '#f5b041',
    '#aeacff',
    '#f58ad8',
    '#5edadb',
    '#9a9ab0',
    '#6b6b85',
    '#ff8e6f',
    '#7fdc9a',
    '#f5b041',
    '#6cc8f5',
    '#d496f9',
    '#5edadb',
    '#ffffff',
  },
}

M.light = {
  bg = '#ffffff',
  raised = '#f7f7f7',
  sunken = '#ebebeb',
  line = '#ebebeb',
  line_strong = '#d4d4d4',
  text = '#000000',
  muted = '#6b6b6b',
  faint = '#999999',
  link = '#5552d9',
  focus = '#000000',
  critical = '#d4183d',
  high = '#c73c00',
  medium = '#a15c00',
  low = '#5552d9',
  ok = '#227c45',
  critical_soft = '#ffebeb',
  high_soft = '#ffede5',
  medium_soft = '#ffefe0',
  low_soft = '#eef1ff',
  ok_soft = '#e5f8e9',
  cat1 = '#4643c9',
  cat2 = '#b0228a',
  cat3 = '#b23b19',
  cat4 = '#0a6c9e',
  cat5 = '#8d3cb6',
  cat6 = '#00787d',
  terminal = {
    '#000000',
    '#d4183d',
    '#227c45',
    '#a15c00',
    '#4643c9',
    '#b0228a',
    '#00787d',
    '#6b6b6b',
    '#999999',
    '#b23b19',
    '#227c45',
    '#a15c00',
    '#0a6c9e',
    '#8d3cb6',
    '#00787d',
    '#d4d4d4',
  },
}

-- Palette for the current 'background'.
function M.get()
  return vim.o.background == 'light' and M.light or M.dark
end

return M
