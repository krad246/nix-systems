{inputs, ...}: let
  inherit (inputs) nix-flatpak;
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak];
}
