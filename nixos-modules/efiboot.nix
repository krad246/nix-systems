{
  config,
  lib,
  ...
}: {
  boot.loader = lib.mkForce {
    efi = {
      canTouchEfiVariables = !config.boot.loader.grub.efiInstallAsRemovable;
    };
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
    };
  };
}
