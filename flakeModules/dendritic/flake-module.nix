{
  config,
  inputs,
  lib,
  ...
}: {
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Mergeable registry of standalone Home Manager configurations.";
  };

  config = {
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
    flake.dendritic = rec {
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules =
        inputs.dendritic.modules
        // {
          generic =
            inputs.dendritic.modules.generic
            // {
              input-registry = {
                config,
                options,
                ...
              }: let
                cfg = config.input-registry;
                isHomeManager = options ? home.file;
              in {
                options.input-registry = {
                  registry = {
                    managed = lib.mkOption {
                      type = lib.types.bool;
                      default = true;
                      description = "Enable the input registry aspect.";
                    };

                    source =
                      options.nix.registry
                      // {
                        default = let
                          isFlake = _: lib.types.isType "flake";
                          toEntry = _: flake: {inherit flake;};
                        in
                          lib.pipe inputs [
                            (lib.filterAttrs isFlake)
                            (lib.mapAttrs toEntry)
                          ];

                        readOnly = cfg.registry.locked;
                      };

                    locked = lib.mkOption {
                      type = lib.types.bool;
                      internal = true;
                      default = !isHomeManager;
                      readOnly = true;
                    };
                  };

                  sysroot = {
                    install = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Install input registry entries into the filesystem.";
                    };

                    destination = {
                      directory = lib.mkOption {
                        type = lib.types.str;
                        internal = true;
                        default =
                          if isHomeManager
                          then config.home.homeDirectory
                          else "/etc";
                        readOnly = true;
                      };

                      prefix = lib.mkOption {
                        type = lib.types.str;
                        default = "/nix/path";
                        description = "Subpath under the destination directory for input links.";
                        apply = value: lib.path.subpath.normalise ("./" + value);
                      };
                    };

                    abspath = lib.mkOption {
                      type = lib.types.str;
                      internal = true;
                      readOnly = true;
                    };
                  };

                  search-path.enable = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Expose the installed input registry through legacy NIX_PATH.";
                  };
                };

                config = lib.mkMerge [
                  (lib.mkIf cfg.registry.managed {
                    nix = {
                      registry = cfg.registry.source;
                      settings.experimental-features = ["nix-command" "flakes"];
                    };
                  })
                  {
                    assertions = [
                      {
                        assertion = cfg.search-path.enable -> cfg.sysroot.install;
                        message = "The input-registry search path requires its filesystem projection.";
                      }
                    ];

                    input-registry.sysroot.abspath = lib.concatStringsSep "/" [
                      cfg.sysroot.destination.directory
                      (lib.removePrefix "./" cfg.sysroot.destination.prefix)
                    ];

                    nix.nixPath = lib.mkIf cfg.search-path.enable [cfg.sysroot.abspath];
                  }
                  (lib.mkIf cfg.sysroot.install (let
                    prefix = cfg.sysroot.destination.prefix;
                    links =
                      lib.mapAttrs' (
                        name: value: {
                          name = lib.path.subpath.join [prefix name];
                          value.source = value.to.path;
                        }
                      )
                      config.nix.registry;
                    attrPath =
                      if isHomeManager
                      then ["home" "file"]
                      else ["environment" "etc"];
                  in
                    lib.setAttrByPath attrPath links))
                ];
              };
            };

          homeManager =
            inputs.dendritic.modules.homeManager
            // rec {
              input-registry = {
                imports = [modules.generic.input-registry];
              };

              base = {
                lib,
                pkgs,
                ...
              }: {
                imports = [
                  inputs.dendritic.homeModules.home-manager
                  inputs.dendritic.homeModules.identity
                  input-registry
                ];

                config = lib.mkMerge [
                  {
                    home.preferXdgDirectories = true;
                    manual = {
                      html.enable = false;
                      json.enable = true;
                    };
                    news.display = "silent";
                    xdg.enable = true;
                  }
                  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
                    targets.genericLinux = {
                      enable = true;
                      gpu.enable = lib.mkDefault false;
                    };

                    systemd.user.startServices = "sd-switch";
                  })
                ];
              };

              standalone = {
                config,
                pkgs,
                ...
              }: {
                imports = [base];

                home = {
                  username = lib.mkDefault config.identity.person.username;
                  homeDirectory = lib.mkDefault (
                    if pkgs.stdenv.hostPlatform.isDarwin
                    then "/Users/${config.identity.person.username}"
                    else "/home/${config.identity.person.username}"
                  );
                };

                nix.package = lib.mkDefault pkgs.nix;
              };
            };
        };

      homeModules = modules.homeManager;

      homeConfigurations = let
        inherit (config.flake.dendritic.homeModules) standalone;
      in {
        base-aarch64-darwin = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
          modules = [standalone];
        };

        base-x86_64-linux = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          modules = [standalone];
        };
      };
    };

    flake.homeConfigurations = lib.mkIf (!lib.inPureEvalMode) {
      base = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = builtins.currentSystem;
          config.allowUnfree = true;
        };
        modules = let inherit (config.flake.dendritic.homeModules) standalone; in [standalone];
      };
    };

    perSystem = {system, ...}:
      lib.mkMerge [
        (lib.mkIf (system == "aarch64-darwin") {
          checks.dendritic-hm-base = let
            configuration = config.flake.dendritic.homeConfigurations.base-aarch64-darwin;
            cfg = configuration.config;
          in
            assert cfg.home.username == "krad246";
            assert cfg.home.homeDirectory == "/Users/krad246";
            assert cfg.identity.person
            == {
              email = "krad246@gmail.com";
              name = "Keerthi Radhakrishnan";
              username = "krad246";
            };
            assert cfg.xdg.enable;
            assert cfg.manual.json.enable;
            assert !cfg.manual.html.enable;
            assert cfg.input-registry.registry.managed;
            assert !cfg.input-registry.registry.locked;
            assert !cfg.input-registry.sysroot.install;
            assert !cfg.input-registry.search-path.enable;
            assert cfg.input-registry.sysroot.abspath == "/Users/krad246/nix/path";
            assert cfg.nix.settings.experimental-features == ["nix-command" "flakes"];
            assert cfg.programs.home-manager.enable;
            assert !cfg.programs.bash.enable;
            assert !cfg.programs.bat.enable;
            assert !cfg.programs.fzf.enable;
            assert !cfg.programs.git.enable;
            assert !cfg.programs.helix.enable;
            assert !cfg.programs.kitty.enable;
            assert !cfg.programs.rbw.enable;
              configuration.activationPackage;
        })
        (lib.mkIf (system == "x86_64-linux") {
          checks.dendritic-hm-base = let
            configuration = config.flake.dendritic.homeConfigurations.base-x86_64-linux;
            cfg = configuration.config;
          in
            assert cfg.home.username == "krad246";
            assert cfg.home.homeDirectory == "/home/krad246";
            assert cfg.targets.genericLinux.enable;
            assert !cfg.targets.genericLinux.gpu.enable;
            assert cfg.systemd.user.startServices;
            assert cfg.input-registry.registry.managed;
            assert !cfg.input-registry.registry.locked;
            assert !cfg.input-registry.sysroot.install;
            assert !cfg.input-registry.search-path.enable;
            assert cfg.input-registry.sysroot.abspath == "/home/krad246/nix/path";
              configuration.activationPackage;
        })
      ];
  };
}
