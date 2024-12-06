{lib, ...}: {
  boot = {
    kernelParams = ["nomodeset"];
    binfmt.emulatedSystems = lib.modules.mkForce [];
  };

  virtualisation.diskSize = 64 * 1024;

  disko.enableConfig = false;
}
