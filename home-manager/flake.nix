{
  description = "";
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "flake:nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "flake:home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs:
    let
      username = builtins.getEnv "USER"; 
      flakeContext = {
        inherit inputs username;
      };
    in
    {
      darwinConfigurations = {
        mbp-nixos = import ./darwin.nix flakeContext;
      };
      homeConfigurations = {
        mynixos = import ./home.nix flakeContext;
      };
    };
}
