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

  disko.devices = modules.mkDefault {
    disk = {
      main = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "100M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            empty = {
              size = "1G";
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            swap = {
              size = "2G";
              content = {
                type = "swap";
                priority = 100;
                resumeDevice = true;
              };
            };
          };
        };

        imageSize = "24G";
      };
    };
  };

  boot.loader.grub.device = modules.mkDefault config.disko.devices.disk.main.device;
}
