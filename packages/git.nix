{ config, ... }: {
  programs.git = {
    enable = true;
    userName = "Kevin Bernfeld";
    userEmail = "kcbernfeld@gmail.com";
    ignores = [
      "flake.nix"
      "flake.lock"
      "shell.nix"
      ".direnv/"
      ".envrc"
      ".DS_Store"
    ];
    signing = {
      key = "948C11FA0881F823";
      signByDefault = true;
    };
    extraConfig = {
      core = {
        excludesFile = "${config.xdg.configHome}/git/ignore";
      };
      credential = {
        helper = "osxkeychain";
      };
      init = {
        defaultbranch = "main";
      };
      merge = {
        conflictStyle = "zdiff3";
      };
      pull = {
        rebase = false;
      };
      push = {
        default = "current";
        autosetupremote = true;
      };
    };
  };
}
