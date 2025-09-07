{config, ...}: {
  age.secrets = {
    "dullahan/binary-caches.json" = {
      file = ./secrets/hercules-ci/dullahan/binary-caches.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "dullahan/binary-caches.json";
    };

    "dullahan/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/dullahan/cluster-join-token.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "dullahan/cluster-join-token.key";
    };

    "dullahan/secrets.json" = {
      file = ./secrets/hercules-ci/dullahan/secrets.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "dullahan/secrets.json";
    };

    "headless-penguin/binary-caches.json" = {
      file = ./secrets/hercules-ci/headless-penguin/binary-caches.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "headless-penguin/binary-caches.json";
    };

    "headless-penguin/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/headless-penguin/cluster-join-token.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "headless-penguin/cluster-join-token.key";
    };

    "headless-penguin/tailscale-auth.key" = {
      file = ./secrets/hercules-ci/headless-penguin/tailscale-auth-key.age;
      mode = "0400";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "headless-penguin/tailscale-auth.key";
    };
  };
}
