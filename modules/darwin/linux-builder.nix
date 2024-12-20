{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.linux-builder;
  inherit (lib) options types;
in {
  options = {
    krad246.darwin.linux-builder = {
      maxJobs = options.mkOption {
        type = types.ints.positive;
        default = 16;
        example = 4;
        description = ''
          The number of concurrent jobs the Linux builder machine supports. The
          build machine will enforce its own limits, but this allows hydra
          to schedule better since there is no work-stealing between build
          machines.

          This sets the corresponding `nix.buildMachines.*.maxJobs` option.
        '';
      };

      cores = options.mkOption {
        type = types.ints.positive;
        default = 8;
        description = ''
          Specify the number of cores the guest is permitted to use.
          The number can be higher than the available cores on the
          host system.
        '';
      };

      memorySize = options.mkOption {
        default = 6 * 1024;
        type = types.ints.positive;
        example = 8192;
        description = "The runner's memory in MB";
      };

      diskSize = options.mkOption {
        default = 32 * 1024;
        type = types.ints.positive;
        example = 30720;
        description = "The maximum disk space allocated to the runner in MB";
      };

      swapSize = options.mkOption {
        default = 16 * 1024;
        type = types.ints.positive;
        example = 30720;
        description = "The maximum disk space allocated to the runner's swapfile in MB";
      };

      ephemeral = options.mkEnableOption "ephemeral";

      extraConfig = options.mkOption {
        type = types.deferredModule;
        default = {};
        example = options.literalExpression ''{}'';
        description = ''
          This option specifies extra NixOS configuration for the builder.
        '';
      };

      systems = options.mkOption {
        type = types.listOf types.str;
        default = ["i386-linux" "i686-linux" "x86_64-linux" "aarch64-linux"];

        defaultText = ''
          The `nixpkgs.hostPlatform.system` of the build machine's final NixOS configuration.
        '';
        example = options.literalExpression ''
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
        '';
        description = ''
          This option specifies system types the build machine can execute derivations on.

          This sets the corresponding `nix.buildMachines.*.systems` option.
        '';
      };
    };
  };

  config = {
    nix = {
      settings.trusted-users = ["@admin" "@wheel"];

      linux-builder = {
        enable = true;
        protocol = "ssh-ng";

        config = {pkgs, ...}: let
          inherit (pkgs.stdenv) system;
          inherit (config.nix) linux-builder;
        in {
          imports =
            (with self; [modules.generic.nix-core nixosModules.ccache-stdenv nixosModules.zram])
            ++ [cfg.extraConfig];

          # Emulate all of the linux-builder systems
          boot.binfmt.emulatedSystems = lib.lists.remove system linux-builder.systems;

          virtualisation = {
            inherit (cfg) cores;
            darwin-builder = {
              inherit (cfg) diskSize memorySize;
            };
          };

          environment = {
            systemPackages = with pkgs; [bottom];
            variables = {
              TERM = "xterm-256color";
            };
          };

          # crashed processes aren't worth debugging in this environment tbh
          systemd.coredump.enable = false;

          # setting priority of swap devices to 1 less than mkVMOverride
          # this makes it take precedence over the default behavior of no swap devices
          # alternatively, you *could* reimplement everything via the defaultFileSystems argument
          # but that stinks.
          swapDevices = lib.mkOverride 9 [
            {
              device = "/swapfile";
              size = cfg.swapSize;
            }
          ];
        };

        inherit (cfg) maxJobs;
        inherit (cfg) ephemeral;
        inherit (cfg) systems;
      };
    };
  };
}
