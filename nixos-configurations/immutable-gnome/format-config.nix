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

    install-iso-hyperv = {modulesPath, ...}: {
      imports =
        [
          "${modulesPath}/profiles/installation-device.nix"
        ]
        ++ [offlineInstaller];

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

    qcow-efi = _: {
    };

    raw-efi = _: {
      imports = [ezModules.steam];

      system.build.raw = let
        diskoLib = disko.lib;
      in
        diskoLib.makeDiskImages {
          nixosConfig = machine.extendModules {modules = [./fs-config];};
          inherit diskoLib;
        };
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
