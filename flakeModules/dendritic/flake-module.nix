{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  composeProjection = {
    construct,
    includeSpecialisation ? null,
  }: let
    inheritPolicy = local: parent: global:
      if local != null
      then local
      else if parent != null
      then parent
      else global;
    resolve = policy:
      lib.mapAttrs (_: declaration:
        declaration
        // {
          variants = lib.mapAttrs (_: variant:
            variant
            // {
              publish = inheritPolicy variant.publish declaration.publish policy.publish;
              includeSpecialisation = inheritPolicy variant.includeSpecialisation declaration.includeSpecialisation policy.includeSpecialisation;
            })
          declaration.variants;
        });
    bare = context: declaration: construct context declaration;
    configuration = context: declaration: let
      root = bare context declaration;
      embedded = lib.filterAttrs (_: variant: variant.includeSpecialisation) declaration.variants;
    in
      if embedded == {}
      then root
      else if includeSpecialisation == null
      then throw "this configuration backend does not support embedded variants"
      else includeSpecialisation root embedded;
    variant = context: declaration: delta:
      (bare context declaration).extendModules {inherit (delta) modules;};
  in {
    inherit configuration resolve variant;
    definitions = context: nameFunction: declarations:
      lib.pipe declarations [
        (lib.mapAttrsToList (rootName: declaration: let
          published = lib.filterAttrs (_: variant: variant.publish) declaration.variants;
        in
          [{${rootName} = configuration context declaration;}]
          ++ lib.mapAttrsToList (variantName: delta: {
            ${nameFunction rootName variantName} = variant context declaration delta;
          })
          published))
        lib.concatLists
      ];
  };

  variantType = lib.types.submodule {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Module delta for this variant.";
      };
      publish = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Independent output policy; null inherits from its containing declaration.";
      };
      includeSpecialisation = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Resident specialisation policy; null inherits from its containing declaration.";
      };
    };
  };

  usersType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "these Home Manager user configurations";
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules passed to homeManagerConfiguration.";
      };
      variants = lib.mkOption {
        type = lib.types.attrsOf variantType;
        default = {};
        description = "Sparse Home Manager variant coordinates.";
      };
      publish = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Publication default for these user variants.";
      };
      includeSpecialisation = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Embedding default for these user variants.";
      };
    };
  };

  hostsType = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "these NixOS or nix-darwin host configurations";
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
        type = lib.types.attrsOf (lib.types.submodule {
          options.modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "Integrated Home Manager modules for this user coordinate.";
          };
        });
        default = {};
        description = "Integrated Home Manager users.";
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
      publish = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Publication default for these host variants.";
      };
      includeSpecialisation = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Embedding default for these host variants.";
      };
    };
  };
in {
  imports = [
    inputs.home-manager.flakeModules.default
    inputs.darwin.flakeModules.default
  ];

  options.dendritic = {
    configurations = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          users = lib.mkOption {
            type = usersType;
            default = {};
            description = "Home Manager user configuration for this declaration.";
          };
          hosts = lib.mkOption {
            type = hostsType;
            default = {};
            description = "NixOS or nix-darwin hosts for this declaration.";
          };
        };
      });
      default = {};
      description = "Mergeable RAII declarations interpreted as a sparse multi-layer output matrix.";
    };

    outputs = {
      nameFunction = lib.mkOption {
        type = lib.types.functionTo (lib.types.functionTo lib.types.str);
        default = configuration: variant: "${configuration}-${variant}";
        defaultText = lib.literalExpression ''configuration: variant: "''${configuration}-''${variant}"'';
        description = "Function naming independently published variants from any configuration layer.";
      };

      imageNameFunction = lib.mkOption {
        type = lib.types.functionTo (lib.types.functionTo (lib.types.functionTo lib.types.str));
        default = root: system: image: "${root}-${image}-${system}";
        defaultText = lib.literalExpression ''root: system: image: "''${root}-''${image}-''${system}"'';
        description = "Function naming image outputs from root, target-system, and image coordinates.";
      };
    };

    defaults = {
      users = {
        publish = lib.mkEnableOption "independently buildable Home Manager variant outputs by default";
        includeSpecialisation = lib.mkEnableOption "Home Manager variants in their parent activation generations by default";
      };
      hosts = {
        publish = lib.mkEnableOption "independently buildable system variant outputs by default";
        includeSpecialisation = lib.mkEnableOption "system variants in their parent specialisation tables by default";
        cross = lib.mkEnableOption "cross-system configurations by default";
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

    nixosConfigurations = composeProjection {
      construct = _: declaration:
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
      includeSpecialisation = root: variants:
        root.extendModules {
          modules = [
            {
              specialisation =
                lib.mapAttrs (_: variant: {
                  configuration.imports = variant.modules;
                })
                variants;
            }
          ];
        };
    };

    darwinConfigurations = composeProjection {
      construct = _: declaration:
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
    };

    resolveSystemDeclarations = policy: declarations:
      lib.mapAttrs (_: declaration:
        declaration
        // {
          cross = declaration.cross || policy.cross;
          variants = lib.mapAttrs (_: variant:
            variant
            // {
              publish =
                if variant.publish != null
                then variant.publish
                else if declaration.publish != null
                then declaration.publish
                else policy.publish;
              includeSpecialisation =
                if variant.includeSpecialisation != null
                then variant.includeSpecialisation
                else if declaration.includeSpecialisation != null
                then declaration.includeSpecialisation
                else policy.includeSpecialisation;
            })
          declaration.variants;
        })
      declarations;

    selectSystemDeclarations = system: declarations:
      lib.mapAttrs (_: declaration: let
        buildSystem =
          if declaration.buildPlatform == null
          then {inherit system;}
          else declaration.buildPlatform;
      in
        if buildSystem.system != system && !declaration.cross
        then throw "dendritic.configurations: ${system} requires cross.enable for build system ${buildSystem.system}"
        else
          declaration
          // {
            hostPlatform = {inherit system;};
            buildPlatform = buildSystem;
          })
      (lib.filterAttrs (_: declaration: builtins.elem system (map platformSystem declaration.hostPlatforms)) declarations);

    isSystem = predicate: system:
      predicate (lib.systems.parse.mkSystemFromString system);

    systemOutputs = system: declarations: let
      selectedDeclarations = selectSystemDeclarations system declarations;
      backend =
        if isSystem lib.systems.inspect.predicates.isDarwin system
        then darwinConfigurations
        else if isSystem lib.systems.inspect.predicates.isLinux system
        then nixosConfigurations
        else throw "dendritic.configurations: unsupported target system ${system}";
    in
      backend.definitions null config.dendritic.outputs.nameFunction selectedDeclarations;

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
          backend =
            if isSystem lib.systems.inspect.predicates.isDarwin target
            then darwinConfigurations
            else if isSystem lib.systems.inspect.predicates.isLinux target
            then nixosConfigurations
            else throw "dendritic.configurations: unsupported image target system ${target}";
          root = backend.configuration null selectedDeclaration;
        in
          lib.mapAttrsToList (imageName: image: let
            imageConfiguration =
              if image.modules == []
              then root
              else root.extendModules {inherit (image) modules;};
            value = lib.getAttrFromPath ["system" "build" "images" imageName] imageConfiguration.config;
          in {${config.dendritic.outputs.imageNameFunction rootName target imageName} = value;})
          declaration.images)
        targetSystems)
      (builtins.attrNames declarations);
    in
      lib.mkMerge candidates;

    homeManagerDeclarations =
      lib.mapAttrs (_: declaration: removeAttrs declaration.users ["enable"])
      (lib.filterAttrs (_: declaration: declaration.users.enable) config.dendritic.configurations);

    hostDeclarations =
      lib.mapAttrs (_: declaration: removeAttrs declaration.hosts ["enable"])
      (lib.filterAttrs (_: declaration: declaration.hosts.enable) config.dendritic.configurations);

    systemDeclarations =
      resolveSystemDeclarations {
        inherit (config.dendritic.defaults.hosts) publish includeSpecialisation cross;
      }
      hostDeclarations;

    targetSystems = lib.pipe systemDeclarations [
      builtins.attrValues
      (lib.foldl' (systems: declaration: systems // lib.genAttrs (map platformSystem declaration.hostPlatforms) (_: true)) {})
      builtins.attrNames
    ];
    darwinSystems = lib.filter (system: isSystem lib.systems.inspect.predicates.isDarwin system) targetSystems;

    homeManagerConfigurations = composeProjection {
      construct = pkgs: declaration:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          inherit (declaration) modules;
        };
      includeSpecialisation = root: specialisations:
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

    declarations = homeManagerConfigurations.resolve config.dendritic.defaults.users homeManagerDeclarations;

    localHomeManagerModules = let
      substrate = config.flake.dendritic.modules.homeManager;
      owner = {
        email = "krad246@gmail.com";
        name = "Keerthi Radhakrishnan";
        username = "krad246";
      };
    in {
      identity.options.identity.person = {
        email = lib.mkOption {
          type = lib.types.str;
          default = owner.email;
          description = "Primary email address for this identity.";
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = owner.name;
          description = "Full name for this identity.";
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = owner.username;
          description = "Username for this identity.";
        };
      };

      base = {pkgs, ...}: {
        imports = [
          localHomeManagerModules.identity
          substrate.input-registry
          substrate.shell
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
          localHomeManagerModules.base
          localHomeManagerModules.homeManagerSupport
        ];

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

      desktop = {
        imports = [
          substrate.browser
          substrate.terminal
        ];
      };

      dev = {
        imports = [substrate.editor];

        shell.profiles.dev.enable = true;
        picker.backends.fzf.integrations.helix.enable = lib.mkDefault true;
      };

      interactive.shell.profiles.interactive.enable = true;

      secrets = {
        imports = [substrate.rbw];

        identity.secrets.backends.rbw.enable = lib.mkDefault true;
      };
    };

    nixbookProUserModules = with localHomeManagerModules; [
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
  in {
    dendritic.defaults = {
      users.publish = lib.mkDefault true;
      hosts.publish = lib.mkDefault true;
    };

    dendritic.configurations = lib.mkMerge [
      {
        standalone.users = {
          enable = true;
          modules = [localHomeManagerModules.standalone];
        };
      }
      {
        standalone.users.variants.dev.modules = [localHomeManagerModules.dev];
      }
      {
        nixbook-pro.users = {
          enable = true;
          modules =
            [localHomeManagerModules.standalone]
            ++ nixbookProUserModules;
        };
      }
      {
        generic-headless-interactive.hosts = {
          enable = true;
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
              includeSpecialisation = true;
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

        nixbook-pro-composed.hosts = {
          enable = true;
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
          users.krad246.modules = nixbookProUserModules;
        };
      }
    ];

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
        config.dendritic.outputs.nameFunction
        declarations
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
      standalone = homeManagerConfigurations.configuration pkgs declaration;
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
