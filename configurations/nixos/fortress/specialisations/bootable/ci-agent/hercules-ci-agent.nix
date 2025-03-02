{config, ...}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      clusterJoinTokenPath = config.age.secrets.cluster-join-token.path;
      binaryCachesPath = config.age.secrets.binary-caches.path;
      concurrentTasks = 48;
      nixVerbosity = "Warn";
    };
  };
}
