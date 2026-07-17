{ config, pkgs, lib, ... }:
{
  # A single global PostgreSQL managed by nix-darwin as a per-user launchd agent
  # (starts at login, KeepAlive) — replaces the brew postgresql@17 and any
  # per-project instances. The module runs `initdb` automatically on first start
  # but does NOT create the data directory, so preActivation does that.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;

    # Local dev box: trust the OS user and loopback (no passwords). Not reachable
    # off the machine. mkOverride 10 wins over the module's default pg_hba.
    authentication = lib.mkOverride 10 ''
      # type  database  DBuser  origin-address  auth-method
      local   all       all                     trust
      host    all       all     127.0.0.1/32    trust
      host    all       all     ::1/128         trust
    '';
  };

  # Activation runs as root, so this can create the dir under /var/lib and the
  # log dir under $HOME, then hand both to `kevin` (whom the agent runs as).
  # mkAfter so it appends rather than clobbering any other preActivation text.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    for dir in "${config.services.postgresql.dataDir}" "/Users/kevin/.local/share/postgresql"; do
      if [ ! -d "$dir" ]; then
        echo "Creating $dir ..."
        mkdir -p "$dir"
        chown -R kevin:staff "$dir"
      fi
    done
  '';

  launchd.user.agents.postgresql.serviceConfig = {
    StandardErrorPath = "/Users/kevin/.local/share/postgresql/postgres.error.log";
    StandardOutPath = "/Users/kevin/.local/share/postgresql/postgres.out.log";
  };
}
