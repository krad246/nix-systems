{
  lib,
  specialArgs,
  ...
}: let
  disko = rec {
    pinned = builtins.fetchTarball {
      url = "https://github.com/nix-community/disko/archive/master.tar.gz";
      sha256 = "1ayxw37arc92frzq0080w7kixdmqbq4jm8a19nrgivb70ra1mqys";
    };

    repo = lib.attrsets.attrByPath ["inputs" "disko"] pinned specialArgs;
  };
in {
  imports = ["${disko.repo}/module.nix"];

  disko.devices = lib.modules.mkDefault {
    disk = {
      main = {
        device = "/dev/vdb";
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
          };
        };
      };
    };
  };

  boot.loader.grub.device = lib.modules.mkDefault "nodev";
}
