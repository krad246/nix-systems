{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    groupme
    launchcontrol
    magnet
    rdp
    signal
    spotify
    utm
    zen-browser
    zoom
  ];

  krad246.darwin.apps = {
    arc = false;
    launchcontrol = false;
  };
}
