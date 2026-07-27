# Shared agent config, tracked in the dotfiles and shared across machines.
#
# Guidance and skills are symlinked out of the nix store so they stay editable
# in place. Each agent receives the same source under the filename it expects.
{ config, lib, ... }:
let
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
  guidance =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/agents/GUIDANCE.md";
  sharedWorkProtocol =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/agents/WORK.md";
in
{
  home.file.".claude/CLAUDE.md".source = guidance;
  home.file.".codex/AGENTS.md".source = guidance;
  home.file.".agents/work/README.md".source = sharedWorkProtocol;

  # Skills live in modules/skills because none of them are Claude-specific:
  # they describe how I want to be worked with, the same as the guidance.
  # Claude can take the whole directory; Codex has to list them one by one.
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/skills";
  home.file.".codex/skills/learning-mode".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/skills/learning-mode";

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
