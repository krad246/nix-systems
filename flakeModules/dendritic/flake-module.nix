{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  moduleLayerType = lib.types.submodule {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules contributed by this layer.";
      };
    };
  };

  variantType = lib.types.submodule {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Module delta for this variant.";
      };
      build = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether to emit this variant as an independent build; null inherits the global default.";
      };
      includeSpecialisations = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether to include this variant in its parent's specialisation set; null inherits the global default.";
      };
    };
  };

  userType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "this Home Manager user";
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules shared by this user's standalone and host-derived configurations.";
      };
      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Hosts for which to emit configurations using the host package set.";
      };
      standalone = {
        pkgs = lib.mkOption {
          type = lib.types.nullOr lib.types.pkgs;
          default = null;
          description = "Package set for a standalone user configuration; null disables the standalone root.";
        };
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
          description = "Modules needed only by the standalone Home Manager evaluation.";
        };
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
      cross = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether differing build and host platforms are permitted.";
      };
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules passed to the selected system evaluator.";
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
      images = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Modules applied while materializing this image coordinate.";
          };
        });
        default = {};
        description = "Sparse image output coordinates.";
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
      build = lib.mkEnableOption "independent variant build outputs by default";
      includeSpecialisations = lib.mkEnableOption "variants in native specialisation sets by default";
      nameFunction = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
        default = coordinates:
          lib.concatStringsSep "-" (
            lib.filter (value: value != null) [coordinates.user coordinates.host coordinates.variant coordinates.image]
            ++ lib.optional (coordinates.image != null) coordinates.hostPlatform
          );
        defaultText = lib.literalExpression ''coordinates: lib.concatStringsSep "-" (lib.filter (value: value != null) [ coordinates.user coordinates.host coordinates.variant coordinates.image ] ++ lib.optional (coordinates.image != null) coordinates.hostPlatform)'';
        description = "Function naming any generated user, host variant, or image coordinate.";
      };
    };
  };

  config = let
    platformSystem = platform: platform.system or platform;

    userModules = declaration:
      lib.mapAttrsToList (username: user: {
        home-manager.users.${username}.imports = user.modules;
      })
      declaration.users;

    nixos = rec {
      baseConfiguration = declaration:
        inputs.nixpkgs.lib.nixosSystem {
          modules =
            [
              {nixpkgs.hostPlatform = declaration.hostPlatform.system;}
            ]
            ++ lib.optional (declaration.cross && declaration.buildPlatform.system != declaration.hostPlatform.system) {
              nixpkgs.buildPlatform = declaration.buildPlatform.system;
            }
            ++ userModules declaration
            ++ declaration.modules;
        };

      configuration = declaration: let
        root = baseConfiguration declaration;
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

      outputs = declarations:
        lib.pipe declarations [
          (lib.mapAttrsToList (name: declaration:
            [{${name} = configuration declaration;}]
            ++ lib.pipe declaration.variants [
              (lib.filterAttrs (_: variant:
                if variant.build != null
                then variant.build
                else config.dendritic.configurations.variants.build))
              (lib.mapAttrsToList (variantName: variant: {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    user = null;
                    host = name;
                    variant = variantName;
                    image = null;
                    hostPlatform = declaration.hostPlatform.system;
                  }
                } =
                  (baseConfiguration declaration).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
        ];
    };

    darwin = rec {
      baseConfiguration = declaration:
        inputs.darwin.lib.darwinSystem {
          modules =
            [
              {nixpkgs.hostPlatform = declaration.hostPlatform.system;}
            ]
            ++ lib.optional (declaration.cross && declaration.buildPlatform.system != declaration.hostPlatform.system) {
              nixpkgs.buildPlatform = declaration.buildPlatform.system;
            }
            ++ userModules declaration
            ++ declaration.modules;
        };

      configuration = declaration: let
        includedSpecialisations = lib.filterAttrs (_: variant:
          if variant.includeSpecialisations != null
          then variant.includeSpecialisations
          else config.dendritic.configurations.variants.includeSpecialisations)
        declaration.variants;
      in
        if includedSpecialisations == {}
        then baseConfiguration declaration
        else throw "nix-darwin configurations do not support included specialisations";

      outputs = declarations:
        lib.pipe declarations [
          (lib.mapAttrsToList (name: declaration:
            [{${name} = configuration declaration;}]
            ++ lib.pipe declaration.variants [
              (lib.filterAttrs (_: variant:
                if variant.build != null
                then variant.build
                else config.dendritic.configurations.variants.build))
              (lib.mapAttrsToList (variantName: variant: {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    user = null;
                    host = name;
                    variant = variantName;
                    image = null;
                    hostPlatform = declaration.hostPlatform.system;
                  }
                } =
                  (baseConfiguration declaration).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
        ];
    };

    selectSystemDeclarations = system: declarations:
      lib.mapAttrs (_: declaration: let
        buildSystem =
          if declaration.buildPlatform == null
          then {inherit system;}
          else declaration.buildPlatform;
        platform = lib.systems.parse.mkSystemFromString system;
        expectedClass =
          if lib.systems.inspect.predicates.isDarwin platform
          then "darwin"
          else if lib.systems.inspect.predicates.isLinux platform
          then "nixos"
          else throw "dendritic.configurations: unsupported host platform ${system}";
      in
        if declaration.class != expectedClass
        then throw "dendritic.configurations: class ${declaration.class} conflicts with host platform ${system}"
        else if buildSystem.system != system && !declaration.cross
        then throw "dendritic.configurations: host platform ${system} requires cross = true for build platform ${buildSystem.system}"
        else
          declaration
          // {
            hostPlatform = {inherit system;};
            buildPlatform = buildSystem;
            modules = declaration.modules ++ (config.dendritic.configurations.perSystem.${system}.modules or []);
          })
      (lib.filterAttrs (_: declaration: builtins.elem system (map platformSystem declaration.hostPlatforms)) declarations);

    isSystem = predicate: system:
      predicate (lib.systems.parse.mkSystemFromString system);

    systemOutputs = system: declarations:
      withSystem system ({pkgs, ...}: let
        selectedDeclarations = selectSystemDeclarations system declarations;
        evaluator =
          if pkgs.stdenv.hostPlatform.isDarwin
          then darwin
          else if pkgs.stdenv.hostPlatform.isLinux
          then nixos
          else throw "dendritic.configurations: unsupported target system ${system}";
      in
        evaluator.outputs selectedDeclarations);

    imageOutputs = buildSystem: declarations: let
      candidates = lib.concatMap (rootName: let
        declaration = declarations.${rootName};
        targetSystems = lib.filter (target: let
          configuredBuild =
            if declaration.buildPlatform == null
            then target
            else declaration.buildPlatform.system;
        in
          configuredBuild == buildSystem)
        (map platformSystem declaration.hostPlatforms);
      in
        lib.concatMap (target: let
          selectedDeclaration = (selectSystemDeclarations target declarations).${rootName};
          evaluator = withSystem target ({pkgs, ...}:
            if pkgs.stdenv.hostPlatform.isDarwin
            then darwin
            else if pkgs.stdenv.hostPlatform.isLinux
            then nixos
            else throw "dendritic.configurations: unsupported image target system ${target}");
          root = evaluator.configuration selectedDeclaration;
        in
          lib.mapAttrsToList (imageName: image: let
            imageConfiguration =
              if image.modules == []
              then root
              else root.extendModules {inherit (image) modules;};
            value = lib.getAttrFromPath ["system" "build" "images" imageName] imageConfiguration.config;
          in {
            ${
              config.dendritic.configurations.variants.nameFunction {
                user = null;
                host = rootName;
                variant = null;
                image = imageName;
                hostPlatform = target;
              }
            } =
              value;
          })
          declaration.images)
        targetSystems)
      (builtins.attrNames declarations);
    in
      lib.mkMerge candidates;

    homeManagerDeclarations = lib.pipe config.dendritic.configurations.users [
      (lib.filterAttrs (_: user: user.enable && user.standalone.pkgs != null))
      (lib.mapAttrs (_: user: {
        inherit (user) variants passInOsConfig;
        inherit (user.standalone) pkgs;
        modules = user.modules ++ user.standalone.modules;
      }))
    ];

    systemDeclarations = lib.pipe config.dendritic.configurations.hosts [
      (lib.filterAttrs (_: host: host.enable))
      (lib.mapAttrs (hostName: host: let
        layers =
          [
            config.dendritic.configurations.shared
            (config.dendritic.configurations.perClass.${host.class} or {})
          ]
          ++ map (tag: config.dendritic.configurations.perTag.${tag} or {}) host.tags
          ++ [host];
      in
        host
        // {
          modules = lib.concatMap (layer: layer.modules or []) layers;
          users = lib.pipe config.dendritic.configurations.users [
            (lib.filterAttrs (_: user: user.enable && builtins.elem hostName user.hosts))
            (lib.mapAttrs (username: user: {
              modules = user.modules ++ (host.users.${username}.modules or []);
            }))
          ];
        }))
    ];

    targetSystems = lib.pipe systemDeclarations [
      builtins.attrValues
      (lib.foldl' (systems: declaration: systems // lib.genAttrs (map platformSystem declaration.hostPlatforms) (_: true)) {})
      builtins.attrNames
    ];
    darwinSystems = lib.filter (system: isSystem lib.systems.inspect.predicates.isDarwin system) targetSystems;

    homeManager = rec {
      baseConfiguration = pkgs: declaration:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          inherit (declaration) modules;
          extraSpecialArgs = declaration.extraSpecialArgs or {};
        };

      configuration = pkgs: declaration: let
        root = baseConfiguration pkgs declaration;
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
            [{${name} = configuration pkgs declaration;}]
            ++ lib.pipe declaration.variants [
              (lib.filterAttrs (_: variant:
                if variant.build != null
                then variant.build
                else config.dendritic.configurations.variants.build))
              (lib.mapAttrsToList (variantName: variant: {
                ${
                  config.dendritic.configurations.variants.nameFunction {
                    user = name;
                    host = null;
                    variant = variantName;
                    image = null;
                    hostPlatform = pkgs.stdenv.hostPlatform.system;
                  }
                } =
                  (baseConfiguration pkgs declaration).extendModules {inherit (variant) modules;};
              }))
            ]))
          lib.concatLists
        ];
    };

    declarations = homeManagerDeclarations;
  in {
    dendritic.configurations = {
      variants.build = lib.mkDefault true;

      users = {
        standalone = {
          enable = true;
          standalone = {
            pkgs = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs);
            modules = [config.flake.dendritic.modules.homeManager.standalone];
          };
          variants.dev.modules = [config.flake.dendritic.modules.homeManager.dev];
        };

        krad246 = {
          enable = true;
          hosts = ["nixbook-pro-composed"];
          modules = config.flake.dendritic.modules.homeManager.nixbook-pro;
          standalone = {
            pkgs = withSystem "aarch64-darwin" ({pkgs, ...}: pkgs);
            modules = [config.flake.dendritic.modules.homeManager.standalone];
          };
        };
      };

      hosts = {
        generic-headless-interactive = {
          enable = true;
          class = "nixos";
          hostPlatforms = [{system = "x86_64-linux";}];
          modules = [
            config.flake.dendritic.modules.nixos.headless
            config.flake.dendritic.modules.nixos.interactive
            (_: {networking.hostName = "generic-headless-interactive";})
          ];
          variants = {
            dev.modules = [
              (_: {environment.etc."dendritic-variant".text = "dev";})
            ];
            vm-nogui = {
              modules = [
                ({config, ...}: {
                  image.modules.vm = import ./image-modules/vm.nix;
                  image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
                    vm = config.image.modules.vm;
                  };
                })
              ];
              includeSpecialisations = true;
            };
          };
          images.vm-nogui.modules = [
            ({config, ...}: {
              image.modules.vm = import ./image-modules/vm.nix;
              image.modules.vm-nogui = import ./image-modules/vm-nogui.nix {
                vm = config.image.modules.vm;
              };
            })
          ];
        };

        nixbook-pro-composed = {
          enable = true;
          class = "darwin";
          hostPlatforms = [{system = "aarch64-darwin";}];
          modules = [
            config.flake.dendritic.modules.darwin.applications
            config.flake.dendritic.modules.darwin.base
            config.flake.dendritic.modules.darwin.app-stores
            config.flake.dendritic.modules.darwin.browser
            config.flake.dendritic.modules.darwin.linux-builder
            config.flake.dendritic.modules.darwin.tailscale
            (_: {networking.hostName = "nixbook-pro-composed";})
          ];
          users.krad246.modules = [];
        };
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
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules =
        inputs.dendritic.modules
        // {
          homeManager =
            inputs.dendritic.modules.homeManager
            // rec {
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
                  identity
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
                imports = [base homeManagerSupport];

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

              desktop.imports = [
                inputs.dendritic.modules.homeManager.browser
                inputs.dendritic.modules.homeManager.terminal
              ];

              dev = {
                imports = [inputs.dendritic.modules.homeManager.editor];
                shell.profiles.dev.enable = true;
                picker.backends.fzf.integrations.helix.enable = lib.mkDefault true;
              };

              interactive.shell.profiles.interactive.enable = true;

              secrets = {
                imports = [inputs.dendritic.modules.homeManager.rbw];
                identity.secrets.backends.rbw.enable = lib.mkDefault true;
              };

              "nixbook-pro" = [
                desktop
                dev
                interactive
                secrets
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
      homeConfigurations = lib.mkIf (!lib.inPureEvalMode) (lib.mkMerge (
        lib.concatLists (lib.mapAttrsToList (name: declaration:
          homeManager.outputs declaration.pkgs {${name} = declaration;})
        declarations)
        ++ lib.concatLists (lib.mapAttrsToList (username: user:
          lib.concatMap (hostName: let
            host = config.flake.nixosConfigurations.${hostName} or config.flake.darwinConfigurations.${hostName};
            name = config.dendritic.configurations.variants.nameFunction {
              user = username;
              host = hostName;
              variant = null;
              image = null;
              hostPlatform = host.pkgs.stdenv.hostPlatform.system;
            };
            declaration = {
              modules = user.modules ++ user.standalone.modules;
              inherit (user) variants;
              extraSpecialArgs = lib.optionalAttrs user.passInOsConfig {osConfig = host.config;};
            };
          in
            homeManager.outputs host.pkgs {${name} = declaration;})
          user.hosts)
        (lib.filterAttrs (_: user: user.enable) config.dendritic.configurations.users))
      ));
      # FIXME(dendritic-hosts): Publish NixOS configurations after declarations
      # distinguish deployable roots from image-only composition substrates.
      # Direct image outputs remain available through perSystem packages.
      darwinConfigurations = lib.mkMerge (lib.concatMap (system: systemOutputs system systemDeclarations) darwinSystems);
    };

    perSystem = {
      pkgs,
      system,
      ...
    }: let
      declaration = declarations.standalone;
      standalone = homeManager.configuration pkgs declaration;
    in
      lib.mkMerge [
        {
          packages = imageOutputs system systemDeclarations;

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
      ];
  };
}
