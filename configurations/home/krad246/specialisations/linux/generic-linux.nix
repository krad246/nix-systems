{self, ...}: {
  imports = with self.homeModules; [
    chromium
    dconf
    kitty
    zen-browser
  ];

  services = {
    flatpak = {
      uninstallUnmanaged = false;
      update = {
        auto.enable = true;
        onActivation = true;
      };
      packages = [
        "org.pulseaudio.pavucontrol"
        "com.github.tchx84.Flatseal"
      ];
    };
  };

  xdg.desktopEntries = {
    "org.kde.kdeconnect.nonplasma" = {
      name = "org.kde.kdeconnect.nonplasma";
      noDisplay = true;
    };
    "org.gnome.Software" = {
      name = "org.gnome.Software";
      noDisplay = true;
    };
    "bottom" = {
      name = "bottom";
      noDisplay = true;
    };
  };
}
