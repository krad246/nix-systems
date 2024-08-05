{ezModules, ...}: {
  imports = with ezModules; [
    darwin
    homebrew
  ];

  users.users.krad246 = {
    home = "/Users/krad246";
    createHome = true;
  };

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["docker"] ++ ["signal"] ++ ["vmware-fusion"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
