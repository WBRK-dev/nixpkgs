{ config, lib, pkgs, ... }:

let
  cfg = config.services.warden;
  wardenPackage = cfg.package.override { dnsmasqPort = cfg.dnsmasqPort; };
in
{
  options.services.warden = {
    enable = lib.mkEnableOption "Warden Docker environment manager";

    package = lib.mkPackageOption pkgs.wbrk "warden" { };

    dnsmasqPort = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Host port bound to warden dnsmasq. Baked into the wrapped warden package at build time; a switch rebuilds the (cheap, non-compiling) wrapper -- no shell env var is involved.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ wardenPackage ];

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
