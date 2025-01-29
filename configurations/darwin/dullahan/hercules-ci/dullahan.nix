{lib, ...}: {
  services.hercules-ci-agent = {
    enable = true;
  };

  age.secrets = let
    inherit (lib) krad246;
    paths = krad246.fileset.filterExt "age" ../secrets/system/hercules-ci;
  in
    krad246.attrsets.genAttrs' paths (path: krad246.attrsets.stemValuePair path {file = path;});
}
