{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

  formatConfigs = rec {
    hyperv = {lib, ...}: {
      disko.enableConfig = false;
      boot.kernelParams = ["nomodeset"];
      boot.binfmt.emulatedSystems = lib.mkForce [];
    };

    iso = {lib, ...}: {
      disko.enableConfig = false;
      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };

      boot.binfmt.emulatedSystems = lib.mkForce [];
    };

    install-iso = args:
      iso args
      // {
        imports =
          [self.nixosModules.efiboot]
          ++ [./disko-install.nix];
      };
    install-iso-hyperv = args: let
      hypervOpts = hyperv args;
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

    qcow-efi = qcow // {imports = [self.nixosModules.efiboot];};

    raw = {
      disko.enableConfig = false;
    };

    raw-efi = raw // {imports = [self.nixosModules.efiboot];};

    sd-aarch64 = {lib, ...}: {
      disko.enableConfig = false;
      nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
      hardware.opengl.driSupport32Bit = lib.mkForce false;
      boot.binfmt.emulatedSystems = lib.mkForce ["x86_64-linux"];
      boot.supportedFilesystems = {
        zfs = lib.mkForce false;
      };
    };

    sd-aarch64-installer = args:
      (sd-aarch64 args)
      // {
        imports = [
          ./disko-install.nix
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

      virtualbox = {
        extraDisk = {
          mountPoint = "/mnt/growable";
          size = 32 * 1024;
        };
      };
    };

    vagrant-virtualbox = args @ {lib, ...}: (virtualbox args) // {sound.enable = lib.mkForce false;};

    vm = {lib, ...}: {
      disko.enableConfig = false;
      boot.binfmt.emulatedSystems = lib.mkForce [];
    };

    vm-bootloader = vm;

    vm-nogui = args @ {lib, ...}:
      vm args
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

    vmware = {lib, ...}: {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
      boot.binfmt.emulatedSystems = lib.mkForce [];
    };
  };
}
