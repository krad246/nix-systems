{self, ...}: {
  imports = with self.darwinModules; [
    arc
    bluesnooze
    groupme
    magnet
    quickemu
    rdp
  ];

  homebrew = {
    casks =
      ["launchcontrol"]
      ++ ["signal"]
      ++ ["spotify"]
      ++ [
        "crystalfetch"
        "utm"
        "vagrant"
        "vagrant-vmware-utility"
        "virtualbox"
        "vmware-fusion"
      ]
      ++ ["zoom"];
  };
}
