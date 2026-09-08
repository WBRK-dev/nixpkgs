{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        let
          wbrkPkgs = import ./default.nix { inherit pkgs; };
        in
        wbrkPkgs // { default = wbrkPkgs.hello-wbrk; };
    };
}
