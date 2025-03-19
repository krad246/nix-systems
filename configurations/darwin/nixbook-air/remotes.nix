{self, ...}: {
  imports = [
    self.modules.generic.dullahan
    self.modules.generic.fortress
  ];

  krad246.remotes.dullahan = {
    enable = false;
    sshUser = "krad246";
    maxJobs = 24;
  };

  krad246.remotes.fortress = {
    enable = false;
    sshUser = "krad246";
    maxJobs = 144;
    speedFactor = 4;
  };
}
