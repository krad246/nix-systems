{
  ezModules,
  inputs,
  lib,
  config,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

  formats = lib.mkForce rec {
    hyperv = config.system.build.hypervImage;
    iso = config.system.build.isoImage;
    install-iso = iso;
    install-iso-hyperv = install-iso;
    kexec = config.system.build.kexec_tarball;
    inherit (config.system.build) kexec_bundle;
    inherit (config.system.build) qcow;
    inherit (config.system.build) qcow-efi;
    inherit (config.system.build) raw;
    inherit (config.system.build) raw-efi;
    sd-aarch64 = config.system.build.sdImage;
    sd-aarch64-installer = sd-aarch64;
    sd-x86_64 = sd-aarch64;
    vagrant-virtualbox = config.system.build.vagrantVirtualbox;
    virtualbox = config.system.build.virtualBoxOVA;
    inherit (config.system.build) vm;
    vm-bootloader = vm;
    vm-nogui = vm;
    vmware = config.system.build.vmwareImage;
  };

  formatConfigs = rec {
    hyperv = {
      disko.enableConfig = false;
      boot.kernelParams = ["nomodeset"];
    };

    iso = {lib, ...}: {
      disko.enableConfig = false;
      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };
    };

    install-iso = {imports = [ezModules.efiboot];};
    # (iso args)
    # // {
    # imports = [ezModules.efiboot] ++ [./offline-closure-installer.nix];
    # };

    install-iso-hyperv = args: let
      hypervOpts = hyperv;
      installIsoOpts = install-iso args;
      removeMissing = builtins.removeAttrs hypervOpts ["hyperv"];
    in
      removeMissing // installIsoOpts;

    kexec = {lib, ...}: {
      networking.hostName = lib.mkForce "kexec";

      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };
    };

    kexec-bundle = kexec;

    qcow = {
      disko.enableConfig = false;
    };

    qcow-efi = qcow // {imports = [ezModules.efiboot];};

    raw = {
      disko.enableConfig = false;
    };

    raw-efi = raw // {imports = [ezModules.efiboot];};

    sd-aarch64 = {lib, ...}: {
      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      hardware.opengl.driSupport32Bit = lib.mkForce false;
      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };
    };

    sd-aarch64-installer = args:
      (sd-aarch64 args)
      // {
        imports = [
          ./offline-closure-installer.nix
        ];
      };

    sd-x86_64 = {lib, ...}: {
      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };
    };

    virtualbox = {lib, ...}: {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
    };

    vagrant-virtualbox = virtualbox;

    vm = {
      disko.enableConfig = false;
    };

    vm-bootloader = vm;

    vm-nogui = {lib, ...}:
      vm
      // {
        services.xserver = lib.mkForce {
          enable = false;
          displayManager.gdm.enable = false;
          desktopManager.gnome.enable = false;
          displayManager.startx.enable = false;
        };
        xdg.portal.enable = lib.mkForce false;
        services.flatpak.enable = lib.mkForce false;
      };

    vmware = {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
    };
  };
}
