{self, ...}: {
  imports = [
    self.modules.generic.dullahan
    self.modules.generic.gremlin
    self.modules.generic.fortress
  ];

  krad246.remotes = {
    dullahan = {
      enable = false;
      sshUser = "krad246";
      maxJobs = 24;
    };

    gremlin = {
      enable = false;
      sshUser = "krad246";
      maxJobs = 72;
    };

    fortress = {
      enable = false;
      sshUser = "krad246";
      maxJobs = 144;
      speedFactor = 2;
    };
  };
}
