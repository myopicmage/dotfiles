{
  description = "Example Darwin system flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    herdr = {
      url = "github:herdrdev/herdr/v0.8.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kevin-server = {
      url = "git+ssh://git@github.com/myopicmage/kevin_server.git?rev=d20b7bef71d6e199e38a751e99892dd92c501d03";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };
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
              inputs.kevin-server.darwinModules.default
              ./config.nix
              {
                home-manager.users.${username} = {
                  imports = [ ./home.nix ];
                  home.packages = [ inputs.herdr.packages.${platform}.default ];
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
