{
  default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.wbrk.enable = lib.mkEnableOption "WBRK base home-manager config";
      config = lib.mkIf config.wbrk.enable {
        home.packages = [ pkgs.hello-wbrk ];
        programs.bash.enable = true;
      };
    };

  warden = import ./warden.nix;
}
