{
  inputs,
  self,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.hercules-ci-agent.nixosModules.agent-profile
    self.modules.nixos.hercules-ci-agent
  ];

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

  # host-side install of hercules CI agent
  services.hercules-ci-agent = {
    enable = true; # enable all child options for this module (including the user that gets created)
    settings = {
      concurrentTasks = 8;
      clusterJoinTokenPath = config.age.secrets."cluster-join-token.key".path;
      binaryCachesPath = config.age.secrets."binary-caches.json".path;
      secretsJsonPath = config.age.secrets."secrets.json".path;
    };
  };

  # disable the systemd service on the host since we're moving to containerize the agent
  # but we could just as easily re-enable the host-side install
  systemd.services = lib.modules.mkIf config.services.hercules-ci-agent.enable {
    hercules-ci-agent = {
      enable = true;

      # for working self-deployments, we need the agent to not kill itself mid system reload.
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };

    hercules-ci-agent-restarter = {
      enable = true;

      # for working self-deployments, we need the agent to not kill itself mid system reload.
      restartIfChanged = false;
      reloadIfChanged = false;
      stopIfChanged = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];
}
