{
  self,
  lib,
  ...
}: {
  imports = with self.darwinModules; [
    apps
  ];

  krad246.darwin.apps = {
    arc = false;
    launchcontrol = false;
  };

  system.defaults.dock.persistent-apps = lib.modules.mkBefore ["/Applications/Zen Browser.app"];

  services.tailscale.enable = true;
}
