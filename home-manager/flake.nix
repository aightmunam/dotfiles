{
  description = "Cross-platform dotfiles";
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "flake:nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "flake:home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs:
    let
      macUsername = builtins.getEnv "USER";
      flakeContext = {
        inherit inputs;
        username = macUsername;
      };
    in
    {
      darwinConfigurations = {
        mbp-nixos = import ./darwin.nix flakeContext;
      };
      homeConfigurations = {
        # macOS (Apple Silicon)
        mynixos = import ./home.nix flakeContext;
        # Linux (x86_64) - for CachyOS
        mylinux = import ./home-linux.nix { inherit inputs; username = "ruin"; };
      };
    };
}
