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
    size = "4G";
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
      device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23080R800503";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          inherit boot ESP;
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
        inherit home nix persist;
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

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["defaults"];
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
