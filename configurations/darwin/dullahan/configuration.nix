{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    base-configuration
  ];

  krad246.darwin.masterUser = {
    enable = true;
    owner = rec {
      name = "krad246";
      home = "/Users/${name}";

      uid = 501;
      gid = 20;

      shell = "${config.homebrew.brewPrefix}/bash";
      createHome = true;
    };
  };

  ids.gids.nixbld = 30000;
}
