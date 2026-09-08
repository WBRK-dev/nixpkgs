{ config, lib, pkgs, ... }:

let
  cfg = config.services.warden;
in
{
  options.services.warden = {
    enable = lib.mkEnableOption "Warden Docker environment manager";

    package = lib.mkPackageOption pkgs.wbrk "warden" { };

    dnsmasqPort = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Host port bound to warden dnsmasq (127.0.0.1:<port> -> 53/udp). Applied at runtime via WARDEN_DNSMASQ_PORT; no rebuild needed.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable or false;
        message = "services.warden requires virtualisation.docker.enable = true.";
      }
    ];

    environment.systemPackages = [ cfg.package ];
    environment.variables.WARDEN_DNSMASQ_PORT = toString cfg.dnsmasqPort;

    programs.ssh.extraConfig = ''
      ## WARDEN START ##
      Host tunnel.warden.test
        HostName 127.0.0.1
        User user
        Port 2222
        IdentityFile ~/.warden/tunnel/ssh_key
      ## WARDEN END ##
    '';

    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNS = "127.0.0.1:${toString cfg.dnsmasqPort}";
        Domains = "~test";
      };
    };
  };
}
