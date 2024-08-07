{inputs, ...}: let
  inherit (inputs) disko impermanence;
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
    size = "384G";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/home";
    };
  };

  nix = {
    size = "512G";
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
  imports = [disko.nixosModules.disko] ++ [impermanence.nixosModules.impermanence];

  disko.devices = {
    disk.main = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          inherit boot ESP;
          inherit persist nix home;
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

  environment.persistence."/nix/persist" = {
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

  users.mutableUsers = false;
}
