args @ {
  self,
  ezModules,
  pkgs,
  config,
  ...
}: let
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
    amazon = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
      services.udisks2.enable = lib.mkForce false;
    };

    azure = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
      networking.networkmanager.enable = lib.mkForce false;
    };

    do = {lib, ...}: {
      networking.hostName = lib.mkForce "";
    };

    docker = {lib, ...}: {
      networking.firewall.enable = lib.mkForce false;
    };

    gce = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
    };

    hyperv = _: {
      imports = [ezModules.gnome-desktop];
      disko.enableConfig = false;
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = {...}: {
      imports = [offlineInstaller];
      disko.enableConfig = false;
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

    kexec = {lib, ...}: {
      networking.hostName = lib.mkForce "kexec";
    };

    kexec-bundle = {lib, ...}: {
      networking.hostName = lib.mkForce "kexec";
    };

    kubevirt = _: {
      disko.enableConfig = false;
    };

    linode = {lib, ...}: {
      disko.enableConfig = false;
      networking.useDHCP = lib.mkForce true;
    };

    openstack = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
    };

    proxmox-lxc = _: {
    };

    proxmox = _: {
      disko.enableConfig = false;
    };

    qcow = _: {
      disko.enableConfig = false;
    };

    qcow-efi = _: {
      disko.enableConfig = false;
    };

    raw = _: {
      imports = [ezModules.steam];
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
