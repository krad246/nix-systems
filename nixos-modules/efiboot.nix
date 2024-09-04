{
  config,
  lib,
  ...
}: {
  boot.loader = lib.mkDefault {
    efi = {
      canTouchEfiVariables = !config.boot.loader.grub.efiInstallAsRemovable;
    };
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
    };
  };
}
