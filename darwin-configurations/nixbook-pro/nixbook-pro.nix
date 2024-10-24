{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
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
  nix.settings.keep-derivations = true;
  nix.linux-builder.maxJobs = 32;
  nix-homebrew.user = "krad246";
}
