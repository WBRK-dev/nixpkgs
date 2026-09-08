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
      description = "Host port bound to warden dnsmasq. Applied at runtime via WARDEN_DNSMASQ_PORT; no rebuild needed.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.variables.WARDEN_DNSMASQ_PORT = toString cfg.dnsmasqPort;

    environment.etc."resolver/test".text = ''
      nameserver 127.0.0.1
      port ${toString cfg.dnsmasqPort}
    '';

    programs.ssh.extraConfig = ''
      ## WARDEN START ##
      Host tunnel.warden.test
        HostName 127.0.0.1
        User user
        Port 2222
        IdentityFile ~/.warden/tunnel/ssh_key
      ## WARDEN END ##
    '';
  };
}
