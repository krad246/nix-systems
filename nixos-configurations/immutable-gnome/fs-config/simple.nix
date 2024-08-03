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
            end = "5%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          encryptedSwap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
              priority = 100; # prefer to encrypt as long as we have space for it
            };
          };
        };
      };
    };
  };
}
