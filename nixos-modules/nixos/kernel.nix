{
  config,
  pkgs,
  ...
}: {
  boot = {
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

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # This just holds up boot, (imo)
  systemd.services.NetworkManager-wait-online.enable = false;

  #
  services.logrotate.checkConfig = false;
}
