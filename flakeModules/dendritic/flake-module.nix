{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  options.dendritic.homeManager = {
    variants = {
      publish = lib.mkEnableOption "independently buildable Home Manager variant outputs";
      ship = lib.mkEnableOption "all Home Manager variants in their parent activation generations";

      nameFunction = lib.mkOption {
        type = lib.types.functionTo (lib.types.functionTo lib.types.str);
        # TODO(dendritic): Workshop the public root/variant naming vocabulary.
        default = configuration: variant: "${configuration}-${variant}";
        defaultText = lib.literalExpression ''configuration: variant: "''${configuration}-''${variant}"'';
        description = "Function generating a flake output name from configuration and variant names.";
      };
    };

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Caller-supplied modules; the interpreter supplies pkgs to homeManagerConfiguration.";
          };

          variants = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options.modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [];
                description = "Home Manager module deltas for this variant.";
              };
            });
            default = {};
            description = "Named module deltas derived from this configuration.";
          };
        };
      });
      default = {};
      description = "Standalone Home Manager configuration declarations.";
    };
  };

  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Mergeable registry of standalone Home Manager configurations.";
  };

  config = let
    materializeHomeConfigurations = pkgs: policy: let
      declarations = config.dendritic.homeManager.configurations;

      # Preserve each declaration's attrset shape while detecting names that a merge would hide.
      outputNameSets = lib.pipe declarations [
        (lib.mapAttrsToList (
          rootName: declaration:
            [{${rootName} = null;}]
            ++ lib.mapAttrsToList (variantName: _: {
              ${policy.nameFunction rootName variantName} = null;
            })
            declaration.variants
        ))
        lib.concatLists
      ];
      duplicateOutputNames = lib.pipe outputNameSets [
        (lib.zipAttrsWith (_: builtins.length))
        (lib.filterAttrs (_: count: count > 1))
        builtins.attrNames
      ];
    in
      assert lib.assertMsg (duplicateOutputNames == [])
      "dendritic Home Manager root and generated variant output names must be unique";
        lib.concatMapAttrs (
          rootName: declaration: let
            root = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              inherit (declaration) modules;
            };
            rootWithVariants =
              if policy.ship
              then
                root.extendModules {
                  modules = [
                    {
                      specialisation =
                        lib.mapAttrs (_: variant: {
                          configuration.imports = variant.modules;
                        })
                        declaration.variants;
                    }
                  ];
                }
              else root;
          in
            # The root optionally carries its variants as embedded specialisations.
            {
              ${rootName} = rootWithVariants;
            }
            # Published variants are convenience handles generated from the same declarations.
            // lib.optionalAttrs policy.publish (
              lib.mapAttrs' (variantName: variant:
                lib.nameValuePair (policy.nameFunction rootName variantName) (
                  if policy.ship
                  then let
                    embedded = rootWithVariants.config.specialisation.${variantName}.configuration;
                  in {
                    # Home Manager exposes only the embedded config, not its evaluation wrapper.
                    config = embedded;
                    activationPackage = embedded.home.activationPackage;
                  }
                  else
                    root.extendModules {
                      inherit (variant) modules;
                    }
                ))
              declaration.variants
            )
        )
        declarations;
  in {
    dendritic.homeManager.variants.publish = lib.mkDefault true;

    dendritic.homeManager.configurations.standalone = {
      modules = [config.flake.dendritic.modules.homeManager.standalone];
      variants.dev.modules = [config.flake.dendritic.modules.homeManager.dev];
    };

    flake-file.inputs.dendritic = {
      url = "github:krad246/nix-systems/dendritic";

      inputs = {
        agenix.follows = "agenix";
        agenix-shell.follows = "agenix-shell";
        disko.follows = "disko";
        flake-compat.follows = "flake-compat";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        flake-root.follows = "flake-root";
        home-manager.follows = "home-manager";
        impermanence.follows = "impermanence";
        just-flake.follows = "just-flake";
        nix-darwin.follows = "darwin";
        nix-homebrew.follows = "nix-homebrew";
        nixos-wsl.follows = "nixos-wsl";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-lib.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    # Stable migration seam. Consumers use this namespace while its values are
    # progressively replaced with modules materialized in the current tree.
    flake.dendritic = {
      inherit (inputs.dendritic) darwinModules modules nixosModules;
    };

    flake = {
      homeConfigurations = lib.mkIf (!lib.inPureEvalMode) (
        materializeHomeConfigurations
        (withSystem builtins.currentSystem ({pkgs, ...}: pkgs))
        config.dendritic.homeManager.variants
      );

      nixosConfigurations.generic-headless-interactive = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          ({config, ...}: {
            image.modules.vm = import ./image-modules/vm.nix;
            image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
              vm = config.image.modules.vm;
            };

            networking.hostName = "generic-headless-interactive";
          })
        ];
      };
    };

    perSystem = {
      pkgs,
      system,
      ...
    }: let
      variants = materializeHomeConfigurations pkgs config.dendritic.homeManager.variants;
      publishVariants = config.dendritic.homeManager.variants.publish;
      shipVariants = config.dendritic.homeManager.variants.ship;
      inherit (variants) standalone;
      dev = variants.standalone-dev;
      cfg = standalone.config;
      devCfg = dev.config;

      carvedDev = dev.extendModules {
        modules = [{shell.profiles.interactive.enable = false;}];
      };
    in
      lib.mkMerge [
        {
          checks = {
            home-manager-standalone = standalone.activationPackage;
          };
        }
        (lib.mkIf (system == "aarch64-darwin") {
          checks =
            {
              dendritic-hm-standalone = assert cfg.home.username == "krad246";
              assert cfg.home.homeDirectory == "/Users/krad246";
              assert cfg.identity.person
              == {
                email = "krad246@gmail.com";
                name = "Keerthi Radhakrishnan";
                username = "krad246";
              };
              assert cfg.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
              assert cfg.xdg.enable;
              assert cfg.manual.json.enable;
              assert !cfg.manual.html.enable;
              assert cfg.input-registry.registry.managed;
              assert !cfg.input-registry.registry.locked;
              assert !cfg.input-registry.sysroot.install;
              assert !cfg.input-registry.search-path.enable;
              assert cfg.nix.registry ? nixpkgs;
              assert cfg.nix.registry ? home-manager;
              assert cfg.nix.settings.experimental-features == ["nix-command" "flakes"];
              assert cfg.programs.home-manager.enable;
              assert cfg.shell.profiles.interactive.enable;
              assert cfg.programs.bash.enable;
              assert cfg.programs.bat.enable;
              assert cfg.programs.fzf.enable;
              assert !cfg.programs.git.enable;
              assert !cfg.programs.helix.enable;
              assert !cfg.programs.kitty.enable;
              assert !cfg.programs.rbw.enable;
                standalone.activationPackage;

              dendritic-nixbook-pro-hm = let
                configuration = inputs.dendritic.darwinConfigurations.nixbook-pro;
                cfg = configuration.config;
                home = cfg.home-manager.users.${cfg.owner.username};
              in
                assert home.home.username == cfg.owner.username;
                assert home.home.homeDirectory == "/Users/${cfg.owner.username}";
                assert home.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
                assert home.programs.home-manager.enable;
                assert home.xdg.enable;
                assert home.manual.json.enable;
                assert !home.manual.html.enable;
                  home.home.activationPackage;
            }
            // lib.optionalAttrs publishVariants {
              home-manager-standalone-dev = dev.activationPackage;

              dendritic-hm-dev = assert devCfg.home.username == cfg.home.username;
              assert devCfg.home.homeDirectory == cfg.home.homeDirectory;
              assert devCfg.shell.profiles.dev.enable;
              assert devCfg.shell.programs.git.enable;
              assert devCfg.shell.programs.gh.enable;
              assert devCfg.shell.programs.direnv.enable;
              assert devCfg.editor.backends.helix.enable;
              assert devCfg.editor.backends.helix.default;
              assert shipVariants || !carvedDev.config.shell.profiles.interactive.enable;
              assert shipVariants || !carvedDev.config.programs.bash.enable;
              assert shipVariants || !carvedDev.config.programs.bat.enable;
              assert shipVariants || carvedDev.config.shell.profiles.dev.enable;
              assert shipVariants || carvedDev.config.editor.backends.helix.enable;
                dev.activationPackage;
            };
        })
        (lib.mkIf (system == "x86_64-linux") {
          checks =
            {
              dendritic-hm-standalone = assert cfg.home.username == "krad246";
              assert cfg.home.homeDirectory == "/home/krad246";
              assert cfg.home.stateVersion == inputs.nixpkgs.lib.trivial.release;
              assert cfg.targets.genericLinux.enable;
              assert !cfg.targets.genericLinux.gpu.enable;
              assert cfg.systemd.user.startServices;
              assert cfg.input-registry.registry.managed;
              assert !cfg.input-registry.registry.locked;
              assert !cfg.input-registry.sysroot.install;
              assert !cfg.input-registry.search-path.enable;
              assert cfg.nix.registry ? nixpkgs;
              assert cfg.nix.registry ? home-manager;
              assert cfg.nix.settings.experimental-features == ["nix-command" "flakes"];
              assert cfg.shell.profiles.interactive.enable;
              assert cfg.programs.bash.enable;
                standalone.activationPackage;

              generic-headless-interactive = let
                configuration = config.flake.nixosConfigurations.generic-headless-interactive;
                image = configuration.config.system.build.images.vm-nogui;
                cfg = image.passthru.config;
              in
                assert !cfg.virtualisation.graphics;
                assert !cfg.services.xserver.enable;
                assert cfg.home-manager.users.${cfg.owner.username}.shell.profiles.interactive.enable; image;
            }
            // lib.optionalAttrs publishVariants {
              home-manager-standalone-dev = dev.activationPackage;

              dendritic-hm-dev = assert devCfg.home.username == cfg.home.username;
              assert devCfg.home.homeDirectory == cfg.home.homeDirectory;
              assert devCfg.targets.genericLinux.enable;
              assert devCfg.shell.profiles.dev.enable;
              assert devCfg.shell.programs.git.enable;
              assert devCfg.shell.programs.gh.enable;
              assert devCfg.shell.programs.direnv.enable;
              assert devCfg.editor.backends.helix.enable;
              assert devCfg.editor.backends.helix.default;
              assert shipVariants || !carvedDev.config.shell.profiles.interactive.enable;
              assert shipVariants || !carvedDev.config.programs.bash.enable;
              assert shipVariants || !carvedDev.config.programs.bat.enable;
              assert shipVariants || carvedDev.config.shell.profiles.dev.enable;
              assert shipVariants || carvedDev.config.editor.backends.helix.enable;
                dev.activationPackage;
            };
        })
      ];
  };
}
