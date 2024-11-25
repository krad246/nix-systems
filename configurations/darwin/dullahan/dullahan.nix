{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules;
    [
      arc
      bluesnooze
      sshd
      wake-on-lan
    ]
    ++ [
      darwin
      dock
      finder
      pointer
      single-user
      ui-ux
    ];

  users = {
    users = {
      krad246 = {
        home = "/Users/krad246";
        createHome = true;

        uid = 501;
        gid = 20;

        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzCjoarVDF5bnWX3SBciYyaiMzGnzTF9uefbja5xLB0"
          ];
        };

        shell = "${config.homebrew.brewPrefix}/bash";
      };
    };

    knownUsers = ["krad246"];
  };

  nix-homebrew.user = "krad246";

  nixpkgs.hostPlatform = "aarch64-darwin";

  # add a remote builder!
  nix = {
    distributedBuilds = true;
    linux-builder.maxJobs = 20;
  };
}
