{
  config,
  lib,
  ...
}: {
  boot = {
    tmp = {
      cleanOnBoot = true;
      useTmpfs = lib.modules.mkDefault true;
    };
  };

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # mount an overlayFS over the /etc dir
  boot.initrd.systemd.enable = true;
  system.etc.overlay = {
    enable = true;
    mutable = true;
  };
}
