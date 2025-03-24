{
  self,
  pkgs,
  ...
}: {
  imports = with self.nixosModules; [
    gnome-desktop
    whitesur
  ];

  users.users.krad246 = {
    isNormalUser = true;
    description = "Keerthi Radhakrishnan";
    extraGroups = ["wheel"];
    initialHashedPassword = "$y$j9T$GlfzmGjYcMf96CrZDYSKf.$vYN1YvO28MeOLulPK6wNc.RnnL5dN4c.pcR7ur/8jP9";
  };

  programs.dconf.enable = true;
  services = {
    dbus.enable = true;
    flatpak.enable = true;
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/flatpak 755 root    root  - -"
  ];

  # note: parent config inheritance does not seem to be able to bundle these in just via switchToSpecialisation as declared in home-manager
  # could be a possible bug dealing with store overlays.
  home-manager.sharedModules = [
    {
      imports = with self.homeModules; [
        kitty
        vscode
        vscode-server
      ];
    }
  ];

  nix.settings.trusted-users = ["krad246"];
}
