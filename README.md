# dotfiles

Cross-platform (macOS + Linux) dev environment, managed with Nix + home-manager.
Covers the shell, editors, terminal, window manager **and** the AI-coding
toolchain (Claude Code, herdr, rtk).

## Setup

The whole environment installs with **one command** on a fresh machine. Clone to
`~/dotfiles` — the path matters, because every config file is symlinked out of
this checkout:

```sh
git clone https://github.com/aightmunam/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

`make install` runs three steps (each also available on its own):

1. **`make setup`** — installs Nix with flakes enabled, if it is missing.
2. **`make build`** — applies the home-manager config, auto-selecting the system
   (`aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`) from
   `uname`.
3. **`make post-install`** — the non-Nix bits: `rtk` (its official installer),
   the global npm package the Claude hooks need (`rins_hooks`), `headroom` (via
   `pipx`), the **Gemini CLI** (`npm`, into `~/.local`) and **Codex CLI** (its
   standalone installer, which self-updates), the installable agent skills (`npx
   skills`), the tool-managed and upstream Claude hooks, the cross-tool wiring
   (Gemini/Codex instruction + skills symlinks and MCP fan-out via `generate.sh`),
   and a scaffolded `~/.zshenv.local` for secrets.

### macOS

```sh
# 1. Command line tools (gives you git + a compiler toolchain)
xcode-select --install

# 2. Clone and install
git clone https://github.com/aightmunam/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

- Nix installs multi-user via a launchd-managed daemon; the installer prompts for
  confirmation and your password.
- Nerd Fonts land in `~/Library/Fonts` automatically.
- The macOS-only pieces (AeroSpace, JankyBorders, Raycast scripts) are linked
  only on Darwin.
- Homebrew is **not** required — everything here is managed by Nix. `.zshrc`
  picks up an existing Homebrew if you have one, but nothing depends on it.

### Linux

```sh
# 1. Prerequisites (Debian/Ubuntu shown; use your distro's package manager)
sudo apt-get update && sudo apt-get install -y git curl xz-utils

# 2. Clone and install
git clone https://github.com/aightmunam/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

- Nix installs multi-user, which needs **systemd** (present on all mainstream
  desktop distros). A minimal/container environment without an init system needs
  a single-user install instead:
  `sh <(curl -L https://nixos.org/nix/install) --no-daemon`.
- The macOS-only packages are skipped automatically.
- The first build compiles **herdr** from source (its vendored Zig
  `libghostty-vt`), which is memory-hungry: give the machine or VM **at least
  ~4 GB of free RAM (8 GB is comfortable)**. A 2 GB environment OOM-kills the Zig
  build. Everything else comes prebuilt from the binary cache and is cheap.
- **rtk** ships a prebuilt Linux binary that needs **glibc ≥ 2.39** (Ubuntu
  24.04+, Debian 13+, Fedora 39+). On older distros it fails with a
  `GLIBC_2.39 not found` error; post-install keeps going (rtk is best-effort), but
  rtk's command-rewrite hook is skipped until you upgrade or build rtk from source.

### After setup (both platforms)

1. Fill in `~/.zshenv.local` with any machine-local secrets/overrides.
2. Restart your shell (`exec zsh`). To make zsh your login shell:
   `chsh -s "$(command -v zsh)"`.
3. Launch Claude Code once — it auto-installs its plugins from `settings.json`.

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
  `approvals`, `sentry`). Work-specific servers are kept out of this public repo;
  re-add any you need locally with `claude mcp add`.
- **Skills**: none are vendored — all are installed by `claude/install-skills.sh`
  (via `npx skills`), which `make install` runs automatically. Edit that script's
  list to add or remove skills.
- **Excluded skills**: some skills are work-specific or personal-confidential and
  are gitignored (this repo is public). They stay in your live `~/.claude`; keep
  them in a private repo if you want them reproduced across machines.
- **Hooks**: only genuinely custom hooks (6) in `claude/hooks/` are versioned
  (`no-claude-attribution`, `dj`, `auto-commit-wrapper`, `api-error-alert`,
  `guard-test-required`, `guard-thoughts`). Everything else is restored by
  `claude/install-hooks.sh` (run by `make install`), not tracked:
  `rtk-rewrite.sh` / `herdr-agent-state.sh` from their own tools (`rtk init` /
  `herdr integration install claude`); and upstream safety hooks fetched pinned
  from [`yurukusa/claude-code-hooks`](https://github.com/yurukusa/claude-code-hooks)
  (12) and [`yurukusa/cc-safe-setup`](https://github.com/yurukusa/cc-safe-setup) (20).
