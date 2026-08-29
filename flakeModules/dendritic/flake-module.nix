{
  config,
  inputs,
  lib,
  ...
}: let
  flakeConfig = config;
  moduleLayer = {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules contributed in the parent evaluator context.";
      };
      homeModules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Home Manager modules contributed to each selected user node.";
      };
      metadata = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Declarative data carried by this composition layer for downstream projections.";
      };
    };
  };

  moduleLayerType = lib.types.submodule moduleLayer;

  compositionLayer = {
    imports = [moduleLayer];
    options.users = lib.mkOption {
      type = lib.types.attrsOf moduleLayerType;
      default = {};
      description = "Home Manager module contributions for users selected by a host.";
    };
  };

  compositionLayerType = lib.types.submodule compositionLayer;

  variantType = lib.types.submodule {
    imports = [compositionLayer];
    options = {
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered tags selecting additional perTag layers for this variant node.";
      };
      build = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to materialize this variant as an independent configuration and artifact coordinate.";
      };
      outputName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional name for this independently materialized variant node.";
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Compatibility gate for this variant; prefer build for new declarations.";
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
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered tags selecting perTag layers for this user node.";
      };
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
            outputName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional name for this standalone Home Manager root.";
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

  hostUserType = lib.types.submodule {
    imports = [moduleLayer];
    options = {
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered tags selecting perTag layers for this user within one host.";
      };
      outputName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional name for this user's Home Manager projection on its host.";
      };
    };
  };

  hostType = lib.types.submodule {
    imports = [moduleLayer];
    options = {
      enable = lib.mkEnableOption "this NixOS or nix-darwin host";
      class = lib.mkOption {
        type = lib.types.str;
        default = "nixos";
        description = "Semantic host class, resolved through configurations.classes.";
      };
      outputName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional name for this host's root system output.";
      };
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered tags selecting the corresponding perTag.<name> declarations.";
      };
      metadata = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Machine facts and annotations carried with this host declaration.";
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
        type = lib.types.attrsOf hostUserType;
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
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Ordered root tags selecting perTag layers for every host declaration.";
    };
    classes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          nativeClass = lib.mkOption {
            type = lib.types.enum ["nixos" "darwin"];
            description = "Native evaluator used to construct hosts in this semantic class.";
          };
          metadata = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = {};
            description = "Class-level metadata exposed on normalized declaration rows.";
          };
        };
      });
      default = {
        nixos.nativeClass = "nixos";
        darwin.nativeClass = "darwin";
      };
      description = "Semantic host classes; aliases retain their own perClass layer while selecting a native evaluator.";
    };
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
      type = compositionLayerType;
      default = {};
      description = "Modules shared by every host.";
    };
    perClass = lib.mkOption {
      type = lib.types.attrsOf compositionLayerType;
      default = {};
      description = "Modules selected by host class.";
    };
    perSystem = lib.mkOption {
      type = lib.types.attrsOf compositionLayerType;
      default = {};
      description = "Modules selected by host platform system.";
    };
    perArch = lib.mkOption {
      type = lib.types.attrsOf compositionLayerType;
      default = {};
      description = "Modules selected by the architecture component of a host platform.";
    };
    perTag = lib.mkOption {
      type = lib.types.attrsOf compositionLayerType;
      default = {};
      description = "Modules selected for each host tag.";
    };
    variants = {
      build = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether variants materialize as independent outputs by default.";
      };
      enable = lib.mkEnableOption "independent variant outputs";
      includeSpecialisations = lib.mkEnableOption "variants in native specialisation sets by default";
      nameFunction = lib.mkOption {
        type = lib.types.functionTo lib.types.str;
        default = coordinates:
          if coordinates ? package
          then "${coordinates.host}-${coordinates.package}-${coordinates.hostPlatform}"
          else if coordinates ? user && coordinates ? host
          then "${coordinates.user}-${coordinates.host}"
          else if coordinates ? host && coordinates ? variant
          then "${coordinates.host}-${coordinates.variant}"
          else if coordinates ? user && coordinates ? variant
          then "${coordinates.user}-${coordinates.variant}"
          else coordinates.name or "dendritic";
        defaultText = lib.literalExpression "coordinates: if coordinates ? package then \"\${coordinates.host}-\${coordinates.package}-\${coordinates.hostPlatform}\" else if coordinates ? user && coordinates ? host then \"\${coordinates.user}-\${coordinates.host}\" else if coordinates ? host && coordinates ? variant then \"\${coordinates.host}-\${coordinates.variant}\" else if coordinates ? user && coordinates ? variant then \"\${coordinates.user}-\${coordinates.variant}\" else coordinates.name or \"dendritic\"";
        description = "Compatibility-only legacy naming hook; output names now belong to the typed host, user, and variant nodes.";
      };
    };
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
    flake.dendritic = {
      inherit (inputs.dendritic) darwinModules nixosModules;

      modules = {
        inherit (inputs.dendritic.modules) nixos darwin;
        profiles = {
          darwin.desktop.imports = [
            inputs.dendritic.modules.darwin.applications
            inputs.dendritic.modules.darwin.app-stores
            inputs.dendritic.modules.darwin.browser
            inputs.dendritic.modules.darwin.linux-builder
            inputs.dendritic.modules.darwin.tailscale
          ];
          home = {
            desktop = flakeConfig.flake.dendritic.modules.homeManager.desktop;
            dev = flakeConfig.flake.dendritic.modules.homeManager.dev;
            interactive = flakeConfig.flake.dendritic.modules.homeManager.interactive;
            secrets = flakeConfig.flake.dendritic.modules.homeManager.secrets;
          };
        };
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

          standalone = {pkgs, ...}: {
            imports = [
              flakeConfig.flake.dendritic.modules.homeManager.base
              flakeConfig.flake.dendritic.modules.homeManager.homeManagerSupport
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
  };
}
