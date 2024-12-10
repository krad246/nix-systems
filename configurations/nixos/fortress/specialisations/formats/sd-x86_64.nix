{lib, ...}: let
  inherit (lib) modules;
in {
  boot.loader = {
    grub.enable = modules.mkForce false;
    generic-extlinux-compatible.enable = modules.mkForce true;
  };

  virtualisation.diskSize = 64 * 1024;

  disko.enableConfig = false;
}
