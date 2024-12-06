{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nix-flatpak;
in {
  imports = [nix-flatpak.homeManagerModules.nix-flatpak];

  services.flatpak.uninstallUnmanaged = lib.modules.mkDefault false;
  targets.genericLinux.enable = true;
}
