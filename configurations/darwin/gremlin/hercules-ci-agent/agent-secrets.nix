{config, ...}: {
  age.secrets = {
    "gremlin/binary-caches.json" = {
      file = ./secrets/hercules-ci/gremlin/binary-caches.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/binary-caches.json";
    };

    "gremlin/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/gremlin/cluster-join-token.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/cluster-join-token.key";
    };

    "gremlin/secrets.json" = {
      file = ./secrets/hercules-ci/gremlin/secrets.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/secrets.json";
    };

    "smeagol/binary-caches.json" = {
      file = ./secrets/hercules-ci/smeagol/binary-caches.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "smeagol/binary-caches.json";
    };

    "smeagol/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/smeagol/cluster-join-token.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "smeagol/cluster-join-token.key";
    };
  };
}
