{
  self,
  specialArgs,
  ...
}: {
  imports = with self.darwinModules; [
    darwin
  ];

  krad246.darwin.masterUser = {
    enable = true;
    username = "krad246";
  };

  users = {
    users.krad246 = {
      uid = 501;
      gid = 20;
    };
  };

  nix = {
    linux-builder.maxJobs = 32;
    settings.keep-derivations = true;
  };

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets;
  in
    krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
}
