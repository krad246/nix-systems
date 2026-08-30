{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  # Project one or more named modules from a module namespace into the
  # evaluator classes consumed by perClass and perTag.
  modules = origin: names:
    lib.pipe names [
      lib.toList
      (map (name: {
        nixos.modules = [origin.nixos.${name}];
        darwin.modules = [origin.darwin.${name}];
        home.modules = [origin.homeManager.${name}];
      }))
      lib.mkMerge
    ];
in {
  # TODO: better name for this interface
  dendritic.configurations = lib.mkMerge [
    {
      # interface 1: variants

      # a unifying interface between image modules and specialisations
      variants = {
        enable = lib.mkDefault true;

        enableFlakeOutputs = lib.mkDefault true; # publish variants as flake outputs
        includeSpecialisations = lib.mkDefault false; # embed variants as specialisations
      };
    }
    {
      # interface 2: module system classes

      # there is a generic registration mechanism for all module system classes now,
      # meaning your flakes can implement as classes as they want / need and use the
      # same generator interface to get things working for different contexts.
      perClass = modules config.flake.dendritic.modules "base";
    }
    {
      # define "tags": a logical "annotation" interface over composed modules.
      # compose tags together as logical closures of capabities.
      perTag = {
        desktop.perClass = modules inputs.dendritic.modules "desktop";
        dev.perClass = modules inputs.dendritic.modules "dev";

        workstation.perClass = lib.mkMerge [
          (modules inputs.dendritic.modules ["desktop" "dev" "interactive" "secrets"])
          {
            darwin.modules = [inputs.dendritic.modules.darwin.applications];
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
          }
        ];

        headless.perClass.nixos.modules = [inputs.dendritic.modules.nixos.terminfo];
        standalone.perClass.home.modules = [inputs.dendritic.modules.homeManager.standalone];
      };
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
