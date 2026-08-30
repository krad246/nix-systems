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
        homeManager.modules = [origin.homeManager.${name}];
      }))
      lib.mkMerge
    ];
in {
  dendritic.configurations = lib.mkMerge [
    {
      # interface 1: variants

      # Variants can be published as independent outputs, embedded as native
      # specialisations, or both; you can choose per-variant.
      variants = {
        enable = lib.mkDefault true;

        enableFlakeOutputs = lib.mkDefault true; # publish variants as flake outputs
        includeSpecialisations = lib.mkDefault false; # embed variants as specialisations
      };
    }
    {
      # interface 2: profile aspects

      # A tag names a semantic profile. It realizes those semantics through
      # its class-specific module contributions.
      tags = ["base"];
      perTag = {
        base.perClass = modules config.flake.dendritic.modules "base";
        desktop.perClass = modules inputs.dendritic.modules "desktop";
        dev.perClass = modules inputs.dendritic.modules "dev";
        workstation.perClass = lib.mkMerge [
          (modules inputs.dendritic.modules [
            "desktop"
            "dev"
            "interactive"
            "secrets"
          ])
          {
            darwin.modules = [inputs.dendritic.modules.darwin.applications];
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

        headless.perClass.nixos.modules = [inputs.dendritic.modules.nixos.terminfo];

        # FIXME: !!!!!!!!!!!!!!!!!!!!!!!!!!!
        # The upstream standalone profile currently imports base itself. Since
        # the root base tag already supplies that import, use only its
        # administrative home-manager module here to avoid importing base twice.
        # Revisit when the upstream profile/base split is decoupled.
        standalone.perClass.homeManager.modules = [
          inputs.dendritic.modules.homeManager.home-manager
          ({pkgs, ...}: {nix.package = lib.mkDefault pkgs.nix;})
        ];
      };
    }
    {
      # interface 3: defining users
      users.krad246 = {
        enable = true;

        # A user is hosted by default. A non-null standalone block opts into an
        # independent Home Manager output and supplies its evaluation pkgs.
        standalone = lib.mkIf (!lib.inPureEvalMode) {
          pkgs = withSystem builtins.currentSystem ({pkgs, ...}: pkgs);
          modules = [];
        };
        tags = ["standalone"]; # add tag interfaces the user implements
        variants.dev.tags = ["dev"]; # add variants, and add tags to the variants
      };
    }
    {
      # interface 4: defining hosts
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
          class = "nixos"; # module class, same
          hostPlatforms = [{system = "x86_64-linux";}]; # cross-compile this host for a list of
          tags = ["headless"]; # add tag interfaces to the host, then implement perClass, same as above.
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
              package = configuration: configuration.config.system.build.toplevel;
              modules = [
                (_: {environment.etc."dendritic-variant".text = "dev";})
              ];
            };
            vm-nogui = {
              package = configuration: configuration.config.system.build.images.vm-nogui;
              modules = [
                {
                  image.modules.vm-nogui = import ./image-modules/vm-nogui.nix;
                }
              ];
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
