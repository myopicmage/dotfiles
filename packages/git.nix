{ config, ... }: {
  programs.git = {
    enable = true;
    ignores = [
      ".direnv/"
      ".DS_Store"
    ];
    signing = {
      key = "948C11FA0881F823";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Kevin Bernfeld";
        email = "kcbernfeld@gmail.com";
      };
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
