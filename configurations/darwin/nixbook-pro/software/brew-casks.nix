{self, ...}: {
  imports = with self.darwinModules; [
    apps
  ];

  krad246.darwin.apps = {
    arc = false;
    launchcontrol = false;
  };
}
