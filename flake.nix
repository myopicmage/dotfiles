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

  outputs = inputs @ { self, home-manager, ... }:
    let
      homeImports = [
        ./config.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kevin = import ./home.nix;
        }
      ];

      workImports = [
        ./config.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kevinbernfeld = import ./home.nix;
        }
      ];
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.nixos-flake.flakeModule ];

      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake = {
        darwinConfigurations = {
          "uplift-macbook-pro" = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "x86_64-darwin";
            imports = workImports;
          };
          "ki9" = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "x86_64-darwin";
            imports = homeImports;
          };
          "m2" = self.nixos-flake.lib.mkMacosSystem {
            nixpkgs.hostPlatform = "aarch64-darwin";
            imports = homeImports;
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
