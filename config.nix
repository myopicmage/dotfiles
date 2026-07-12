{ config, pkgs, lib, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    gnupg
    iterm2
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/dotfiles/config.nix";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    bash.enable = true;
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # explicitly allow these unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
    "vim-polyglot"
  ];

  nix = {
    gc = {
      automatic = true;
    };
  };

  users.users = {
    "kevin" = {
      name = "kevin";
      home = "/Users/kevin";
    };
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "flyctl"
    ];
    casks = [
      "1password-cli"
      "authy"
      "discord"
      "dropbox"
      "podman-desktop"
      "whatsapp"
    ];
  };

  system = {
    defaults = {
      CustomUserPreferences = {
        "com.googlecode.iterm2" = {
          PrefsCustomFolder = "~/dotfiles/packages/iterm";
          LoadPrefsFromCustomFolder = true;
        };
      };
      finder = {
        FXPreferredViewStyle = "clmv"; # default to column view
        ShowPathbar = true;
      };
      menuExtraClock = {
        Show24Hour = true;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  security = {
    pam = {
      services.sudo_local.touchIdAuth = true;
    };
  };
}
