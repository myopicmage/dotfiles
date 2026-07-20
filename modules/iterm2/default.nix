# A nix-darwin (system) module — import into config.nix, toggle with
# `programs.iterm2.enable`. It sets system options only (systemPackages +
# system.defaults); the previous version also set the home-manager option
# `home.packages`, which is a different module system and is why it could never
# be imported cleanly.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.iterm2;
in
{
  options.programs.iterm2 = {
    enable = lib.mkEnableOption "iTerm2 (installed system-wide, prefs loaded from the dotfiles)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.iterm2 ];

    # Load iTerm2's preferences from the version-controlled folder in this repo.
    system.defaults.CustomUserPreferences."com.googlecode.iterm2" = {
      PrefsCustomFolder = "~/code/dotfiles/modules/iterm2";
      LoadPrefsFromCustomFolder = true;
    };
  };
}
