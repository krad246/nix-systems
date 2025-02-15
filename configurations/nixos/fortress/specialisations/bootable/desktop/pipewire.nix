{lib, ...}: {
  hardware = {
    pulseaudio.enable = false;
    pulseaudio.support32Bit = true;
  };

  # sound.enable = lib.modules.mkDefault true;
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = lib.modules.mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
