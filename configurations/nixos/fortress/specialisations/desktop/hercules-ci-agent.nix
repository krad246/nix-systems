{config, ...}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      clusterJoinTokenPath = config.age.secrets.hercules-token.path;
      binaryCachesPath = config.age.secrets.cachix.path;
    };
  };
}
