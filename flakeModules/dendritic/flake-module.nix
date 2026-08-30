{
  config,
  inputs,
  lib,
  ...
}: let
  argumentOption = description:
    lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      inherit description;
    };
  moduleContributions = {
    options = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "Modules contributed in the parent evaluator context.";
      };
      specialArgs = argumentOption "Early module arguments passed to the native system evaluator.";
      extraSpecialArgs = argumentOption "Additional arguments passed to Home Manager modules.";
      lateModuleArgs = argumentOption "Late module arguments contributed through _module.args.";
      metadata = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Declarative data carried by this composition for downstream projections.";
      };
    };
  };

  moduleContributionsType = lib.types.submodule moduleContributions;

  composition = {
    imports = [moduleContributions];
    options.users = lib.mkOption {
      type = lib.types.attrsOf moduleContributionsType;
      default = {};
      description = "Home Manager module contributions for users selected by a host.";
    };
  };

  compositionType = lib.types.submodule composition;
  perClassType = lib.types.attrsOf compositionType;

  tagType = lib.types.submodule {
    options = {
      perClass = lib.mkOption {
        type = perClassType;
        default = {};
        description = "Class-specific module contributions selected when this profile aspect is active.";
      };
      meta = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Descriptive metadata carried by this profile aspect.";
      };
      passthru = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Arbitrary declarative data passed through with this profile aspect.";
      };
    };
  };

  variantType = lib.types.submodule {
    imports = [composition];
    options = {
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered profile aspects selecting additional contributions for this variant node.";
      };
      enableFlakeOutput = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to materialize this variant as an independent flake output and artifact coordinate.";
      };
      outputName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional name for this independently materialized variant node.";
      };
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Compatibility gate for this variant; prefer enableFlakeOutput for new declarations.";
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
    imports = [moduleContributions];
    options = {
      enable = lib.mkEnableOption "this Home Manager user";
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered profile aspects selecting contributions for this user node.";
      };
      standalone = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {
          imports = [moduleContributions];
          options = {
            pkgs = lib.mkOption {
              type = lib.types.pkgs;
              description = "Package set used to evaluate this standalone Home Manager configuration.";
            };
            outputName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional name for this standalone Home Manager root.";
            };
          };
        });
        default = null;
        description = "Optional standalone Home Manager output for this user; presence enables the output.";
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
    imports = [moduleContributions];
    options = {
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Ordered profile aspects selecting contributions for this user within one host.";
      };
      outputName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional name for this user's Home Manager projection on its host.";
      };
    };
  };

  hostType = lib.types.submodule {
    imports = [moduleContributions];
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
        description = "Ordered profile aspects selecting the corresponding perTag.<name> overlays.";
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
        description = "Host-specific module contributions for integrated Home Manager users.";
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
    globalArgs = argumentOption "Target-independent early arguments shared by every native and Home Manager evaluator.";
    earlyModuleArgs = argumentOption "Target-independent early arguments shared by every composed module evaluation.";
    lateModuleArgs = argumentOption "Late arguments shared through _module.args by every composed evaluator.";
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Ordered root profile aspects selecting perTag overlays for every host declaration.";
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
      description = "Semantic host classes; each name selects a native evaluator class, while profile composition belongs in tags.";
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
      type = compositionType;
      default = {};
      description = "Modules shared by every host.";
    };
    perSystem = lib.mkOption {
      type = lib.types.attrsOf compositionType;
      default = {};
      description = "Modules selected by host platform system.";
    };
    perArch = lib.mkOption {
      type = lib.types.attrsOf compositionType;
      default = {};
      description = "Modules selected by the architecture component of a host platform.";
    };
    perTag = lib.mkOption {
      type = lib.types.attrsOf tagType;
      default = {};
      description = "Canonical profile aspects, each with class-specific contributions shaped like perClass.";
    };
    variants = {
      enableFlakeOutputs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether variants materialize as independent flake outputs by default.";
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
