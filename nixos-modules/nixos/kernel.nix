{
  config,
  pkgs,
  ...
}: {
  boot = {
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
  };

  services.zram-generator.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # This just holds up boot, (imo)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Screeches about UID 30000
  services.logrotate.checkConfig = false;
}
