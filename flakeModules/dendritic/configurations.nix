{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  localModules = config.flake.dendritic.modules;
in {
  dendritic.configurations = lib.mkMerge [
    (with inputs.dendritic.modules; {
      variants.enable = lib.mkDefault true;

      perClass = {
        nixos = {
          modules = [localModules.nixos.base];
        };
        darwin = {
          modules = [localModules.darwin.base];
        };
        home.modules = [localModules.homeManager.base];
      };

      perTag = {
        desktop = {
          perClass = {
            nixos.modules = [nixos.desktop];
            darwin.modules = [darwin.desktop];
            home.modules = [homeManager.desktop];
          };
        };
        dev = {
          perClass = {
            nixos.modules = [nixos.dev];
            darwin.modules = [darwin.dev];
            home.modules = [homeManager.dev];
          };
        };
        headless = {
          perClass.nixos.modules = [nixos.terminfo];
        };
        standalone = {
          perClass.home.modules = [homeManager.standalone];
        };
        workstation = {
          perClass = {
            darwin.modules = [
              darwin.applications
              darwin.desktop
              darwin.dev
              darwin.interactive
              darwin.secrets
            ];
            home.modules = [
              homeManager.desktop
              homeManager.dev
              homeManager.interactive
              homeManager.secrets
              ({lib, ...}: {
                browser.backends.zen = {
                  enable = lib.mkDefault true;
                  default = lib.mkDefault true;
                };
              })
            ];
            nixos.modules = [
              nixos.desktop
              nixos.dev
              nixos.interactive
              nixos.secrets
              (_: {
                boot.tmp.cleanOnBoot = true;
                programs.nix-ld.enable = true;
              })
            ];
          };
        };
      };

      users = {
        standalone = {
          enable = true;
          standalone = {
            enable = !lib.inPureEvalMode;
            pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
            modules = [];
          };
          tags = ["standalone"];
          variants.dev.tags = ["dev"];
        };

        krad246 = {
          enable = true;
          tags = ["standalone"];
          standalone = {
            enable = !lib.inPureEvalMode;
            pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
            modules = [];
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
          tags = ["headless"];
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
          tags = ["workstation"];
          modules = [
            (_: {networking.hostName = "nixbook-pro-composed";})
          ];
          users.krad246 = {};
          variants.dev.tags = ["dev"];
        };
      };
    })
  ];
}
