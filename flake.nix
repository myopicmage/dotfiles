{
  description = "home manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      username = "kevinbernfeld";
    in
    {
      defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
      defaultPackage.aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;

      homeConfigurations = {
        "${username}@ki9" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-darwin"; };
          modules = [ ./home.nix ];
        };
        "${username}@m2" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-darwin"; };
          modules = [ ./home.nix ];
        };
      };
    };
}
