{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) modules;
in {
  imports = with inputs; [
    disko.nixosModules.disko
    impermanence.nixosModules.impermanence
  ];

  boot.loader.grub = {
    device = modules.mkDefault config.disko.devices.disk.main.device;
    efiSupport = true;
  };

  virtualisation = let
    toMB = size: let
      m = builtins.match "^([0-9]+)([MG])$" size;
    in
      if m == null
      then throw "Invalid size string (expected <int>M or <int>G): ${size}"
      else let
        value = builtins.fromJSON (builtins.elemAt m 0);
        unit = builtins.elemAt m 1;
      in
        if unit == "M"
        then value
        else value * 1024;
  in {
    diskSize = toMB config.disko.devices.disk.main.imageSize;
  };

  disko = {
    memSize = 6 * 1024; # for VMs

    devices = {
      disk = {
        main = {
          type = "disk";

          device = modules.mkDefault "/dev/vda";
          imageSize = "24G"; # for VMs

          content = {
            type = "gpt";

            partitions = {
              ##### Hybrid MBR #####

              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };

              ESP = {
                type = "EF00";
                size = "100M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };

              ##### LVM #####

              # Override to LUKS or other desired layout.
              # We'll enforce a strict LVM architecture because of its flexibility as an interface.
              root = modules.mkDefault {
                size = "100%";
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

        lvs = modules.mkDefault {
          home = {
            size = "20%VG";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
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

          nix = {
            size = "45%VG";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };

          swap = {
            size = "5%VG";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };
      };

      nodev."/" = {
        fsType = "tmpfs";
      };
    };
  };

  fileSystems = modules.mkIf config.disko.enableConfig {
    "/nix/persist" = {
      neededForBoot = true;
    };
  };

  environment.persistence = {
    "/nix/persist" = {
      enable = config.disko.enableConfig;
      hideMounts = true;
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
