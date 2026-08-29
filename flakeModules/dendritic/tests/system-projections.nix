{
  config,
  lib,
  ...
}: let
  flakeConfig = config;
in {
  config = lib.mkMerge [
    (lib.mkIf flakeConfig.debug {
      dendritic.configurations = {
        shared.modules = [
          ({lib, ...}: {
            options.dendritic.evaluatorTest.layerOrder = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
            };
            dendritic.evaluatorTest.layerOrder = ["shared"];
          })
        ];
        perClass.nixos.modules = [
          (_: {dendritic.evaluatorTest.layerOrder = ["perClass"];})
        ];
        perTag.first.modules = [
          (_: {
            dendritic.evaluatorTest.layerOrder = ["perTag:first"];
          })
        ];
        perTag.second.modules = [
          (_: {
            dendritic.evaluatorTest.layerOrder = ["perTag:second"];
          })
        ];
        hosts.dendritic-layer-order = {
          enable = true;
          class = "nixos";
          hostPlatforms = [{system = "x86_64-linux";}];
          tags = ["first" "second"];
          modules = [
            ({lib, ...}: {
              networking.hostName = "dendritic-layer-order";
              fileSystems."/" = lib.mkDefault {
                device = "none";
                fsType = "tmpfs";
              };
              boot.loader.grub.devices = lib.mkDefault ["nodev"];
              dendritic.evaluatorTest.layerOrder = ["host"];
            })
          ];
        };
      };
    })

    {
      perSystem = {
        config,
        system,
        ...
      }: let
        darwin = flakeConfig.flake.darwinConfigurations;
        nixos = flakeConfig.flake.nixosConfigurations;
        image = config.packages.generic-headless-interactive-vm-nogui-x86_64-linux or null;
        coordinates = lib.concatMap (declaration:
          map (hostPlatform: {
            inherit declaration hostPlatform;
            buildPlatform =
              if declaration.buildPlatform == null
              then hostPlatform
              else declaration.buildPlatform;
          })
          declaration.hostPlatforms)
        (builtins.attrValues flakeConfig.dendritic.internal.systemDeclarations);
        expectedClass = hostPlatform:
          if lib.systems.inspect.predicates.isDarwin (lib.systems.parse.mkSystemFromString hostPlatform.system)
          then "darwin"
          else "nixos";
      in {
        dendritic.assertions = [
          {
            assertion = system != "aarch64-darwin" || darwin ? nixbook-pro-composed;
            message = "the composed nixbook-pro Darwin configuration is published";
          }
          {
            assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.interactive.enable;
            message = "nixbook-pro includes the interactive user profile";
          }
          {
            assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.shell.profiles.dev.enable;
            message = "nixbook-pro includes the development user profile";
          }
          {
            assertion = system != "aarch64-darwin" || darwin.nixbook-pro-composed.config.home-manager.users.krad246.browser.backends.zen.enable;
            message = "nixbook-pro selects the Zen browser backend";
          }
          {
            assertion = system != "x86_64-linux" || image.name == "nixos-vm";
            message = "the generic headless image materializes as a NixOS VM";
          }
          {
            assertion = lib.all (coordinate: coordinate.declaration.class == expectedClass coordinate.hostPlatform) coordinates;
            message = "each host class matches every declared target platform";
          }
          {
            assertion = lib.all (coordinate: coordinate.buildPlatform.system == coordinate.hostPlatform.system || coordinate.declaration.crossCompile) coordinates;
            message = "a non-native build platform is gated by crossCompile";
          }
          {
            assertion = system != "x86_64-linux" || nixos ? generic-headless-interactive;
            message = "the normalized NixOS declaration is published directly";
          }
          {
            assertion = !flakeConfig.debug || system != "x86_64-linux" || nixos.dendritic-layer-order.config.dendritic.evaluatorTest.layerOrder == ["shared" "perClass" "perTag:first" "perTag:second" "host"];
            message = "shared, class, ordered tags, and host modules accumulate in declaration order";
          }
          {
            assertion = system != "x86_64-linux" || builtins.attrNames (lib.filterAttrs (name: _: lib.hasPrefix "generic-headless-interactive-vm-nogui" name) config.packages) == ["generic-headless-interactive-vm-nogui-x86_64-linux"];
            message = "only package-bearing variant coordinates receive sparse package outputs";
          }
        ];
      };
    }
  ];
}
