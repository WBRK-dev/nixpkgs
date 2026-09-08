{ config, lib, pkgs, ... }:

let
  cfg = config.programs.warden;
in
{
  options.programs.warden = {
    enable = lib.mkEnableOption "Warden Docker environment manager";

    package = lib.mkPackageOption pkgs.wbrk "warden" { };

    dnsmasqPort = lib.mkOption {
      type = lib.types.port;
      default = 53;
      description = "Host port bound to warden dnsmasq. Exported as WARDEN_DNSMASQ_PORT session variable; no rebuild needed.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.sessionVariables.WARDEN_DNSMASQ_PORT = toString cfg.dnsmasqPort;

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
