{ config, pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;
      enableTCPIP = true;
      checkConfig = true;
      authentication = pkgs.lib.mkOverride 10 ''
        # type  database  DBuser  origin-address  auth-method
        local   all       all                     trust
        host    all       all     127.0.0.1/32    trust
        host    all       all     ::1/128         trust
      '';
    };
  };

  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      if [ ! -d "/var/lib/postgresql/14" ]; then
        echo "Creating PostgreSQL data directory..."
        sudo mkdir -m 777 -p /var/lib/postgresql/14
        sudo chown -R kevinbernfeld:staff /var/lib/postgresql/14
      fi
    '';
  };

  launchd.user.agents = {
    postgresql.serviceConfig = {
      StandardErrorPath = "/Users/kevinbernfeld/.local/share/postgresql/postgres.error.log";
      StandardOutPath = "/Users/kevinbernfeld/.local/share/postgresql/postgres.out.log";
    };
  };
}
