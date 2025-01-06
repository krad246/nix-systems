{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    groupme
    kitty
    launchcontrol
    magnet
    rdp
    signal
    spotify
    utm
    vscode
    zen-browser
    zoom
  ];

  krad246.darwin.apps = {
    launchcontrol = false;
    kitty = false;
    vscode = false;
  };
}
