{lib, ...}: {
  # boot.loader.grub.device = "nodev";
  disko.enableConfig = lib.modules.mkForce false;
}
