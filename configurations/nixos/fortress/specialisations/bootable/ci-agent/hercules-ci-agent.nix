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

  systemd.services.hercules-ci-agent = {
    reloadIfChanged = false;
    restartIfChanged = false;
    stopIfChanged = false;
    serviceConfig.RemainAfterExit = true;
  };

  systemd.services.hercules-ci-agent-restarter = {
    reloadIfChanged = false;
    restartIfChanged = false;
    stopIfChanged = false;
    serviceConfig.RemainAfterExit = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];
}
