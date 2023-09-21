{ pkgs, config, lib, ... }:
{
  imports = [
    ./nvim/nvim.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bash
    doctl
    eza
    flyctl
    git
    gnupg
    nerdfonts
    nixpkgs-fmt
    nodejs_18
    rustup
    rnix-lsp
    thefuck
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "ngrok"
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

  programs.git = {
    enable = true;
    userName = "Kevin Bernfeld";
    userEmail = "kcbernfeld@gmail.com";
    ignores = [
      "shell.nix"
      ".direnv/"
      ".envrc"
    ];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    initExtra = ''
      bindkey -v

      export PATH="/Users/kevinbernfeld/.local/bin:$PATH"
      export PATH="/usr/local/opt/tcl-tk/bin:$PATH"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "poetry" "vi-mode" ];
      theme = "ys";
      extraConfig = ''
        DISABLE_LS_COLORS=true
      '';
    };
    shellAliases = {
      ls = "eza";
    };
  };
}
