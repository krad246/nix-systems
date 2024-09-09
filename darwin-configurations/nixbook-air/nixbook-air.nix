{
  ezModules,
  config,
  ...
}: {
  imports = with ezModules; [
    darwin
  ];

  users = {
    users.krad246 = {
      home = "/Users/krad246";
      createHome = true;
      uid = 501;
      gid = 20;
      shell = "${config.homebrew.brewPrefix}/bash";
    };
    knownUsers = ["krad246"];
  };

  # add SSH access for remote building
  environment.etc."ssh/ssh_config.d/101-dullahan.conf".text = ''
    Host dullahan
      HostName dullahan.local
      User krad246

      IdentitiesOnly yes
      IdentityFile ${config.age.secrets."id_ed25519_priv.age".path}
  '';

  # add a remote builder!
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "dullahan";
        system = "aarch64-darwin";
        protocol = "ssh-ng";
        maxJobs = 16;
        speedFactor = 2;

        sshUser = "krad246";
        sshKey = config.age.secrets."id_ed25519_priv.age".path;
      }
    ];
  };

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["signal"] ++ ["spotify"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
