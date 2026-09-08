{ pkgs }:
let
  wbrk = {
    ab-download-manager = pkgs.callPackage ../by-name/ab-download-manager/package.nix { };
    hello-wbrk = pkgs.callPackage ../by-name/hello-wbrk/package.nix { };
    warden = pkgs.callPackage ../by-name/warden/package.nix { };
  };
in
{
  inherit wbrk;
  hello-wbrk = wbrk.hello-wbrk;
}
