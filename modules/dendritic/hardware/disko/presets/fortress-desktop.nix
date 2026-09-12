{
  self,
  lib,
  ...
}: {
  # The former fortress-desktop disko definition is a reusable Dendritic
  # preset now. The module providers are selected by the preset itself so
  # consumers do not need the legacy flakeModules/packages/disko wrapper.
  flake.diskoConfigurations.fortress-desktop = {config, ...}: {
    imports = [self.modules.nixos.disko self.modules.nixos.impermanence];

    disko.devices = lib.mkIf config.disko.enableConfig {
      disk.main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23026J804343";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
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
          home = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
          nix = {
            size = "45%VG";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
          persist = {
            size = "5%VG";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix/persist";
            };
          };
          swap = {
            size = "5%VG";
            content = {
              type = "swap";
              priority = 100;
              resumeDevice = true;
            };
          };
        };
      };

      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = ["defaults" "mode=1755"];
      };
    };

    persistence = {
      enable = config.disko.enableConfig;
      backends.impermanence.enable = config.disko.enableConfig;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/flatpak"
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
        "/etc/ssh/ssh_host_ed25519_key"
      ];
    };
  };
}
