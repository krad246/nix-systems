{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  classes = [
    "nixos"
    "darwin"
    "home"
  ];
  classModules = {
    nixos = config.flake.dendritic.modules.nixos;
    darwin = config.flake.dendritic.modules.darwin;
    home = config.flake.dendritic.modules.homeManager;
  };
  profileModules = {
    nixos = inputs.dendritic.modules.nixos;
    darwin = inputs.dendritic.modules.darwin;
    home = inputs.dendritic.modules.homeManager;
  };
  profile = name: {
    perClass =
      lib.mapAttrs (_: modules: {
        modules = [modules.${name}];
      })
      profileModules;
  };
in {
  dendritic.configurations = lib.mkMerge [
    {
      variants.enable = lib.mkDefault true;
    }
    (with inputs.dendritic.modules; {
      perTag = {
        desktop = profile "desktop";
        dev = profile "dev";
        headless.perClass.nixos.modules = [nixos.terminfo];
        standalone.perClass.home.modules = [homeManager.standalone];
        workstation = lib.mkMerge [
          (profile "desktop")
          (profile "dev")
          (profile "interactive")
          (profile "secrets")
          {
            perClass = {
              darwin.modules = [darwin.applications];
              home.modules = [
                ({lib, ...}: {
                  browser.backends.zen = {
                    enable = lib.mkDefault true;
                    default = lib.mkDefault true;
                  };
                })
              ];
              nixos.modules = [
                (_: {
                  boot.tmp.cleanOnBoot = true;
                  programs.nix-ld.enable = true;
                })
              ];
            };
          }
        ];
      };
    })
    {
      perClass = lib.genAttrs classes (class: {
        modules = [classModules.${class}.base];
      });
    }
    {
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
    }
    {
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
    }
  ];
}
