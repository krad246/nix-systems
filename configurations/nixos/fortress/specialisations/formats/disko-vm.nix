{
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    imports = [./vm.nix];
    boot.initrd.kernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_blk"
    ];
  };
}
