{config, ...}: {
  environment.etc = {
    "ssh/ssh_config.d/103-fortress.conf".text = ''
      Host fortress
        HostName fortress.local
        User krad246

        IdentitiesOnly yes
        IdentityFile ${config.age.secrets."id_ed25519_priv.age".path}
        StrictHostKeyChecking no

        ConnectTimeout 60
    '';
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "fortress";
        systems = ["x86_64-linux"];
        protocol = "ssh-ng";
        maxJobs = 64;
        speedFactor = 4;
        sshUser = "krad246";
        sshKey = config.age.secrets."id_ed25519_priv.age".path;
      }
    ];
  };
}
