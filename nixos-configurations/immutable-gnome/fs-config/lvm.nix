{inputs, ...}: let
  inherit (inputs) disko;
  boot = {
    size = "1M";
    type = "EF02"; # for grub MBR
  };

  ESP = {
    name = "ESP";
    size = "512M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
    };
  };
in {
  imports = [disko.nixosModules.disko];

  disko.devices = {
    disk.main = {
      device = "/dev/null";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          inherit boot ESP;
          root = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        root = {
          size = "95%VG";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = ["defaults"];
          };
        };

        swap = {
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
  };
}
