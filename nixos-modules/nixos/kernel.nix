{
  config,
  pkgs,
  ...
}: {
  boot = {
    tmpOnTmpfs = true;
    initrd.systemd.enable = true;
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-amd" "kvm-intel"];
  };

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  services.zram-generator.enable = true;

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # This just holds up boot, (imo)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Screeches about UID 30000
  services.logrotate.checkConfig = false;
}
