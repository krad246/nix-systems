{
  config,
  lib,
  ...
}: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = !config.boot.loader.grub.efiInstallAsRemovable;
    };
    grub = {
      enable = lib.mkDefault true;
      efiSupport = true;
      efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
    };
  };
}
