{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  imports = [inputs.home-manager.flakeModules.default];

  options.dendritic.homeManager = {
    nameFunction = lib.mkOption {
      type = lib.types.functionTo (lib.types.functionTo lib.types.str);
      default = configuration: variant: "${configuration}-${variant}";
      defaultText = lib.literalExpression ''configuration: variant: "''${configuration}-''${variant}"'';
      description = "Function generating a flake output name from configuration and variant names.";
    };

    variants = {
      publish = lib.mkEnableOption "independently buildable Home Manager variant outputs by default";
      embed = lib.mkEnableOption "Home Manager variants in their parent activation generations by default";
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
              options = {
                modules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [];
                  description = "Home Manager module deltas for this variant.";
                };

                publish = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                  description = "Whether to publish this variant independently; null inherits configuration policy.";
                };

                embed = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                  description = "Whether to embed this variant in its parent generation; null inherits configuration policy.";
                };
              };
            });
            default = {};
            description = "Named module deltas derived from this configuration.";
          };

          publishVariants = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default publication policy for this configuration's variants; null inherits global policy.";
          };

          embedVariants = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Default embedding policy for this configuration's variants; null inherits global policy.";
          };
        };
      });
      default = {};
      description = "Standalone Home Manager configuration declarations.";
    };
  };

  config = let
    homeManagerConfigurations = import ./configuration-projections.nix {
      inherit lib;
      construct = pkgs: declaration:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          inherit (declaration) modules;
        };
      embed = root: specialisations:
        root.extendModules {
          modules = [
            {
              specialisation =
                lib.mapAttrs (_: delta: {
                  configuration.imports = delta.modules;
                })
                specialisations;
            }
          ];
        };
    };

    declarations = homeManagerConfigurations.resolve config.dendritic.homeManager.variants config.dendritic.homeManager.configurations;
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
      homeConfigurations = lib.mkIf (!lib.inPureEvalMode) (lib.mkMerge (
        homeManagerConfigurations.definitions
        (withSystem builtins.currentSystem ({pkgs, ...}: pkgs))
        config.dendritic.homeManager.nameFunction
        declarations
      ));
    };

    perSystem = {
      pkgs,
      system,
      ...
    }: let
      declaration = declarations.standalone;
      publishVariants = lib.any (variant: variant.publish) (builtins.attrValues declaration.variants);
      standalone = homeManagerConfigurations.configuration pkgs declaration;
      dev = homeManagerConfigurations.variant pkgs declaration declaration.variants.dev;
      cfg = standalone.config;
      devCfg = dev.config;

      carvedDev = dev.extendModules {
        modules = [{shell.profiles.interactive.enable = false;}];
      };
    in
      lib.mkMerge [
        {
          checks = {
            dendritic-hm-standalone = standalone.activationPackage;
            home-manager-standalone = standalone.activationPackage;
          };

          pre-commit.settings.hooks.realize-dendritic-hm-standalone = {
            enable = true;
            description = "Realize the Dendritic standalone Home Manager configuration before pushing";

            # FIXME(dendritic-migration): Delete this hook once the Home Manager
            # closure has been ported. Discarding the string context keeps hook
            # installation from realizing the check; pre-push still receives the
            # exact derivation selected by the adjacent checks schema.
            entry = "${lib.meta.getExe' pkgs.nix "nix-store"} --realise ${
              lib.strings.escapeShellArg (
                builtins.unsafeDiscardStringContext standalone.activationPackage.drvPath
              )
            }";

            always_run = true;
            pass_filenames = false;
            stages = ["pre-push"];
          };
        }
        (lib.mkIf (system == "aarch64-darwin") {
          checks =
            {
              dendritic-hm-contract = assert cfg.home.username == "krad246";
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
              assert !carvedDev.config.shell.profiles.interactive.enable;
              assert !carvedDev.config.programs.bash.enable;
              assert !carvedDev.config.programs.bat.enable;
              assert carvedDev.config.shell.profiles.dev.enable;
              assert carvedDev.config.editor.backends.helix.enable;
                dev.activationPackage;
            };
        })
        (lib.mkIf (system == "x86_64-linux") {
          checks =
            {
              dendritic-hm-contract = assert cfg.home.username == "krad246";
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
                configuration = config.flake.nixosConfigurations.generic-headless-interactive-vm-nogui;
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
              assert !carvedDev.config.shell.profiles.interactive.enable;
              assert !carvedDev.config.programs.bash.enable;
              assert !carvedDev.config.programs.bat.enable;
              assert carvedDev.config.shell.profiles.dev.enable;
              assert carvedDev.config.editor.backends.helix.enable;
                dev.activationPackage;
            };
        })
      ];
  };
}
