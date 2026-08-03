# Shared agent config, tracked in the dotfiles and shared across machines.
#
# Guidance and skills are symlinked out of the nix store so they stay editable
# in place. Each agent receives the same source under the filename it expects.
{ config, lib, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
  guidance =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/agents/GUIDANCE.md";
  sharedWorkProtocol =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/agents/WORK.md";
  agentsWork = pkgs.writeShellApplication {
    name = "agents-work";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 "${dotfiles}/modules/agents/agents_work.py" "$@"
    '';
  };
  goWord = pkgs.writeShellApplication {
    name = "go-word";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec python3 "${dotfiles}/modules/agents/go_word.py" \
        --catalog "${dotfiles}/modules/agents/go_words.tsv" \
        --state "${config.home.homeDirectory}/.agents/go-words.tsv" \
        "$@"
    '';
  };
in
{
  home.packages = [ agentsWork goWord ];

  home.file.".claude/CLAUDE.md".source = guidance;
  home.file.".codex/AGENTS.md".source = guidance;
  home.file.".agents/work/README.md".source = sharedWorkProtocol;

  # Both agents share one learning loop, including the translated go-word gate.
  home.file.".claude/skills/learning-mode".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/skills/learning-mode";
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
