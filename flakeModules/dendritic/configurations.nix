{
  config,
  lib,
  withSystem,
  ...
}: {
  dendritic.configurations = {
    variants.enable = lib.mkDefault true;

    perClass.darwin.modules = [config.flake.dendritic.modules.darwin.base];

    perTag = {
      generic-headless-interactive.modules = [
        config.flake.dendritic.modules.nixos.headless
        config.flake.dendritic.modules.nixos.interactive
      ];
      nixbook-pro.modules = [
        config.flake.dendritic.modules.darwin.applications
        config.flake.dendritic.modules.darwin.app-stores
        config.flake.dendritic.modules.darwin.browser
        config.flake.dendritic.modules.darwin.linux-builder
        config.flake.dendritic.modules.darwin.tailscale
      ];
    };

    users = {
      standalone = {
        enable = true;
        standalone = {
          enable = !lib.inPureEvalMode;
          pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
          modules = [config.flake.dendritic.modules.homeManager.standalone];
        };
        variants.dev.modules = [config.flake.dendritic.modules.homeManager.dev];
      };

      krad246 = {
        enable = true;
        standalone = {
          enable = !lib.inPureEvalMode;
          pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
          modules = [config.flake.dendritic.modules.homeManager.standalone];
        };
      };
    };

    hosts = {
      generic-headless-interactive = {
        enable = true;
        class = "nixos";
        hostPlatforms = [{system = "x86_64-linux";}];
        tags = ["generic-headless-interactive"];
        modules = [
          ({lib, ...}: {
            networking.hostName = "generic-headless-interactive";
            fileSystems."/" = lib.mkDefault {
              device = "none";
              fsType = "tmpfs";
            };
            boot.loader.grub.devices = lib.mkDefault ["nodev"];
          })
        ];
        variants = {
          dev.modules = [
            (_: {environment.etc."dendritic-variant".text = "dev";})
          ];
          vm-nogui = {
            modules = [
              ({config, ...}: {
                image.modules.vm = import ./image-modules/vm.nix;
                image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
                  vm = config.image.modules.vm;
                };
              })
            ];
            package = configuration: configuration.config.system.build.images.vm-nogui;
          };
        };
      };

      nixbook-pro-composed = {
        enable = true;
        class = "darwin";
        hostPlatforms = [{system = "aarch64-darwin";}];
        tags = ["nixbook-pro"];
        modules = [
          (_: {networking.hostName = "nixbook-pro-composed";})
        ];
        users.krad246.modules = [config.flake.dendritic.modules.homeManager.nixbook-pro];
      };
    };
  };
}
