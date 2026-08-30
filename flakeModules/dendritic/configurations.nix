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
  # The example is intentionally assembled as independent declaration blocks.
  # mkMerge lets each interface contribute without hiding its merge boundary.
  dendritic.configurations = lib.mkMerge [
    {
      # interface 1: variants

      # Variants can be published as independent outputs, embedded as native
      # specialisations, or both; each variant chooses its own delta later.
      variants = {
        enable = lib.mkDefault true;

        enableFlakeOutputs = lib.mkDefault true; # publish variants as flake outputs
        includeSpecialisations = lib.mkDefault false; # embed variants as specialisations
      };
    }
    {
      # interface 2: module-system class defaults

      # perClass is the class-indexed baseline contribution table. The helper
      # expands one named module from a namespace across the actual module
      # classes: nixos, darwin, and homeManager.
      perClass = modules config.flake.dendritic.modules "base";
    }
    {
      # interface 3: profile aspects

      # A tag names a semantic profile. Its perClass value has the same
      # class-indexed contribution shape as the root baseline above.
      perTag = {
        # These tags are pure profile projections: the helper supplies the
        # corresponding module from each evaluator-class namespace.
        desktop.perClass = modules inputs.dendritic.modules "desktop";
        dev.perClass = modules inputs.dendritic.modules "dev";

        # A tag can also merge named profiles with class-specific additions.
        # The extra modules below are intentionally limited to their classes.
        workstation.perClass = lib.mkMerge [
          (modules inputs.dendritic.modules ["desktop" "dev" "interactive" "secrets"])
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
        # The upstream standalone profile currently imports base itself. Since
        # perClass.homeManager owns the base import, use only its administrative
        # home-manager module here to avoid importing base twice. Revisit when
        # the upstream profile/base split is decoupled.
        standalone.perClass.homeManager.modules = [
          inputs.dendritic.modules.homeManager.home-manager
          ({pkgs, ...}: {nix.package = lib.mkDefault pkgs.nix;})
        ];
      };
    }
    {
      # interface 4: defining users
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
      # interface 5: defining hosts
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
          # A host names one native evaluator coordinate and its host-local
          # module delta; profile tags provide reusable semantic composition.
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
              # Variant tags are additive: this host keeps headless and adds dev.
              modules = [
                (_: {environment.etc."dendritic-variant".text = "dev";})
              ];
            };
            vm-nogui = {
              # A package selector turns this sparse variant into a perSystem
              # artifact without making the variant a second host identity.
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
          # Darwin uses the same host grammar; only its native class, platform,
          # and selected profile/user coordinates differ.
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
