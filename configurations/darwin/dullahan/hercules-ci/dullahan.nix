{config, ...}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.age.secrets.dullahan-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.dullahan-cluster-join-token.path;
      concurrentTasks = 12;
    };
  };

  environment.variables.NIX_REMOTE = "daemon";
}
