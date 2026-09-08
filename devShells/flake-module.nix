{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt-tree
            pkgs.git
          ];
        };
        python = pkgs.mkShell {
          packages = [
            pkgs.python3
            pkgs.uv
          ];
        };
      };
    };
}
