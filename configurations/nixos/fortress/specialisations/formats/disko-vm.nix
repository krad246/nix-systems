{
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    imports = [./vm.nix];

    boot.initrd.kernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_blk"
    ];

    virtualisation.fileSystems = {
      "/home".neededForBoot = true;
      "/nix/persist".neededForBoot = true;
    };
  };
}
