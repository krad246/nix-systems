{lib, ...}: {
  boot = {
    binfmt.emulatedSystems = lib.modules.mkForce [];
    supportedFilesystems = {
      zfs = lib.modules.mkForce false;
    };

    loader.grub.enable = lib.modules.mkForce false;
  };

  disko.enableConfig = false;
}
