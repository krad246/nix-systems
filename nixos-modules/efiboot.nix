{config, ...}: {
  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = !config.boot.loader.efi.canTouchEfiVariables;

      # Define on which hard drive you want to install Grub.
      device = "nodev"; # or "nodev" for efi only
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = config.fileSystems."/boot".mountPoint;
    };
  };
}
