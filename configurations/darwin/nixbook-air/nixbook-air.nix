{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules;
    [
      darwin
      dock
      finder
      pointer
      single-user
      ui-ux
    ]
    ++ [
      ./brew-casks.nix
    ];

  krad246.darwin.masterUser = {
    enable = true;
    username = "krad246";
  };

  users = {
    users.krad246 = {
      uid = 501;
      gid = 20;
      shell = "${config.homebrew.brewPrefix}/bash";
    };

    knownUsers = ["krad246"];
  };

  nix.settings.keep-outputs = false;
}
