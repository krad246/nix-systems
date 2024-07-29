{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}: let
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

  home = {
    size = "128G";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/home";
    };
  };

  nix = {
    size = "256G";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/nix";
    };
  };

  persist = {
    size = "16G";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/nix/persist";
    };
  };
in {
  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          inherit boot ESP;
          inherit home nix persist;
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
    };
  };

  fileSystems."/nix/persist".neededForBoot = true;

  formatConfigs.impermanence = _: let
    impermanence = import ./fetch-impermanence.nix;
  in {
    imports = [impermanence] ++ [../../../nixos-modules/impermanence.nix];
    formatAttr = "impermanence";

    system.build.impermanence = import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit config lib pkgs;
      diskSize = "auto";
      format = "raw";
    };
  };
}
