{
  self,
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  hostPkgs = pkgs;
  cfg = config.krad246.darwin.virtualisation.linux-builder;
in {
  options = {
    krad246.darwin.virtualisation.linux-builder = {
      enable = (lib.options.mkEnableOption "linux-builder") // {default = true;};

      maxJobs = lib.options.mkOption {
        default = 24;
        inherit (options.nix.linux-builder.maxJobs) type defaultText example description;
      };

      cores = lib.options.mkOption {
        type = lib.types.ints.positive;
        default = 6;
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
        default = 64 * 1024;
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

      ephemeral = lib.options.mkEnableOption "ephemeral";

      extraConfig = lib.options.mkOption {
        inherit (options.nix.linux-builder.config) type default example description;
      };

      systems = lib.options.mkOption {
        default = ["i686-linux" "x86_64-linux" "aarch64-linux"];
        inherit (options.nix.linux-builder.systems) type description defaultText;
      };
    };
  };

  config = {
    nix = {
      linux-builder = {
        inherit (cfg) enable;
        protocol = "ssh-ng";

        config = {pkgs, ...}: let
          innerPkgs = pkgs;
          inherit (innerPkgs.pkgs.stdenv) system;
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
            qemu.package = hostPkgs.qemu.overrideAttrs (
              _finalAttrs: previousAttrs: {
                patches = let
                  patch = hostPkgs.fetchpatch {
                    name = "fix-sme-darwin.patch";
                    url = "https://github.com/utmapp/UTM/raw/acbf2ba8cd91f382a5e163c49459406af0b462b7/patches/qemu-9.1.0-utm.patch";
                    hash = "sha256-S7DJSFD7EAzNxyQvePAo5ZZyanFrwQqQ6f2/hJkTJGA=";
                  };
                in
                  previousAttrs.patches
                  ++ [
                    patch
                  ];
              }
            );
          };

          environment = {
            systemPackages = with innerPkgs; [bottom];
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
