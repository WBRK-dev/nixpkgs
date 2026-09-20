{ config, lib, pkgs, ... }:

let
  cfg = config.programs.warden;
  wardenPackage = cfg.package.override { dnsmasqPort = cfg.dnsmasqPort; };
in
{
  options.programs.warden = {
    enable = lib.mkEnableOption "Warden Docker environment manager";

    package = lib.mkPackageOption pkgs.wbrk "warden" { };

    dnsmasqPort = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Host port bound to warden dnsmasq. Baked into the wrapped warden package at build time; a switch rebuilds the (cheap, non-compiling) wrapper -- no shell env var is involved.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ wardenPackage ];

    programs.ssh.enable = lib.mkDefault true;
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
