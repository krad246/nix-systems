{
  self,
  lib,
  ...
}: {
  dendritic.configurations.hosts.miniboi = {
    enable = true;
    class = "nixos";
    hostPlatforms = [
      {system = "x86_64-linux";}
      {system = "aarch64-linux";}
    ];

    # The VM runner and disko helper are Linux-side build products. Keep
    # Darwin out of this fixture's builder constraint table while still
    # publishing both Linux build/host cross directions.
    buildPlatforms = [
      {system = "x86_64-linux";}
      {system = "aarch64-linux";}
    ];
    crossCompile = true;
    tags = ["headless"];

    modules = [
      self.modules.nixos.disko
      self.modules.nixos.bootloader
      self.diskoConfigurations.simple
      {
        networking.hostName = "miniboi";
        security.sudo.wheelNeedsPassword = false;
        disko.enableConfig = true;
        boot.loader = {
          enable = true;
          mode = "bios";
        };
        users.users.krad246.initialHashedPassword = "";
      }
    ];

    variants = {
      vm = {
        package = configuration: configuration.config.system.build.vm;
        tags = ["virtualisation"];
        virtualisation = {enable = true;};
      };

      vm-with-bootloader = {
        package = configuration: configuration.config.system.build.vmWithBootLoader;
        tags = ["virtualisation"];
        virtualisation = {
          enable = true;
          modules = [
            (_: {
              virtualisation.vmVariantWithBootLoader.virtualisation.diskSize = 20 * 1024;
            })
          ];
        };
      };

      vm-nogui = {
        package = configuration: configuration.config.system.build.vm;
        tags = ["virtualisation"];
        virtualisation = {enable = true;};
      };

      disko-vm = {
        package = configuration: configuration.config.system.build.vmWithDisko;
        tags = ["virtualisation"];
        virtualisation = {
          enable = true;
          modules = [
            (_: {
              virtualisation.vmVariantWithDisko = {
                boot.loader.grub.devices = lib.mkForce [];
                boot.loader.grub.mirroredBoots = lib.mkForce [
                  {
                    # Keep the VM's GRUB configuration bootable without
                    # colliding with disko's installer-side /dev/vda
                    # projection. The image builder still installs GRUB to
                    # the actual disk when it materializes the disko image.
                    devices = ["nodev"];
                    path = "/boot";
                  }
                ];
              };
            })
          ];
        };
      };
    };
  };
}
