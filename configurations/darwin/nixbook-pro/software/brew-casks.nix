{self, ...}: {
  imports = with self.darwinModules; [
    bluesnooze
    groupme
    launchcontrol
    magnet
    signal
    utm
    zoom
  ];

  krad246.darwin.apps = {
    arc = false;
    launchcontrol = false;
  };
}
