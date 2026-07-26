# Codex config, tracked in the dotfiles and shared across machines.
#
# AGENTS.md points at the shared GUIDANCE.md outside the nix store so it stays
# editable in place and consistent across agents.
# User skills are linked individually because ~/.codex/skills also contains
# Codex-managed built-in skills under .system.
{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
in
{
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/GUIDANCE.md";

  # No user skills at present. `nix-dev-env` was removed on 2026-07-26: its
  # general nix content moved into the global GUIDANCE.md and its BRBAviation
  # content into that repo's own agent instructions, which load automatically.
  # Add new ones here individually, one home.file per skill.
}
