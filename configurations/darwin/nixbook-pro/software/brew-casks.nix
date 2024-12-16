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
}
