{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          wbrkPkgs = import ./default.nix { inherit pkgs; };
        in
        {
          inherit (wbrkPkgs) hello-wbrk;
          inherit (wbrkPkgs.wbrk) warden ab-download-manager;
          wbrk-warden = wbrkPkgs.wbrk.warden;
          wbrk-ab-download-manager = wbrkPkgs.wbrk.ab-download-manager;
          default = wbrkPkgs.hello-wbrk;
        };
    };
}
