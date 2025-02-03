{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [system-preferences];

  krad246.darwin.system-preferences.masterUser = {
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
