# Gemini CLI config, tracked in the dotfiles and shared across machines.
#
# GEMINI.md points at the shared GUIDANCE.md outside the nix store so it stays
# editable in place and consistent across agents.
{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
in
{
  home.file.".gemini/GEMINI.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/GUIDANCE.md";
}
