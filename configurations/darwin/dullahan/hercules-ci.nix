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
    dullahan-binary-caches.name = "dullahan/binary-caches.json";
    dullahan-cluster-join-token.name = "dullahan/cluster-join-token.key";
    dullahan-secrets.name = "dullahan/secrets.json";
    headless-penguin-binary-caches.name = "headless-penguin/binary-caches.json";
    headless-penguin-cluster-join-token.name = "headless-penguin/cluster-join-token.key";
  };

  # point the darwin CI agent to our secrets' runtime decryption paths.
  services.hercules-ci-agent = {
    settings = {
      binaryCachesPath = config.age.secrets.dullahan-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.dullahan-cluster-join-token.path;
    };
  };

  krad246.darwin.virtualisation.linux-builder.extraConfig = {
    imports =
      (with inputs.hercules-ci-agent.nixosModules; [
        agent-profile
      ])
      ++ [self.modules.generic.hercules-ci-agent];

    nix.settings.keep-going = false;

    networking.hostName = "headless-penguin";

    # same identity that decrypts the host side secrets will be used to access root on the linux-builder
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXafRdLT+qPTMUzzMc35PxOP4zun6zIPTf98jQ6Bv5P"
    ];

    # give the only interactive user the ability to see the logs
    users.users.builder.extraGroups = ["systemd-journal"];

    # Allow the CI VM to join my tailnet
    services.tailscale.enable = true;
  };

  system.activationScripts = {
    postActivation = let
      # Convert the list of identity files to a command line that passes each one.
      identityFiles = lib.strings.concatMapStringsSep " " (x: "-i ${x}") config.age.identityPaths;
      printf = lib.meta.getExe' pkgs.coreutils "printf";
      rsync = lib.meta.getExe pkgs.rsync;
      ssh = lib.meta.getExe pkgs.openssh;
      sleep = lib.meta.getExe' pkgs.coreutils "sleep";
    in {
      text = ''
        #!${pkgs.stdenv.shell}

        # wait for the VM to come up, then use our host key to log in, so that we can rsync our secrets to the hercules-ci-agent.
        until ${printf} >&2 'copying keys to linux-builder...\n' &&
                ${rsync} -q -e "${ssh} -q ${identityFiles}" --mkpath --chmod 0600 --chown hercules-ci-agent:hercules-ci-agent -o hercules-ci-agent -g hercules-ci-agent \
                  ${config.age.secrets.headless-penguin-binary-caches.path} \
                  ${config.age.secrets.headless-penguin-cluster-join-token.path} \
                  ${config.age.secrets.dullahan-secrets.path} \
                    root@linux-builder:${config.services.hercules-ci-agent.settings.staticSecretsDirectory}/ 2>/dev/null; do
            ${sleep} 1
        done

        ${ssh} root@linux-builder ${identityFiles} systemctl restart hercules-ci-agent
      '';
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj/uRwLu2OnR99uZSIZYOVeLJGh1DLBrHRabYF2ofho _hercules-ci-agent@dullahan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD6hLeL5EzA8msaTLS964+fPIwtHPWSRZU3nVEGaNi5 _hercules-ci-agent@gremlin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];

  nix.gc.user = "root";
}
