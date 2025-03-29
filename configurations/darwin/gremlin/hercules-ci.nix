{
  inputs,
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [self.modules.generic.hercules-ci-agent];

  # stop on the first failure
  nix.settings.keep-going = false;

  # secrets aliases, really
  age.secrets = {
    "gremlin/binary-caches.json" = {
      file = ./secrets/hercules-ci/gremlin/binary-caches.age;
      mode = "0600";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/binary-caches.json";
    };

    "gremlin/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/gremlin/cluster-join-token.age;
      mode = "0600";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/cluster-join-token.key";
    };

    "gremlin/secrets.json" = {
      file = ./secrets/hercules-ci/gremlin/secrets.age;
      mode = "0600";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "gremlin/secrets.json";
    };

    "smeagol/binary-caches.json" = {
      file = ./secrets/hercules-ci/smeagol/binary-caches.age;
      mode = "0600";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "smeagol/binary-caches.json";
    };

    "smeagol/cluster-join-token.key" = {
      file = ./secrets/hercules-ci/smeagol/cluster-join-token.age;
      mode = "0600";
      owner = config.users.users._hercules-ci-agent.name;
      group = config.users.groups._hercules-ci-agent.name;
      name = "smeagol/cluster-join-token.key";
    };
  };

  # point the darwin CI agent to our secrets' runtime decryption paths.
  services.hercules-ci-agent = {
    settings = {
      binaryCachesPath = config.age.secrets."gremlin/binary-caches.json".path;
      clusterJoinTokenPath = config.age.secrets."gremlin/cluster-join-token.key".path;
    };
  };

  krad246.darwin.virtualisation.linux-builder = {
    systems = ["aarch64-linux" "x86_64-linux"];
    extraConfig = {
      imports =
        (with inputs.hercules-ci-agent.nixosModules; [
          agent-profile
        ])
        ++ [self.modules.generic.hercules-ci-agent];

      nix.settings.keep-going = false;

      networking.hostName = "smeagol";

      # same identity that decrypts the host side secrets will be used to access root on the linux-builder
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0IJSgLQ/JomKuYZVV5/ZuboysqBJQCgBcHTvKklQDb root@gremlin"
      ];

      # give the only interactive user the ability to see the logs
      users.users.builder.extraGroups = ["systemd-journal"];
    };
  };

  system.activationScripts = {
    postActivation = {
      text = ''
        #!${pkgs.stdenv.shell}

        # wait for the VM to come up, then use our host key to log in, so that we can rsync our secrets to the hercules-ci-agent.
        until ${lib.meta.getExe pkgs.rsync} -q -e "${lib.meta.getExe pkgs.openssh} -q -i /etc/ssh/ssh_host_ed25519_key" \
          --chmod 0600 --chown hercules-ci-agent:hercules-ci-agent --mkpath \
          ${config.age.secrets."smeagol/binary-caches.json".path} \
          ${config.age.secrets."smeagol/cluster-join-token.key".path} \
          ${config.age.secrets."gremlin/secrets.json".path} \
            root@linux-builder:${config.services.hercules-ci-agent.settings.staticSecretsDirectory}/ 2>/dev/null; do

            ${lib.meta.getExe' pkgs.coreutils "printf"} >&2 'copying keys to linux-builder...\n'
            ${lib.meta.getExe' pkgs.coreutils "sleep"} 1
        done

        ${lib.meta.getExe pkgs.openssh} root@linux-builder -i /etc/ssh/ssh_host_ed25519_key systemctl restart hercules-ci-agent
      '';
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD6hLeL5EzA8msaTLS964+fPIwtHPWSRZU3nVEGaNi5 _hercules-ci-agent@gremlin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj/uRwLu2OnR99uZSIZYOVeLJGh1DLBrHRabYF2ofho _hercules-ci-agent@dullahan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];

  nix.gc.user = "root";
}
