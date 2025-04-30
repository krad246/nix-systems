{
  self,
  config,
  ...
}: {
  imports = [self.modules.darwin.hercules-ci-agent];

  # point the darwin CI agent to our secrets' runtime decryption paths.
  services.hercules-ci-agent = {
    settings = {
      concurrentTasks = 6;
      binaryCachesPath = config.age.secrets."gremlin/binary-caches.json".path;
      clusterJoinTokenPath = config.age.secrets."gremlin/cluster-join-token.key".path;
    };
  };

  nix.settings.keep-going = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD6hLeL5EzA8msaTLS964+fPIwtHPWSRZU3nVEGaNi5 _hercules-ci-agent@gremlin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj/uRwLu2OnR99uZSIZYOVeLJGh1DLBrHRabYF2ofho _hercules-ci-agent@dullahan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/5yaElFDoFQtyZAg2yJaqr+7JjJx0LiWlRUoTRYkPL hercules-ci-agent@fortress"
  ];

  nix.gc.user = "root";
}
