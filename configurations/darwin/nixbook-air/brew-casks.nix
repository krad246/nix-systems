{self, ...}: {
  imports = with self.darwinModules; [arc bluesnooze rdp];
  nix-homebrew.user = "krad246";
  homebrew = {
    casks =
      ["launchcontrol"]
      ++ ["signal"]
      ++ ["spotify"];
  };
}
