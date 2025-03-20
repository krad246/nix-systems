{
  specialArgs,
  config,
  ...
}: let
  inherit (specialArgs) krad246;
in {
  age.secrets =
    (let
      paths = krad246.fileset.filterExt "age" ./secrets/krad246;
    in
      krad246.attrsets.genAttrs' paths (path:
        krad246.attrsets.stemValuePair path {
          file = path;
          mode = "0600";
          owner = config.users.users.krad246.name;
          inherit (config.users.users.krad246) group;
        }))
    // (let
      paths = krad246.fileset.filterExt "age" ./secrets/system/hercules-ci;
    in
      krad246.attrsets.genAttrs' paths (path:
        krad246.attrsets.stemValuePair path {
          file = path;
          mode = "0600";
          owner = config.users.users._hercules-ci-agent.name;
          group = config.users.groups._hercules-ci-agent.name;
        }));
}
