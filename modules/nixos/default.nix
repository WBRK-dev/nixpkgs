{
  default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.wbrk.enable = lib.mkEnableOption "WBRK base NixOS config";
      config = lib.mkIf config.wbrk.enable {
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        environment.systemPackages = [ pkgs.hello-wbrk ];
      };
    };

  warden = import ./warden.nix;
}
