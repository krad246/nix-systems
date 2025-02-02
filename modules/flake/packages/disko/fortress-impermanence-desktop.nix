{
  specialArgs,
  config,
  lib,
  ...
}: let
  # prefer flake inputs version of agenix, unless the arg is missing
  # fall back to main of the repo otherwise
  commit = "master";

  disko = rec {
    pinned = builtins.fetchTarball {
      url = "https://github.com/nix-community/disko/archive/${commit}.tar.gz";
      sha256 = "1ayxw37arc92frzq0080w7kixdmqbq4jm8a19nrgivb70ra1mqys";
    };
    repo = lib.attrsets.attrByPath ["inputs" "disko"] pinned specialArgs;
  };

  impermanence = rec {
    pinned = builtins.fetchTarball {
      url = "https://github.com/nix-community/impermanence/archive/${commit}.tar.gz";
      sha256 = "1k30ig9b5bx51f0y617yvcn61bgpahf8r0i55mnl3hy6nqjbfw07";
    };
    repo = lib.attrsets.attrByPath ["inputs" "impermanence"] pinned specialArgs;
  };

  inherit (config.disko) enableConfig;

  persistPath = "/nix/persist";
in {
  imports = ["${disko.repo}/module.nix"] ++ ["${impermanence.repo}/nixos.nix"];

  disko.devices = lib.modules.mkIf enableConfig {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23026J804343";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "boot" = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };

            "ESP" = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            "luks" = {
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
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs = {
        "home" = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };

        "nix" = {
          size = "45%VG";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
          };
        };

        "persist" = {
          size = "5%VG";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "${persistPath}";
          };
        };

        "swap" = {
          size = "5%VG";
          content = {
            type = "swap";
            priority = 100;
            resumeDevice = true;
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["defaults"] ++ ["mode=1755"];
    };
  };

  fileSystems = lib.modules.mkIf enableConfig {
    "${persistPath}" = {
      neededForBoot = true;
    };
  };

  environment.persistence = lib.modules.mkIf enableConfig {
    "${persistPath}" = {
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
