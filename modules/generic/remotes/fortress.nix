{
  config,
  lib,
  ...
}: let
  cfg = config.krad246.remotes.fortress;
in {
  options = {
    krad246.remotes.fortress = {
      enable = lib.options.mkEnableOption "fortress";

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
      "ssh/ssh_config.d/103-fortress.conf".text = ''
        Host fortress
          HostName fortress.tailb53085.ts.net
          User ${cfg.sshUser}
          IdentitiesOnly yes
          ${lib.strings.optionalString (cfg.sshKey != null) ''IdentityFile ${cfg.sshKey}''}
          ConnectTimeout ${builtins.toString cfg.connectTimeout}
      '';
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "fortress";
          systems = ["x86_64-linux" "aarch64-linux"];
          protocol = "ssh-ng";
          inherit (cfg) maxJobs;
          inherit (cfg) speedFactor;
          inherit (cfg) sshUser;
          inherit (cfg) sshKey;
        }
      ];
    };
  };
}
