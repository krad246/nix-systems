{
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    boot.initrd.kernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_blk"
    ];

    virtualisation.cores = 8;
  };
}
