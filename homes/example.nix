{ wbrk, ... }:
{
  imports = [ wbrk.homeManagerModules.default ];
  wbrk.enable = true;
  home.stateVersion = "25.05";
}
