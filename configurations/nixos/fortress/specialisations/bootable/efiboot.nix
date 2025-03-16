{lib, ...}: {
  boot.loader = {
    grub = {
      enable = lib.modules.mkDefault true;
      efiSupport = true;
      device = "nodev";
    };
  };
}
