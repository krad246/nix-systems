{self, ...}: {
  imports = with self.darwinModules; [groupme magnet];
  homebrew = {
    casks =
      ["arc"]
      ++ ["bluesnooze"]
      ++ ["launchcontrol"]
      ++ ["signal"]
      ++ ["spotify"]
      ++ [
        "crystalfetch"
        "utm"
        "vagrant"
        "vagrant-vmware-utility"
        "virtualbox"
        "vmware-fusion"
        "windows-app"
      ]
      ++ ["zoom"];
  };
}
