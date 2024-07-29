{
  config,
  lib,
  ...
}: {
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = lib.mkDefault true;
      efiSupport = true;
      efiInstallAsRemovable = !config.boot.loader.efi.canTouchEfiVariables;
      device = lib.mkDefault "nodev"; # or "nodev" for efi only
    };

    efi = {
      canTouchEfiVariables = false;
    };
  };
}
