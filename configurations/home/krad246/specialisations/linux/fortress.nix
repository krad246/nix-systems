{self, ...}: {
  imports =
    [
      ./generic-linux.nix
    ]
    ++ (with self.homeModules; [
      discord
      kdeconnect
      vscode
      vscode-server
    ]);

  services = {
    flatpak = {
      packages = [
        "us.zoom.Zoom"
        "org.signal.Signal"
        "com.spotify.Client"
        "com.valvesoftware.Steam"
      ];
    };
  };
}
