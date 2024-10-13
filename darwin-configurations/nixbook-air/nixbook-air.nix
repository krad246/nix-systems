{
  ezModules,
  config,
  ...
}: {
  imports = with ezModules; [
    darwin
    dock
    finder
    pointer
    single-user
    ui-ux
  ];

  users = {
    users.krad246 = {
      home = "/Users/krad246";
      createHome = true;
      uid = 501;
      gid = 20;
      shell = "${config.homebrew.brewPrefix}/bash";
    };

    knownUsers = ["krad246"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.settings.keep-outputs = false;
}
