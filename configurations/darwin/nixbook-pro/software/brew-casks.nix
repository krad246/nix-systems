{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    groupme
    launchcontrol
    rdp
    signal
    spotify
    utm
    zoom
  ];

  krad246.darwin.apps.vscode = false;
  krad246.darwin.apps.kitty = false;
}
