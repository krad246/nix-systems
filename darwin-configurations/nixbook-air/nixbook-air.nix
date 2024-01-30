{ezModules, ...}: {
  imports = with ezModules; [
    darwin
  ];

  users.users.krad246 = {
    home = "/Users/krad246";
    createHome = true;
  };

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["signal"] ++ ["spotify"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
