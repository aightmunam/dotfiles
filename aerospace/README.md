# AeroSpace Configuration Guide

AeroSpace is a tiling window manager for macOS, inspired by i3. This configuration provides vim-style navigation and workspace management.

## General Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `start-at-login` | `true` | AeroSpace starts automatically at login |
| `accordion-padding` | `100` | Padding size for accordion layout |
| `default-root-container-layout` | `tiles` | Windows tile by default |
| `default-root-container-orientation` | `auto` | Wide monitors = horizontal, tall monitors = vertical |
| `key-mapping.preset` | `qwerty` | Keyboard layout preset |

### Mouse Behavior

- Mouse follows focus when monitor changes (`monitor-lazy-center`)
- Mouse moves to window center on focus change (`window-lazy-center`)

### Window Borders

Active window borders are enabled via `borders` command on startup:
- Active: `#e1e3e4` (light gray)
- Inactive: `#494d64` (dark gray)
- Width: `5.0`

## Gaps Configuration

All gaps are set to `10` pixels:

```
inner.horizontal = 10
inner.vertical   = 10
outer.left       = 10
outer.bottom     = 10
outer.top        = 10
outer.right      = 10
```

## Keybindings

All keybindings use `alt` (Option) as the primary modifier.

### Window Focus (Vim-style)

| Keybinding | Action |
|------------|--------|
| `alt + h` | Focus left |
| `alt + j` | Focus down |
| `alt + k` | Focus up |
| `alt + l` | Focus right |

### Window Movement

| Keybinding | Action |
|------------|--------|
| `alt + shift + h` | Move window left |
| `alt + shift + j` | Move window down |
| `alt + shift + k` | Move window up |
| `alt + shift + l` | Move window right |

### Window Joining

| Keybinding | Action |
|------------|--------|
| `alt + shift + left` | Join with left |
| `alt + shift + down` | Join with down |
| `alt + shift + up` | Join with up |
| `alt + shift + right` | Join with right |

### Layout Control

| Keybinding | Action |
|------------|--------|
| `alt + /` | Toggle tiles horizontal/vertical |
| `alt + ,` | Toggle accordion horizontal/vertical |
| `alt + ctrl + f` | Toggle floating/tiling |
| `alt + ctrl + shift + f` | Toggle fullscreen |

### Window Management

| Keybinding | Action |
|------------|--------|
| `alt + x` | Close window |
| `alt + shift + q` | Close all windows but current |
| `alt + shift + -` | Resize smaller (-50) |
| `alt + shift + =` | Resize larger (+50) |

### Workspace Navigation

| Keybinding | Workspace |
|------------|-----------|
| `alt + 1` | Workspace 1 |
| `alt + 2` | Workspace 2 |
| `alt + 3` | Workspace 3 |
| `alt + 4` | Workspace 4 |
| `alt + 5` | Workspace 5 |
| `alt + c` | Code |
| `alt + b` | Browser |
| `alt + s` | Slack |
| `alt + m` | Mail |
| `alt + tab` | Switch to previous workspace |

### Move Window to Workspace

| Keybinding | Destination |
|------------|-------------|
| `alt + shift + 1` | Workspace 1 |
| `alt + shift + 2` | Workspace 2 |
| `alt + shift + 3` | Workspace 3 |
| `alt + shift + 4` | Workspace 4 |
| `alt + shift + c` | Code |
| `alt + shift + b` | Browser |
| `alt + shift + s` | Slack |
| `alt + shift + m` | Mail |
| `alt + shift + tab` | Move workspace to next monitor |

### Modes

| Keybinding | Mode |
|------------|------|
| `alt + shift + ;` | Service mode |
| `alt + shift + enter` | Apps mode |

#### Service Mode

| Key | Action |
|-----|--------|
| `esc` | Reload config, return to main |
| `r` | Reset layout (flatten workspace tree) |
| `f` | Toggle floating/tiling |
| `backspace` | Close all windows but current |

## Auto Window Rules

Applications are automatically assigned to workspaces or layouts:

| Application | Rule |
|-------------|------|
| Finder | Floating layout |
| Mail | Move to `Mail` workspace |
| Chrome | Move to `Browser` workspace |
| Firefox | Move to `Browser` workspace |
| Slack | Move to `Slack` workspace |
| WezTerm | Move to `Code` workspace |

## Monitor Assignment

Workspaces are assigned to monitors:

| Workspace | Monitor(s) |
|-----------|------------|
| 1, 2 | Main |
| 3, 4 | Secondary |
| 5 | Main or Secondary |
| Slack, Mail | Main |
| Code | Secondary (fallback: Main) |
| Browser | Main (fallback: Secondary) |

## Quick Reference

```
        Focus               Move                Join
          k                  K                   Up
          |                  |                   |
    h --- + --- l      H --- + --- L       Left--+--Right
          |                  |                   |
          j                  J                  Down

    (alt + key)        (alt + shift + key)   (alt + shift + arrow)
```
