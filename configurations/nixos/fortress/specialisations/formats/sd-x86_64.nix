{lib, ...}: let
  inherit (lib) modules;
in {
  boot = {
    supportedFilesystems = {
      zfs = modules.mkForce false;
    };

    loader.grub.enable = modules.mkForce false;
    loader.generic-extlinux-compatible.enable = modules.mkForce true;
  };

  disko.enableConfig = false;
}
