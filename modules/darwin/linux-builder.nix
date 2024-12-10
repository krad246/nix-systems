{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.linux-builder;
in {
  options = {
    krad246.darwin.linux-builder = {
      ephemeral = lib.options.mkEnableOption "ephemeral";

      extraConfig = lib.options.mkOption {
        type = lib.types.deferredModule;
        default = {};
        example = lib.options.literalExpression ''{}'';
        description = ''
          This option specifies extra NixOS configuration for the builder.
        '';
      };

      maxJobs = lib.options.mkOption {
        type = lib.types.ints.positive;
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

      cores = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 8;
        description = ''
          Specify the number of cores the guest is permitted to use.
          The number can be higher than the available cores on the
          host system.
        '';
      };

      memorySize = lib.options.mkOption {
        default = 6 * 1024;
        type = lib.types.ints.positive;
        example = 8192;
        description = "The runner's memory in MB";
      };

      diskSize = lib.options.mkOption {
        default = 32 * 1024;
        type = lib.types.ints.positive;
        example = 30720;
        description = "The maximum disk space allocated to the runner in MB";
      };

      swapSize = lib.options.mkOption {
        default = 16 * 1024;
        type = lib.types.ints.positive;
        example = 30720;
        description = "The maximum disk space allocated to the runner's swapfile in MB";
      };

      systems = lib.options.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["i386-linux" "i686-linux" "x86_64-linux" "aarch64-linux"];

        defaultText = ''
          The `nixpkgs.hostPlatform.system` of the build machine's final NixOS configuration.
        '';
        example = lib.options.literalExpression ''
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
            [self.modules.generic.nix-core]
            ++ (with self.nixosModules; [ccache-stdenv zram])
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

          systemd.coredump.enable = false;

          # setting priorirty of swap devices to 1 less than mkVMOverride
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
