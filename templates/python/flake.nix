{
  description = "Python project using WBRK-dev/nixpkgs";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wbrk.url = "github:WBRK-dev/nixpkgs";
    wbrk.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs, wbrk, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAll = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAll (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ wbrk.overlays.default ];
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.python3
              pkgs.hello-wbrk
            ];
          };
        }
      );
    };
}
