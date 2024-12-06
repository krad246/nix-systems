{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    rdp
  ];

  homebrew = {
    casks =
      ["launchcontrol"]
      ++ ["signal"]
      ++ ["spotify"];
  };
}
