{
  ezModules,
  pkgs,
  ...
}: {
  imports = with ezModules; [
    darwin
  ];

  # add nix to sshd path so nix store is pingable
  environment.etc."ssh/sshd_config.d/102-sshd-nix-env-on-path".text = ''
    SetEnv PATH=/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  '';

  environment.etc."ssh/sshd_config.d/103-sshd-use-pam".text = ''
    UsePAM yes
  '';

  users = {
    users = {
      krad246 = {
        home = "/Users/krad246";
        createHome = true;

        uid = 501;
        gid = 20;
      };

      nixremote = {
        home = "/Users/nixremote";
        createHome = true;

        openssh.authorizedKeys = {
          # public key of krad246@nixbook-air
          keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxG+GLvLuIXhSskofvux2kvRBSDECBf6G3+9rUguER1"];
        };

        uid = 502;
        gid = 20;

        shell = pkgs.bashInteractive;
      };
    };

    knownUsers = ["krad246" "nixremote"];
  };

  nix.settings.trusted-users = ["nixremote"];

  homebrew = {
    casks = ["arc"] ++ ["bluesnooze"] ++ ["docker"] ++ ["signal"];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
