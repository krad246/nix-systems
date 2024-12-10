{lib, ...}: {
  boot = {
    binfmt.emulatedSystems = lib.modules.mkForce [];
    kernelParams = ["nomodeset"];
  };

  virtualisation.diskSize = 32 * 1024;

  disko.enableConfig = false;
}
