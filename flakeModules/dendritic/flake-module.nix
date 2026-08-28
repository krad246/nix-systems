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
      # TODO(dendritic): Workshop the public root/variant naming vocabulary.
      default = configuration: variant: "${configuration}-${variant}";
      defaultText = lib.literalExpression ''configuration: variant: "''${configuration}-''${variant}"'';
      description = "Function generating a flake output name from configuration and variant names.";
    };

    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
        options = {
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Caller-supplied modules; the interpreter supplies pkgs to homeManagerConfiguration.";
          };

          includeSpecialisations = lib.mkEnableOption "embedding this configuration's variants as Home Manager specialisations in its own activation generation";

          variants = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                modules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [];
                  description = "Home Manager module deltas for this variant.";
                };

                # Home Manager's `specialisation` option has no per-entry
                # enable of its own, so entries are filtered on our side
                # before being handed to it. Defaults from the configuration's
                # master switch; a variant may still override it individually.
                includeSpecialisation = lib.mkOption {
                  type = lib.types.bool;
                  default = config.includeSpecialisations;
                  defaultText = lib.literalExpression "the configuration's includeSpecialisations";
                  description = "Whether this variant is embedded as a Home Manager specialisation in the parent configuration's activation generation.";
                };
              };
            });
            default = {};
            description = "Named module deltas derived from this configuration.";
          };
        };
      }));
      default = {};
      description = "Standalone Home Manager configuration declarations.";
    };
  };

  config = let
    homeConfigurationEntries = pkgs: let
      declarations = config.dendritic.homeManager.configurations;
      inherit (config.dendritic.homeManager) nameFunction;
    in
      lib.pipe declarations [
        (lib.mapAttrsToList (
          rootName: declaration: let
            root = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              inherit (declaration) modules;
            };
            rootWithSpecialisations = root.extendModules {
              modules = [
                {
                  specialisation = lib.mapAttrs (_: variant:
                    lib.mkIf variant.includeSpecialisation {
                      configuration.imports = variant.modules;
                    })
                  declaration.variants;
                }
              ];
            };
          in
            # The root, with any opted-in variants embedded as specialisations.
            [(lib.nameValuePair rootName rootWithSpecialisations)]
            # Every declared variant is always reachable as its own
            # lightweight Home Manager configuration - a genuine
            # `extendModules` result, not a hand-built stand-in - regardless
            # of whether the root embeds it as a specialisation.
            ++ lib.mapAttrsToList (
              variantName: variant:
                lib.nameValuePair (nameFunction rootName variantName) (
                  root.extendModules {inherit (variant) modules;}
                )
            )
            declaration.variants
        ))
        lib.concatLists
      ];
  in {
    dendritic = {
      homeManager.configurations.standalone = {
        modules = [config.flake.dendritic.modules.homeManager.standalone];
        includeSpecialisations = lib.mkDefault true;
        variants.dev.modules = [config.flake.dendritic.modules.homeManager.dev];
      };

      hosts.nixos.configurations.generic-headless-interactive = {
        includeSpecialisations = lib.mkDefault true;
        modules = [
          config.flake.dendritic.modules.nixos.headless
          config.flake.dendritic.modules.nixos.interactive
          ({config, ...}: {
            nixpkgs.hostPlatform = "x86_64-linux";
            image.modules.vm = import ./image-modules/vm.nix;
            image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
              vm = config.image.modules.vm;
            };
            networking.hostName = "generic-headless-interactive";
          })
        ];
        variants.dev.modules = [{virtualisation.docker.enable = true;}];
      };
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
        lib.mkMerge (
          map (entry: {${entry.name} = entry.value;}) (
            homeConfigurationEntries (withSystem builtins.currentSystem ({pkgs, ...}: pkgs))
          )
        )
      );
    };

    perSystem = {
      pkgs,
      system,
      ...
    }: let
      # Uniqueness is already proven at the flake level; this system's
      # entries are indexed directly since nothing here needs to re-validate
      # that guarantee.
      variants = builtins.listToAttrs (homeConfigurationEntries pkgs);
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
          checks = {
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
          checks = {
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
