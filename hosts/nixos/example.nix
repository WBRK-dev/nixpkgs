{ wbrk, ... }:
{
  imports = [ wbrk.nixosModules.default ];
  wbrk.enable = true;
  system.stateVersion = "25.05";
}
