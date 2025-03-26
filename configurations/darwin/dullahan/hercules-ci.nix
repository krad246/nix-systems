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
  };

  system.activationScripts = {
    postActivation = {
      text = ''
        #!${pkgs.stdenv.shell}

        # wait for the VM to come up, then use our host key to log in, so that we can rsync our secrets to the hercules-ci-agent.
        until ${lib.meta.getExe pkgs.rsync} -q -e "${lib.meta.getExe pkgs.openssh} -q -i /etc/ssh/ssh_host_ed25519_key" \
          --chmod 0600 --chown hercules-ci-agent:hercules-ci-agent --mkpath \
          ${config.age.secrets.headless-penguin-binary-caches.path} \
          ${config.age.secrets.headless-penguin-cluster-join-token.path} \
            root@linux-builder:${config.services.hercules-ci-agent.settings.staticSecretsDirectory}/; do
            :
        done
      '';
    };
  };

  users.users.krad246.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj/uRwLu2OnR99uZSIZYOVeLJGh1DLBrHRabYF2ofho _hercules-ci-agent@dullahan"
  ];
}
#

