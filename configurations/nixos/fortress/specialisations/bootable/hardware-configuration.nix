# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  inputs,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib) modules;
  inherit (inputs) nixos-hardware;
in {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ]
    ++ (with nixos-hardware.nixosModules; [
      common-hidpi
      common-pc
      common-pc-ssd
    ]);
  # ++ lists.optionals pkgs.stdenv.isx86_64 (with nixos-hardware.nixosModules; [
  #   common-cpu-amd
  #   common-cpu-amd-pstate
  #   common-cpu-amd-zenpower
  #   common-gpu-amd
  # ]);

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod"];
      kernelModules = ["amdgpu"];
    };

    kernelModules = ["kvm-amd"];
    kernelParams = ["usbcore.old_scheme_first=1"];

    extraModulePackages = [];
  };

  networking.useDHCP = modules.mkDefault true;

  networking.interfaces.enp10s0 = {
    useDHCP = false;

    ipv4.addresses = [
      {
        address = "169.254.199.18";
        prefixLength = 16;
      }
    ];

    macAddress = "c8:7f:54:6a:6e:4b";
    wakeOnLan = {
      enable = true;
      policy = [
        "broadcast"
        "magic"
      ];
    };
  };

  # hardware.cpu.amd.updateMicrocode = lib.modules.mkIf pkgs.stdenv.isx86_64 config.hardware.enableRedistributableFirmware;
}
