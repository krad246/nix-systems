{lib, ...}: let
  inherit (lib) modules;
in {
  hardware.opengl.driSupport32Bit = modules.mkForce false;

  boot = {
    binfmt.emulatedSystems = modules.mkForce ["x86_64-linux"];
    supportedFilesystems = {
      zfs = modules.mkForce false;
    };
  };

  disko.enableConfig = false;
}
