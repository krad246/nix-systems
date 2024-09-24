{config, ...}: {
  boot = {
    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
  };

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;
}
