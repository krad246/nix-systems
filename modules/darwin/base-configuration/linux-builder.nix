global @ {
  withSystem,
  self,
  config,
  lib,
  ...
}: let
  cfg = config.krad246.darwin.virtualisation.linux-builder;
  inherit (lib) options types;
in {
  options = {
    krad246.darwin.virtualisation.linux-builder = {
      enable = (options.mkEnableOption "linux-builder") // {default = true;};

      maxJobs = options.mkOption {
        default = 24;
        inherit (global.options.nix.linux-builder.maxJobs) type defaultText example description;
      };

      cores = options.mkOption {
        type = types.ints.positive;
        default = 6;
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
        default = 64 * 1024;
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
        inherit (global.options.nix.linux-builder.config) type default example description;
      };

      systems = options.mkOption {
        default = ["i686-linux" "x86_64-linux" "aarch64-linux"];
        inherit (global.options.nix.linux-builder.systems) type description defaultText;
      };
    };
  };

  config = {
    nix = {
      linux-builder = {
        inherit (cfg) enable;
        protocol = "ssh-ng";

        config = {pkgs, ...}: let
          inherit (pkgs.stdenv) system;
          inherit (config.nix) linux-builder;
        in {
          imports =
            (with self; [
              modules.generic.nix-core
              nixosModules.ccache-stdenv
              nixosModules.zram
            ])
            ++ [cfg.extraConfig];

          # Emulate all of the linux-builder systems
          boot.binfmt.emulatedSystems = lib.lists.remove system linux-builder.systems;

          virtualisation = {
            inherit (cfg) cores;
            darwin-builder = {
              inherit (cfg) diskSize memorySize;
            };
            qemu.package = withSystem "aarch64-darwin" ({pkgs, ...}:
              pkgs.qemu.overrideAttrs (
                _finalAttrs: previousAttrs: {
                  patches =
                    previousAttrs.patches
                    ++ pkgs.lib.optional pkgs.stdenv.targetPlatform.isDarwin (
                      pkgs.fetchpatch {
                        name = "fix-sme-darwin.patch";
                        url = "https://github.com/utmapp/UTM/raw/acbf2ba8cd91f382a5e163c49459406af0b462b7/patches/qemu-9.1.0-utm.patch";
                        hash = "sha256-S7DJSFD7EAzNxyQvePAo5ZZyanFrwQqQ6f2/hJkTJGA=";
                      }
                    );
                }
              ));
          };

          environment = {
            systemPackages = with pkgs; [bottom];
            sessionVariables = {
              TERM = "xterm-256color";
            };
          };

          # crashed processes aren't worth debugging in this environment tbh
          systemd.coredump.enable = false;

          # dynamic swap allocator for the underlying QCOW2, keeps space utilization efficient
          services.swapspace = {
            enable = true;
          };

          # setting priority of swap devices to 1 less than mkVMOverride
          # to make it take precedence over the default behavior of no swap devices
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
