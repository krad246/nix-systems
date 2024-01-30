{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (inputs) disko impermanence;
  inherit (config.disko) enableConfig;

  persistPath = "/nix/persist";
in {
  imports = [disko.nixosModules.disko] ++ [impermanence.nixosModules.impermanence];

  disko.devices = let
    random = builtins.readFile /dev/random;
    systemSuffix =
      lib.strings.optionalString (!lib.trivial.inPureEvalMode)
      ("-" + "${random}");
  in
    lib.mkIf enableConfig {
      disk.main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23080R800503";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "boot${systemSuffix}" = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };

            "ESP${systemSuffix}" = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            "luks${systemSuffix}" = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted${systemSuffix}";
                extraOpenArgs = [];
                settings = {};
                additionalKeyFiles = [];
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };

      lvm_vg.pool = {
        type = "lvm_vg";
        lvs = {
          "home${systemSuffix}" = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };

          "nix${systemSuffix}" = {
            size = "45%VG";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };

          "persist${systemSuffix}" = {
            size = "4G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "${persistPath}";
            };
          };

          "swap${systemSuffix}" = {
            size = "5%VG";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100;
              resumeDevice = true;
            };
          };
        };
      };

      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = ["defaults"];
      };
    };

  fileSystems = lib.mkIf enableConfig {
    "${persistPath}" = {
      neededForBoot = true;
    };
  };

  environment.persistence = lib.mkIf enableConfig {
    "${persistPath}" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  users.mutableUsers = false;
}
