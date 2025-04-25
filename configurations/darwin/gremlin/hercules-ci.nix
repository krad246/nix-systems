{
  inputs,
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [self.modules.generic.hercules-ci-agent inputs.hercules-ci-agent.darwinModules.agent-profile];

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
      concurrentTasks = 4;
      binaryCachesPath = config.age.secrets."gremlin/binary-caches.json".path;
      clusterJoinTokenPath = config.age.secrets."gremlin/cluster-join-token.key".path;
    };
  };

  krad246.darwin.virtualisation.linux-builder = {
    extraConfig = {
      imports =
        (with inputs.hercules-ci-agent.nixosModules; [
          agent-profile
        ])
        ++ [self.modules.generic.hercules-ci-agent];

      services.hercules-ci-agent.settings.concurrentTasks = 2;

      nix.settings.keep-going = false;

      networking.hostName = "smeagol";

      # same identity that decrypts the host side secrets will be used to access root on the linux-builder
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0IJSgLQ/JomKuYZVV5/ZuboysqBJQCgBcHTvKklQDb root@gremlin"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCbmq/8XMXMyBDrFSPCphoMvWrdjPxzjJZko+KO1eAoeH3IQVD2YX5veyw5HWUUXHdoG4qTEAMnNjXWhyC+fiQnyLW2O/hiP/1NOCVMVM5hdRnBULSvPgza9PgrOTIvaZtIRYs/Ks5oDzbWw2+JgvVq727VDHKSGWhAzFx5aEp5Ch76Hqo83xZVEuAaUCFoTk210dRaQBVUJ9h6y/AL85gIkYYzj4HwR96yX+GuIe1N9iW2s6h5ZhdWhFCWu9AR4pUjBsS7Lk9rnojegA8i5QTk5tzX0hJQA59fR5DdEDKZTDYcZzD62HRbuGbc3KmdUkS7JK3K9VO9cy/JBVoJpAmDE6AKtCtd7rwQgm0YJAzOKzbd47f7VSSpakAFhDNWp1GhhRRqljHf901xQyNVKjoCxv6ojNP7S+LUlE7RK7UinYYzqF5F30YtWbXytKmQPo24z92LtPi7/lr/li8zmMbaifAlT32psUWdQg/prYj+G5xS18BkswCrSyco06v1svk= root@gremlin"
      ];

      # give the only interactive user the ability to see the logs
      users.users.builder.extraGroups = ["systemd-journal"];
    };
  };

  system.activationScripts = {
    postActivation = let
      # Convert the list of identity files to a command line that passes each one.
      identityFiles = lib.strings.concatMapStringsSep " " (x: "-i ${x}") config.age.identityPaths;
      printf = lib.meta.getExe' pkgs.coreutils "printf";
      rsync = lib.meta.getExe pkgs.rsync;
      ssh = lib.meta.getExe pkgs.openssh;
      sleep = lib.meta.getExe' pkgs.coreutils "sleep";
      copyFiles = [
        config.age.secrets."smeagol/binary-caches.json".path
        config.age.secrets."smeagol/cluster-join-token.key".path
        config.age.secrets."gremlin/secrets.json".path
      ];
    in {
      text = ''
        #!${pkgs.stdenv.shell}

        # wait for the VM to come up, then use our host key to log in, so that we can rsync our secrets to the hercules-ci-agent.
        until ${printf} >&2 'copying keys to linux-builder...\n' &&
                ${rsync} -q -e "${ssh} -q ${identityFiles}" \
                  --mkpath --chmod 0600 --chown hercules-ci-agent:hercules-ci-agent \
                    ${lib.strings.concatStringsSep " " copyFiles} root@linux-builder:${config.services.hercules-ci-agent.settings.staticSecretsDirectory}/; do
            ${sleep} 0.5
        done

        ${ssh} root@linux-builder ${identityFiles} systemctl restart hercules-ci-agent
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
