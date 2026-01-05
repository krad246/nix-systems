{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib) modules;
in {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";

        device = modules.mkDefault "/dev/vda";
        imageSize = "24G"; # for VMs

        content = {
          type = "gpt";

          partitions = {
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
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };

        home = {
          size = "20%VG";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };

        # nix = {
        #   size = "45%VG";
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/nix";
        #   };
        # };

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
  };

  boot.loader.grub = {
    inherit (config.disko.devices.disk.main) device;
    efiSupport = true;
  };
}
