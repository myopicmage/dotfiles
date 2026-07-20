# Make GUI-launched apps (Dock / Spotlight — VS Code, etc.) see the nix PATH.
#
# GUI apps inherit their environment from the launchd user session, which —
# unlike a shell — never runs the nix / home-manager PATH setup, so they can't
# find nix-installed tools (direnv, nil, a flake's node, …). This agent runs
# `launchctl setenv PATH` at login to seed that session PATH with the same dirs
# a login shell gets; GUI apps launched afterward inherit it. Shells are
# unaffected — they set their own PATH.
#
# Takes effect at the next login. To activate now without logging out, run
# `launchctl setenv PATH "$PATH"` from a fresh terminal, then restart the app.
{ config, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  # environment.systemPath is a shell string with literal $HOME / $USER (a shell
  # expands them). launchctl does no expansion, so bake the real values in.
  guiPath = builtins.replaceStrings [ "$HOME" "$USER" ] [ home user ] config.environment.systemPath;
in
{
  launchd.user.agents.nix-gui-path = {
    serviceConfig = {
      ProgramArguments = [ "/bin/launchctl" "setenv" "PATH" guiPath ];
      RunAtLoad = true;
    };
  };
}
