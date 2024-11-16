{
  self,
  config,
  ...
}: {
  imports = with self.darwinModules; [
    darwin
    dock
    finder
    pointer
    single-user
    ui-ux
  ];

  # add nix to sshd path so nix store is pingable
  environment.etc."ssh/sshd_config.d/102-sshd-nix-env-on-path".text = ''
    SetEnv PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  '';

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
  homebrew = {
    brews = ["wakeonlan"];
    casks = ["arc"] ++ ["bluesnooze"] ++ ["docker"] ++ ["windows-app"] ++ ["wireshark"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  # add SSH access for remote building
  environment.etc."ssh/ssh_config.d/101-fortress.conf".text = ''
    Host fortress
      HostName fortress.local
      User krad246

      IdentitiesOnly yes
      IdentityFile ${config.age.secrets."id_ed25519_priv.age".path}
      StrictHostKeyChecking no
  '';

  # add a remote builder!
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "fortress";
        systems = ["x86_64-linux"];
        protocol = "ssh-ng";
        maxJobs = 64;
        speedFactor = 3;
        sshUser = "krad246";
        sshKey = config.age.secrets."id_ed25519_priv.age".path;
      }
    ];

    linux-builder.maxJobs = 20;
  };
}
