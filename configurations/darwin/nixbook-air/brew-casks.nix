{self, ...}: {
  imports = with self.darwinModules; [
    bluesnooze
    groupme
    launchcontrol
    signal
  ];
}
