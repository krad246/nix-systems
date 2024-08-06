{
  inputs,
  self,
  ...
}: let
  inherit (inputs) disko;
  diskoLib = disko.lib;
in {
  formatConfigs = {
    hyperv = _: {
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = _: {
      boot.kernelParams = ["nomodeset"];
    };

    install-iso = {modulesPath, ...}: {
      imports = ["${modulesPath}/profiles/installation-device.nix"];
      boot.supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    };

    iso = _: {
    };

    qcow-efi = _: {
    };

    raw-efi = _: {
      system.build.raw = diskoLib.makeDiskImages {
        nixosConfig = self.nixosConfigurations.immutable-gnome.extendModules {modules = [./fs-config/simple.nix];};
        inherit diskoLib;
      };
    };

    vagrant-virtualbox = _: {
    };

    virtualbox = _: {
    };

    vm-bootloader = _: {
    };

    vm-nogui = _: {
    };

    vm = _: {
    };

    vmware = _: {
    };
  };
}
