.PHONY: setup build install post-install verify-ai help

# --- Select the home-manager configuration for this machine --------------------
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_S),Darwin)
  ifeq ($(UNAME_M),arm64)
    HM_CONFIG := mynixos-aarch64-darwin
  else
    HM_CONFIG := mynixos-x86_64-darwin
  endif
else
  ifeq ($(UNAME_M),x86_64)
    HM_CONFIG := mynixos-x86_64-linux
  else
    HM_CONFIG := mynixos-aarch64-linux
  endif
endif

help:
	@echo "make install   - one-shot: Nix + home-manager + post-install (recommended)"
	@echo "make setup     - install Nix with flakes support (if missing)"
	@echo "make build     - apply the home-manager config for this machine ($(HM_CONFIG))"
	@echo "make post-install - install non-Nix bits (rtk, headroom, gemini, codex, npm hook deps) + scaffold secrets"
	@echo "make verify-ai - check Gemini/Codex instruction+skills symlinks and MCP wiring"

# One command to stand the whole environment up on a fresh machine.
install: setup build post-install
	@echo ""
	@echo "Done. Next steps:"
	@echo "  1. Fill in ~/.zshenv.local with any machine-local secrets/overrides."
	@echo "  2. Restart your shell (or: exec zsh)."
	@echo "  3. Launch Claude Code once; it auto-installs plugins from settings.json."

setup:
	@if command -v nix >/dev/null 2>&1; then \
		echo "✅ Nix is already installed."; \
	else \
		echo "Nix not found. Proceeding with installation..."; \
		curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install -o /tmp/install-nix.sh; \
		echo "-> Running installer script (it will prompt for confirmation and your sudo password)..."; \
		sh /tmp/install-nix.sh; \
		rm /tmp/install-nix.sh; \
		echo "\n✅ Nix installation script finished."; \
		mkdir -p ~/.config/nix; \
		grep -qxF 'experimental-features = nix-command flakes' ~/.config/nix/nix.conf || \
			echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf; \
		echo "✅ Nix configured with flakes support."; \
	fi

build:
	@command -v nix >/dev/null 2>&1 || { \
		echo "❌ Nix is not installed."; \
		echo "Run make setup"; \
		exit 1; \
	}
	@echo "-> Applying home-manager config: $(HM_CONFIG)"
	NIXPKGS_ALLOW_UNFREE=1 nix run home-manager -- switch --flake ./home-manager#$(HM_CONFIG) --impure -b backup

# Non-Nix pieces of the AI toolchain. Best-effort: a failure here never aborts the
# whole setup, it just prints a warning to resolve manually.
post-install:
	@export PATH="$$HOME/.nix-profile/bin:$$HOME/.local/bin:$$PATH"; \
	ok(){ echo "   ✓ $$1"; }; skip(){ echo "   • $$1"; }; warn(){ echo "   ⚠️  $$1"; }; \
	echo "==> post-install: non-Nix tools, skills, hooks, cross-tool wiring"; \
	echo "-> rtk (token-optimizing CLI proxy)"; \
	if command -v rtk >/dev/null 2>&1; then skip "already installed ($$(rtk --version 2>/dev/null | head -1))"; \
	elif curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh; then ok "installed"; \
	else warn "install failed — see https://www.rtk-ai.app/"; fi; \
	echo "-> rins_hooks (npm global used by Claude hooks)"; \
	mkdir -p "$$HOME/.claude/npm"; \
	if npm install -g rins_hooks --prefix "$$HOME/.claude/npm" >/dev/null 2>&1; then ok "installed/updated in ~/.claude/npm"; else warn "'npm install -g rins_hooks' failed — run manually"; fi; \
	echo "-> headroom MCP (pipx)"; \
	if command -v headroom >/dev/null 2>&1; then skip "already installed"; \
	elif pipx install headroom >/dev/null 2>&1; then ok "installed"; \
	else warn "'pipx install headroom' failed — confirm the package name and install manually"; fi; \
	echo "-> Gemini CLI (npm --prefix ~/.local; nix's global npm prefix is read-only)"; \
	if command -v gemini >/dev/null 2>&1; then skip "already installed ($$(gemini --version 2>/dev/null | head -1))"; \
	elif npm install -g @google/gemini-cli --prefix "$$HOME/.local" >/dev/null 2>&1; then ok "installed to ~/.local/bin"; \
	else warn "gemini install failed — run: npm install -g @google/gemini-cli --prefix ~/.local"; fi; \
	echo "-> Codex CLI (official standalone installer; self-updating)"; \
	if command -v codex >/dev/null 2>&1; then skip "already installed ($$(codex --version 2>/dev/null | head -1))"; \
	elif curl -fsSL https://chatgpt.com/codex/install.sh | sh; then ok "installed to ~/.local/bin"; \
	else warn "codex install failed — see https://github.com/openai/codex"; fi; \
	echo "-> agent skills (npx skills into ~/.agents/skills)"; \
	bash ai/install-skills.sh || warn "some skills failed — re-run: bash ai/install-skills.sh"; \
	echo "-> Claude hooks (tool-managed + pinned upstream)"; \
	bash ai/install-hooks.sh || warn "some hooks failed — re-run: bash ai/install-hooks.sh"; \
	echo "-> cross-tool wiring (Gemini/Codex symlinks + MCP fan-out)"; \
	bash ai/generate.sh || warn "cross-tool wiring failed — re-run: bash ai/generate.sh"; \
	echo "-> Claude settings.json (machine-local; template only if missing)"; \
	if [ -f "$$HOME/.claude/settings.json" ]; then skip "exists — left as is (machine-local; may hold confidential/env config)"; \
	else mkdir -p "$$HOME/.claude"; cp ai/claude/settings.json "$$HOME/.claude/settings.json"; ok "created from sanitized template"; fi; \
	echo "-> secrets scaffold (~/.zshenv.local)"; \
	if [ -f "$$HOME/.zshenv.local" ]; then skip "exists — left untouched"; \
	else cp zshenv.local.example "$$HOME/.zshenv.local"; ok "created from template — fill in real secrets"; fi; \
	echo "==> post-install complete."

# Drift check: confirm cross-tool config reaches Gemini and Codex.
verify-ai:
	@bash ai/verify.sh
