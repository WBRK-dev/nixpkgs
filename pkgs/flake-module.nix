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
          inherit (wbrkPkgs.wbrk) warden;
          wbrk-warden = wbrkPkgs.wbrk.warden;
          default = wbrkPkgs.hello-wbrk;
        };
    };
}
