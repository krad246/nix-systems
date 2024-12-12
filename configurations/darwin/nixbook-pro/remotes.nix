{
  self,
  config,
  ...
}: {
  imports = [
    self.modules.generic.dullahan
    self.modules.generic.fortress
  ];

  krad246.remotes.dullahan = {
    enable = true;
    sshUser = "krad246";
    sshKey = config.age.secrets.id_ed25519_priv.path;
    maxJobs = 24;
  };

  krad246.remotes.fortress = {
    enable = true;
    sshUser = "krad246";
    sshKey = config.age.secrets.id_ed25519_priv.path;
    maxJobs = 144;
    speedFactor = 2;
  };
}
