{config, ...}: {
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

  nix.settings.keep-outputs = false;
}
