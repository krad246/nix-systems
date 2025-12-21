{lib, ...}: {
  boot.kernelParams = ["nomodeset"];
  disko.enableConfig = lib.modules.mkForce false;
}
