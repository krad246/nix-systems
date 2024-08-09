{config, ...}: let
  inherit (config.networking) hostName;
in {
  formatConfigs = {
    amazon = {lib, ...}: {
      networking.hostName = lib.mkForce "";
      services.udisks2.enable = lib.mkForce false;
    };

    azure = {lib, ...}: {
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
      networking.hostName = lib.mkForce "";
    };

    hyperv = _: {
      boot.kernelParams = ["nomodeset"];
    };

    install-iso-hyperv = {lib, ...}: {
      boot.loader.grub.enable = lib.mkForce false;
      boot.kernelParams = ["nomodeset"];
    };

    install-iso = {lib, ...}: {
      boot.loader.grub.enable = lib.mkForce false;
      boot.supportedFilesystems = ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
    };

    iso = {lib, ...}: {
      boot.loader.grub.enable = lib.mkForce false;
    };

    kexec = {lib, ...}: {
      networking.hostName = lib.mkForce "kexec";
    };

    kexec-bundle = {lib, ...}: {
      networking.hostName = lib.mkForce "kexec";
    };

    kubevirt = _: {
    };

    linode = {lib, ...}: {
      networking.useDHCP = lib.mkForce true;
    };

    openstack = {lib, ...}: {
      networking.hostName = lib.mkForce "";
    };

    proxmox-lxc = _: {
    };

    proxmox = _: {
    };

    qcow = _: {
    };

    qcow-efi = _: {
    };

    raw = _: {
    };

    raw-efi = _: {
      # TODO: determine what overriding system.build.raw with diskoLib's disk image builder does
    };

    sd-aarch64 = {lib, ...}: {
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      boot.loader.grub.enable = lib.mkForce false;
    };

    sd-aarch64-installer = {lib, ...}: {
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      boot.loader.grub.enable = lib.mkForce false;
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
