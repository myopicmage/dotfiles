# Codex config, tracked in the dotfiles and shared across machines.
#
# AGENTS.md is symlinked out of the nix store so it stays editable in place.
# User skills are linked individually because ~/.codex/skills also contains
# Codex-managed built-in skills under .system.
{ config, ... }:
let
  codex = "${config.home.homeDirectory}/code/dotfiles/modules/codex";
in
{
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${codex}/AGENTS.md";

  home.file.".codex/skills/nix-dev-env".source =
    config.lib.file.mkOutOfStoreSymlink "${codex}/skills/nix-dev-env";
}
