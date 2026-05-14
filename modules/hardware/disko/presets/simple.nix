{
  flake.diskoConfigurations.simple = {
    disko.devices.disk.main = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            attributes = [0]; # partition attribute
          };
          # ESP = {
          #   type = "EF00";
          #   size = "512M";
          #   content = {
          #     type = "filesystem";
          #     format = "vfat";
          #     mountpoint = "/boot";
          #     mountOptions = ["umask=0077"];
          #   };
          # };

          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
