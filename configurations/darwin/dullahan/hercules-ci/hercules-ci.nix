{
  config,
  lib,
  pkgs,
  ...
}: {
  services.hercules-ci-agent = {
    enable = true;
    settings = {
      binaryCachesPath = config.age.secrets.dullahan-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.dullahan-cluster-join-token.path;
      concurrentTasks = "auto";
    };
  };

  environment.variables.NIX_REMOTE = "daemon";

  krad246.darwin.virtualisation.linux-builder.extraConfig = _: {
    networking.hostName = "headless-penguin";

    services.hercules-ci-agent = {
      enable = true;
      settings = {
        # clusterJoinTokenPath = config.age.secrets.headless-penguin-cluster-join-token.path;
        # binaryCachesPath = config.age.secrets.headless-penguin-binary-caches.path;
        concurrentTasks = 12;
        nixVerbosity = "Warn";
      };
    };

    users.users.builder = {
      extraGroups = ["systemd-journal"];
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

  system.activationScripts = {
    postActivation = {
      enable = true;
      text = ''
        set -x
        ${lib.meta.getExe pkgs.rsync} ${config.age.secrets.headless-penguin-binary-caches.path} builder@linux-builder:~/binary-caches.json
        ${lib.meta.getExe pkgs.rsync} ${config.age.secrets.headless-penguin-cluster-join-token.path} builder@linux-builder:~/cluster-join-token.key
      '';
    };
  };
}
