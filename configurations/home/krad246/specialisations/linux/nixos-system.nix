{self, ...}: {
  imports =
    (with self.homeModules; [
      discord
      kdeconnect
      vscode
      vscode-server
    ])
    ++ [./base-graphical.nix];

  services = {
    flatpak = {
      uninstallUnmanaged = true;
      update.onActivation = true;
      packages = [
        "org.pulseaudio.pavucontrol"
        "us.zoom.Zoom"
        "org.signal.Signal"
        "com.spotify.Client"
        "com.github.tchx84.Flatseal"
        "com.valvesoftware.Steam"
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
