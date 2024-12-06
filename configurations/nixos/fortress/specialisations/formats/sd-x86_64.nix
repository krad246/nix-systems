{lib, ...}: {
  boot = {
    supportedFilesystems = {
      zfs = lib.modules.mkForce false;
    };

    loader.grub.enable = lib.modules.mkForce false;
    loader.generic-extlinux-compatible.enable = lib.modules.mkForce true;
  };

  disko.enableConfig = false;
}
