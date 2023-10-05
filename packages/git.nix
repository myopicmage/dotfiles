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
        excludesfile = "${config.xdg.configHome}/git/config/ignore";
      };
      credential = {
        helper = "osxkeychain";
      };
      init = {
        defaultbranch = "main";
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
