# dotfiles

Cross-platform (macOS + Linux) dev environment, managed with Nix + home-manager.
Covers the shell, editors, terminal, window manager **and** the AI-coding
toolchain (Claude Code, herdr, rtk).

## One-command setup

On a fresh machine:

```sh
# 1. Prerequisites: git, and on macOS the Xcode command line tools
#    (macOS)  xcode-select --install
# 2. Clone to ~/dotfiles (the path matters — config is symlinked from here)
git clone https://github.com/aightmunam/dotfiles.git ~/dotfiles
cd ~/dotfiles
# 3. Stand everything up
make install
```

`make install` will:

1. Install Nix (with flakes) if it is missing.
2. Apply the home-manager config for this machine — it auto-selects the right
   system (`aarch64-darwin`, `x86_64-linux`, `aarch64-linux`, ...) from `uname`.
3. Run the non-Nix post-install: `rtk` (its official installer), the global npm
   packages the Claude hooks need (`rins_hooks`, `@agentmemory/agentmemory`),
   `headroom` (via `pipx`), and scaffold `~/.zshenv.local` for secrets.

Then: fill in `~/.zshenv.local`, restart your shell, and launch Claude Code once
(it auto-installs its plugins from `settings.json`).

Other targets: `make setup`, `make build`, `make post-install`, `make help`.

## What is managed

| Area | Where |
|---|---|
| Shell (zsh), git, tmux, vim/nvim, wezterm | `.*`, `nvim/`, `tmux/`, `wezterm/`, `git/` |
| Window manager (macOS) | `aerospace/` |
| Nix / home-manager | `home-manager/`, `nix/` |
| Claude Code (settings, skills, agents, commands, hooks, output-styles, rules) | `claude/` |
| herdr | `herdr/config.toml` |
| Packages + herdr | `home-manager/home.nix` (+ herdr flake input) |

## Live editing (no rebuild)

Config is linked with home-manager's `mkOutOfStoreSymlink`, so the symlinks in
`$HOME` point at this live checkout. **Editing any config file takes effect
immediately — no `make build` needed.** You only rebuild to change *which* files
are linked or *which* packages/programs are installed. Edits show up in
`git status` here.

## Secrets

Real secrets never live in this (public) repo. `settings.json` and other configs
reference `${VARS}`; the real values go in `~/.zshenv.local` (gitignored via
`*.local`, sourced by `~/.zshenv`). Copy `zshenv.local.example` to
`~/.zshenv.local` and fill it in (`make install` does this for you if it is
missing).

## Notes on the AI toolchain

- **herdr** is pinned via its own Nix flake (`home-manager/flake.nix`). Update it
  with `nix flake update herdr` after bumping the tag.
- **rtk** has no Nix flake, so it is installed by its own cross-platform script in
  `make post-install`. Re-running the script updates it.
- **MCP servers** are defined in `claude/settings.json` (generic tools only:
  `agentmemory`, `approvals`, `sentry`). Work-specific servers are kept out of
  this public repo; re-add any you need locally with `claude mcp add`.
- **Skills**: only custom, user-authored skills are versioned (currently
  `subagent-orchestrator`). Publicly available skills are not vendored — they are
  installed by `claude/install-skills.sh` (via `npx skills`), which `make install`
  runs automatically.
- **Excluded skills**: some skills are work-specific or personal-confidential and
  are gitignored (this repo is public). They stay in your live `~/.claude`; keep
  them in a private repo if you want them reproduced across machines.
- **Hooks**: your custom hooks in `claude/hooks/` are versioned. Hooks that come
  from elsewhere are not — `claude/install-hooks.sh` (run by `make install`)
  restores them: `rtk-rewrite.sh` / `herdr-agent-state.sh` from their own tools
  (`rtk init` / `herdr integration install claude`), and 12 upstream safety hooks
  from [`yurukusa/claude-code-hooks`](https://github.com/yurukusa/claude-code-hooks)
  (fetched pinned; used verbatim).
