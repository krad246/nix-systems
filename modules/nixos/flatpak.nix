{pkgs, ...}: {
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/flatpak 755 root    root  - -"
  ];
}
