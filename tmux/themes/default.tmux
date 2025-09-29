#!/usr/bin/env bash
# --- General Styles ---
set -g mode-style "fg=#F08B51,bg=#7C6F68" # selection mode
set -g message-style "fg=#F08B51,bg=#7C6F68"
set -g message-command-style "fg=#F08B51,bg=#7C6F68"

set -g pane-border-style "fg=#7C6F68"        # inactive border
set -g pane-active-border-style "fg=#F08B51" # active border

# --- Status Bar ---
set -g status "on"
set -g status-justify "left"
set -g status-style "fg=#DEE8CE,bg=#1E1A17"

set -g status-left-length "100"
set -g status-right-length "100"
set -g status-left-style NONE
set -g status-right-style NONE

# --- Status Left/Right ---
set -g status-left "#[fg=#1E1A17,bg=#BB6653,bold] #S #[fg=#F08B51,bg=#1E1A17,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#FFF8E8,bg=#1E1A17] #[fg=#F08B51] #{prefix_highlight} #[fg=#7C6F68] %d-%m-%Y #[fg=#1E1A17,bg=#DEE8CE] %H:%M #[fg=#1E1A17,bg=#F08B51,bold] #h "

# --- Window Tabs ---
setw -g window-status-activity-style "fg=#D94F2A,bg=#1E1A17"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#DEE8CE,bg=#1E1A17"

setw -g window-status-format "#[fg=#7C6F68] #[bg=#1E1A17,fg=#F08B51] #I ❯#{?window_zoomed_flag,#[fg=#8FA76F]❯,}#[fg=#F08B51,bold] #W #{?window_zoomed_flag,#[fg=#8FA76F]❮,} #[fg=#7C6F68]"
setw -g window-status-current-format "#[fg=#1E1A17] #[bg=#BB6653,fg=#FFF8E8] #I ❯#{?window_zoomed_flag,#[fg=#8FA76F]❯,}#[fg=#FFF8E8,bold] #W #{?window_zoomed_flag,#[fg=#8FA76F]❮,} #[fg=#1E1A17]"

# --- Prefix Highlight (tmux-plugins/tmux-prefix-highlight) ---
set -g @prefix_highlight_output_prefix "#[fg=#D94F2A]#[bg=#1E1A17] #[fg=#1E1A17]#[bg=#D94F2A]"
set -g @prefix_highlight_output_suffix " "
