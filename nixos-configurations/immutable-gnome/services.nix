{pkgs, ...}: {
  imports = [../../nixos-modules/flake-registry.nix];

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  environment.systemPackages = with pkgs; [gnome.gnome-tweaks];
}
