# dotfiles

My development environment for macOS and Linux. Nix and home-manager install the
packages and link each config file from this checkout into `$HOME`. The config
covers zsh, git, tmux, Vim, Neovim, WezTerm, AeroSpace (macOS), herdr, and one
shared AI setup for Claude Code, Gemini CLI, and Codex CLI.

## Set up a new machine

You can clone the repo to any path. The steps use `~/dotfiles`. Each link
points at the checkout that `make build` runs in. To move the checkout, run
`make build` in the new place.

1. Install the prerequisites.
   - macOS: `xcode-select --install`
   - Debian or Ubuntu: `sudo apt-get update && sudo apt-get install -y git make curl xz-utils`
   - Arch Linux or CachyOS: `sudo pacman -Syu --needed git make curl xz zsh`
2. Clone the repo and run the install:

   ```sh
   git clone https://github.com/aightmunam/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   make install
   ```

   If `make install` stops after the Nix install because `nix` is not found,
   open a new shell and run `make install` again.
3. Put your machine-local secrets in `~/.zshenv.local`. See
   [Keep secrets out of the repo](#keep-secrets-out-of-the-repo).
4. Start a new shell with `exec zsh`. To make zsh your login shell, run
   `chsh -s "$(command -v zsh)"`. `chsh` accepts only a shell that
   `/etc/shells` lists. If `chsh` rejects the Nix zsh, use the distro zsh:
   `chsh -s /usr/bin/zsh`.
5. Start Claude Code one time. It installs the plugins that `enabledPlugins` in
   `~/.claude/settings.json` lists.
6. On Linux, install WezTerm from your distro (on Arch Linux or CachyOS, `sudo pacman -S wezterm`).
   The Nix build of WezTerm cannot find the GPU drivers on a Linux that is not
   NixOS.
7. To see the links and MCP servers of each AI tool, run `make verify-ai`.

`make install` installs no Claude Code binary. Install Claude Code on its own.

## Edit a config file

To change a config, edit the file in `~/dotfiles`. The change applies at once,
and `git status` shows it. Restart or reload the program if it reads its config
only at start.

To change which packages home-manager installs or which files it links, edit
`home-manager/modules/` and run `make build`.

To change a skill, an MCP server, or `ai/AGENTS.md`, edit the file under `ai/`.
Then run `bash ai/generate.sh` if you added a skill, changed a skill, or changed
an MCP server. Gemini slash commands are copies of the skill text, so they do
not see a skill edit until `generate.sh` writes them again.

`~/.claude/settings.json` is a copy, not a link, because Claude Code writes to
it while it runs. Edit that file for this machine. Edit
`ai/claude/settings.json` to change the template for a new machine.

## Keep secrets out of the repo

This repo is public.

- Put each secret in `~/.zshenv.local` as an `export` line. `~/.zshenv` sources
  that file. Git ignores it through the `*.local` pattern.
- To use a secret in an MCP server or in `~/.claude/settings.json`, write it as
  `${VAR}`. Claude Code reads the value from the environment.
- Put shell overrides in `~/.zshrc.local` and git overrides (for example your
  name and email) in `~/.gitconfig.local`.
- To keep work names (company, org aliases, services) on one machine, copy
  `ai/local.example/` to `ai/local/` and fill it in. Git ignores `ai/local/`.
  `ai/generate.sh` links it to `~/.agents/local`.
- To add a work MCP server, run `claude mcp add` on that machine. Do not add it
  to `ai/mcp/servers.json`.

## Update a pinned dependency

To update herdr:

1. Change the tag in `herdr.url` in `home-manager/flake.nix`.
2. In `home-manager/`, run `nix flake update herdr`.
3. Run `make build`.

To update the upstream Claude hooks, change `CCH_REF` or `CCS_REF` in
`ai/install-hooks.sh`, then run `bash ai/install-hooks.sh`.

## Reference

### Make targets

| Target | What it does |
|---|---|
| `make install` | Runs `setup`, `build`, and `post-install` in that order. |
| `make setup` | If `nix` is not on `PATH`, runs the Nix installer and adds `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf`. If Nix is there, it changes nothing. |
| `make build` | Runs `home-manager switch` with the flake in `home-manager/`. It picks `mynixos-<arch>-<os>` from `uname`. A file that is in the way gets the `.backup` suffix. Then it runs `ai/generate.sh`. |
| `make post-install` | Installs the parts that Nix does not manage (see the next table). A failed step prints a warning, and the next step runs. |
| `make verify-ai` | Runs `ai/verify.sh`. It shows the instruction and skill links of each AI tool and the MCP servers that each tool has. |
| `make help` | Lists the targets. |

`make post-install` runs these steps in order:

| Step | Result |
|---|---|
| `pipx install headroom` | `headroom`, if it is missing |
| `npm install -g @google/gemini-cli` | Gemini CLI in `~/.local`, if it is missing |
| the Codex install script | Codex CLI in `~/.local/bin`, if it is missing |
| `bash ai/install-hooks.sh` | the Claude hooks that git does not track |
| `bash ai/generate.sh` | the links and MCP servers of each AI tool |
| copy `ai/claude/settings.json` | `~/.claude/settings.json`, if it is missing |
| copy `zshenv.local.example` | `~/.zshenv.local`, if it is missing |

### Links

Each module in `home-manager/modules/` lists its packages and its links.

| Repo path | Link in `$HOME` | Module |
|---|---|---|
| `.zshrc`, `.zshenv`, `.zsh_functions`, `.zsh_prompt`, `.dircolors` | same name | `core-cli.nix` |
| `atuin/config.toml` | `.config/atuin/config.toml` | `core-cli.nix` |
| `git/.gitconfig`, `git/.gitignore_global` | same name | `git.nix` |
| `tmux/.tmux.conf`, `.vimrc` | same name | `terminal.nix` |
| `nvim/` | `.config/nvim` | `terminal.nix` |
| `wezterm/` | `.config/wezterm` | `terminal.nix` |
| `aerospace/` | `.config/aerospace` (macOS) | `darwin.nix` |
| `raycast-scripts/` | `raycast-scripts` (macOS) | `darwin.nix` |
| `herdr/config.toml` | `.config/herdr/config.toml` | `ai.nix` |
| `herdr/herdr-bar.json` | `.config/herdr/plugins/config/herdr-bar/config.json` | `ai.nix` |
| `nix/` | `.config/nix` | `home.nix` |
| `home-manager/` | `.config/home-manager` | `home.nix` |

On macOS, `darwin.nix` also installs `aerospace`, `jankyborders`,
`reattach-to-user-namespace`, and Raycast. On Linux, `terminal.nix` adds
`wl-clipboard` and leaves out WezTerm, and `home.nix` turns on fontconfig.

These paths are in the repo, but no module links them: `hypr/`, `hyprland/`,
`vim/`, `setup.sh` (an older install script), and `home-manager/darwin.nix` (an
old nix-darwin test).

### AI toolchain

`ai/AGENTS.md` is the one instruction file for all three AI tools.

| Source in `ai/` | Link | Made by |
|---|---|---|
| `AGENTS.md` | `~/.claude/AGENTS.md` | `ai.nix` |
| `AGENTS.md` | `~/.gemini/GEMINI.md`, `~/.codex/AGENTS.md` | `generate.sh` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | `ai.nix` |
| `agents/` | `~/.claude/agents` | `ai.nix` |
| `claude/hooks/` | `~/.claude/hooks` | `ai.nix` |
| `claude/output-styles/` | `~/.claude/output-styles` | `ai.nix` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` | `ai.nix` |
| each skill in `skills/` | `~/.agents/skills/<name>` | `generate.sh` |
| `principles/`, `test-cards/`, `local/` | `~/.agents/principles`, `~/.agents/test-cards`, `~/.agents/local` | `generate.sh` |
| `bin/` | `~/.agents/bin` | `generate.sh` |

`~/.agents/skills` is the shared skill store. `ai.nix` links `~/.claude/skills`
to it. `generate.sh` links each store skill into `~/.gemini/skills` and
`~/.codex/skills`, and writes one Gemini slash command for each skill into
`~/.gemini/commands/`.

`ai/mcp/servers.json` lists the MCP servers. `generate.sh` adds each one to
Claude Code, Gemini CLI, and Codex CLI with the `mcp add` command of that tool.
You can run `generate.sh` again with no harm.

Git tracks only the hooks that I wrote. To list them, run
`git ls-files ai/claude/hooks`. `ai/install-hooks.sh` adds the other hooks to
the same directory, and `ai/claude/.gitignore` keeps them out of git:

- `herdr-agent-state.sh`, from `herdr integration install claude`
- safety hooks from
  [yurukusa/claude-code-hooks](https://github.com/yurukusa/claude-code-hooks)
  and [yurukusa/cc-safe-setup](https://github.com/yurukusa/cc-safe-setup), at
  the commits in `CCH_REF` and `CCS_REF`

`ai/bin/` holds helper tools. `pressure-run` and `routing-eval` test the skills
under Claude Code and Codex. `plan-lint` checks plan files. `migration-drift`
compares the Alembic heads of a repo with staging. Skills call them through
`~/.agents/bin`. `rig` starts and drives local scratch apps from private
configuration. `rewrite-refs` updates file references from a TSV map. Their tests
are in `ai/tests/`. Run them with
`uvx pytest -q ai/tests`. `ai/sources.lock` pins the upstream skill repos that
some skills adapt.
