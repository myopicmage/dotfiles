{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # `brew bundle` runs under sudo during activation, so it does NOT inherit
      # the user's `brew trust` state — Homebrew then refuses to load casks from
      # third-party taps (e.g. sikarugir-app/sikarugir). Waive that trust check
      # for the activation run; the taps are explicitly declared just below.
      extraEnv.HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
    };
    taps = [
      "sikarugir-app/sikarugir"
    ];
    brews = [
      "bash"
      "elixir"
      "flyctl"
      "podman"
      "qemu"
      "swiftlint"
      "vapor"
      "wget"
      "yt-dlp"
    ];
    # gh and the fira-code font are intentionally NOT here — nix already provides
    # them (programs.gh.enable + nerd-fonts.fira-code), so brew would duplicate.
    casks = [
      "1password-cli"
      "android-platform-tools"
      "android-studio"
      "discord"
      "docker-desktop"
      "dropbox"
      "firefox"
      "mitmproxy"
      "sikarugir"
      "whatsapp"
    ];
  };
}
