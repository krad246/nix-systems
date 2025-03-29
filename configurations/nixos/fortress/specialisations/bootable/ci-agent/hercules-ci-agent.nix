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

  systemd.services = {
    hercules-ci-agent = {
      stopIfChanged = false;
    };

    hercules-ci-agent-restarter = {
      stopIfChanged = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];
}
