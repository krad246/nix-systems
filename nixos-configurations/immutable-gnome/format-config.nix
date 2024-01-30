args @ {
  self,
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
      disko.enableConfig = false;
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = _: {
      imports = [offlineInstaller];

      disko.enableConfig = false;
      boot.kernelParams = ["nomodeset"];
    };

    install-iso = {...}: {
      imports = [offlineInstaller];

      disko.enableConfig = false;
      boot.supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    };

    iso = _: {
      disko.enableConfig = false;
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
      disko.enableConfig = false;
    };

    raw-efi = _: {
      disko.enableConfig = false;

      # TODO: determine what overriding system.build.raw with diskoLib's disk image builder does
    };

    sd-aarch64 = {lib, ...}: {
      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      hardware.opengl.driSupport32Bit = lib.mkForce false;
    };

    sd-aarch64-installer = {lib, ...}: {
      imports = [offlineInstaller];

      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      hardware.opengl.driSupport32Bit = lib.mkForce false;
    };

    vagrant-virtualbox = _: {
      disko.enableConfig = false;
    };

    virtualbox = _: {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
    };

    vm-bootloader = _: {
      disko.enableConfig = false;
    };

    vm-nogui = _: {
      disko.enableConfig = false;
    };

    vm = _: {
      disko.enableConfig = false;
    };

    vmware = _: {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
    };
  };
}
