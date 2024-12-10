{lib, ...}: {
  hardware.opengl.driSupport32Bit = lib.modules.mkForce false;

  boot = {
    binfmt.emulatedSystems = lib.modules.mkForce ["x86_64-linux"];
    supportedFilesystems = {
      zfs = lib.modules.mkForce false;
    };
  };

  disko.enableConfig = false;
}
