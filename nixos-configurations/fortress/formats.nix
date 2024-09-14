{
  ezModules,
  inputs,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

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

    install-iso = _args: {disko.enableConfig = false;} // {imports = [ezModules.efiboot];};
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
