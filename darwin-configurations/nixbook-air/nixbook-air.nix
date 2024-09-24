{
  ezModules,
  config,
  ...
}: {
  imports = with ezModules; [
    darwin
    dock
    finder
    pointer
    single-user
    ui-ux
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

  environment.etc = {
    "ssh/ssh_config.d/101-dullahan.conf".text = ''
      Host dullahan
        HostName dullahan.local
        User krad246

        IdentitiesOnly yes
        IdentityFile ${config.age.secrets."id_ed25519_priv.age".path}
    '';

    "ssh/ssh_config.d/102-headless-penguin.conf".text = ''
      Host headless-penguin
        User builder
        HostName localhost
        Port 31022

        ProxyJump dullahan

        IdentitiesOnly yes
        IdentityFile /etc/nix/builder_ed25519
    '';

    "ssh/ssh_config.d/103-fortress.conf".text = ''
      Host fortress
        HostName fortress.local
        User krad246

        IdentitiesOnly yes
        IdentityFile ${config.age.secrets."id_ed25519_priv.age".path}
        StrictHostKeyChecking no
    '';
  };

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
      {
        hostName = "headless-penguin";
        systems = ["aarch64-linux" "x86_64-linux"];
        protocol = "ssh-ng";
        maxJobs = 16;
        speedFactor = 2;
        sshUser = "builder";
        sshKey = "/etc/nix/builder_ed25519";
      }
      {
        hostName = "fortress";
        systems = ["x86_64-linux"];
        protocol = "ssh-ng";
        maxJobs = 128;
        speedFactor = 8;
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
