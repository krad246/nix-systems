{
  lib,
  pkgs,
  ...
}: {
  services = {
    gnome.gnome-remote-desktop.enable = true;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = lib.meta.getExe pkgs.gnome.gnome-session;
  services.xrdp.openFirewall = true;
}
