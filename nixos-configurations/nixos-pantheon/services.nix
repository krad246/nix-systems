{
  config,
  lib,
  ...
}: {
  imports = [];

  networking.wireless.enable = lib.mkDefault true;
  networking.networkmanager.enable = !config.networking.wireless.enable;
}
