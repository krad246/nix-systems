{config, ...}: {
  imports = [
    ../../nixos-modules/efiboot.nix
    ../../nixos-modules/nix-daemon.nix
    ../../nixos-modules/nix-ld.nix
    ../../nixos-modules/zram.nix
  ];

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  networking.wireless.enable = !config.networking.networkmanager.enable;

  # This just holds up boot, (imo)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Screeches about UID 30000
  services.logrotate.checkConfig = false;
}
