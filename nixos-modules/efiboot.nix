{config, ...}: {
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = !config.boot.loader.efi.canTouchEfiVariables;
      device = "nodev"; # or "nodev" for efi only
    };

    efi = {
      canTouchEfiVariables = false;
    };
  };
}
