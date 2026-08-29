{
  config,
  lib,
  withSystem,
  ...
}: {
  dendritic.configurations = {
    variants.enable = lib.mkDefault true;

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
        modules = [config.flake.dendritic.modules.homeManager.nixbook-pro];
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
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          (_: {networking.hostName = "generic-headless-interactive";})
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
        modules = [
          config.flake.dendritic.modules.darwin.applications
          config.flake.dendritic.modules.darwin.base
          config.flake.dendritic.modules.darwin.app-stores
          config.flake.dendritic.modules.darwin.browser
          config.flake.dendritic.modules.darwin.linux-builder
          config.flake.dendritic.modules.darwin.tailscale
          (_: {networking.hostName = "nixbook-pro-composed";})
        ];
        users.krad246 = {};
      };
    };
  };
}
