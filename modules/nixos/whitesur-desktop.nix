{self, ...}: {
  imports = [
    ./gnome-desktop.nix
    ./whitesur.nix
  ];

  programs.dconf.enable = true;
  services.dbus.enable = true;

  home-manager.sharedModules = [
    {imports = [self.homeModules.whitesur-dconf];}
  ];
}
