{ config, lib, pkgs, system, ... }:
let
  cfg = config.programs.iterm2;
in
{
  options.programs.iterm2 = {
    enable = lib.mkEnableOption "Enable the iTerm2 package (system-wide)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.iterm2 ];

    system.defaults.CustomUserPreferences = {
      "com.googlecode.iterm2" = {
        PrefsCustomFolder = "~/dotfiles/packages/iterm";
        LoadPrefsFromCustomFolder = true;
      };
    };
  };
}
