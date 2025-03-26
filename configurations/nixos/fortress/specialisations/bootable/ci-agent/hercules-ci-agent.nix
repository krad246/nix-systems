{
  inputs,
  self,
  config,
  ...
}: {
  imports = [inputs.hercules-ci-agent.nixosModules.agent-profile] ++ [self.modules.generic.hercules-ci-agent];

  services.hercules-ci-agent = {
    settings = {
      clusterJoinTokenPath = config.age.secrets.cluster-join-token.path;
      binaryCachesPath = config.age.secrets.binary-caches.path;
    };
  };
}
