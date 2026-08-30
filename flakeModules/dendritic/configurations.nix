{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  dendritic.configurations = lib.mkMerge [
    {
      # variants: a unifying interface between image modules and specialisations
      variants = {
        enable = lib.mkDefault true;

        enableFlakeOutputs = lib.mkDefault true;       # publish variants as flake outputs
        includeSpecialisations = lib.mkDefault false;  # embed variants as specialisations
      };
    }
    {
      perTag = with inputs.dendritic.modules; let
        modules = names:
          lib.pipe names [
            lib.toList
            (map (name: {
              nixos.modules = [nixos.${name}];
              darwin.modules = [darwin.${name}];
              homeManager.modules = [homeManager.${name}];
            }))
            lib.mkMerge
          ];
      in {
        desktop.perClass = modules "desktop";
        dev.perClass = modules "dev";

        workstation = {
          perClass = lib.mkMerge [
            (modules ["desktop" "dev" "interactive" "secrets"])
            {
              darwin.modules = [darwin.applications];
              homeManager.modules = [
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
        };

        headless.perClass.nixos.modules = [nixos.terminfo];
        standalone.perClass.homeManager.modules = [homeManager.standalone];
      };
    }
    {
      perClass = {
        nixos.modules = [config.flake.dendritic.modules.nixos.base];
        darwin.modules = [config.flake.dendritic.modules.darwin.base];
        homeManager.modules = [config.flake.dendritic.modules.homeManager.base];
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
