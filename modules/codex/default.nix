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

  # No user skills at present. `nix-dev-env` was removed on 2026-07-26: its
  # general nix content moved into the global CLAUDE.md and its BRBAviation
  # content into that repo's own CLAUDE.md, which loads without being invoked.
  # Add new ones here individually, one home.file per skill.
}
