{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmp = {
      cleanOnBoot = true;
      useTmpfs = false;
    };
  };

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # This just holds up boot, (imo)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Screeches about UID 30000
  services.logrotate.checkConfig = false;
}
