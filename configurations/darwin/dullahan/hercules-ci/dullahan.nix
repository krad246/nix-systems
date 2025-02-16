{
  specialArgs,
  config,
  ...
}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.age.secrets.dullahan-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.dullahan-cluster-join-token.path;
    };
  };

  age.secrets = let
    inherit (specialArgs) krad246;
    paths = krad246.fileset.filterExt "age" ../secrets/system/hercules-ci;
  in
    krad246.attrsets.genAttrs' paths (path:
      krad246.attrsets.stemValuePair path {
        file = path;
        mode = "770";
        group = "_hercules-ci-agent";
      });
}
