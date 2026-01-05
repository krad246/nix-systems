{lib, ...}: {
  disko.enableConfig = lib.modules.mkForce false;
  virtualisation = {
    cores = 8;
    # vmVariant.disko.enableConfig = lib.modules.mkForce false;
  };
}
