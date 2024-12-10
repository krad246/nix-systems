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

  krad246.darwin.linux-builder = {
    ephemeral = true;

    maxJobs = 128;
    cores = 8;

    memorySize = 16 * 1024;
    diskSize = 256 * 1024;
  };

  users = {
    users.krad246 = {
      uid = 501;
      gid = 20;
    };
  };

  nix = {
    settings.keep-derivations = true;
  };

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ./secrets;
  in
    krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
}
