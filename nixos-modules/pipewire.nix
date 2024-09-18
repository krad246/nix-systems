{lib, ...}: {
  hardware = {
    pulseaudio.enable = false;
    pulseaudio.support32Bit = true;
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
