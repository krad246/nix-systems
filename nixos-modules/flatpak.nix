{lib, ...}: {
  services.flatpak.enable = lib.mkForce true;
}
