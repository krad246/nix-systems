{
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixos-generators;
in {
  imports = [nixos-generators.nixosModules.all-formats];

  formatConfigs =
    rec {
      hyperv = {lib, ...}:
        {
          disko.enableConfig = false;
        }
        // {
          boot = {
            kernelParams = ["nomodeset"];
            binfmt.emulatedSystems = lib.modules.mkForce [];
          };
        };

      iso = {lib, ...}: {
        disko.enableConfig = false;
        boot.supportedFilesystems = {
          zfs = lib.modules.mkForce false;
        };

        boot.binfmt.emulatedSystems = lib.modules.mkForce [];
      };

      install-iso = args:
        iso args
        // {
          imports =
            [self.nixosModules.efiboot]
            ++ [./disko-install.nix];

          environment.systemPackages = with pkgs; [
            calamares-nixos
            calamares-nixos-extensions
          ];
        };
      install-iso-hyperv = args: let
        hypervOpts = hyperv args;
        installIsoOpts = install-iso args;
        removeMissing = builtins.removeAttrs hypervOpts ["hyperv"];
      in
        removeMissing // installIsoOpts;
    }
    // rec {
      kexec = {lib, ...}: {
        networking.hostName = lib.modules.mkForce "kexec";

        boot.supportedFilesystems = {
          zfs = lib.modules.mkForce false;
        };
      };

      kexec-bundle = kexec;
    }
    // rec {
      qcow = {
        disko.enableConfig = false;
      };

      qcow-efi = qcow // {imports = [self.nixosModules.efiboot];};
    }
    // rec {
      raw = {
        disko.enableConfig = false;
      };

      raw-efi = raw // {imports = [self.nixosModules.efiboot];};
    }
    // rec {
      sd-aarch64 = {lib, ...}: {
        disko.enableConfig = false;
        nixpkgs.hostPlatform = "aarch64-linux";
        hardware.opengl.driSupport32Bit = lib.modules.mkForce false;
        boot.binfmt.emulatedSystems = lib.modules.mkForce ["x86_64-linux"];
        boot.supportedFilesystems = {
          zfs = lib.modules.mkForce false;
        };
      };

      sd-aarch64-installer = args:
        (sd-aarch64 args)
        // {
          imports = [
            ./disko-install.nix
          ];
        };
    }
    // rec {
      sd-x86_64 = {lib, ...}: {
        disko.enableConfig = false;
        nixpkgs.hostPlatform = "x86_64-linux";
        boot.supportedFilesystems = {
          zfs = lib.modules.mkForce false;
        };
      };

      virtualbox = _: {
        boot.kernelParams = ["nomodeset"];
        disko.enableConfig = false;

        virtualbox = {
          extraDisk = {
            mountPoint = "/mnt/growable";
            size = 32 * 1024;
          };
        };
      };

      vagrant-virtualbox = args @ {lib, ...}: (virtualbox args) // {sound.enable = lib.modules.mkForce false;};
    }
    // rec {
      vm = {lib, ...}: {
        disko.enableConfig = false;
        boot.binfmt.emulatedSystems = lib.modules.mkForce [];
      };

      vm-bootloader = vm;

      vm-nogui = args @ {lib, ...}:
        vm args
        // {
          services.xserver = lib.modules.mkForce {
            enable = false;
            displayManager.gdm.enable = false;
            desktopManager.gnome.enable = false;
            displayManager.startx.enable = false;
          };
          xdg.portal.enable = lib.modules.mkForce false;
          services.flatpak.enable = lib.modules.mkForce false;
        };
    }
    // {
      vmware = {lib, ...}: {
        boot.kernelParams = ["nomodeset"];
        disko.enableConfig = false;
        boot.binfmt.emulatedSystems = lib.modules.mkForce [];
      };
    };
}
