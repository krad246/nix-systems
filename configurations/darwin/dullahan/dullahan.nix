{
  self,
  specialArgs,
  ...
}: {
  imports = with self.darwinModules;
    [
      arc
      bluesnooze
      wake-on-lan
    ]
    ++ [
      darwin
      dock
      finder
      pointer
      single-user
      ui-ux
    ];

  krad246.darwin.masterUser = {
    enable = true;
    username = "krad246";
  };

  users = {
    users = {
      krad246 = {
        uid = 501;
        gid = 20;
      };
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
}
