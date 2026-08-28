{lib, ...}: {
  boot = {
    tmp = {
      cleanOnBoot = true;
      useTmpfs = lib.modules.mkDefault true;
    };
  };

  # Not technically a part of the kernel, but close enough...
  networking.networkmanager.enable = true;
  # FIXME(networking): Let NetworkManager's NixOS module own wpa_supplicant.
  # Explicitly setting this conflicts with image modules that enable it.
  # networking.wireless.enable = !config.networking.networkmanager.enable;
}
