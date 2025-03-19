{
  self,
  specialArgs,
  lib,
  ...
}: {
  krad246.darwin.virtualisation.linux-builder.extraConfig = {config, ...}: {
    imports = [self.nixosModules.agenix];

    networking.hostName = "headless-penguin";

    services.hercules-ci-agent = {
      enable = true;
      settings = {
        clusterJoinTokenPath = config.age.secrets.headless-penguin-cluster-join-token.path;
        binaryCachesPath = config.age.secrets.headless-penguin-binary-caches.path;
        concurrentTasks = 12;
        nixVerbosity = "Warn";
      };
    };

    # pull all .age files and give them to the CI agent
    age.secrets = let
      inherit (specialArgs) krad246;
      paths = krad246.fileset.filterExt "age" ../secrets/system;
    in
      krad246.attrsets.genAttrs' paths (path:
        krad246.attrsets.stemValuePair path {
          file = path;
          mode = "770";
          group = "hercules-ci-agent";
        });

    # enable remote SSH connections into the builder for other machines
    users.users.builder = {
      extraGroups = ["systemd-journal"];
      openssh.authorizedKeys.keys = let
        inherit (specialArgs) krad246;
        paths = krad246.fileset.filterExt "pub" ../authorized_keys;
      in
        lib.lists.forEach paths (path: builtins.readFile path);
    };

    nix = {
      daemonIOSchedClass = lib.mkDefault "idle";
      daemonCPUSchedPolicy = lib.mkDefault "idle";
    };

    # put the service in top-level slice
    # so that it's lower than system and user slice overall
    # instead of only being lower in system slice
    systemd.services.nix-daemon.serviceConfig.Slice = "-.slice";

    # always use the daemon, even executed  with root
    environment.variables.NIX_REMOTE = "daemon";

    systemd.services.nix-daemon.serviceConfig = {
      memoryHigh = "7G";
    };
  };
}
