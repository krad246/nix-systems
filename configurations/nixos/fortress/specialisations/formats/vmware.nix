{lib, ...}: {
  boot = {
    binfmt.emulatedSystems = lib.modules.mkForce [];
    kernelParams = ["nomodeset"];
  };

  disko.enableConfig = false;
}
