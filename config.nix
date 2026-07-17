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

  # Back up pre-existing dotfiles that home-manager would otherwise clobber,
  # renaming them with a `.backup` suffix instead of aborting activation.
  home-manager.backupFileExtension = "backup";

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
    # Weekly garbage collection. Crucially, WITHOUT `options` the automatic GC
    # only drops unreferenced paths and never deletes old profile generations —
    # which is how ~3 years of generations piled up despite automatic = true.
    # `--delete-older-than 30d` reclaims the long tail while keeping a 30-day
    # rollback window.
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 3; Minute = 0; }; # Sundays 03:00
      options = "--delete-older-than 30d";
    };

    # Hard-link identical files in the store to dedupe it, weekly (an hour after
    # GC, so it optimises what's left rather than paths about to be collected).
    optimise = {
      automatic = true;
      interval = { Weekday = 0; Hour = 4; Minute = 0; }; # Sundays 04:00
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
