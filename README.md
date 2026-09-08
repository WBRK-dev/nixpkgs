# WBRK-dev/nixpkgs

Personal nixpkgs-style repo: packages, overlays, NixOS/darwin/home-manager modules, dev shells.

## Use in your configs

```nix
{
  inputs.wbrk.url = "github:WBRK-dev/nixpkgs";
}
```

NixOS: `imports = [ inputs.wbrk.nixosModules.default inputs.wbrk.nixosModules.warden ];`
Darwin: `imports = [ inputs.wbrk.darwinModules.default inputs.wbrk.darwinModules.warden ];`
Home-manager: `imports = [ inputs.wbrk.homeManagerModules.default inputs.wbrk.homeManagerModules.warden ];`
Overlay: `nixpkgs.overlays = [ inputs.wbrk.overlays.default ];` then use `pkgs.wbrk.warden`.

```nix
# NixOS / darwin
services.warden = {
  enable = true;
  dnsmasqPort = 5353; # runtime via WARDEN_DNSMASQ_PORT, no rebuild
};
# home-manager
programs.warden = {
  enable = true;
  dnsmasqPort = 5353;
};
```

## Packages / shells

```sh
nix build github:WBRK-dev/nixpkgs#warden
nix build github:WBRK-dev/nixpkgs#hello-wbrk
nix develop github:WBRK-dev/nixpkgs
nix develop github:WBRK-dev/nixpkgs#python
nix flake init -t github:WBRK-dev/nixpkgs#minimal
```

## Add a package

Create `pkgs/by-name/<name>/package.nix`, wire it in `pkgs/top-level/all-packages.nix`.

## Layout

`flake.nix`, `pkgs/`, `overlays/`, `lib/`, `modules/{nixos,darwin,home-manager}/`, `hosts/`, `homes/`, `devShells/`, `templates/`.
