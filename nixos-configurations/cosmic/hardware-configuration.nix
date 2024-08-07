# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/7c74b7a9-a651-4a45-9896-247bbacdc9c4";
    fsType = "ext4";
  };

  fileSystems."/nix/persist" = {
    device = "/dev/disk/by-uuid/3058c568-7c20-4a30-9e48-9db7e80634c0";
    fsType = "ext4";
  };

  fileSystems."/var/lib/nixos" = {
    device = "/nix/persist/var/lib/nixos";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/var/log" = {
    device = "/nix/persist/var/log";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/etc/NetworkManager/system-connections" = {
    device = "/nix/persist/etc/NetworkManager/system-connections";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/var/lib/bluetooth" = {
    device = "/nix/persist/var/lib/bluetooth";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/var/lib/colord" = {
    device = "/nix/persist/var/lib/colord";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/var/lib/systemd/coredump" = {
    device = "/nix/persist/var/lib/systemd/coredump";
    fsType = "none";
    options = ["bind"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d06e5064-58bf-4229-a540-eda2f7a33aa6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0776-9F3F";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/3ca69a7d-6ba6-4a18-a1b7-1a5adae971be";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
