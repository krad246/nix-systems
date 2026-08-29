{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  moduleLayer = {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules contributed by this layer.";
      };
    };
  };

  moduleLayerType = lib.types.submodule moduleLayer;

  variantType = lib.types.submodule {
    imports = [moduleLayer];
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to emit this variant independently when variant outputs are enabled.";
      };
      includeSpecialisations = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether to include this variant in its parent's specialisation set; null inherits the global default.";
      };
      package = lib.mkOption {
        type = lib.types.nullOr (lib.types.functionTo lib.types.package);
        default = null;
        description = "Optional target-specific selector returning a package from this independently evaluated variant configuration.";
      };
    };
  };

  userType = lib.types.submodule {
    imports = [moduleLayer];
    options = {
      enable = lib.mkEnableOption "this Home Manager user";
      standalone = lib.mkOption {
        type = lib.types.submodule {
          imports = [moduleLayer];
          options = {
            enable = lib.mkEnableOption "this standalone Home Manager configuration";
            pkgs = lib.mkOption {
              type = lib.types.nullOr lib.types.pkgs;
              default = null;
              description = "Optional package-set override; impure standalone evaluation defaults to the current system.";
            };
          };
        };
        default = {};
        description = "Standalone Home Manager output for this user.";
      };
      passInOsConfig = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether host-derived configurations receive osConfig.";
      };
      variants = lib.mkOption {
        type = lib.types.attrsOf variantType;
        default = {};
        description = "Sparse Home Manager variant coordinates.";
      };
    };
  };

  hostType = lib.types.submodule {
    imports = [moduleLayer];
    options = {
      enable = lib.mkEnableOption "this NixOS or nix-darwin host";
      class = lib.mkOption {
        type = lib.types.enum ["nixos" "darwin"];
        default = "nixos";
        description = "Native system module class.";
      };
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Layer tags applied to this host.";
      };
      hostPlatforms = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {options.system = lib.mkOption {type = lib.types.str;};});
        default = [];
        description = "Target host-platform coordinates; evaluator selection is internal.";
      };
      buildPlatform = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {options.system = lib.mkOption {type = lib.types.str;};});
        default = null;
        description = "Optional build platform; omission selects native construction.";
      };
      crossCompile = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether differing build and host platforms are permitted.";
      };
      users = lib.mkOption {
        type = lib.types.attrsOf moduleLayerType;
        default = {};
        description = "Host-specific module layers for integrated Home Manager users.";
      };
      variants = lib.mkOption {
        type = lib.types.attrsOf variantType;
        default = {};
        description = "Sparse system variant and specialisation coordinates.";
      };
    };
  };
in {
  imports = [
    inputs.home-manager.flakeModules.default
    inputs.darwin.flakeModules.default
  ];

  options.dendritic.configurations = {
    users = lib.mkOption {
      type = lib.types.attrsOf userType;
      default = {};
      description = "Home Manager users forming one axis of the configuration matrix.";
    };
    hosts = lib.mkOption {
      type = lib.types.attrsOf hostType;
      default = {};
      description = "System hosts forming one axis of the configuration matrix.";
    };
    shared = lib.mkOption {
      type = moduleLayerType;
      default = {};
      description = "Modules shared by every host.";
    };
    perClass = lib.mkOption {
      type = lib.types.attrsOf moduleLayerType;
      default = {};
      description = "Modules selected by host class.";
    };
    perSystem = lib.mkOption {
      type = lib.types.attrsOf moduleLayerType;
      default = {};
      description = "Modules selected by host platform system.";
    };
    perTag = lib.mkOption {
      type = lib.types.attrsOf moduleLayerType;
      default = {};
      description = "Modules selected for each host tag.";
    };
    variants = {
      enable = lib.mkEnableOption "independent variant outputs";
      includeSpecialisations = lib.mkEnableOption "variants in native specialisation sets by default";
      nameFunction = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
        default = coordinates:
          lib.pipe ["user" "host" "variant" "package"] [
            (map (name: coordinates.${name} or null))
            (lib.filter (value: value != null))
            (values: values ++ lib.optional (coordinates ? package) coordinates.hostPlatform)
            (lib.concatStringsSep "-")
          ];
        defaultText = lib.literalExpression ''coordinates: lib.pipe [ "user" "host" "variant" "package" ] [ (map (name: coordinates.''${name} or null)) (lib.filter (value: value != null)) (values: values ++ lib.optional (coordinates ? package) coordinates.hostPlatform) (lib.concatStringsSep "-") ]'';
        description = "Function naming any generated user, host variant, or package coordinate.";
      };
    };
  };

  config = let
    platformSystem = platform: platform.system or platform;

    system = {
      baseConfiguration = declaration: let
        constructor = withSystem declaration.hostPlatform.system ({pkgs, ...}:
          if pkgs.stdenv.hostPlatform.isDarwin
          then inputs.darwin.lib.darwinSystem
          else if pkgs.stdenv.hostPlatform.isLinux
          then inputs.nixpkgs.lib.nixosSystem
          else throw "dendritic.configurations: unsupported target system ${declaration.hostPlatform.system}");
      in
        constructor {
          modules =
            [{nixpkgs.hostPlatform = declaration.hostPlatform.system;}]
            ++ lib.optional (declaration.crossCompile && declaration.buildPlatform.system != declaration.hostPlatform.system) {
              nixpkgs.buildPlatform = declaration.buildPlatform.system;
            }
            ++ lib.mapAttrsToList (username: user: {
              home-manager.users.${username} = {pkgs, ...}: {
                imports = user.modules;
                home.username = lib.mkDefault username;
                home.homeDirectory = lib.mkDefault (
                  if pkgs.stdenv.hostPlatform.isDarwin
                  then "/Users/${username}"
                  else "/home/${username}"
                );
              };
            })
            declaration.users
            ++ declaration.modules;
        };

      configuration = declaration: let
        root = system.baseConfiguration declaration;
        includedSpecialisations = lib.filterAttrs (_: variant:
          if variant.includeSpecialisations != null
          then variant.includeSpecialisations
          else config.dendritic.configurations.variants.includeSpecialisations)
        declaration.variants;
      in
        if includedSpecialisations == {}
        then root
        else if declaration.class == "darwin"
        then throw "nix-darwin configurations do not support included specialisations"
        else
          root.extendModules {
            modules = [
              {
                specialisation =
                  lib.mapAttrs (_: variant: {
                    configuration.imports = variant.modules;
                  })
                  includedSpecialisations;
              }
            ];
          };

      outputs = declarations:
        lib.pipe declarations [
          (lib.mapAttrsToList (name: declaration:
            [{${name} = system.configuration declaration;}]
            ++ lib.pipe declaration.variants [
              (lib.filterAttrs (_: variant: config.dendritic.configurations.variants.enable && variant.enable))
              (lib.mapAttrsToList (variantName: variant: {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    host = name;
                    variant = variantName;
                  }
                } =
                  (system.baseConfiguration declaration).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
        ];
    };

    selectSystemDeclarations = targetSystem: declarations:
      lib.pipe declarations [
        (lib.filterAttrs (_: declaration: builtins.elem targetSystem (map platformSystem declaration.hostPlatforms)))
        (lib.mapAttrs (_: declaration: let
          buildSystem =
            if declaration.buildPlatform == null
            then {system = targetSystem;}
            else declaration.buildPlatform;
          platform = lib.systems.parse.mkSystemFromString targetSystem;
          expectedClass =
            if lib.systems.inspect.predicates.isDarwin platform
            then "darwin"
            else if lib.systems.inspect.predicates.isLinux platform
            then "nixos"
            else throw "dendritic.configurations: unsupported host platform ${targetSystem}";
        in
          assert lib.assertMsg (declaration.class == expectedClass) "dendritic.configurations: class ${declaration.class} conflicts with host platform ${targetSystem}";
          assert lib.assertMsg (buildSystem.system == targetSystem || declaration.crossCompile) "dendritic.configurations: host platform ${targetSystem} requires crossCompile = true for build platform ${buildSystem.system}"; {
            inherit (declaration) enable class tags hostPlatforms crossCompile users variants;
            hostPlatform = {system = targetSystem;};
            buildPlatform = buildSystem;
            modules = declaration.modules ++ (config.dendritic.configurations.perSystem.${targetSystem}.modules or []);
          }))
      ];

    variantPackages = buildSystem: declarations:
      lib.pipe (builtins.attrNames declarations) [
        (lib.concatMap (rootName:
          lib.pipe (map platformSystem declarations.${rootName}.hostPlatforms) [
            (lib.filter (target:
                (declarations.${rootName}.buildPlatform.system or target) == buildSystem))
            (lib.concatMap (target: let
              declaration = (selectSystemDeclarations target declarations).${rootName};
              root = system.baseConfiguration declaration;
            in
              lib.mapAttrsToList (variantName: variant: let
                variantConfiguration =
                  if variant.modules == []
                  then root
                  else root.extendModules {inherit (variant) modules;};
              in {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    host = rootName;
                    package = variantName;
                    hostPlatform = target;
                  }
                } =
                  variant.package variantConfiguration;
              })
              (lib.filterAttrs (_: variant: variant.package != null) declaration.variants)))
          ]))
        lib.mkMerge
      ];

    homeManagerDeclarations = lib.pipe config.dendritic.configurations.users [
      (lib.filterAttrs (_: user: user.enable && user.standalone.enable))
      (lib.mapAttrs (username: user: {
        inherit username;
        inherit (user) variants passInOsConfig;
        inherit (user.standalone) pkgs;
        modules = user.modules ++ user.standalone.modules;
      }))
    ];

    systemDeclarations = lib.pipe config.dendritic.configurations.hosts [
      (lib.filterAttrs (_: host: host.enable))
      (lib.mapAttrs (_hostName: host: {
        inherit (host) enable class tags hostPlatforms buildPlatform crossCompile variants;
        modules =
          lib.pipe (
            [
              config.dendritic.configurations.shared
              (config.dendritic.configurations.perClass.${host.class} or {})
            ]
            ++ map (tag: config.dendritic.configurations.perTag.${tag} or {}) host.tags
            ++ [host]
          ) [
            (map (layer: layer.modules or []))
            lib.concatLists
          ];
        users =
          lib.mapAttrs (username: layer: {
            modules = config.dendritic.configurations.users.${username}.modules ++ layer.modules;
          })
          host.users;
      }))
    ];

    targetSystems = lib.unique (
      lib.concatMap
      (declaration: map platformSystem declaration.hostPlatforms)
      (builtins.attrValues systemDeclarations)
    );
    darwinSystems =
      lib.filter (
        system: lib.systems.inspect.predicates.isDarwin (lib.systems.parse.mkSystemFromString system)
      )
      targetSystems;

    homeManager = {
      baseConfiguration = pkgs: declaration:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules =
            [
              ({pkgs, ...}: {
                home.username = lib.mkDefault declaration.username;
                home.homeDirectory = lib.mkDefault (
                  if pkgs.stdenv.hostPlatform.isDarwin
                  then "/Users/${declaration.username}"
                  else "/home/${declaration.username}"
                );
              })
            ]
            ++ declaration.modules;
          extraSpecialArgs = declaration.extraSpecialArgs or {};
        };

      configuration = pkgs: declaration: let
        root = homeManager.baseConfiguration pkgs declaration;
        includedSpecialisations = lib.filterAttrs (_: variant:
          if variant.includeSpecialisations != null
          then variant.includeSpecialisations
          else config.dendritic.configurations.variants.includeSpecialisations)
        declaration.variants;
      in
        if includedSpecialisations == {}
        then root
        else
          root.extendModules {
            modules = [
              {
                specialisation =
                  lib.mapAttrs (_: variant: {
                    configuration.imports = variant.modules;
                  })
                  includedSpecialisations;
              }
            ];
          };

      outputs = pkgs: declarations:
        lib.pipe declarations [
          (lib.mapAttrsToList (name: declaration:
            [{${name} = homeManager.configuration pkgs declaration;}]
            ++ lib.pipe declaration.variants [
              (lib.filterAttrs (_: variant: config.dendritic.configurations.variants.enable && variant.enable))
              (lib.mapAttrsToList (variantName: variant: {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    user = name;
                    variant = variantName;
                  }
                } =
                  (homeManager.baseConfiguration pkgs declaration).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
        ];
    };
  in {
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
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules = {
        inherit (inputs.dendritic.modules) nixos darwin;
        homeManager = {
          identity.options.identity.person = {
            email = lib.mkOption {
              type = lib.types.str;
              default = "krad246@gmail.com";
              description = "Primary email address for this identity.";
            };
            name = lib.mkOption {
              type = lib.types.str;
              default = "Keerthi Radhakrishnan";
              description = "Full name for this identity.";
            };
            username = lib.mkOption {
              type = lib.types.str;
              default = "krad246";
              description = "Username for this identity.";
            };
          };

          base = {pkgs, ...}: {
            imports = [
              config.flake.dendritic.modules.homeManager.identity
              inputs.dendritic.modules.homeManager.input-registry
              inputs.dendritic.modules.homeManager.shell
            ];

            config = lib.mkMerge [
              {
                home = {
                  preferXdgDirectories = true;
                  stateVersion = inputs.dendritic.lib.trivial.release;
                };
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

          homeManagerSupport = {
            home.stateVersion = inputs.dendritic.lib.trivial.release;
            programs.home-manager.enable = true;
          };

          standalone = {
            config,
            pkgs,
            ...
          }: {
            imports = [
              config.flake.dendritic.modules.homeManager.base
              config.flake.dendritic.modules.homeManager.homeManagerSupport
            ];

            nix.package = lib.mkDefault pkgs.nix;
          };

          desktop.imports = [
            inputs.dendritic.modules.homeManager.browser
            inputs.dendritic.modules.homeManager.terminal
          ];

          dev = {
            imports = [inputs.dendritic.modules.homeManager.editor];
            shell.profiles.dev.enable = true;
            picker.backends.fzf.integrations.helix.enable = lib.mkDefault true;
          };

          interactive = {
            shell.profiles.interactive.enable = true;
          };

          secrets = {
            imports = [inputs.dendritic.modules.homeManager.rbw];
            identity.secrets.backends.rbw.enable = lib.mkDefault true;
          };

          nixbook-pro.imports = [
            config.flake.dendritic.modules.homeManager.desktop
            config.flake.dendritic.modules.homeManager.dev
            config.flake.dendritic.modules.homeManager.interactive
            config.flake.dendritic.modules.homeManager.secrets
            {
              browser.backends.zen = {
                enable = lib.mkDefault true;
                default = lib.mkDefault true;
              };
            }
          ];
        };
      };
    };

    flake = {
      homeConfigurations = lib.mkMerge (
        lib.concatLists (lib.mapAttrsToList (name: declaration:
          homeManager.outputs declaration.pkgs {${name} = declaration;})
        homeManagerDeclarations)
        ++ lib.concatMap (hostName: let
          hostDeclaration = systemDeclarations.${hostName};
        in
          lib.concatMap (username: let
            userLayer = hostDeclaration.users.${username};
            host = config.flake.nixosConfigurations.${hostName} or config.flake.darwinConfigurations.${hostName};
            name = config.dendritic.configurations.variants.nameFunction {
              user = username;
              host = hostName;
            };
            user = config.dendritic.configurations.users.${username};
            declaration = {
              inherit username;
              modules = user.standalone.modules ++ userLayer.modules;
              inherit (user) variants;
              extraSpecialArgs = lib.optionalAttrs user.passInOsConfig {osConfig = host.config;};
            };
          in
            homeManager.outputs host.pkgs {${name} = declaration;})
          (builtins.attrNames hostDeclaration.users))
        (builtins.attrNames systemDeclarations)
      );
      # FIXME(dendritic-hosts): Publish NixOS configurations after declarations
      # distinguish deployable roots from image-only composition substrates.
      # Direct image outputs remain available through perSystem packages.
      darwinConfigurations = lib.mkMerge (
        lib.concatMap (target: system.outputs (selectSystemDeclarations target systemDeclarations)) darwinSystems
      );
    };

    perSystem = {
      pkgs,
      system,
      ...
    }:
      lib.mkMerge [
        {
          packages = variantPackages system systemDeclarations;
        }

        (lib.mkIf (homeManagerDeclarations ? standalone) (let
          declaration = homeManagerDeclarations.standalone;
          standalone = homeManager.configuration pkgs declaration;
        in {
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
        }))
      ];
  };
}
