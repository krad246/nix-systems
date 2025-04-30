{
  self,
  config,
  ...
}: {
  imports = [
    self.modules.nixos.hercules-ci-agent
  ];

  services.hercules-ci-agent = {
    settings = {
      concurrentTasks = 16;
      clusterJoinTokenPath = config.age.secrets."cluster-join-token.key".path;
      binaryCachesPath = config.age.secrets."binary-caches.json".path;
      secretsJsonPath = config.age.secrets."secrets.json".path;
    };
  };

  # CI agent secrets:
  # - binary-caches.json (optional): push-pull access to a binary cache
  # - cluster-join-token.key: access to Hercules CI API
  # - secrets.json: secrets needed for effects
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

  # allow login with the machine host key for CI deployments
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];
}
