{
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [self.modules.generic.hercules-ci-agent];

  # point the darwin CI agent to our secrets' runtime decryption paths.
  services.hercules-ci-agent = {
    settings = {
      binaryCachesPath = config.age.secrets.dullahan-binary-caches.path;
      clusterJoinTokenPath = config.age.secrets.dullahan-cluster-join-token.path;
    };
  };

  krad246.darwin.virtualisation.linux-builder.extraConfig = _: {
    imports = [self.modules.generic.hercules-ci-agent];
    networking.hostName = "headless-penguin";
  };

  system.activationScripts = {
    postActivation = {
      text = let
        inherit (config.age.secrets) headless-penguin-binary-caches headless-penguin-cluster-join-token;
        inherit (config.services) hercules-ci-agent;
      in ''
        ${lib.meta.getExe pkgs.rsync} ${headless-penguin-binary-caches.path}      builder@linux-builder:${hercules-ci-agent.settings.binaryCachesPath}
        ${lib.meta.getExe pkgs.rsync} ${headless-penguin-cluster-join-token.path} builder@linux-builder:${hercules-ci-agent.settings.clusterJoinTokenPath}
      '';
    };
  };
}
