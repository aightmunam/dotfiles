---
date: 2026-01-13T00:00:00-05:00
researcher: Claude
git_commit: cd804cd7a4c6adea1435d715fd6d8866a86d0e38
branch: master
repository: aightmunam/dotfiles
topic: "Neovim Keymaps Reference Guide"
tags: [research, codebase, keymaps, neovim, shortcuts]
status: complete
last_updated: 2026-01-13
last_updated_by: Claude
---

# Research: Neovim Keymaps Reference Guide

**Date**: 2026-01-13
**Researcher**: Claude
**Git Commit**: cd804cd7a4c6adea1435d715fd6d8866a86d0e38
**Branch**: master
**Repository**: aightmunam/dotfiles

## Research Question

Document all configured Neovim shortcuts with descriptions and examples, categorized by usage.

## Summary

The Neovim configuration uses **Space** as the leader key and defines shortcuts across multiple files: core keymaps (`lua/core/keymaps.lua`), LSP keymaps (`lua/core/lsp.lua`), and various plugin configurations. The keymaps are organized into logical categories below.

---

## 1. Basic File Operations

| Shortcut     | Mode   | Description                  | Example                                             |
| ------------ | ------ | ---------------------------- | --------------------------------------------------- |
| `<C-s>`      | Normal | Save file                    | Press `Ctrl+s` to save current buffer               |
| `<leader>sn` | Normal | Save without auto-formatting | Press `Space sn` to save without running formatters |
| `<C-q>`      | Normal | Quit file                    | Press `Ctrl+q` to close current window              |

**Source**: `lua/core/keymaps.lua:14-20`

---

## 2. Navigation & Scrolling

| Shortcut | Mode            | Description                       | Example                                                     |
| -------- | --------------- | --------------------------------- | ----------------------------------------------------------- |
| `<C-d>`  | Normal          | Scroll down half page and center  | Press `Ctrl+d` to scroll down, cursor stays centered        |
| `<C-u>`  | Normal          | Scroll up half page and center    | Press `Ctrl+u` to scroll up, cursor stays centered          |
| `n`      | Normal          | Next search result and center     | After `/search`, press `n` to jump to next match (centered) |
| `N`      | Normal          | Previous search result and center | Press `N` to jump to previous match (centered)              |
| `]]`     | Normal/Terminal | Jump to next reference (LSP)      | Press `]]` to go to next occurrence of word under cursor    |
| `[[`     | Normal/Terminal | Jump to previous reference (LSP)  | Press `[[` to go to previous occurrence                     |

**Source**: `lua/core/keymaps.lua:25-31`, `lua/plugins/snacks.lua:339-353`

---

## 3. Window Navigation (Tmux Integration)

| Shortcut    | Mode   | Description                        | Example                                        |
| ----------- | ------ | ---------------------------------- | ---------------------------------------------- |
| `<C-h>`     | Normal | Navigate to left window/tmux pane  | Press `Ctrl+h` to move focus left              |
| `<C-j>`     | Normal | Navigate to window/pane below      | Press `Ctrl+j` to move focus down              |
| `<C-k>`     | Normal | Navigate to window/pane above      | Press `Ctrl+k` to move focus up                |
| `<C-l>`     | Normal | Navigate to right window/tmux pane | Press `Ctrl+l` to move focus right             |
| `<C-a>`     | Normal | Navigate to last active pane       | Press `Ctrl+a` to return to last active window |
| `<C-Space>` | Normal | Navigate to next pane              | Press `Ctrl+Space` to cycle through panes      |

**Source**: `lua/plugins/misc.lua:111-125`

---

## 4. Window Management

| Shortcut     | Mode   | Description                 | Example                                            |
| ------------ | ------ | --------------------------- | -------------------------------------------------- |
| `<leader>=`  | Normal | Split window vertically     | Press `Space =` to create vertical split           |
| `<leader>-`  | Normal | Split window horizontally   | Press `Space -` to create horizontal split         |
| `<leader>se` | Normal | Equalize split sizes        | Press `Space se` to make all splits equal size     |
| `<leader>xs` | Normal | Close current split         | Press `Space xs` to close the current split window |
| `<Up>`       | Normal | Decrease window height by 5 | Press Up arrow to shrink window vertically         |
| `<Down>`     | Normal | Increase window height by 5 | Press Down arrow to expand window vertically       |
| `<Left>`     | Normal | Decrease window width by 5  | Press Left arrow to shrink window horizontally     |
| `<Right>`    | Normal | Increase window width by 5  | Press Right arrow to expand window horizontally    |

**Source**: `lua/core/keymaps.lua:33-48`

---

## 5. Buffer Management

| Shortcut     | Mode   | Description             | Example                                      |
| ------------ | ------ | ----------------------- | -------------------------------------------- |
| `<Tab>`      | Normal | Go to next buffer       | Press `Tab` to switch to next open file      |
| `<S-Tab>`    | Normal | Go to previous buffer   | Press `Shift+Tab` to switch to previous file |
| `<leader>b`  | Normal | Create new empty buffer | Press `Space b` to open a new blank buffer   |
| `<leader>x`  | Normal | Delete current buffer   | Press `Space x` to close current buffer      |
| `<leader>sb` | Normal | Open buffer picker      | Press `Space sb` to see list of open buffers |

**Source**: `lua/core/keymaps.lua:39-42`, `lua/plugins/snacks.lua:53-58, 289-294`

---

## 6. Tab Management

| Shortcut     | Mode   | Description        | Example                                    |
| ------------ | ------ | ------------------ | ------------------------------------------ |
| `<leader>to` | Normal | Open new tab       | Press `Space to` to create new tab         |
| `<leader>tx` | Normal | Close current tab  | Press `Space tx` to close the tab          |
| `<leader>tn` | Normal | Go to next tab     | Press `Space tn` to switch to next tab     |
| `<leader>tp` | Normal | Go to previous tab | Press `Space tp` to switch to previous tab |

**Source**: `lua/core/keymaps.lua:50-54`

---

## 7. File Explorer (mini.files)

| Shortcut     | Mode   | Description                                    | Example                                              |
| ------------ | ------ | ---------------------------------------------- | ---------------------------------------------------- |
| `<leader>ff` | Normal | Open file explorer at current file's directory | Press `Space ff` to browse files around current file |
| `\`          | Normal | Open file explorer at working directory        | Press `\` to browse from project root                |

**Source**: `lua/plugins/mini.lua:17-36`

---

## 8. Search & Pickers (Snacks)

### File Search

| Shortcut          | Mode   | Description                   | Example                                         |
| ----------------- | ------ | ----------------------------- | ----------------------------------------------- |
| `<leader><space>` | Normal | Smart file finder             | Press `Space Space` for intelligent file search |
| `<leader>sf`      | Normal | Find files (including hidden) | Press `Space sf` to search all files            |
| `<leader>sg`      | Normal | Find git-tracked files        | Press `Space sg` to search only git files       |
| `<leader>sr`      | Normal | Recent files                  | Press `Space sr` to see recently opened files   |
| `<leader>fc`      | Normal | Find config files             | Press `Space fc` to search nvim config          |
| `<leader>sp`      | Normal | Projects picker               | Press `Space sp` to browse projects             |

**Source**: `lua/plugins/snacks.lua:37-93`

### Content Search

| Shortcut     | Mode          | Description              | Example                                     |
| ------------ | ------------- | ------------------------ | ------------------------------------------- |
| `<leader>sg` | Normal        | Grep in files            | Press `Space sg` and type to search content |
| `<leader>sw` | Normal/Visual | Search word under cursor | Press `Space sw` to grep current word       |

**Source**: `lua/plugins/snacks.lua:144-158`

### Other Pickers

| Shortcut     | Mode   | Description        | Example                                 |
| ------------ | ------ | ------------------ | --------------------------------------- |
| `<leader>s"` | Normal | Registers picker   | Press `Space s"` to see vim registers   |
| `<leader>sc` | Normal | Command history    | Press `Space sc` to see recent commands |
| `<leader>sC` | Normal | Commands picker    | Press `Space sC` to browse all commands |
| `<leader>sh` | Normal | Help pages         | Press `Space sh` to search help docs    |
| `<leader>sk` | Normal | Keymaps picker     | Press `Space sk` to see all keymaps     |
| `<leader>sq` | Normal | Quickfix list      | Press `Space sq` to browse quickfix     |
| `<leader>sR` | Normal | Resume last picker | Press `Space sR` to reopen last search  |

**Source**: `lua/plugins/snacks.lua:159-222`

---

## 9. Git Operations

| Shortcut     | Mode          | Description                  | Example                                          |
| ------------ | ------------- | ---------------------------- | ------------------------------------------------ |
| `<leader>lg` | Normal        | Open Lazygit                 | Press `Space lg` to launch full git UI           |
| `<leader>gs` | Normal        | Git status picker            | Press `Space gs` to see changed files            |
| `<leader>gb` | Normal        | Git branches picker          | Press `Space gb` to switch branches              |
| `<leader>gl` | Normal        | Git log                      | Press `Space gl` to browse commit history        |
| `<leader>gL` | Normal        | Git log for current line     | Press `Space gL` to see commits for current line |
| `<leader>gf` | Normal        | Git log for current file     | Press `Space gf` to see file's commit history    |
| `<leader>gd` | Normal        | Git diff (hunks)             | Press `Space gd` to see changes                  |
| `<leader>gS` | Normal        | Git stash picker             | Press `Space gS` to manage stashes               |
| `<leader>gB` | Normal/Visual | Git browse (open in browser) | Press `Space gB` to open file on GitHub          |

**Source**: `lua/plugins/snacks.lua:94-143, 309-316, 317-323`

---

## 10. LSP Operations

### Navigation

| Shortcut | Mode   | Description           | Example                                            |
| -------- | ------ | --------------------- | -------------------------------------------------- |
| `gd`     | Normal | Go to definition      | Press `gd` on a function to jump to its definition |
| `gD`     | Normal | Go to declaration     | Press `gD` to see where symbol is declared         |
| `gr`     | Normal | Find references       | Press `gr` to see all usages of symbol             |
| `gI`     | Normal | Go to implementation  | Press `gI` on interface to see implementations     |
| `gy`     | Normal | Go to type definition | Press `gy` to see type of symbol                   |

**Source**: `lua/plugins/snacks.lua:223-259`

### Symbols & Actions

| Shortcut     | Mode   | Description              | Example                                           |
| ------------ | ------ | ------------------------ | ------------------------------------------------- |
| `K`          | Normal | Show hover documentation | Press `K` on symbol to see docs                   |
| `<leader>la` | Normal | Code action              | Press `Space la` to see available fixes/refactors |
| `<leader>lr` | Normal | Rename symbol            | Press `Space lr` to rename variable/function      |
| `<leader>ll` | Normal | Run CodeLens             | Press `Space ll` to execute codelens action       |
| `<leader>li` | Normal | LSP info                 | Press `Space li` to see attached LSP servers      |
| `<leader>ss` | Normal | LSP symbols (buffer)     | Press `Space ss` to browse symbols in file        |
| `<leader>sS` | Normal | LSP workspace symbols    | Press `Space sS` to search symbols across project |

**Source**: `lua/core/lsp.lua:53-58`, `lua/plugins/snacks.lua:260-273`

---

## 11. Diagnostics

| Shortcut     | Mode   | Description                 | Example                                            |
| ------------ | ------ | --------------------------- | -------------------------------------------------- |
| `<leader>dn` | Normal | Go to next diagnostic       | Press `Space dn` to jump to next error/warning     |
| `<leader>dp` | Normal | Go to previous diagnostic   | Press `Space dp` to jump to previous error/warning |
| `<leader>sd` | Normal | Diagnostics picker (all)    | Press `Space sd` to see all project diagnostics    |
| `<leader>sD` | Normal | Diagnostics picker (buffer) | Press `Space sD` to see current file diagnostics   |

**Source**: `lua/core/keymaps.lua:66-73`, `lua/plugins/snacks.lua:181-194`

---

## 12. Harpoon (Quick File Marks)

| Shortcut     | Mode   | Description                 | Example                                         |
| ------------ | ------ | --------------------------- | ----------------------------------------------- |
| `<leader>a`  | Normal | Add file to harpoon list    | Press `Space a` to bookmark current file        |
| `<leader>sm` | Normal | Toggle harpoon quick menu   | Press `Space sm` to see/edit bookmarks          |
| `<leader>hh` | Normal | Harpoon picker (Snacks)     | Press `Space hh` for picker with delete support |
| `<leader>hp` | Normal | Go to previous harpoon file | Press `Space hp` to cycle backwards             |
| `<leader>hn` | Normal | Go to next harpoon file     | Press `Space hn` to cycle forwards              |

**Note**: In the harpoon picker, press `dd` to delete an entry.

**Source**: `lua/plugins/harpoon.lua:33-68`

---

## 13. Session Management

| Shortcut     | Mode   | Description     | Example                                             |
| ------------ | ------ | --------------- | --------------------------------------------------- |
| `<leader>wr` | Normal | Search sessions | Press `Space wr` to find and restore a session      |
| `<leader>ws` | Normal | Save session    | Press `Space ws` to save current workspace          |
| `<leader>wa` | Normal | Toggle autosave | Press `Space wa` to toggle automatic session saving |

**Source**: `lua/plugins/auto_session.lua:4-9`

---

## 14. Formatting

| Shortcut     | Mode   | Description         | Example                                           |
| ------------ | ------ | ------------------- | ------------------------------------------------- |
| `<leader>lf` | Normal | Format current file | Press `Space lf` to format the buffer             |
| `<leader>lF` | Normal | Toggle auto-format  | Press `Space lF` to enable/disable format on save |

**Commands**: `:Format` - Manual format, `:FormatToggle` - Toggle autoformat

**Source**: `lua/plugins/conform.lua:107`, `lua/core/lsp.lua:54`

---

## 15. UI Toggles

| Shortcut     | Mode   | Description                  | Example                                       |
| ------------ | ------ | ---------------------------- | --------------------------------------------- |
| `<leader>lw` | Normal | Toggle line wrapping         | Press `Space lw` to wrap/unwrap long lines    |
| `<leader>uL` | Normal | Toggle relative line numbers | Press `Space uL` to switch number style       |
| `<leader>ul` | Normal | Toggle line numbers          | Press `Space ul` to show/hide line numbers    |
| `<leader>ud` | Normal | Toggle diagnostics           | Press `Space ud` to hide/show all diagnostics |
| `<leader>uh` | Normal | Toggle inlay hints           | Press `Space uh` to show/hide type hints      |
| `<leader>ug` | Normal | Toggle indent guides         | Press `Space ug` to show/hide indent lines    |
| `<leader>uD` | Normal | Toggle dim mode              | Press `Space uD` to dim inactive code         |

**Source**: `lua/core/keymaps.lua:56-57`, `lua/plugins/snacks.lua:377-382`

---

## 16. Notifications

| Shortcut     | Mode   | Description               | Example                                       |
| ------------ | ------ | ------------------------- | --------------------------------------------- |
| `<leader>n`  | Normal | Show notification history | Press `Space n` to see past notifications     |
| `<leader>sn` | Normal | Notification picker       | Press `Space sn` to browse notifications      |
| `<leader>un` | Normal | Dismiss all notifications | Press `Space un` to clear notification popups |

**Source**: `lua/plugins/snacks.lua:46-51, 296-301, 325-330`

---

## 17. Miscellaneous

| Shortcut     | Mode   | Description                 | Example                                         |
| ------------ | ------ | --------------------------- | ----------------------------------------------- |
| `<leader>.`  | Normal | Toggle scratch buffer       | Press `Space .` for quick notes/scratch pad     |
| `<leader>S`  | Normal | Select scratch buffer       | Press `Space S` to choose a scratch buffer      |
| `<leader>T`  | Normal | Toggle terminal             | Press `Space T` to open/close terminal          |
| `<leader>o`  | Normal | Open URL under cursor       | Press `Space o` to open link in browser         |
| `<leader>mp` | Normal | Toggle markdown preview     | Press `Space mp` to render/unrender markdown    |
| `<leader>cR` | Normal | Rename file                 | Press `Space cR` to rename current file         |
| `x`          | Normal | Delete char without yanking | Press `x` to delete without copying to register |

**Source**: `lua/plugins/snacks.lua:274-287, 331-337`, `lua/plugins/misc.lua:75-82, 105-108`

---

## 18. Visual Mode Specific

| Shortcut | Mode   | Description                         | Example                                                  |
| -------- | ------ | ----------------------------------- | -------------------------------------------------------- |
| `<`      | Visual | Indent left and keep selection      | Select text, press `<` to indent left                    |
| `>`      | Visual | Indent right and keep selection     | Select text, press `>` to indent right                   |
| `p`      | Visual | Paste without yanking replaced text | Select text and `p` to paste, original stays in register |

**Source**: `lua/core/keymaps.lua:59-64`

---

## 19. Snacks Input Window (Picker)

| Shortcut  | Mode          | Description         |
| --------- | ------------- | ------------------- |
| `<Esc>`   | Normal/Insert | Close picker        |
| `<Tab>`   | Normal/Insert | Scroll preview down |
| `<S-Tab>` | Normal/Insert | Scroll preview up   |

**Source**: `lua/plugins/snacks.lua:14-20`

---

## Quick Reference Card

### Most Used

- `Space Space` - Smart find files
- `Space sf` - Find all files
- `Space sg` - Grep in files
- `Space lg` - Open Lazygit
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover docs
- `Space la` - Code actions
- `Space x` - Close buffer
- `\` - File explorer

### Leader Key Groups

- `Space s*` - Search/pickers
- `Space g*` - Git operations
- `Space l*` - LSP/Language
- `Space u*` - UI toggles
- `Space t*` - Tab management
- `Space w*` - Session/workspace
- `Space h*` - Harpoon
- `Space d*` - Diagnostics

---

## Code References

- `lua/core/keymaps.lua` - Core navigation, buffers, windows, tabs
- `lua/core/lsp.lua:45-59` - LSP-specific keymaps (hover, code actions, rename)
- `lua/plugins/snacks.lua:36-354` - Search pickers, LSP navigation, git, utilities
- `lua/plugins/harpoon.lua:33-68` - Quick file bookmarking
- `lua/plugins/mini.lua:17-36` - File explorer shortcuts
- `lua/plugins/misc.lua:75-82, 111-125` - URL open, tmux navigation
- `lua/plugins/conform.lua:107` - Formatting keymap
- `lua/plugins/auto_session.lua:4-9` - Session management
