# Claude Code config, tracked in the dotfiles and shared across machines.
#
# CLAUDE.md and skills/ are symlinked OUT of the nix store (mkOutOfStoreSymlink)
# so they stay editable in place — edit them directly, no rebuild needed to
# apply. Only these two are tracked; the rest of ~/.claude (projects/, sessions/,
# cache/, history, telemetry, …) is machine-local.
{ config, ... }:
let
  claude = "${config.home.homeDirectory}/code/dotfiles/claude";
in
{
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${claude}/CLAUDE.md";

  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${claude}/skills";

  # Kill Claude Code's non-essential phone-home. The umbrella flag disables
  # telemetry, crash/error reporting, and update checks in one shot; the two
  # explicit flags are belt-and-suspenders. (Verified against the 2.1.205
  # binary — all three are real env vars it reads.)
  home.sessionVariables = {
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    DISABLE_TELEMETRY = "1";
    DISABLE_ERROR_REPORTING = "1";
  };
}
