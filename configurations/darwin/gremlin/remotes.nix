{self, ...}: {
  imports = [
    self.modules.generic.dullahan
    self.modules.generic.fortress
  ];

  krad246.remotes = {
    dullahan = {
      enable = true;
      sshUser = "krad246";
      maxJobs = 24;
      connectTimeout = 30;
    };

    fortress = {
      enable = true;
      sshUser = "krad246";
      maxJobs = 144;
      speedFactor = 2;
      connectTimeout = 30;
    };
  };
}
