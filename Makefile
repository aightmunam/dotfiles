PHONY: setup build

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
	NIXPKGS_ALLOW_UNFREE=1 nix run home-manager -- switch --flake ./home-manager#mynixos --impure -b backup
