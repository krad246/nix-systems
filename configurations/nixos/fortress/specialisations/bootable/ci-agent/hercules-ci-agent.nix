{
  inputs,
  self,
  config,
  ...
}: {
  imports = [
    inputs.hercules-ci-agent.nixosModules.agent-profile
    self.modules.generic.hercules-ci-agent
  ];

  age.secrets = {
    "binary-caches.json" = {
      file = ./secrets/hercules-ci-agent/binary-caches.age;
      mode = "0600";
      owner = config.users.users.hercules-ci-agent.name;
      group = config.users.groups.hercules-ci-agent.name;
      name = "hercules-ci/binary-caches.json";
    };

    "cluster-join-token.key" = {
      file = ./secrets/hercules-ci-agent/cluster-join-token.age;
      mode = "0600";
      owner = config.users.users.hercules-ci-agent.name;
      group = config.users.groups.hercules-ci-agent.name;
      name = "hercules-ci/cluster-join-token.key";
    };

    "secrets.json" = {
      file = ./secrets/hercules-ci-agent/secrets.age;
      mode = "0600";
      owner = config.users.users.hercules-ci-agent.name;
      group = config.users.users.hercules-ci-agent.name;
      name = "hercules-ci/secrets.json";
    };
  };

  services.hercules-ci-agent = {
    settings = {
      clusterJoinTokenPath = config.age.secrets."cluster-join-token.key".path;
      binaryCachesPath = config.age.secrets."binary-caches.json".path;
      secretsJsonPath = config.age.secrets."secrets.json".path;
    };
  };

  systemd.services = {
    hercules-ci-agent = {
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };

    hercules-ci-agent-restarter = {
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];
}
