{
  specialArgs,
  config,
  ...
}: {
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

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets/krad246;
  in
    krad246.attrsets.genAttrs' paths (path:
      krad246.attrsets.stemValuePair path {
        file = path;
      });

  ids.gids.nixbld = 30000;
}
