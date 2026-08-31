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
      # interface 1: inherited defaults

      # Variants can be published as independent outputs, embedded as native
      # specialisations, or both; you can choose per-variant.
      defaults.variants = {
        enable = lib.mkDefault true;

        enableFlakeOutputs = lib.mkDefault true; # publish variants as flake outputs
        includeSpecialisations = lib.mkDefault false; # embed variants as specialisations
      };
    }
    {
      # interface 2: profile aspects

      # A tag names a semantic profile. It realizes those semantics through
      # its class-specific module contributions.
      defaults.tags = ["base"];
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

        headless.perClass = {
          nixos.modules = [
            inputs.dendritic.modules.nixos.tailscale
            inputs.dendritic.modules.nixos.terminal
            inputs.dendritic.modules.nixos.terminfo
          ];
        };

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
        # Miniboi is the end-to-end deployment fixture: one real disko-backed
        # system coordinate, with each backend represented as a variant.
        miniboi = {
          enable = true;
          class = "nixos";
          hostPlatforms = [
            {system = "x86_64-linux";}
            {system = "aarch64-linux";}
          ];
          buildPlatform = {system = "x86_64-linux";};
          crossCompile = true;
          tags = ["headless"];
          modules = [
            inputs.dendritic.modules.nixos.disko
            inputs.dendritic.modules.nixos.bootloader
            inputs.dendritic.diskoConfigurations.simple
            {
              networking.hostName = "miniboi";
              security.sudo.wheelNeedsPassword = false;
              disko.enableConfig = true;
              boot.loader = {
                enable = true;
                mode = "bios";
              };
              users.users.krad246.initialHashedPassword = "";
            }
          ];
          variants = {
            vm = {
              package = configuration: configuration.config.system.build.vm;
              modules = [
                ({pkgs, ...}: {
                  virtualisation.vmVariant.virtualisation.host.pkgs = pkgs;
                })
              ];
            };
            vm-with-bootloader = {
              package = configuration: configuration.config.system.build.vmWithBootLoader;
              modules = [
                ({pkgs, ...}: {
                  virtualisation.vmVariantWithBootLoader.virtualisation.host.pkgs = pkgs;
                  virtualisation.vmVariantWithBootLoader.virtualisation.diskSize = 20 * 1024;
                })
              ];
            };
            disko-vm = {
              package = configuration: configuration.config.system.build.vmWithDisko;
              modules = [
                ({pkgs, ...}: {
                  virtualisation.vmVariantWithDisko = {
                    virtualisation.host.pkgs = pkgs;
                    boot.loader.grub.devices = lib.mkForce [];
                    boot.loader.grub.mirroredBoots = lib.mkForce [
                      {
                        # Keep the VM's GRUB configuration bootable without
                        # colliding with disko's installer-side /dev/vda
                        # projection. The image builder still installs GRUB to
                        # the actual disk when it materializes the disko image.
                        devices = ["nodev"];
                        path = "/boot";
                      }
                    ];
                  };
                })
              ];
            };
          };
        };

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
