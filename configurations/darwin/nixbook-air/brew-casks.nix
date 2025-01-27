{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    groupme
    launchcontrol
    signal
  ];
}
