{ config, pkgs, lib, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/dotfiles/config.nix";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.bash.enable = false;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # explicitly allow these unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
    "slack"
  ];

  users.users = {
    "kevin" = {
      name = "kevin";
      home = "/Users/kevin";
    };
    "kevinbernfeld" = {
      name = "kevinbernfeld";
      home = "/Users/kevinbernfeld";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  services = {
    # Auto upgrade nix package and the daemon service.
    nix-daemon = {
      enable = true;
    };
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    casks = [
      "podman-desktop"
    ];
  };

  imports = [
    # ./services/postgres.nix
  ];
}
