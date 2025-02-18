{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.remotes.dullahan;
in {
  options = {
    krad246.remotes.dullahan = {
      enable = lib.options.mkEnableOption "dullahan";

      sshUser = lib.options.mkOption {
        type = lib.types.str;
        example = "alice";
      };

      sshKey = lib.options.mkOption {
        type = lib.types.str;
        default = null;
        example = "/home/alice/.ssh/id_ed25519";
      };

      connectTimeout = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 120;
        example = 30;
      };

      maxJobs = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 8;
        example = 4;
        description = ''
          The number of concurrent jobs the Linux builder machine supports. The
          build machine will enforce its own limits, but this allows hydra
          to schedule better since there is no work-stealing between build
          machines.

          This sets the corresponding `nix.buildMachines.*.maxJobs` option.
        '';
      };

      speedFactor = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 1;
        example = 2;
        description = ''
          The relative speed of this builder. This is an arbitrary integer that indicates the speed of this builder, relative to other builders. Higher is faster.
        '';
      };
    };
  };

  config = lib.modules.mkIf cfg.enable {
    environment.etc = {
      "ssh/ssh_config.d/101-dullahan.conf".text = ''
        Host dullahan
          HostName dullahan.local
          User ${cfg.sshUser}
          IdentitiesOnly yes
          ${lib.strings.optionalString (cfg.sshKey != null) ''IdentityFile ${cfg.sshKey}''}
          ConnectTimeout ${builtins.toString cfg.connectTimeout}
      '';

      "ssh/ssh_config.d/102-headless-penguin.conf".text = ''
        Host headless-penguin
          User builder
          HostName localhost
          Port 31022

          ProxyJump dullahan

          IdentitiesOnly yes
          IdentityFile /etc/nix/builder_ed25519
          ConnectTimeout ${builtins.toString cfg.connectTimeout}
      '';
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "dullahan";
          system = "aarch64-darwin";
          protocol = "ssh-ng";
          inherit (cfg) maxJobs;
          inherit (cfg) speedFactor;
          inherit (cfg) sshUser;
          inherit (cfg) sshKey;
        }
        {
          hostName = "headless-penguin";
          systems = ["aarch64-linux" "x86_64-linux"];
          protocol = "ssh-ng";
          inherit (cfg) maxJobs;
          inherit (cfg) speedFactor;
          sshUser = "builder";
          sshKey = "/etc/nix/builder_ed25519";
        }
      ];
    };
  };
}
