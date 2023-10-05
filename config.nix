{ config, pkgs, lib, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    gnupg
    iterm2
    slack
    ((vscode.override { isInsiders = true; }).overrideAttrs
      (oldAttrs: rec {
        src = (builtins.fetchTarball {
          url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-universal";
          sha256 = "1kghyg9hx2nzn8la67052l17xh1rxh6y7k3pw7id53i4s988l6dy";
        });
        version = "latest";
        buildInputs = oldAttrs.buildInputs ++ [ krb5 ];
      }))
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
    "discord"
    "ngrok"
    "slack"
    "vscode-insiders"
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

  services = {
    # Auto upgrade nix package and the daemon service.
    nix-daemon = {
      enable = true;
    };
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    brews = [
      "vapor"
    ];
    casks = [
      "authy"
      "docker"
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

    activationScripts = {
      postUserActivation.text = ''
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
  };

  security = {
    pam = {
      enableSudoTouchIdAuth = true;
    };
  };
}
