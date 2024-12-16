{
  self,
  config,
  ...
}: {
  imports = [
    self.modules.generic.fortress
  ];

  krad246.remotes.fortress = {
    enable = true;
    sshUser = "krad246";
    sshKey = config.age.secrets.id_ed25519_priv.path;
    maxJobs = 72;
    speedFactor = 3;
  };
}
