{
  description = "Example Darwin system flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ inputs.nixos-flake.flakeModule ];

      flake = {
        darwinConfigurations = {
          "ki9" = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "x86_64-darwin";
            imports = [
              ./config.nix
              self.darwinModules.home-manager
              {
                home-manager.users.kevinbernfeld = {
                  imports = [ ./home.nix ];
                };
              }
            ];
          };
          "m2" = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "aarch64-darwin";
            imports = [
              ./config.nix
              self.darwinModules.home-manager
              {
                home-manager.users.kevin = {
                  imports = [ ./home.nix ];
                };
              }
            ];
          };
        };
      };

      perSystem = { self', ... }: {
        nixos-flake.primary-inputs = [
          "nixpkgs"
          "home-manager"
          "nix-darwin"
          "nixos-flake"
        ];

        packages.default = self'.packages.activate;
      };
    };
}
