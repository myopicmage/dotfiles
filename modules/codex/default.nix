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

  # Skills live in modules/skills, shared with Claude, because none of them are
  # agent-specific. Listed one by one because ~/.codex/skills also holds
  # Codex's own built-ins under .system, so the directory cannot be replaced
  # wholesale the way Claude's can. One line per skill.
  home.file.".codex/skills/learning-mode".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/skills/learning-mode";
}
