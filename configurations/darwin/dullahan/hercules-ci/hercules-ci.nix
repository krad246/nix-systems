{
  self,
  config,
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
      # TODO: share decrypted agenix files with hercules-ci-agent
      text = ''
      '';
    };
  };
}
