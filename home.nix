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
    rnix-lsp
    thefuck
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.username}!"
    # '')
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

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kevinbernfeld/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    DIGITALOCEAN_ACCESS_TOKEN = "dop_v1_03d1d8b00be980461e4122d6af284578ebf03b53de02004e9d5ec36505772197";
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
