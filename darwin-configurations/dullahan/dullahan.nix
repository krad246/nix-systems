{
  ezModules,
  config,
  ...
}: {
  imports = with ezModules; [
    darwin
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

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["docker"] ++ ["signal"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
