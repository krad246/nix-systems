{lib, ...}: {
  virtualisation = {
    cores = 8;
    vmVariant.disko.enableConfig = lib.modules.mkForce false;
  };
}
