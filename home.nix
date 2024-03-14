{ pkgs, config, lib, ... }:
{
  imports = [
    ./packages
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    act
    doctl
    eza
    git
    nerdfonts
    ngrok
    nixpkgs-fmt
    rustup
    rnix-lsp
    thefuck
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/zsh/backend.zsh".source = ./misc/backend.zsh;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = false;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.gh.enable = true;

  programs.ripgrep = {
    enable = true;
    arguments = [
      "-C2"
    ];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    initExtra = ''
      bindkey -v

      export PATH="/Users/kevin/.local/bin:$PATH"
      export PATH="/usr/local/opt/tcl-tk/bin:$PATH"
    '';
    oh-my-zsh = {
      enable = true;
      custom = "${config.xdg.configHome}/zsh";
      plugins = [ "git" "poetry" "vi-mode" ];
      theme = "ys";
      extraConfig = ''
        DISABLE_LS_COLORS=true
      '';
    };
    shellAliases = {
      code = "code-insiders";
      grep = "rg";
      ls = "eza";
    };
  };

  xdg = {
    enable = true;
  };
}
