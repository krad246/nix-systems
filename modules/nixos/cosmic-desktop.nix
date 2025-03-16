{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixos-cosmic;
in {
  imports = [nixos-cosmic.nixosModules.default];
  nix.settings = {
    substituters = ["https://cosmic.cachix.org/"];
    trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
  };

  # Enable sound with pipewire.
  sound.enable = lib.modules.mkDefault true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services = {
    desktopManager = {
      cosmic.enable = true;
      cosmic-greeter.enable = true;
    };
    pipewire = {
      enable = lib.modules.mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
