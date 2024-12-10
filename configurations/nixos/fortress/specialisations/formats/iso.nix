{lib, ...}: let
  inherit (lib) modules;
in {
  boot = {
    binfmt.emulatedSystems = modules.mkForce [];
    supportedFilesystems = {
      zfs = modules.mkForce false;
    };

    loader.grub.enable = modules.mkForce false;
  };

  disko.enableConfig = false;
}
