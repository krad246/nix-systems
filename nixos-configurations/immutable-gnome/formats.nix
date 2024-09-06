{
  formatConfigs = rec {
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

    cloudstack = {
      disko.enableConfig = false;
    };

    do = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
    };

    docker = {lib, ...}: {
      disko.enableConfig = false;
      networking.firewall.enable = lib.mkForce false;
    };

    gce = {lib, ...}: {
      disko.enableConfig = false;
      networking.hostName = lib.mkForce "";
    };

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

    install-iso = args:
      (iso args)
      // {
        imports = [./offline-closure-installer.nix];
      };

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

    kubevirt = {
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

    proxmox = {
      disko.enableConfig = false;
    };

    proxmox-lxc = proxmox;

    qcow = {
      disko.enableConfig = false;
    };

    qcow-efi = qcow;

    raw = {
      disko.enableConfig = false;
    };

    raw-efi = raw;

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

    virtualbox = {
      boot.kernelParams = ["nomodeset"];
      disko.enableConfig = false;
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
