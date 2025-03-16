{specialArgs, ...}: let
  inherit (specialArgs) krad246;
in {
  age.secrets =
    (let
      paths = krad246.fileset.filterExt "age" ./secrets/krad246;
    in
      krad246.attrsets.genAttrs' paths (path:
        krad246.attrsets.stemValuePair path {
          file = path;
        }))
    // (let
      paths = krad246.fileset.filterExt "age" ./secrets/system/hercules-ci;
    in
      krad246.attrsets.genAttrs' paths (path:
        krad246.attrsets.stemValuePair path {
          file = path;
          mode = "770";
          group = "_hercules-ci-agent";
        }));
}
