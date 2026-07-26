# Claude Code config, tracked in the dotfiles and shared across machines.
#
# CLAUDE.md and skills/ are symlinked OUT of the nix store (mkOutOfStoreSymlink)
# so they stay editable in place. Edit them directly, no rebuild needed to
# apply. Only these two are tracked; the rest of ~/.claude (projects/, sessions/,
# cache/, history, telemetry, …) is machine-local.
{ config, lib, ... }:
let
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
in
{
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/GUIDANCE.md";

  # Skills live in modules/skills because none of them are Claude-specific:
  # they describe how I want to be worked with, the same as GUIDANCE.md.
  # Claude can take the whole directory; Codex has to list them one by one.
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/skills";

  # Claude Code itself is the self-updating native build (~/.local/bin/claude),
  # not the brew cask or a pinned nixpkgs package, so it keeps auto-updating
  # instead of being frozen to a rebuild. This only bootstraps a fresh machine:
  # if the binary already exists we leave it alone and let it update itself.
  home.activation.installClaudeCode =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${config.home.homeDirectory}/.local/bin/claude" ]; then
        echo "Claude Code not found. Running native installer…"
        $DRY_RUN_CMD /usr/bin/env PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
          /bin/bash -c "curl -fsSL https://claude.ai/install.sh | bash" \
          || echo "warning: Claude Code native install failed; install manually with: curl -fsSL https://claude.ai/install.sh | bash" >&2
      fi
    '';
}
