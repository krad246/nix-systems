args @ {
  inputs,
  self,
  ezModules,
  pkgs,
  config,
  ...
}: let
  inherit (inputs) disko;

  inherit (config.networking) hostName;
  machine = self.nixosConfigurations."${hostName}";

  offlineInstaller = import ./offline-closure-installer.nix (args
    // {
      inherit self pkgs;
      specialArgs = {
        nixosConfig = machine;
      };
    });
in {
  formatConfigs = {
    hyperv = _: {
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = {...}: {
      imports = [offlineInstaller];

      boot.kernelParams = ["nomodeset"];
    };

    install-iso = {modulesPath, ...}: {
      imports =
        [
          "${modulesPath}/profiles/installation-device.nix"
        ]
        ++ [offlineInstaller];

      boot.supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    };

    iso = _: {
    };

    kubevirt = _: {
      disko.enableConfig = false;
    };

    raw = _: {
      disko.enableConfig = false;
    };

    raw-efi = _: {
      imports = [ezModules.steam];
    };

    vagrant-virtualbox = _: {
    };

    virtualbox = _: {
      boot.kernelParams = ["nomodeset"];
    };

    vm-bootloader = _: {
    };

    vm-nogui = _: {
    };

    vm = _: {
    };

    vmware = _: {
      boot.kernelParams = ["nomodeset"];
    };
  };
}
