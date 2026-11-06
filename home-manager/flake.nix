{
  description = "aightmunam dotfiles: cross-platform home-manager (macOS + Linux)";

  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    home-manager.url = "flake:home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # herdr ships its own flake + overlay (packages.<system>.default / overlays.default),
    # supporting x86_64/aarch64 on both Linux and Darwin. Update with:
    #   nix flake update herdr   (bump the pinned tag below first)
    herdr.url = "github:herdrdev/herdr/v0.9.0";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # rig is a private repo, so the fetch needs the GitHub SSH key. Update with:
    #   nix flake update rig   (bump the pinned tag below first)
    rig.url = "git+ssh://git@github.com/aightmunam/rig?ref=refs/tags/v0.1.3";
    rig.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      # --impure: read the invoking user so the same flake works for any account.
      username = builtins.getEnv "USER";
      # --impure: the absolute path of the checkout that the links point at.
      # `make build` sets DOTFILES_DIR to the checkout it runs in.
      dotfilesDir = builtins.getEnv "DOTFILES_DIR";

      mkHome = system:
        let
          home = if builtins.match ".*-darwin" system != null then "/Users/${username}" else "/home/${username}";
          repoRoot = if dotfilesDir != "" then dotfilesDir else "${home}/dotfiles";
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.herdr.overlays.default ];
          };
          extraSpecialArgs = { inherit inputs username repoRoot; };
          modules = [ ./home.nix ];
        };
    in
    {
      homeConfigurations = {
        # `mynixos` stays as the default macOS target for back-compat with `make build`.
        "mynixos" = mkHome "aarch64-darwin";

        # Per-system targets. The Makefile selects the right one via `uname`.
        "mynixos-aarch64-darwin" = mkHome "aarch64-darwin";
        "mynixos-x86_64-darwin" = mkHome "x86_64-darwin";
        "mynixos-x86_64-linux" = mkHome "x86_64-linux";
        "mynixos-aarch64-linux" = mkHome "aarch64-linux";
      };
    };
}
