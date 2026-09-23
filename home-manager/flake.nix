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
  };

  outputs = inputs:
    let
      # --impure: read the invoking user so the same flake works for any account.
      username = builtins.getEnv "USER";

      mkHome = system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.herdr.overlays.default ];
          };
          extraSpecialArgs = { inherit inputs username; };
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
