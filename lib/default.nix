{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
in
{
  inherit lib;
  mkSystem = args: args;
}
