{
  description = "Example Darwin system flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";
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
    let
      # A macOS host running as user `kevin`.
      mkHome = username: platform:
        self.nixos-unified.lib.mkMacosSystem
          { home-manager = true; }
          {
            nixpkgs.hostPlatform = platform;
            system.primaryUser = username;
            imports = [
              ./config.nix
              {
                home-manager.users.${username} = {
                  imports = [ ./home.nix ];
                };
              }
            ];
          };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.nixos-unified.flakeModules.default ];

      systems = [
        "aarch64-darwin"
      ];

      flake = {
        darwinConfigurations = {
          "m2" = mkHome "kevin" "aarch64-darwin";
        };
      };
    };
}
