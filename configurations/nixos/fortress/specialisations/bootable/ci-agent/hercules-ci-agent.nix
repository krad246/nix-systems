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

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg9s+XAwWrvRf0k16ua9/3tpxbohrTGJEp4rOPnqgOh root@fortress"
  ];
}
