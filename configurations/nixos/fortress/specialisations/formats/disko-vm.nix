{self, ...}: {
  formatAttr = "vmWithDisko";
  virtualisation.vmVariantWithDisko = {
    imports = [./vm.nix] ++ [self.diskoConfigurations.fortress-desktop];

    boot.initrd.kernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_blk"
    ];

    # disko.devices = {
    #   disk.main = {
    #     device = "/dev/vda";
    #     content.partitions."ESP".content.mountpoint = lib.modules.mkForce "/boot";
    #   };
    #   lvm_vg.pool.lvs = {
    #     home.content.mountpoint = lib.modules.mkForce "/home";
    #     nix.content.mountpoint = lib.modules.mkForce "/nix";
    #     persist.content.mountpoint = lib.modules.mkForce "/nix/persist";
    #   };
    # };

    # boot.loader = {
    #   grub = {
    #     enable = true;
    #     efiSupport = true;
    #     device = "nodev";
    #   };
    # };
    virtualisation.fileSystems."/nix/persist".neededForBoot = true;
  };
}
