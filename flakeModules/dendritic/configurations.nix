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
      headless.modules = [config.flake.dendritic.modules.nixos.headless];
      interactive.modules = [config.flake.dendritic.modules.nixos.interactive];
      dev.homeModules = [config.flake.dendritic.modules.homeManager.dev];
    };

    users = {
      standalone = {
        enable = true;
        standalone = {
          enable = !lib.inPureEvalMode;
          pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
          modules = [config.flake.dendritic.modules.homeManager.standalone];
        };
        variants.dev.tags = ["dev"];
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
      # TODO: missing miniboi

      # a concrete example we could work with is:
      # 1. miniboi has a large number of variants
      # with heterogeneous capability sets (vm-nogui)
      # 2. define an actually useful testbed for the
      # broader secure boot, disko cleanup, etc. on
      # the "standard" miniboi, an actually usable config
      # 3. use variants and the tag management to customize
      # something like a graphical miniboi vm down to a
      # vm-nogui

      generic-headless-interactive = {
        enable = true;
        class = "nixos";
        hostPlatforms = [{system = "x86_64-linux";}];
        tags = ["headless" "interactive"];
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
          dev = {
            tags = ["dev"]; # TODO: figure out if this is an additive merge over the tags up there.
            modules = [
              (_: {environment.etc."dendritic-variant".text = "dev";})
            ];
          };
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
        tags = []; # TODO: what tags at this level?
        modules = [
          (_: {networking.hostName = "nixbook-pro-composed";})
        ];
        users.krad246.modules = [config.flake.dendritic.modules.homeManager.nixbook-pro];
        variants.dev.tags = ["dev"];
      };
    };
  };
}
