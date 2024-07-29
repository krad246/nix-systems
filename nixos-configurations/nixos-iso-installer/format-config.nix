{lib, ...}: {
  formatConfigs = {
    hyperv = _: {
    };

    install-iso-hyperv = _: {
      imports = [../../nixos-modules/efiboot.nix];
    };

    install-iso = _: {
      imports = [../../nixos-modules/efiboot.nix];
    };

    iso = _: {
      imports = [../../nixos-modules/efiboot.nix];
    };

    kexec-bundle = _: {
    };

    qcow-efi = _: {
      imports = [../../nixos-modules/efiboot.nix];
    };

    qcow = _: {
      boot.loader.grub.device = "/dev/vda";
    };

    raw-efi = _: {
      imports = [../../nixos-modules/efiboot.nix];
    };

    raw = _: {
      boot.loader.grub.device = "/dev/vda";
    };

    sd-aarch64-installer = _: {
    };

    sd-aarch64 = _: {
    };

    vagrant-virtualbox = _: {
      sound.enable = lib.mkForce false;
    };

    virtualbox = _: {
    };

    vm-bootloader = _: {
      virtualisation.diskSize = 16 * 1024;
    };

    vm-nogui = _: {
    };

    vm = _: {
    };

    vmware = _: {
    };
  };
}
