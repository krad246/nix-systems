{lib, ...}: {
  hardware = {
    pulseaudio.enable = false;
  };

  sound.enable = lib.mkDefault true;
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
